<#
SYNOPSIS
Example Microsoft 365 SharePoint Unified Audit Log ingestion pipeline.

DESCRIPTION
Retrieves SharePoint file/folder audit events from Microsoft 365 Unified Audit Log,
transforms JSON payloads, and stores results in a local SQLite database.

NOTE: This is a reference implementation and uses placeholder values only.
#>

start-transcript "path\to\PowerAuditlog.txt"
Import-Module ExchangeOnlineManagement
#Function which will parse an object property and sanitize it for sql injection.
function Sanitize-string {
     param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$inputstring
    )
        if ($null -eq $inputstring -or $inputstring -eq "")
        {
            return $inputstring
        }
    return $inputstring.replace("'","''")
}

function Write-log {
     param(
        [ValidateSet("INFO","ERROR","DEBUG")]
        [string]$level,

        [Parameter(Mandatory=$true)]
        [string]$message
    )
        Add-content $logpath "$(Get-Date): [$level]: $message"
        Write-host "$(Get-date): [$level]: $message"
}
#========================================================================================================================
# Global variables 
$success = 0 #amount of successful entries
$fail = 0  #amount of failed entries
$dedup = 0 #deduplications ran
$errors = @() #@() makes it a collection objects can go into.
$logpath = "<LOGPATHERE/log.txt"

#========================================================================================================================
# Section in which we authenticate to O365.
$appid = "<APPID_HERE>"
$organization = "<DOMAIN_HERE>"
$certificatethumbprint = "<THUMBPRINT_HERE>"

try {
    connect-exchangeonline -appid $appid -organization $organization  -certificatethumbprint $certificatethumbprint
    Write-log INFO "Successfully authenticated to 365"
}
catch {
    Write-log ERROR "Error authenticating, aborting."
    throw
}

Add-content $logpath "===================================================================================================="

# Section in which we pull our audit logs.

#Operations to pull from the AuditLogs
$Operations = @(
    # FILES
    "FileMoved",
    "FileDeleted",
    "FileRecycled",
    "FileDeletedFirstStageRecycleBin",
    "FileDeletedSecondStageRecycleBin",
    "FileRestored",
    "FileCopied",
    "FileRenamed",
    "FileModified",
    "FileUploaded",

    # FOLDERS
    "FolderMoved",
    "FolderDeleted",
    "FolderRecycled",
    "FolderDeletedFirstStageRecycleBin",
    "FolderDeletedSecondStageRecycleBin",
    "FolderRestored",
    "FolderCopied",
    "FolderRenamed",
    "FolderModified",
    "FolderCreated"
)

#Pull the audit logs, store in variable.
$log= Search-UnifiedAuditlog -Startdate (Get-date).Adddays(-1) -EndDate (Get-date) -ObjectIDs "<SPO_LIBRARY_SCOPE >" -SessionCommand ReturnLargeSet -ResultSize 5000 -Operations $Operations

#Log it
Write-log INFO "New run started"
Write-log INFO "Logs returned $($log.count)"

#=========================================================================================================================
# Grab the Auditdata (JSON) from each log entry, convert the JSON into an 'audit' object and shape the data into SQL readable format.

ForEach ($entry in $log) 
{
$audit = $entry.AuditData | ConvertFrom-Json
$RawJson = ($entry.AuditData | ConvertTo-Json -Compress)
# Saniziting properties of the audit object.
$CleanSourceRelativeUrl = Sanitize-string $audit.SourceRelativeUrl
$CleanDestinationRelativeUrl = Sanitize-string $audit.DestinationRelativeUrl
$CleanSourceFileName = Sanitize-string $audit.SourceFileName
$CleanObjectId = Sanitize-string $audit.ObjectId
$CleanJson = Sanitize-string $rawjson

#Shape the JSON into SQL insertable format.
$sql = @"
INSERT INTO AuditEvents (
    AuditId,
    CreationTime,
    Operation,
    UserId,
    SourceRelativeUrl,
    DestinationRelativeUrl,
    Filename,
    ObjectId,
    RawJson
)
VALUES (
    '$($audit.id)',
    '$($audit.CreationTime)',
    '$($audit.Operation)',
    '$($audit.UserId)',
    '$CleanSourceRelativeUrl',
    '$CleanDestinationRelativeUrl',
    '$CleanSourceFileName',
    '$CleanObjectId',
    '$CleanJson'
);
"@
#'$(Sanitize-string $entry.AuditData | ConvertTo-Json -Compress)'
#=========================================================================================================================
# Section we insert each entry into the SQL database.

# Setup variables for calling the sql process, and put any SQL errors into the error datastream.

$result = $sql | & <PATH_TO_BINARY/qlite3.exe> <PATH_TO_auditlog.db> 2>&1
$exitCode = $LASTEXITCODE
$errortext= "$($result | Out-string)"


#Start putting actual data into SQL table by calling the variable.
$result

#=========================================================================================================================
# Section where we have error handeling logic.

# Logic which handles errors, success and failure counters.
    if ($exitcode -eq 0)
    {
        $success++
    }
    elseif ($errortext -match "UNIQUE constraint failed")
    {
        $dedup++
    }
    else
    {
        $fail++

        #create an object to catch information about the error.
        $ErrorObject = [PSCustomObject]@{
        Time      = Get-Date
        ObjectId  = $audit.ObjectId
        Operation = $audit.Operation
        Message   = $errortext
        }
        
        #put our error object into a container for later reporting.
        $errors += $ErrorObject
    }
}
#=========================================================================================================================
#Backup the .db to SPO
try {
    Copy-Item -Path "PATH_TO_auditlog.db" -Destination "BACKUP_PATH/auditlog.db" -Force
    Write-log INFO "Successfully copied DB file to SPO for backup"
}
catch {
    Write-log ERROR "Could not copy DB file to SPO backup"
}

#=========================================================================================================================
# Summarize to a log.

#write to log file
Write-log INFO ":Time Finished" 
Write-log INFO "Failures: $fail Successes: $success Deduplication Events: $($dedup)"
Write-log INFO "Error messages: $($errors | ForEach-Object {$_ | Out-String })"
write-log INFO "============================================================================================================================="
Disconnect-ExchangeOnline -Confirm:$false
stop-transcript 
exit 0
