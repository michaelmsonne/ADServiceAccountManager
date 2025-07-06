# AD ServiceAccount Manager

<p align="center">
  <a href="https://github.com/michaelmsonne/ADServiceAccountManager"><img src="https://img.shields.io/github/languages/top/michaelmsonne/ADServiceAccountManager.svg"></a>
  <a href="https://github.com/michaelmsonne/ADServiceAccountManager"><img src="https://img.shields.io/github/languages/code-size/michaelmsonne/ADServiceAccountManager.svg"></a>
  <a href="https://github.com/michaelmsonne/ADServiceAccountManager"><img src="https://img.shields.io/github/downloads/michaelmsonne/ADServiceAccountManager/total.svg"></a><br>
  <a href="https://www.buymeacoffee.com/sonnes" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 117px !important;"></a>
</p>

<div align="center">
  <a href="https://github.com/michaelmsonne/ADServiceAccountManager/issues/new?assignees=&labels=bug&template=01_BUG_REPORT.md&title=bug%3A+">Report a Bug</a>
  ·
  <a href="https://github.com/michaelmsonne/ADServiceAccountManager/issues/new?assignees=&labels=enhancement&template=02_FEATURE_REQUEST.md&title=feat%3A+">Request a Feature</a>
  .
  <a href="https://github.com/michaelmsonne/ADServiceAccountManager/discussions">Ask a Question</a>
</div>

## Table of Contents
- [Introduction](#introduction)
- [Contents](#contents)
- [Features](#features)
- [Download](#download)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

# Introduction

The AD ServiceAccount Manager is a powerful PowerShell script and tool designed to streamline the management of service accounts in an Active Directory environment.

It simplifies the creation, modification, and removal of both Group Managed Service Accounts (gMSA) and Standard Accounts (SSA), but also the migration to gSMA!.

I originally built this tool for internal use — it solved a very specific pain point for managing accounts across domains and OUs at a previous job.

Some sneak peak from the original private repo: 

![Private repo](./docs/pictures/original%20repo.png)

Your feedback and support are always welcome! 🤩🤘

## Why this tool is needed in the community
Many existing solutions for managing etc. gMSA accounts (like the build-in MMC), lack the ease of use and cohesion that this tool provides. This PowerShell tool solves those issues by offering:

- **Simplicity**: Consolidates everything in one place—no need to search for scripts.
- **Security**: Confirmation prompts for high-risk tasks, with full logging for audit transparency.
- **Efficiency**: Handles your task easy and fast!

## How this tool will help you
- **Build confidence**: Logging and confirmations provide peace of mind.
- **Save time**: No more script-hunting; everything is centralized.
- **Reduce errors**: User-friendly steps and prompts help avoid mistakes.
- **Increase efficiency**: Easily manage multiple service accounts in your enviroment!

## Contents

Outline the file contents of the repository. It helps users navigate the codebase, build configuration and any related assets.

| File/folder       | Description                                 |
|-------------------|---------------------------------------------|
| `\src`            | Source code.                                |
| `\docs`           | Div. documents and information.             |
| `\exports`        | Exports in raw PowerShell code.             |
| `.gitignore`      | Define what to ignore at commit time.       |
| `CHANGELOG.md`    | List of changes to the sample.              |
| `CONTRIBUTING.md` | Guidelines for contributing to the TEMPLATE.|
| `README.md`       | This README file.                           |
| `SECURITY.md`     | This README file.                           |
| `LICENSE`         | The license for the TEMPLATE.               |

There is over 6000 lines of Powershell code 😆

## 🚀 Features

### Group Managed Service Accounts (gMSA)

- Create new Group Managed Service Accounts (gMSA).
- Remove existing gMSA.
- Assign and remove Service Principal Names (SPNs) to gMSA.
- Add and remove gMSA from Active Directory groups.
- Modify gMSA attributes.

### Standard Accounts (SSA)

- Create new Standard Accounts (SSA).
- Remove existing Standard Accounts (SSA).
- Add and remove Standard Accounts (SSA) from Active Directory groups.
- Modify Standard Service Account attributes.
- Migrate Standard Accounts (SSA) to gMSA.

### Domain Information

- Information about connected Active Directory:
  - Check for SYSVOL type (FRS or DFRS).
  - Check for Enabled users.
  - Check for stale user objects not logged in the last 30, 60, or 90 days.
  - Check for stale computer objects not logged in the last 30, 60, or 90 days.
  - Check for Tombstone Lifetime.
  - Check for when Active Directory is created.
  - Check for if and where an Azure AD Connect is installed.
  - Check for UPN suffixes.
  - Check for Trusts.
  - Check for Exchange Server(s) in the domain.
  - Information about where FSMO Roles are in the domain (server names).
  - Domain functions and levels.
  - Domain Objects (like users, computers, and groups).
  - Check if Microsoft Group Key Distribution Service (KdsSvc) is installed in Active Directory.
  - ...

### Exports
- Export data from the domain information page to .csv.
- Export stale objects from the domain information page to .csv.
- Access a dynamic name for the export file of .csv for GMSA and SSA accounts.

## 📸 Screenshots

To be continued...

![Main gMSA UI](./docs/pictures/main%20gmsa.png)

![Main SSA UI](./docs/pictures/main%20ssa.png)

![Main Domain UI](./docs/pictures/main%20domaininfo.png)

![Main menu UI](./docs/pictures/main%20menu.png)

This tool offers an extensive set of features that cater to the needs of administrators, making it an indispensable resource for managing service accounts in an Active Directory environment.

## Download

[Download the latest version](../../releases/latest)

[Version History](CHANGELOG.md)

## ⚡ Getting Started

### Known bugs
- None

### 🛠 Prerequisites
To run the AD ServiceAccount Manager, you will need:

- Windows PowerShell 5.1 or later
- The Active Directory module installed on your system
- The appropriate permissions to create and manage service accounts in Active Directory

#### Network Protocols and Features Required for Remote Actions

To use remote features in **AD ServiceAccount Manager** (such as checking if service accounts are used, or installing/uninstalling a gMSA account on remote servers), the following protocols and features must be enabled and configured on both the management and target computers:

#### Required Protocols & Features:

- **WinRM (Windows Remote Management)**
  - WinRM must be enabled and running on all remote computers.
  - By default, WinRM listens on HTTP (port 5985) and optionally HTTPS (port 5986).

- **PowerShell Remoting**
  - PowerShell Remoting must be enabled (`Enable-PSRemoting -Force`).
  - The user running the command must have permission to connect remotely (typically a member of the Administrators group on the target machine, or configured via `Set-PSSessionConfiguration`).

- **Network Connectivity**
  - TCP port 5985 (HTTP) or 5986 (HTTPS) must be open between the management host and the target computers.
  - Firewalls must allow inbound connections on these ports.

- **Kerberos Authentication**
  - For domain-joined computers, Kerberos is used for authentication by default.
  - Both the management host and target computers must be in the same or trusted domains.

- **Remote Management Exceptions**
  - The target computer’s firewall must allow "Windows Remote Management" (can be enabled via `Enable-PSRemoting`).

##### Optional/Recommended

- **CredSSP or HTTPS**
  - For passing credentials or running commands that require credential delegation, configure CredSSP or use HTTPS for WinRM.

- **Active Directory Module**
  - The Active Directory module should be available on the management host for AD-related cmdlets.

---

**Example: Enable Remoting on Target Computer**

```powershell
Enable-PSRemoting -Force
```

**Example: Open Firewall for WinRM**

```powershell
Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -Enabled True
```

---

**Summary**  
You need WinRM enabled, PowerShell Remoting configured, open network ports (5985/5986), proper authentication (Kerberos), and firewall rules allowing remote management. Both management and target computers should be domain-joined for seamless Kerberos authentication.

### Changes to the tools code

For changes, **PowerShell Studio** is it for now

### Installation
You can either clone this repository and build the project yourself.

The AD ServiceAccount Manager GUI can be run as an elevated executable (preferred) or as a script. Below are the instructions to load as a script.

1. Log into a Domain Controller, in the domain where the service account will be created
2. Open PowerShell as Administrator
3. Navigate to the folder where the script is located
4. Run the following command:
 ```
 .\ADServiceAccountManager.ps1
 ```

 Or run executable:
  ```
 .\ADServiceAccountManager v. x.x.x.x - Build at xxxxxxxx-xxxxxx
 ```

## Usage

🔧 How to Use

***

- [**Open the AD ServiceAccount Manager GUI**](#open-the-service-account-gui)
- [**Group Managed Service Accounts (gMSA)**](#group-managed-service-accounts-gmsa)
  - [Add/Remove Group Managed Service Accounts](#addremove-group-managed-service-accounts)
    - [Create a New Group Managed Service Account](#create-a-new-group-managed-service-account)
    - [Remove a Group Managed Service Account](#remove-a-group-managed-service-account)
  - [Service Principal Names (SPNs)](#service-principal-names-spns)
    - [Assign a Service Principal Name (SPN) to a Group Managed Service Account](#assign-a-service-principal-name-spn-to-a-group-managed-service-account)
    - [Remove a Service Principal Name (SPN) to a Group Managed Service Account](#remove-a-service-principal-name-spn-to-a-group-managed-service-account)
  - [Principals Allowed to Retrieve Managed Password](#principals-allowed-to-retrieve-managed-password)
    - [Assign a Group Managed Service Account to a Computer or Group](#assign-a-group-managed-service-account-to-a-computer-or-group)
    - [Remove an Assigned Computer\Group from the Group Managed Service Account](#remove-an-assigned-computergroup-from-the-group-managed-service-account)
  - [Active Directory Group Membership](#active-directory-group-membership)
    - [Add a Group Managed Service Account to an AD Group](#add-a-group-managed-service-account-to-an-ad-group)
    - [Remove a Group Managed Service Account from an AD Group](#remove-a-group-managed-service-account-from-an-ad-group)
  - [Modify Group Managed Service Account (gMSA)](#modify-group-managed-service-account-gmsa)
    - [Modify a Group Managed Service Account Attributes](#modify-a-group-managed-service-account-attributes)
- [**Standard Accounts (SSA)**](#standard-service-accounts)
  - [Add/Remove Standard Accounts (SSA)](#addremove-standard-service-accounts)
    - [Create a New Standard Service Account](#create-a-new-standard-service-account)
    - [Remove a Standard Service Account](#remove-a-standard-service-account)
  - [Active Directory Group Membership](#active-directory-group-membership-1)
    - [Add a Standard Service Account to an AD Group](#add-a-standard-service-account-to-an-ad-group)
    - [Remove a Standard Service Account from an AD Group](#remove-a-standard-service-account-from-an-ad-group)
  - [Modify Standard Service Account](#modify-standard-service-account)
    - [Modify a Standard Service Account Attributes](#modify-a-standard-service-account-attributes)
  - [Account Migration](#account-migration)
    - [Create an identical gMSA from a Standard Service Account](#create-an-identical-gmsa-from-a-standard-service-account)

***

# **Group Managed Service Accounts (gMSA)**

## Add/Remove Group Managed Service Accounts

### Create a New Group Managed Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
        1. Click the **Create New** button
2. In the **New Group Managed Service Account** window that appears
    1. Type the **Name** of the new account
        1. *NOTE: As you type, it is testing if an account exists with that name. If it does, it will recommend a new name.*
    2. Type the **Service Request #** from HPSM or Service Now
    3. Type the **Purpose** of the service account
    4. Select or type the **Functional Owner&#39;s Distribution Email Address**
    5. Optional Uncommon Options:
        1. Modify the User Logon name (sAMAccountName) if needed
        2. Modify the auto-populated **Description** if needed
        3.  **Enable** or Disable the account as required
        4. Modify the **Encryption Types** only if required
        5. Modify the **Container** to store the Managed Service Account
            1. This is not common
        6. Modify the **DNS Host Name** 
            1. This is not common
    6. Click **Create New Group Managed Service Account** button to create the account
        1. *NOTE: The button will be disabled if any field is not correct or needs attention.*

3. A success pop-up should appear, reminding you to run a command on the server that will be using the account - in the pop-up you have the option to install it automaticly if the access is possible (permissions and network/firewall). - in the pop-up you have the option to install it automaticly if the access is possible (permissions and network/firewall).
    1. Click **OK**


### Remove a Group Managed Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. Right click the Account, and click the **Remove** menu item
4. In the **Confirm** pop-up, type the name of the account exactly as shown
    1. Click **OK** to immediately (and irreversibly) delete the account

***

## Service Principal Names (SPNs)

### Assign a Service Principal Name (SPN) to a Group Managed Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. In the bottom right, select the **Service Principal Names (SPNs)** tab
4. Type the SPN that you would like to add, to the **Add SPN** textbox
    1. Click **Add** to add the SPN immediately to the account
5. Repeat to add additional SPNs



### Remove a Service Principal Name (SPN) to a Group Managed Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. In the bottom right, select the **Service Principal Names (SPNs)** tab
4. Select the SPN that you would like to remove
    1. Click the **Remove** button
    2. At the confirmation pop-up, select **Yes** to remove the SPN immediately

***

## Principals Allowed to Retrieve Managed Password

### Assign a Group Managed Service Account to a Computer or Group

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. In the bottom right, select the **Assigned Computers** tab
    1. Click the **Add** button
4. In the **AD Object Picker** pop up
    1. Select the **Type** (either Computer or Group)
    2. Type the **Name** (or partial name) of the Computer or Group
    3. Select the **Check Name** button
        1. In the table, select the Computer or Group to assign the gMSA to
        2. Click the **Select** button to immediately assign the Computer or Group to the gMSA


### Remove an Assigned Computer\Group from the Group Managed Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. In the bottom right, select the **Service Principal Names (SPNs)** tab
4. Select the SPN that you would like to remove
    1. Click the **Remove** button, to remove the assigned computer immediately (it´s checks for if any services are running as the account if possible)

***

## Active Directory Group Membership

### Add a Group Managed Service Account to an AD Group

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. In the bottom right, select the **Member Of** tab
    1. Click Add
4. In the **AD Object Picker** pop up
    1. Type the **Name** (or partial name) of the Group
    2. Select the **Check Name** button
        1. In the table, select the Group to add the gMSA to
        2. Click the **Select** button to immediately add the gMSA to the selected group.


### Remove a Group Managed Service Account from an AD Group

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. In the bottom right, select the **Member Of** tab
4. Select the Group that you would like to remove
    1. Click the **Remove** button
    2. At the confirmation pop-up, select **Yes** to remove the gMSA from the AD Group immediately

***

## Modify Group Managed Service Account (gMSA)

### Modify a Group Managed Service Account Attributes

1. In the AD ServiceAccount Manager GUI
    1. Select the **Group Managed Accounts (gMSA)** tab
2. Select the Account from the **Group Managed Service Account List**
3. In the bottom left, modify the selected attribute(s)
    1. Any pending changes will change to a Green font
4. Click **Apply** , to apply the pending changes.
    1. *NOTE: If you add an Encryption Type other than AES256, you will be required to type in a phrase exactly (case-sensitive), to verify you want to select an unsafe encryption type*

***

# **Standard Accounts (SSA)**

## Add/Remove Standard Accounts (SSA)

### Create a New Standard Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Standard Accounts (SSA)** tab
        1. Click the **Create New** button
2. In the **New Standard Service Account** window that appears
    1. Type the **Name** of the new account
        1. *NOTE: As you type, it is testing if an account exists with that name. If it does, it will recommend a new name.*
    2. Type the **Service Request #** from HPSM or Service Now
    3. Type the **Purpose** of the service account
    4. Either type in a **password** , or click the **Generate** button to create random 25 Character Password
        1. Save this password, as it will not be available again after account creation
    5. Select or type the **Functional Owner&#39;s Distribution Email Address**
    6. Optional Uncommon Options:
        1. Modify the User Logon name (sAMAccountName) if needed
        2. Modify the auto-populated **Description** if needed
        3.  **Enable** or Disable the account as required
            1. This option is only available if added a password above
        4. Modify the **Encryption Types** only if required
        5. Modify the password options and Account expiration as required
    7. Click **Create New Standard Service Account** button to create the account
        1. NOTE: The button will be disabled if any field is not correct or needs attention.
    8. A pop-up will appear to confirm you have saved the password (if created).
        1. Select **Yes** to continue; or select **No** to go back to save it
    9. A success pop-up should appear, reminding you to run a command on the server that will be using the account - in the pop-up you have the option to install it automaticly if the access is possible (permissions and network/firewall).
        1. Click **OK**


### Remove a Standard Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Standard Accounts (SSA)** tab
2. Select the Account from the **Standard Service Account List**
3. Right click the Account, and click the **Remove** menu item
4. In the **Confirm** pop-up, type the name of the account exactly as shown
    1. Click **OK** to immediately (and irreversibly) delete the account

***

## Active Directory Group Membership

### Add a Standard Service Account to an AD Group

1. In the AD ServiceAccount Manager GUI
    1. Select the **Standard Accounts (SSA)** tab
2. Select the Account from the **Standard Service Account List**
3. In the bottom right, in the **Member Of** box
    1. Click Add
4. In the **AD Object Picker** pop up
    1. Type the **Name** (or partial name) of the Group
    2. Select the **Check Name** button
        1. In the table, select the Group to add the Account to
        2. Click the **Select** button to immediately add the Account to the selected group.

### Remove a Standard Service Account from an AD Group

1. In the AD ServiceAccount Manager GUI
    1. Select the **Standard Accounts (SSA)** tab
2. Select the Account from the **Standard Service Account List**
3. In the bottom right, select the **Member Of** box
4. Select the Group that you would like to remove
    1. Click the **Remove** button
    2. At the confirmation pop-up, select **Yes** to remove the Account from the AD Group immediately

***

## Modify Standard Service Account

### Modify a Standard Service Account Attributes

1. In the AD ServiceAccount Manager GUI
    1. Select the **Standard Accounts (SSA)** tab
2. Select the Account from the **Standard Service Account List**
3. In the bottom left, modify the selected attribute(s)
    1. Any pending changes will change to a Green font
4. Click **Apply** , to apply the pending changes.
    1. *NOTE: If you add an Encryption Type other than AES256, you will be required to type in a phrase exactly (case-sensitive), to verify you want to select an unsafe encryption type*

***

## Account Migration

### Create an identical gMSA from a Standard Service Account

1. In the AD ServiceAccount Manager GUI
    1. Select the **Standard Accounts (SSA)** tab
2. Select the Account from the **Standard Service Account List**
3. Right click the Account, and click the **Create a gMSA from [accountname]** menu item
4. In the **New Group Managed Service Account** window that appears
    1. The Name field will be pre-populated with the selected account name
    2. Type the **Service Request #** from HPSM or Service Now
    3. Type the **Purpose** of the service account
    4. Select or type the **Functional Owner&#39;s Distribution Email Address**
    5. Optional Uncommon Options:
        1. Modify the User Logon name (sAMAccountName) if needed
        2. Modify the auto-populated **Description** if needed
        3.  **Enable** or Disable the account as required
        4. Modify the **Encryption Types** only if required
        5. Modify the **Container** to store the Managed Service Account
            1. This is not common
        6. Modify the **DNS Host Name**
            1. This is not common
    6. Click **Create New Group Managed Service Account** button to create the account
        1. NO*TE: The button will be disabled if any field is not correct or needs attention.*
    7. A success pop-up should appear, asking if you would like to add this gMSA account to the same groups that the Standard Service Account was in.
    8. Click **Yes** to add to the selected groups; Click **No** to not add to the selected Groups
    9. A success pop-up should appear, reminding you to run a command on the server that will be using the account - in the pop-up you have the option to install it automaticly if the access is possible (permissions and network/firewall).
        1. Click **OK**

# Contributing
If you want to contribute to this project, please open an issue or submit a pull request. I welcome contributions :)

See [CONTRIBUTING](CONTRIBUTING.md) for more information.

First off, thanks for taking the time to contribute! Contributions are what makes the open-source community such an amazing place to learn, inspire, and create. Any contributions you make will benefit everybody else and are **greatly appreciated**.
Feel free to send pull requests or fill out issues when you encounter them. I'm also completely open to adding direct maintainers/contributors and working together! :)

Please try to create bug reports that are:

- _Reproducible._ Include steps to reproduce the problem.
- _Specific._ Include as much detail as possible: which version, what environment, etc.
- _Unique._ Do not duplicate existing opened issues.
- _Scoped to a Single Bug._ One bug per report.´´

# Status

The project is actively developed and updated.

# Support

Commercial support

This project is open-source and I invite everybody who can and will to contribute, but I cannot provide any support because I only created this as a "hobby project" ofc. with tbe best in mind. For commercial support, please contact me on LinkedIn so we can discuss the possibilities. It’s my choice to work on this project in my spare time, so if you have commercial gain from this project you should considering sponsoring me.

<a href="https://www.buymeacoffee.com/sonnes" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 117px !important;"></a>

## From the community

- 
- ...

and many more posts and shareing online - check it out! ❤️

# 📄 License
This project is licensed under the **MIT License** - see the LICENSE file for details.

See [LICENSE](LICENSE) for more information.