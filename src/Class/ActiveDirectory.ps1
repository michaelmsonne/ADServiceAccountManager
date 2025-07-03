#Test if Active Directory Recycle Bin is enabled or not
function Test-ADRecycleBin
{
	<#
	.SYNOPSIS
		Test-ADRecycleBin returns the value if function is installed or not.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
	#>
	
	$enabledScopes = (Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"').EnabledScopes
	if ($enabledScopes)
	{
		#If enabled
		return $true
	}
	else
	{
		#If not enabled
		return $false
	}
}

#Test if Active Directory KdsRootKey is enabled or not
function Test-KdsRootKey
{
<#
	.SYNOPSIS
		Test-KdsRootKey returns the value if function is installed or not.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct value within a packaged executable.
#>
	if (Get-KdsRootKey)
	{
		#If enabled
		return $true
	}
	else
	{
		#If not enabled
		return $false
	}
}

#Get AD Forrest level
function Test-GetForestModeForADRecycleBin
{
<#
	.SYNOPSIS
		Test-GetForestModeForADRecycleBin returns the value if function is installed or not.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct value within a packaged executable.
#>
	$supportedforest = @('Windows2008R2Forest', 'Windows2012Forest', 'Windows2012R2Forest', 'Windows2016Forest', 'Windows2025Forest')
	#$notsupportedforest = @('Windows2000Forest', 'Windows2003InterimForest', 'Windows2003Forest', 'Windows2008Forest', 'UnknownForest')
	$ForestMode = (Get-ADForest).ForestMode
	# If supported
	if ($supportedforest -contains $ForestMode)
	{
		return $true
	}
	# If not supported
	if ($supportedforest -notcontains $ForestMode)
	{
		return $false
	}
}

#Test connection to Active Directory
function Test-DomainConnection
{
<#
	.SYNOPSIS
		Test-DomainConnection returns the value if connected or not.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct value within a packaged executable.
#>
	try
	{
		#Check if computer is connected to domain network
		[void]::([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain())
		
		#Domain network
		return $true
	}
	catch
	{
		#Remote network/no domain
		return $false
	}
}

#Find-ServiceAccountOU function
function Find-ServiceAccountOU
{
<#
    .SYNOPSIS
        Finds the Organizational Unit (OU) for service accounts in Active Directory.

    .DESCRIPTION
        This function searches for OUs that are likely to contain service accounts by looking for standard naming patterns such as "Privileged Account*", "Service*", or "*Service*Account*".
        If a "Privileged Account*" OU is found, it searches within that OU for "Service*" OUs.
        If not found, it searches the entire directory for "*Service*Account*" OUs.
        Returns the Distinguished Name (DN) of the first matching OU, or an empty result if none are found.

    .OUTPUTS
        System.String

    .NOTES
        Returns the correct value within a packaged executable.
        If no matching OU is found, returns an empty string.
#>
	$result = @()
	Try
	{
		# Find OUs by names for Service Accounts
		$PrivilegedAccountsOUFound = Get-ADOrganizationalUnit -Filter { name -like "Privileged Account*" }
		
		If ($PrivilegedAccountsOUFound)
		{
			# If a "Privileged Account*" OU is found, search for "Service*" OUs within it
			[array]$result = $(Get-ADOrganizationalUnit -Filter { name -like "Service*" } -SearchBase $($PrivilegedAccountsOUFound.DistinguishedName)).DistinguishedName
		}
		else
		{
			# Otherwise, search for any OU matching "*Service*Account*"
			[array]$result = $(Get-ADOrganizationalUnit -Filter { name -like "*Service*Account*" }).DistinguishedName
		}
	}
	Catch
	{
		# If unable to find any service account OUs in the current Active Directory
		Write-Verbose "Can't locate the service account OU automaticly be name a standard aka: Privileged Account*, Service* or *Service*Account*"
		
		# Optionally, prompt the user or log the event here
		
		#Show-MsgBox -Prompt "Can't locate the service account OU automaticly be name a standard aka: Privileged Account*, Service* or *Service*Account*`r`n`r`nPlease select your OU for Service Accounts." -Title "Can't locate the service account OU automaticly" -Icon Exclamation -BoxType OKOnly
		#Write-Log -Level INFO -Message "Can't locate the service account OU automaticly be name a standard aka: Privileged Account*, Service* or *Service*Account*"
	}
	If ($result.count -gt "0")
	{
		# Return the first matching OU DN
		return $result[0]
	}
	else
	{
		# Return empty if no OU found
		return $result
	}
}

function ConvertFrom-DistinguishedName
{
    <#
    .SYNOPSIS
    Converts Active Directory Distinguished Names to different formats.
    
    .DESCRIPTION
    This function takes Active Directory Distinguished Names (DN) as input and converts them to various formats, including Organizational Units (OUs), Domain Controller (DC) format, or Domain Common Name (CN) format.
    
    .PARAMETER DistinguishedName
    Specifies an array of Distinguished Names (DNs) to be converted.
    
    .PARAMETER ToOrganizationalUnit
    When this switch is used, the function will convert the DN to the Organizational Unit (OU) format.
    
    .PARAMETER ToDC
    When this switch is used, the function will convert the DN to the Domain Controller (DC) format.
    
    .PARAMETER ToDomainCN
    When this switch is used, the function will convert the DN to the Domain Common Name (CN) format.
    #>
	[CmdletBinding()]
	param (
		[alias('Identity', 'DN')]
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
		[string[]]$DistinguishedName,
		[switch]$ToOrganizationalUnit,
		[switch]$ToDC,
		[switch]$ToDomainCN
	)
	process
	{
		foreach ($Distinguished in $DistinguishedName)
		{
			if ($ToDomainCN)
			{
				# Convert to Domain Common Name (CN) format, e.g. "domain.local"
				$DN = $Distinguished -replace '.*?((DC=[^=]+,)+DC=[^=]+)$', '$1'
				$CN = $DN -replace ',DC=', '.' -replace "DC="
				$CN
			}
			elseif ($ToOrganizationalUnit)
			{
				# Extract and convert to Organizational Unit (OU) format
				[Regex]::Match($Distinguished, '(?=OU=)(.*\n?)(?<=.)').Value
			}
			elseif ($ToDC)
			{
				# Convert to Domain Controller (DC) format, e.g. "DC=domain,DC=local"
				$Distinguished -replace '.*?((DC=[^=]+,)+DC=[^=]+)$', '$1'
			}
			else
			{
				# Default: Extract Common Name (CN) using regular expressions
				$Regex = '^CN=(?<cn>.+?)(?<!\\),(?<ou>(?:(?:OU|CN).+?(?<!\\),)+(?<dc>DC.+?))$'
				$Output = foreach ($_ in $Distinguished)
				{
					$_ -match $Regex
					$Matches
				}
				$Output.cn
			}
		}
	}
}

function Get-WindowsServerVersion
{
	<#
	.SYNOPSIS
	    Gets the Windows Server version based on Active Directory schema version.

	.DESCRIPTION
	    This function maps Active Directory schema version numbers to their corresponding 
	    Windows Server versions. The schema version is obtained from the objectVersion 
	    attribute in Active Directory and is updated with each major Windows Server release.

	.PARAMETER SchemaVersion
	    The Active Directory schema version number as a string. This corresponds to the 
	    objectVersion attribute found in the Active Directory schema.

	.OUTPUTS
	    String
	    Returns the corresponding Windows Server version name. If the schema version is 
	    not recognized, returns 'Windows Server N/A'.

	.EXAMPLE
	    Get-WindowsServerVersion -SchemaVersion "91"
	    Returns: "Windows Server 2025"

	.EXAMPLE
	    Get-WindowsServerVersion -SchemaVersion "88"
	    Returns: "Windows Server 2019/2022"

	.FUNCTIONALITY
    	Active Directory Schema Version Detection
	#>
	
	param ([string]$SchemaVersion)
	
	# Reference: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/find-active-directory-schema?tabs=gui#mapping-the-objectversion-attribute
	
	# Define a hashtable mapping Active Directory schema version numbers to Windows Server versions
	# The schema version corresponds to the objectVersion attribute in Active Directory
	# Each major Windows Server release updates the AD schema with a new version number
	$ServerVersions = @{
		'91' = 'Windows Server 2025' 		# Latest version as of 2025
		'88' = 'Windows Server 2019/2022' 	# Schema version 88 is shared between 2019 and 2022
		'87' = 'Windows Server 2016' 		# First version to support many modern AD features
		'69' = 'Windows Server 2012 R2' 	# Introduced significant AD improvements
		'56' = 'Windows Server 2012' 		# Major AD schema update from 2012
		'47' = 'Windows Server 2008 R2' 	# Enhanced AD features and PowerShell integration
		'44' = 'Windows Server 2008' 		# First version with significant schema changes
		'31' = 'Windows Server 2003 R2' 	# R2 release with additional features
		'30' = 'Windows Server 2003' 		# Legacy version, basic AD functionality
	}
	
	# Return the corresponding Windows Server version if the schema version exists in our hashtable
	# If the schema version is not found (unknown/unsupported version), return 'Windows Server N/A'
	# This handles cases where the AD schema might be from an unsupported or future version
	return $(if ($ServerVersions[$SchemaVersion]) { $ServerVersions[$SchemaVersion] }
		else { 'Windows Server N/A' })
}

function Show-DomainInfo
{
	Try
	{
		Write-Log -Level INFO -Message "Getting information to Domain Information Tab in MainForm..."
		Write-Log -Level INFO -Message "Counting domain users, computers etc..."
		
		#Get currect date for functions
		$date = Get-Date
		
		# Create a new DirectorySearcher object to search for the SYSVOL object
		$searchFRS = New-Object DirectoryServices.DirectorySearcher
		$searchFRS.Filter = "(&(objectClass=nTFRSSubscriber)(name=Domain System Volume (SYSVOL share)))"
		$searchFRS.SearchRoot = $dcObjectPath
		$Computers = (Get-ADComputer -Filter *).count
		$Workstations = (Get-ADComputer -LDAPFilter "(&(objectClass=Computer)(!operatingSystem=*server*))" -Searchbase (Get-ADDomain).distinguishedName).count
		$Servers = (Get-ADComputer -LDAPFilter "(&(objectClass=Computer)(operatingSystem=*server*))" -Searchbase (Get-ADDomain).distinguishedName).count
		#$Users = (get-aduser -filter *).count
		
		#$EnabledUsers = ($Users | Where-Object { $_.enabled -eq "True" }).count
		$Users = Get-ADuser -Filter * -Properties name, lastlogondate, enabled
		$UserCount = ($Users).count
		$eUsers = ($Users | Where-Object { $_.enabled -eq "True" }).count
		$DomainAdmins = (Get-ADGroup "Domain Admins" -Properties *).Member.Count
		$EnterpriseAdmins = (Get-ADGroup "Enterprise Admins" -Properties *).Member.Count
		$SchemaAdmins = (Get-ADGroup "Schema Admins" -Properties *).Member.Count
		$Groups = (Get-ADGroup -Filter *).Count
		$DomainControllers = 0
		
		#Get inactive user count
		$30Days = ($date).AddDays(-30)
		$60Days = ($date).AddDays(-60)
		$90Days = ($date).AddDays(-90)
		#Calculate
		$30 = ($users | Where-Object { $_.lastlogondate -lt $30Days -and $_.enabled }).count
		$60 = ($users | Where-Object { $_.lastlogondate -lt $60Days -and $_.enabled }).count
		$90 = ($users | Where-Object { $_.lastlogondate -lt $90Days -and $_.enabled }).count
		#Last 30 days
		if ($30 -gt 0) { $label_Information_label30DaysInactiveText.Text = $30 }
		else { $label_Information_label30DaysInactiveText.Text = 0 }
		#Last 60 days
		if ($60 -gt 0) { $label_Information_label60DaysInactiveText.Text = $60 }
		else { $label_Information_label60DaysInactiveText.Text = 0 }
		#Last 90 days
		if ($90 -gt 0) { $label_Information_label90DaysInactiveText.Text = $90 }
		else { $label_Information_label90DaysInactiveText.Text = 0 }
		
		#Get inactive computer count
		$30DaysC = New-TimeSpan -Days 30
		$60DaysC = New-TimeSpan -Days 60
		$90DaysC = New-TimeSpan -Days 90
		#Calculate
		$30C = (Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan $30DaysC | Where-Object { $_.Name -notlike "*AZUREADSSOACC*" } | Measure-Object).Count
		$60C = (Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan $60DaysC | Where-Object { $_.Name -notlike "*AZUREADSSOACC*" } | Measure-Object).Count
		$90C = (Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan $90DaysC | Where-Object { $_.Name -notlike "*AZUREADSSOACC*" } | Measure-Object).Count
		#Last 30 days
		if ($30C -gt 0) { $label_Information_label30DaysInactiveComputersText.Text = $30C }
		else { $label_Information_label30DaysInactiveComputersText.Text = 0 }
		#Last 60 days
		if ($60C -gt 0) { $label_Information_label60DaysInactiveComputersText.Text = $60C }
		else { $label_Information_label60DaysInactiveComputersText.Text = 0 }
		#Last 90 days
		if ($90C -gt 0) { $label_Information_label90DaysInactiveComputersText.Text = $90C }
		else { $label_Information_label90DaysInactiveComputersText.Text = 0 }
		
		#Get Tombstone Lifetime
		$rDSE = Get-ADRootDSE
		$ts = (Get-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,$(($rDSE).configurationNamingContext)" -Properties tombstoneLifetime).tombstoneLifetime
		$label_Information_LableTombstoneLifetimeText.Text = $ts
		
		#Get when AD is created
		$dAge = Get-ADObject ($rDSE).rootDomainNamingContext -Property whencreated
		$label_Information_DomainAgeText.Text = $dAge.whencreated
		
		#Get Domain Controller numers
		$tDomainControllers = 0
		(Get-ADForest).Domains | ForEach-Object {
			$tDomainControllers += (Get-ADDomain -Identity $_ | Select-Object -ExpandProperty ReplicaDirectoryServers).Count
		}
		$DomainControllers = $tDomainControllers
		
		#Fix text if null
		if ([string]::IsNullOrEmpty($Computers))
		{
			$Computers = "0"
		}
		if ([string]::IsNullOrEmpty($Workstations))
		{
			$Workstations = "0"
		}
		if ([string]::IsNullOrEmpty($Servers))
		{
			$Servers = "0"
		}
		if ([string]::IsNullOrEmpty($Users))
		{
			$Users = "0"
		}
		if ([string]::IsNullOrEmpty($eUsers))
		{
			$eUsers = "0"
		}
		if ([string]::IsNullOrEmpty($Groups))
		{
			$Groups = "0"
		}
		if ([string]::IsNullOrEmpty($DomainAdmins))
		{
			$DomainAdmins = "0"
		}
		if ([string]::IsNullOrEmpty($EnterpriseAdmins))
		{
			$EnterpriseAdmins = "0"
		}
		if ([string]::IsNullOrEmpty($SchemaAdmins))
		{
			$SchemaAdmins = "0"
		}
		
		Write-Log -Level INFO -Message "Counting domain users, computers etc... DONE"
		
		#$domain = Get-ADDomain | Select-Object Forest
		Write-Log -Level INFO -Message "Getting Domain information like name, Forest Mode and version..."
		$domain = $env:USERDNSDOMAIN
		$ADForest = (Get-ADForest).ForestMode
		$ADDomain = (Get-ADDomain).DomainMode
		$ADVer = Get-ADObject (Get-ADRootDSE).schemaNamingContext -property objectVersion | Select-Object objectVersion
		$ADNUM = $ADVer -replace "@{objectVersion=", "" -replace "}", ""		
		$srv = Get-WindowsServerVersion -SchemaVersion $ADNum
		
		# Check whether SYSVOL is using FRS or DFSR
		if ($searchFRS.FindAll().Count -eq '0')
		{
			$label_Information_FRSorDFSRText.Text = "DFRS"
		}
		else
		{
			$label_Information_FRSorDFSRText.Text = "FRS"
		}
		
		# Find UPN suffixes
		if ((Get-ADForest).UPNSuffixes)
		{
			$label_Information_UPNSuffixesText.Text = (Get-ADForest).UPNSuffixes -join ", "
		}
		else
		{
			$label_Information_UPNSuffixesText.Text = "None"
		}
		
		# Find Trusts
		if (Get-ADTrust -Filter *)
		{
			$label_Information_TrustsText.Text = (Get-ADTrust -Filter *).Name -join ", "
		}
		else
		{
			$label_Information_TrustsText.Text = "None"
		}
		
		Write-Log -Level INFO -Message "Getting Domain information like name, Forest Mode and version... DONE"
		
		#Active Directory Recycle Bin
		Write-Log -Level INFO -Message "Getting Active Directory Recykle Bin status..."
		If (Test-ADRecycleBin)
		{
			$label_Information_RecycleBinText.Text = "Enabled"
		}
		else
		{
			$label_Information_RecycleBinText.Text = "Disabled"
			$label_Information_RecycleBinText.ForeColor = 'Red'
		}
		Write-Log -Level INFO -Message "Getting Active Directory Recykle Bin status... DONE"
		
		#FIMO Roles
		Write-Log -Level INFO -Message "Getting FSMO roles on servers..."
		$ServerDomainNamingMaster = (Get-ADDomainController -Filter { OperationMasterRoles -like 'DomainNamingMaster' } | Select-Object -ExpandProperty name)
		$ServerSchemaMasterMaster = (Get-ADDomainController -Filter { OperationMasterRoles -like 'SchemaMaster' } | Select-Object -ExpandProperty name)
		$ServerRIDMaster = (Get-ADDomainController -Filter { OperationMasterRoles -like 'RIDMaster' } | Select-Object -ExpandProperty name)
		$ServerPDCEmulator = (Get-ADDomainController -Filter { OperationMasterRoles -like 'PDCEmulator' } | Select-Object -ExpandProperty name)
		$ServerInfrastructureMaster = (Get-ADDomainController -Filter { OperationMasterRoles -like 'InfrastructureMaster' } | Select-Object -ExpandProperty name)
		Write-Log -Level INFO -Message "Getting FSMO roles on servers... DONE"
		Write-Log -Level INFO -Message "Setting data in GUI there was found for FSMO Roles..."
		$label_Information_DomainNamingMasterText.Text = $ServerDomainNamingMaster
		$label_Information_SchemaMasterText.Text = $ServerSchemaMasterMaster
		$label_Information_RIDMasterText.Text = $ServerRIDMaster
		$label_Information_PDCEmulatorText.Text = $ServerPDCEmulator
		$label_Information_InfrastructureMasterText.Text = $ServerInfrastructureMaster
		Write-Log -Level INFO -Message "Setting data in GUI there was found for FSMO Roles... DONE"
		
		Write-Log -Level INFO -Message "Setting data in GUI there was found..."
		$label_Information_DCsNumbers.Text = $DomainControllers
		$label_Information_ComputersNumbers.Text = $Computers
		$label_Information_WorkstationsNumbers.Text = $Workstations
		$label_Information_ServersNumbers.Text = $Servers
		$label_Information_UsersNumbers.Text = $UserCount #$Users
		$label_Information_EnabledUsersNumbers.Text = $eUsers
		$label_Information_GroupsNumbers.Text = $Groups
		$label_Information_DomainAdminsNumbers.Text = $DomainAdmins
		$label_Information_EnterpriseAdminsNumbers.Text = $EnterpriseAdmins
		$label_Information_SchemaAdminUsersNumbers.Text = $SchemaAdmins
		$label_Information_DomainNameText.Text = $domain
		$label_Information_ForestModeText.Text = $ADForest
		$label_Information_DomainModeText.Text = $ADDomain
		$label_Information_SchemaVersionText.Text = "$ADNum which corresponds to $Srv"
		
		Write-Log -Level INFO -Message "Getting Domain information like Azure AD Connect server(s) and Exchange Servers..."
		# Find out if an Azure AD Connect exits in domain
		try
		{
			if (Get-ADUser -LDAPFilter "(description=*configured to synchronize to tenant*)" -Properties description | ForEach-Object { $_.description.SubString(142, $_.description.IndexOf(" ", 142) - 142) })
			{
				$label_Information_AzureADConnectText.Text = Get-ADUser -LDAPFilter "(description=*configured to synchronize to tenant*)" -Properties description | ForEach-Object { $_.description.SubString(142, $_.description.IndexOf(" ", 142) - 142) -join ", " }
			}
			else
			{
				$label_Information_AzureADConnectText.Text = "None"
			}
		}
		# Catch specific types of exceptions thrown by one of those commands
		catch [System.Exception]
		{
			$label_Information_AzureADConnectText.Text = "None"
			Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
		}
		# Catch all other exceptions thrown by one of those commands
		catch
		{
			$label_Information_AzureADConnectText.Text = "None"
		}
		
		# Find Exchange Servers if any
		if (Get-ADGroup -Filter { SamAccountName -eq "Exchange Servers" })
		{
			$label_Information_ExchangeServersText.Text = (Get-ADGroupMember -Identity "Exchange Servers" | Where-Object ObjectClass -eq 'Computer').Name -join ", "
		}
		else
		{
			$label_Information_ExchangeServersText.Text = "None"
		}
		Write-Log -Level INFO -Message "Getting Domain information like Azure AD Connect server(s) and Exchange Servers... DONE"
		
		Write-Log -Level INFO -Message "Getting Domain information - disabled accounts..."
		
		# Count disabled accounts
		$disabledaccounts = Search-ADaccount -AccountDisabled -UsersOnly
		$count = 0
		$totalcount = ($disabledaccounts | Measure-Object | Select-Object Count).count
		foreach ($account in $disabledaccounts)
		{
			if ($totalcount -eq 0) { break }
			$count++
		}
		$label_Information_DisabledUsersNumbers.Text = $count
		
		Write-Log -Level INFO -Message "Getting Domain information - disabled accounts... DONE"
		
		Write-Log -Level INFO -Message "Getting Domain information - locked accounts..."
		
		# Count locked accounts
		$lockedAccounts = Get-ADUser -Filter * -Properties LockedOut | Where-Object { $_.LockedOut -eq $true }
		$count = 0
		$totalcount = ($lockedAccounts | Measure-Object | Select-Object Count).Count
		foreach ($account in $lockedAccounts)
		{
			if ($totalcount -eq 0) { break }
			$count++
		}
		$label_Information_LockedUsersNumbers.Text = $count
		
		Write-Log -Level INFO -Message "Getting Domain information - locked accounts..."
		
		Write-Log -Level INFO -Message "Getting Domain information - accounts who's passwords dont expire..."
		
		# Count accounts who's passwords dont expire
		$count = 0
		$nonexpiringpasswords = Search-ADAccount -PasswordNeverExpires -UsersOnly | Where-Object { $_.Enabled -eq $true }
		$totalcount = ($nonexpiringpasswords | Measure-Object | Select-Object Count).count
		foreach ($account in $nonexpiringpasswords)
		{
			if ($totalcount -eq 0) { break }
			$count++
		}
		$label_Information_NeverExpirePasswordUsersNumbers.Text = $count
		
		Write-Log -Level INFO -Message "Getting Domain information - accounts who's passwords dont expire... DONE"
		
		Write-Log -Level INFO -Message "Setting data in GUI there was found... DONE"
		
		Write-Log -Level INFO -Message "Getting information to Domain Information Tab in MainForm... DONE"
		
		#Enable export after got information
		$exportDataToolStripMenuItem.Enabled = $true
	}
	Catch
	{
		#If error, log it
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
		
		#Keep export after got information disabled as error
		$exportDataToolStripMenuItem.Enabled = $false
	}
}

# NOT IN USE FOR NOW
# Function to get stale AD user objects
Function Get-StaleADUsers
{
	param (
		[int]$Days
	)
	
	$staleUsers = Get-ADUser -Filter * -Properties SamAccountName, Enabled, LastLogonDate |
	Where-Object { $_.Enabled -and $_.LastLogonDate -lt (Get-Date).AddDays(-$Days) }
	
	return $staleUsers
}

# Function to get stale AD computer objects
Function Get-StaleADComputers
{
	param (
		[int]$Days
	)
	
	$staleComputers = Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan (New-TimeSpan -Days $Days) |
	Where-Object { $_.Name -notlike "*AZUREADSSOACC*" }
	
	return $staleComputers
}
# NOT IN USE FOR NOW