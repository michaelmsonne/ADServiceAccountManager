## [1.0.16.0] - xx-xx-xx

### Add
- Added

### Changed
- Changed the code for getting Windows Server Version in class ActiveDirectory.ps1 - Thanks to my friend @[Harm Veenstra](https://github.com/HarmVeenstra) for the tip

### Fixed
- Fix 

## [1.0.15.0] - 29-06-2025

### First public release at GitHub! 🎉

### Add
- Added a new logo 🥳
- Application renamed 🥳
- Added function to export data from domain information page to .csv
- Added function to export stale objects from domain information page to .csv
- Added function to count disabled accounts
- Added function to count locked accounts
- Added function to count accounts whose passwords don’t expire
- Added function to count Schema Admins
- Added main menu and moved buttons in top of application into that
- Added dynamic name for the export file of .csv - GMSA and SSA accounts
- Added option to open log file for today in the GUI, not just only the log folder now
- Added support for Windows Server 2025
- Added check and confirmation from user when selecting custom SSA OU as it can hold normal users
- Added a lot of code comments to the tool, so easier for others to read/see what the tool is doing
- Added improved error handling and user feedback throughout the application
- Added more detailed logging for troubleshooting and auditing actions
- Added in-app help and updated tooltips for better guidance

### Changed
- Changed main form header and footer layout/text
- Changed gMSA properties text
- Reordered a lot of code and introduced classes in tool
- Improved layout and responsiveness of the main window
- Enhanced accessibility and keyboard navigation
- Improved compatibility with different Windows Server and Active Directory versions

### Fixed
- Fix that pop-up not shows up if can´t find OU for standard service accounts if not connected to a Active Directory
- Fix correct numbers of enabled users if new domain without OUs
- Fix correct message flow for end user in GUI if abort SSA password reset
- Fix correct message when user abort installation af Active Directory PowerShell module
- Fix error in function when check for Azure AD Connect in domain
- Fixed minor typos and improved consistency in messages and logs

## [1.0.14.0] - 1/11/2023

### Add
- Added information about connected Active Directory (Tab: Domain Information):
    - Added check for SYSVOL type (FRS or DFRS)
    - Added check for Enabled users
    - Added check for stale user objects not logged in the last 30, 60 or 90 days
    - Added check for stale computer objects not logged in the last 30, 60 or 90 days
    - Added check for Tombstone Lifetime
    - Added check for when Active Directory is created
    - Added check for if and where an Azure AD Connect is installed
    - Added check for UPN suffixes
    - Added check for Trusts
    - Added check for Exchange Server(s) in domain

### Changed
- Some small GUI changes
- Some small fixes to changelog

## Fixed
- Fix SSA not deleted if have a space in the name


## [1.0.13.0] - 29/1/2023

- Application is now signed with my Code Sign certificate

### Fixed
- Fix wrong number count for Domain Admins and Enterprise Admins in main GUI


## [1.0.12.0] - 13/11/2022

###
- Add Domain Controller numbers and fix if values is empty
- Add Domain and Enterprise admin count in Domain tab

# Fixed
- Fix wrong v. number in topbar in main GUI
- Fix in function Find-ServiceAccountOU to show a message if no OU is find automatically


## [1.0.11.0] - 23/10/2022

### Added
- Added function to set -ManagedPasswordIntervalInDays on a new gMSA account (And this data is showed in gMSA account list in the GUI too)


## [1.0.10.0] - 25/09/2022

### Added
- Added information about connected Active Directory (Tab: Domain Information):
    - Information about whare FSMO Roles are in domain (server names)
    - Domain functions and levels.
    - Domain Objects (like users, computers and groups)
- Added a function to check if a Service Account is used to an Service on a server you will remove from a gMSA (PrincipalPrincipal Allowed to Retrieve PasswordToRemove)
    (Have to use WMI for this as Get-Service doesn't show the Log On As user..)

### Changed
- Rewrite some functions to show better information to user and in logfiles for errors etc.


## [1.0.9.0] - 18/06/2022

### Added
- Added check for if Microsoft Group Key Distribution Service (KdsSvc) is installed or not in Active Directory

### Changed
- Rewrite some functions to show better information to user and in logfiles for errors etc.


## [1.0.8.0] - 14/06/2022

### Changed
- Changed order checks for if Active Directory module is installed or not
- Changed order for multiple functions to get more accurate information
- Updated GUI color to write all over in tool (when possible)
- Updated log in code so more task is logged for troubleshooting if needed
- Updated some typo in code and functions


## [1.0.7.0] - 20/4/2022

### Added
- Added function to install missing PowerShell Module if not found and installed (Rsat.ActiveDirectory.DS-LDS.Tools) if running tool from a workstation (installed on Domain Controllers as default) and RSAT-AD-PowerShell for member servers
- Added dynamic year to 'About' on main GUI

### Changed
- Cleanup in startup code
- Changed auto cleanup for logfiles to 15 days

### Fixed
- Fixed wrong titel for a '-' on main GUI


## [1.0.6.0] - 18/4/2022

### Added
- Added option to install/uninstall gMSA on server remote with Invoke-Command if added/removed from gMSA under Principals Allowed To Retrieve Password
	   (Works if firewall allow it and feature is available)
- Added function to install Active Directory Recycle Bin if it is not installed

### Changed
- Small changes to code and code cleanup
- Changed logfile location to:
	   C:\Users\%username%\AppData\Local\ServiceAccounts
	   (yes, it´s your username over here dynamic)


## [1.0.5.0] - 13/4/2022

### Added
- Added check for connection to an Active Directory
- Added check for Active Directory Forrest level in relation to Active Directory Recycle-bin (on Domain level)

### Changed
- Small changes to load code and code cleanup

### Fixed
- Fixed logfile name not include timestamp (format: dd/MM/yyyy) for the date log is created


## [1.0.4.0] - 2/4/2022

### Fixed
- Small fixes (text in messages etc.) and code cleanup
- Fixes for find Standard Service Accounts in more OU´s (Wildcard changes in Search code)


## [1.0.3.0] - 18/3/2022

### Added
- Set gMSA to be disabled as default (like SSA,Standard Service Accounts)

### Fixed
- Fixed Distribution Group Membership
- Fixed some GUI bugs


## [1.0.2.0] - 17/3/2022

### Added
- Added log feature

### Changed
- Changed Get-ADObject filtering on Users and Groups

### Fixed
- Error pop-up title fixed


## [1.0.1.0] - 16/3/2022

### Changed
- Changed order for password resets
- Updated AD Object picker to find objects when type in for Computers and Groups

## [1.0.0.0] - 14/3/2022
- Initial release

## [0.0.1.0] - 18/02/2022

### Alpha/Beta Builds (2020 to 2022)

These early alpha and beta builds laid the foundation for the AD ServiceAccount Manager tool. Over the course of the first year, the following core features and improvements were introduced:

### Added
- Initial implementation of the main GUI for managing service accounts
- Basic support for creating, editing, and deleting standard service accounts (SSA) and group managed service accounts (gMSA)
- Integration with Active Directory for user and group management
- Logging of key actions and errors for troubleshooting
- Basic checks for Active Directory connectivity and required modules
- Early version of the domain information page
- Initial implementation of permission and group membership management for service accounts

### Changed
- Iterative improvements to the user interface and workflow based on early feedback
- Refactoring of code for better maintainability and performance
- Enhanced error handling and user notifications

### Fixed
- Various bug fixes and stability improvements during alpha/beta testing
- Improved compatibility with different Windows Server and Active Directory versions

> These pre-1.0 releases were shared with a small group of testers and internal users to gather feedback and ensure a stable foundation for the first release.