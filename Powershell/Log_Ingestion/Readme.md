# SPO Audit Pipeline

Automated Microsoft 365 audit log ingestion pipeline using PowerShell and SQLite.
________________________________________
# Summary
This project collects audit logs from Microsoft 365 using app-only authentication, processes the data with PowerShell, and stores structured results in a local SQLite database for querying and analysis.
It is designed as a lightweight, portable automation pipeline for security and audit visibility use cases.
________________________________________
# What Problem This Solves
Microsoft 365 audit logs are:
•	Difficult to retain locally
•	Limited in query window size
•	Not easily structured for custom analysis

This pipeline provides:
•	Local persistence of audit data
•	Structured querying via SQLite
•	Automated scheduled ingestion
________________________________________
# Architecture (High Level)
Microsoft 365 Audit Logs -> PowerShell Ingestion Script -> Data Parsing + Sanitization -> SQLite Database -> Local Query / Analysis
________________________________________
# Key Features
•	App-only authentication using Entra ID certificate-based service principal

•	Microsoft 365 audit log ingestion (Unified Audit Log)

•	JSON parsing and normalization

•	SQLite structured storage

•	Deduplication via AuditId unique constraint

•	Scheduled execution via Windows Task Scheduler

________________________________________
# Repository Structure
SPO-Audit-Pipeline/ README.md RUNBOOK.md scripts/ audit-1.0.ps1 sql/ schema.sql docs/ architecture.md
________________________________________
# Quick Start
1.	Create Entra ID App Registration
2.	Upload certificate for authentication
3.	Assign required Exchange Online audit permissions
4.	Configure script execution in Task Scheduler
5.	Run script manually or wait for schedule
________________________________________
# What This Repo Includes
•	Pipeline design overview (README)

•	Full operational runbook (RUNBOOK.md)

•	SQL schema definition

•	PowerShell ingestion script (sanitized)

________________________________________
# What This Repo Does NOT Include

•	No tenant-specific identifiers

•	No credentials or secrets

•	No production environment configuration

All values must be supplied by the implementer.
________________________________________
# Limitations

•	Microsoft 365 API ingestion window limits (~5000 records per query window)

•	No external SIEM integration

•	Single-node execution model

•	Local-only storage (SQLite)
________________________________________
# Related Documentation
Full operational procedures, troubleshooting, and recovery steps are documented in RUNBOOK.md
________________________________________
# Notes
This project demonstrates:

•	Microsoft 365 app-only authentication design

•	RBAC-based access control for audit logs

•	PowerShell-based data pipeline construction

•	Scheduled automation via Windows Task Scheduler

•	Local persistence and deduplication patterns
