# SPO Audit Pipeline - Runbook
## 1. Overview
   
This project is a Microsoft 365 / SharePoint Online audit log ingestion pipeline designed for automated data collection and local persistence.
What it does

•	Connects to Microsoft 365 audit log endpoints using app-only authentication

•	Retrieves audit log events from Microsoft 365 services

•	Parses and normalizes JSON audit data

•	Stores structured records in a local SQLite database

•	Uses deduplication via unique audit event identifiers

•	Runs on a scheduled interval via Windows Task Scheduler

________________________________________
## 2. System Architecture
   
Microsoft 365 Audit Logs -> PowerShell Script -> Data Transformation & Sanitization -> SQLite Database → Local Query / Reporting
________________________________________
## 3. Prerequisites
   
## Required Software

•	PowerShell 7+

•	Exchange Online PowerShell module (ExchangeOnlineManagement)

•	Microsoft Graph PowerShell module

•	SQLite CLI (sqlite3)

## Required Configuration

•	Microsoft Entra ID App Registration (service principal)

•	Certificate-based authentication configured for app-only access

•	Appropriate Exchange Online audit log permissions assigned via RBAC

________________________________________
## 4. Database Schema

Audit Events Table

```
CREATE TABLE IF NOT EXISTS AuditEvents (

    RowId INTEGER PRIMARY KEY AUTOINCREMENT,
    
    AuditId TEXT UNIQUE,
    
    CreationTime TEXT,
    
    Operation TEXT,
    
    UserId TEXT,
    
    SourceRelativeUrl TEXT,
    
    DestinationRelativeUrl TEXT,
    
    FileName TEXT,
    
    ObjectId TEXT,
    
    RawJson TEXT
    
);

Insert Pattern

INSERT INTO AuditEvents (

    AuditId,
    
    CreationTime,
    
    Operation,
    
    UserId,
    
    SourceRelativeUrl,
    
    DestinationRelativeUrl,
    
    FileName,
    
    ObjectId,
    
    RawJson
    
)

VALUES (

    @AuditId,
    
    @CreationTime,
    
    @Operation,
    
    @UserId,
    
    @SourceRelativeUrl,
    
    @DestinationRelativeUrl,
    
    @FileName,
    
    @ObjectId,
    
    @RawJson
    
);
```
________________________________________
## 5. Authentication Model (App-Only Certificate Auth)

Certificate Creation
```
New-SelfSignedCertificate \
    -Subject "CN=AuditPipelineCert" \
    -CertStoreLocation "Cert:\LocalMachine\My"
```
    
Certificate Export
```
Get-ChildItem Cert:\LocalMachine\My\<CERT_THUMBPRINT> |
Export-Certificate -FilePath "<CERT_EXPORT_PATH>"
```

App Registration Requirements

•	Upload public certificate to Entra ID App Registration

•	Assign Microsoft Graph / Exchange Online application permissions

•	Grant admin consent for required scopes

________________________________________
## 6. Service Principal Setup
```   
Connect-MgGraph -Scopes "Application.ReadWrite.All"

New-MgServicePrincipal -AppId "<APP_ID>"

Map service principal to Exchange Online:

New-ServicePrincipal -AppId "<APP_ID>" -ServiceId "<SERVICE_PRINCIPAL_OBJECT_ID>"
```
________________________________________
## 7. RBAC Configuration

Role Group Setup
```
New-RoleGroup -Name "AuditLog Reader" \

    -Description "Least privilege access for audit log ingestion" \
    
    -Roles "View-Only Audit Logs"
```
________________________________________
## 8. Authentication Execution
```
Connect-ExchangeOnline \
    -AppId $appId \
    -Organization $organization \
    -CertificateThumbprint $thumbprint
    
Validation

Search-UnifiedAuditLog
```
________________________________________
## 9. Scheduled Execution (Task Scheduler)
Configuration

•	Create task in Windows Task Scheduler

•	Configure task to run on a schedule (daily recommended)

## Settings

•	Run whether user is logged on or not

•	Run with highest privileges

## Action

Program: `powershell.exe`

Arguments:`-NoProfile -ExecutionPolicy Bypass -File "<SCRIPT_PATH>"`

Notes

•	Ensure required PowerShell modules are installed in AllUsers scope if running under SYSTEM context

•	Ensure all file paths are absolute and accessible
________________________________________
## 10. Operational Usage
    
## Manual Execution

powershell.exe -File <SCRIPT_PATH>

## Expected Behavior

•	Authentication to Microsoft 365 succeeds

•	Audit logs are retrieved successfully

•	Data is inserted into SQLite database

•	Duplicate records are ignored via UNIQUE constraint on AuditId

________________________________________
## 11. Health Check
System is considered healthy when:

•	New records appear in AuditEvents table

•	CreationTime values continue to update

•	Script logs show successful authentication

•	No persistent SQLite constraint or runtime errors

________________________________________
## 12. Troubleshooting
    
## Cmdlet Not Found

•	Required module not installed or not available in execution context

## No Audit Data Returned

•	Insufficient RBAC permissions

•	Invalid query scope or time window limitations

Duplicate Constraint Errors

•	Expected behavior when overlapping ingestion windows occur

Task Scheduler Executes But No Output

•	Execution context missing required modules

•	File path or permissions issue under SYSTEM account

________________________________________
## 13. Recovery Procedures

## Reprocessing Data

•	Re-run script manually for missing time ranges

## Database Recovery

•	SQLite database can be rebuilt or restored from backup if needed

•	Raw JSON field allows reprocessing of historical records
________________________________________
## 14. Design Decisions
    
•	Deduplication handled via UNIQUE constraint on AuditId

•	Raw JSON stored to allow flexible schema evolution

•	App-only authentication used for automation and security isolation

•	Scheduled execution via Windows Task Scheduler for simplicity

________________________________________
## 15. Known Limitations

•	Microsoft 365 API query limits (e.g., ~5,000 record constraints per window)

•	No external SIEM integration implemented

•	Single-node execution model (no distributed processing)

________________________________________
## 16. Security Notes

This repository is sanitized for public sharing. All tenant-specific identifiers, paths, and environment-specific values have been removed or abstracted.
