# Enterprise Windows 11 Mass Migration Toolkit

![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?style=flat&logo=windows)
![Language](https://img.shields.io/badge/Language-Batch%20Script-4CAF50?style=flat&logo=gnubash)
![Tool](https://img.shields.io/badge/Deployment-PDQ%20Deploy-orange?style=flat)

## Overview
This repository hosts the automation engine used to successfully migrate **400+ workstations** from Windows 10 to Windows 11 in a high-availability BPO environment.

The solution was engineered to bypass manual intervention, leveraging a custom wrapper script that handles silent installation, pre-flight validation, and error resilience strictly via Batch scripting (due to GPO constraints on PowerShell).

## Authors & Engineering
* **Helder Arburola** - *Core Scripting & Automation Logic*
* **Leonardo Mejia** - *QA Strategy, Stress Testing & Deployment Validation*

## Technical Implementation

### The Challenge
* **Scale:** 400+ Nodes (Production Critical).
* **SLA:** Zero downtime allowed for active agents.
* **Constraints:** Restricted PowerShell execution (GPO) and limited network bandwidth during shift hours.

### Deployment Strategy
We implemented a two-phase architecture using PDQ Deploy:

1.  **Phase 1: Staging (File Copy)**
    * The 5GB+ installation media is staged locally to `C:\W11` during maintenance windows to prevent network congestion.
2.  **Phase 2: Execution (The Wrapper)**
    * The script `deploy_win11_upgrade.bat` executes the upgrade locally.

### Script Logic Features
The wrapper adds an enterprise logic layer over the standard Microsoft Setup:
* **Disk Space Guard:** Prevents execution if free space is < 64GB (calculating via WMI).
* **Process Resilience:** Retries the installation up to 3 times if the Windows Installer service is locked.
* **Exit Code Translation:** Captures code `3010` (Reboot Required) and flags it as a success to the deployment console.
* **Logging:** Writes concise audit trails to `C:\PDQ\Upgrade_W11.log`.

## Deployment Metrics
| Metric | Value |
| :--- | :--- |
| **Nodes Migrated** | 400+ |
| **Success Rate** | ~98% (First pass) |
| **Downtime** | 0% (Background Staging) |

## Usage
1.  Stage Windows 11 files to `C:\W11`.
2.  Run `deploy_win11_upgrade.bat` with Admin privileges.
3.  Logs are generated at `C:\PDQ\Upgrade_W11.log`.

## License
MIT License. See `LICENSE` file for details.