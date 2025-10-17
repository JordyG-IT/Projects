## Condensed Security Investigation Report – TryHackMe Ubuntu Web Server - Infinity Shell Room
---

**Investigator:** Jordy Garrett  
**Date:** 17 October 2025  
**System:** Ubuntu 24.04.1 LTS  
**Target:** CMSsite-master web application

---

**Context:**
Suspected webshell on webserver, tasked with investigating and locating the reverse webshell.

---

## 1. System Overview

- OS: Ubuntu 24.04.1 LTS (Noble Numbat)
    
- Webserver: Apache 2.4.58
    
- PHP application: CMSsite-master
    

---

## 2. Web Server Logs

### 2.1 Access Logs

- `/var/log/apache2/access.log` and `/var/log/apache2/error.log` were empty.
    
- Relevant activity was found in archived logs: `error.log.1` and `other_vhosts_access.log.1`.
    

### 2.2 Error Logs (`error.log.1`)

- Numerous PHP errors observed from the same client IP: `10.11.93.143`.
    
- Errors indicated:
    
    - Failed database connection attempts (`mysqli_sql_exception`) in `includes/db.php`.
        
    - Missing scripts in `/img/images.php`.
        
    - PHP `system()` calls with empty arguments, causing fatal errors.
        
    - Undefined array keys in `images.php`.
        

**Observation:**

- Repeated PHP errors suggest misuse or attempted exploitation of `images.php`, an unusual file in an image directory.
    

### 2.3 Virtual Host Logs (`other_vhosts_access.log.1`)

- Multiple GET requests to `CMSsite-master` and associated assets.
    
- Some requests contained encoded query strings.
    
- Several 404 errors for missing assets (e.g., `award githud.JPG`, `bootstrap.min.css`).
    
- POST requests observed for `register.php` and `login.php` endpoints.
    

**Observation:**

- The client performed sequential interaction typical of a user navigating and testing the CMS interface.
    
- Repeated access to `profile.php?section=not_cipher` and `img/images.php` suggests probing for potential vulnerabilities.
    

---

## 3. Findings

1. **Potential Exploit Attempts:** The repeated errors in `images.php` and malformed system calls indicate an attacker may be attempting Remote Code Execution (RCE).
    
2. **Database Misconfiguration:** PHP errors show access denied for `root@localhost`, which could indicate misconfigured credentials.
    
3. **Missing Files/Assets:** Multiple 404s indicate incomplete deployment or deliberate file removal to hinder analysis.
    
4. **Suspicious Activity Patterns:** Consistent access from the same IP across multiple endpoints, including encoded queries, suggests automated or scripted probing.
    

---

## 4. Recommendations

1. **Immediate Security Review:** Investigate `images.php` and any scripts in the `/img` folder for malicious code.
    
2. **Database Hardening:** Ensure MySQL credentials follow the principle of least privilege.
    
3. **File Integrity Checks:** Verify that all required web assets are present and unaltered.
    
4. **Monitor Client Activity:** Flag repeated failed access attempts and encoded queries for potential intrusion alerts.
    
5. **Patch Management:** Ensure PHP, Apache, and CMSsite-master are updated to the latest secure versions.
    

---

**Classification:** Potential intrusion attempt / misconfiguration exploitation.
