
# PowerShell Projects

This folder contains my PowerShell scripts and related experiments and tools.  
Each script or mini-project is organized into its own subfolder for clarity.  

## Structure
- `script1/` → Individual PowerShell script + notes
- `script2/` → Another script or project
- (and so on...)

## Purpose
The goal of this folder is to:
- Store and version-control my PowerShell work
- Keep each script/project self-contained
- Provide a reference for future automation tasks and learning

## Explanations of Each Project
### 1. Log Ingestion
   
This tool retrieves Microsoft 365 audit logs using the Search-UnifiedAuditLog cmdlet. It parses the returned JSON data and stores it in a SQLite database, providing a centralized and queryable dataset for auditing, reporting, and analysis.

### 2. User Backup

This tool is designed for use during user offboarding. It collects the user profile from a local machine, archives the data into a compressed tarball, and transfers it to a network-attached storage (NAS) location using Robocopy for centralized backup and retention.
