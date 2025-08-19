# --- Split-Path Reference ---
# Split-Path -Parent   → returns the directory (removes the file name)
# Split-Path -Leaf     → returns just the file/folder name (last part of the path)
# Join-Path            → combines parent path + child name into a valid full path

# Example:
# $fullPath = "C:\Users\User\Documents\report.txt"
# Split-Path $fullPath -Parent  # → "C:\Users\User\Documents"
# Split-Path $fullPath -Leaf    # → "report.txt"
# Join-Path -Path (Split-Path $fullPath -Parent) -ChildPath "backup.txt"
# -->"C:\Users\User\Documents\backup.txt"
# ------------------------------

# --- RoboCopy Reference ---
# Quickly copies and has error handeling, faster than copy-item.

#Basic Syntax:
#    robocopy <SourceFolder> <DestinationFolder> [<File(s)>] [options]
	
#	*robocopy only wants directories*
#	
#	Common Options:
#    /E      – Copies all subfolders, including empty ones.
#    /Z      – Enables restartable mode (resume copies).
#    /MIR    – Mirrors a directory tree (equivalent to /E and /PURGE).
#    /LOG    – Outputs results to a log file.
#    /R:n    – Retry n times on failure (default is 1 million).
#    /W:n    – Wait n seconds between retries.
# ------------------------------


#NAS Variables#

$NasNetworkPath = "\\NAS_SERVER_HERE\images"
$NasRemoteSubfolder = "Offboarding"
$NasDestinationFolder = "Z:\$NasRemoteSubfolder"
$NasUsername = "SERVICE_ACCOUNT_HERE"
$NasPassword = $env:password

#User Variables#

$UserProfilePath = $env:USERPROFILE
$Username = $env:USERNAME

#Path Variables#

$BackupRootFolder = "C:\Your\BackupFolder"
$TempBackupFolder = Join-Path $BackupRootFolder "Temp_$Username"
$TarballFullPath = Join-Path $BackupRootFolder "$Username.tar.gz"

#Transfer Inprogress Variables#
$InProgressName = "$Username.tar.gz.inprogress"
$InProgressFullPath = Join-Path $BackupRootFolder $InProgressName


#Create BackupFolder#

if (-not (Test-Path $BackupRootFolder)) {
    New-Item -ItemType Directory -Path $BackupRootFolder -Force | Out-Null
}

if (-not (Test-Path $TempBackupFolder)) {
    New-Item -ItemType Directory -Path $TempBackupFolder -Force | Out-Null
}

#Copy User Folders#

robocopy "$UserProfilePath\Documents" "$TempBackupFolder\Documents" /E /R:0 /W:0 | Out-Null
Write-Host "Documents successfully copied."

#robocopy "$UserProfilePath\Downloads" "$TempBackupFolder\Downloads" /E /R:0 /W:0 | Out-Null
#Write-Host "Downloads successfully copied."

robocopy "$UserProfilePath\Desktop" "$TempBackupFolder\Desktop" /E /R:0 /W:0 | Out-Null
Write-Host "Desktop successfully copied."


#Remove old TAR if exists

if (Test-Path $TarballFullPath) {
    Remove-Item $TarballFullPath -Force
}

# === Create tar.gz archive of the temp folder ===
tar -czf $TarballFullPath -C $TempBackupFolder .

if (Test-Path $TarballFullPath) {
    Write-Host "Tarball created successfully at: $TarballFullPath"
} else {
    Write-Error "Failed to create tarball!"
    exit 1
}

#Map NAS Network Drive
$SecureNasPassword = ConvertTo-SecureString $NasPassword -AsPlainText -Force
$NasCredential = New-Object System.Management.Automation.PSCredential ($NasUsername, $SecureNasPassword)

New-PSDrive -Name "Z" -PSProvider FileSystem -Root $NasNetworkPath -Credential $NasCredential -Persist


#Copy tarball to NAS
##robocopy <SourceFolder> <DestinationFolder> [<File(s)>] [options]##

#Use robocopy to copy the file
$LogFile = "C:\Your\BackupFolder\robocopy_log.txt"

Rename-Item $TarballFullPath $InProgressFullPath

robocopy $BackupRootFolder $NasDestinationFolder $InProgressName /Z /J /NFL /NDL /R:1 /W:1 /LOG:$LogFile

#Rename on NAS to display complete
$NASFile = Join-Path $NasDestinationFolder $InProgressName
Rename-Item $NASFile -NewName "$Username.tar.gz"

#Remove mapped network drive
Remove-PSDrive -Name "Z"
