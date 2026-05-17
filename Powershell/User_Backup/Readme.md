# User Profile Backup Script

## Problem
Automate backing up user profiles (Documents, Desktop) to a NAS, packaging the contents into a tarball, compressing with gzip, and ensuring safe transfer.

## Approach
- Copy important folders to a temporary backup folder - Handles copying even when folder / file permissions may be an issue.
- Compress the folder into a `.tar.gz` file. Good to get around compress-archive 4 GB limitations.
- Map NAS network drive and transfer the archive.
- Clean up mapped drive and temp files.

## Tools
- PowerShell
- Robocopy
- tar (via PowerShell)

## Outcome
- Efficient, repeatable backup process for offboarding users local profile.
- Reduces manual errors and saves time.

## Lessons Learned
- Using `$env:USERNAME` and `$env:USERPROFILE` allows the script to be generic.
- In-progress renaming ensures partial copies aren't mistaken as complete.
