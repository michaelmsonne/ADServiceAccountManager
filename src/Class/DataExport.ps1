function Export-DomainInfo
{
	# Create custom objects to represent the data
	$ADInfo = New-Object PSObject -Property @{
		"Domain Controllers"			   = $label_Information_DCsNumbers.Text
		"Total Computers"				   = $label_Information_ComputersNumbers.Text
		"Workstations"					   = $label_Information_WorkstationsNumbers.Text
		"Servers"						   = $label_Information_ServersNumbers.Text
		"Total Users"					   = $label_Information_UsersNumbers.Text
		"Enabled Users"				       = $label_Information_EnabledUsersNumbers.Text
		"Disabled Users"				   = $label_Information_DisabledUsersNumbers.Text
		"Locked Users"					   = $label_Information_LockedUsersNumbers.Text
		"Users whos passwords dont expire" = $label_Information_NeverExpirePasswordUsersNumbers.Text
		"Groups"						   = $label_Information_GroupsNumbers.Text
		"Domain Admins"				       = $label_Information_DomainAdminsNumbers.Text
		"Enterprise Admins"			       = $label_Information_EnterpriseAdminsNumbers.Text
		"Schema Admins"				       = $label_Information_SchemaAdminUsersNumbers.Text
		"Domain Name"					   = $label_Information_DomainNameText.Text
		"Forest Mode"					   = $label_Information_TrustsText.Text
		"Domain Mode"					   = $label_Information_DomainModeText.Text
		"Schema Version"				   = $label_Information_SchemaVersionText.Text
		"SYSVOL Replication"			   = $label_Information_FRSorDFSRText.Text
		"UPN Suffixes"					   = $label_Information_UPNSuffixesText.Text
		"Trusts"						   = $label_Information_TrustsText.Text
		"AD Recycle Bin"				   = $label_Information_RecycleBinText.Text
		"Tombstone Lifetime"			   = $label_Information_LableTombstoneLifetimeText.Text
		"Domain Age"					   = $label_Information_DomainAgeText.Text
		"Azure AD Connect"				   = $label_Information_AzureADConnectText.Text
		"Exchange Servers"				   = $label_Information_ExchangeServersText.Text
		"Last 30 Days Inactive Users"	   = $label_Information_label30DaysInactiveText.Text
		"Last 60 Days Inactive Users"	   = $label_Information_label60DaysInactiveText.Text
		"Last 90 Days Inactive Users"	   = $label_Information_label90DaysInactiveText.Text
		"Last 30 Days Inactive Computers"  = $label_Information_label30DaysInactiveComputersText.Text
		"Last 60 Days Inactive Computers"  = $label_Information_label60DaysInactiveComputersText.Text
		"Last 90 Days Inactive Computers"  = $label_Information_label90DaysInactiveComputersText.Text
	}
	
	# Try export to file
	try
	{
		# Export the data to a CSV file		
		# Get the current timestamp
		$timestamp = Get-Date -Format "dd-MM-yyyy-HHmmss"
		
		# Construct the CSV filename with the Domain Name and Timestamp
		$csvFileName = ".\ADInfo_$($label_Information_DomainNameText.Text)_$timestamp.csv"
		
		# Export the data to the CSV file
		$ADInfo | Export-Csv -Path $csvFileName -NoTypeInformation
	}
	# Catch specific types of exceptions thrown by one of those commands
	catch [System.Exception]
	{
		Show-MsgBox -Prompt "Error exporting AD data to .csv. Exception: " + $_.Exception.Message -Title "Error" -Icon Exclamation -BoxType OKOnly
	}
	# Catch all other exceptions thrown by one of those commands
	catch
	{
	}
}

function Export-StateUserObjectsInfo
{
	# Export stale user objects to .csv file
	
	# Get the current timestamp
	$timestamp = Get-Date -Format "dd-MM-yyyy-HHmmss"
	# Set the number of days since last logon
	$DaysInactive = 90
	$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
	
	# Try export to file
	try
	{
		# Users
		# Automated way (includes never logged on users)
		$Users = Search-ADAccount -AccountInactive -DateTime $InactiveDate -UsersOnly | ForEach-Object {
			if ($_.Name -ne "Guest" -and $_.Name -ne "krbtgt")
			{
				$lastLogon = If ($_ -and $_.LastLogonDate) { $_.LastLogonDate }
				else { "Never" }
				[PSCustomObject]@{
					Username		  = $_.SamAccountName
					Name			  = $_.Name
					LastLogonDate	  = $lastLogon
					DistinguishedName = $_.DistinguishedName
				}
			}
		}
		
		# Construct the CSV filename with the Domain Name and Timestamp
		$csvFileNameStaleUserData = ".\StaleUserData_$($DaysInactive)days_$($label_Information_DomainNameText.Text)_$timestamp.csv"
		
		# Export the data to the CSV file
		$Users | Export-Csv -Path $csvFileNameStaleUserData -NoTypeInformation
	}
	# Catch specific types of exceptions thrown by one of those commands
	catch [System.Exception] {
		Show-MsgBox -Prompt "Error exporting stale user data to .csv. Exception: " + $_.Exception.Message -Title "Error" -Icon Exclamation -BoxType OKOnly
	}
	# Catch all other exceptions thrown by one of those commands
	catch
	{
	}
}

function Export-StateComputerObjectsInfo
{
	# Export stale computer objects to .csv file
	
	# Get the current timestamp
	$timestamp = Get-Date -Format "dd-MM-yyyy-HHmmss"
	# Set the number of days since last logon
	$DaysInactive = 90
	$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
	
	# Try export to file
	try
	{
		# Computers
		# Automated way (includes never logged on computers)
		$Computers = Search-ADAccount -AccountInactive -DateTime $InactiveDate -ComputersOnly | ForEach-Object {
			$lastLogon = If ($_ -and $_.LastLogonDate) { $_.LastLogonDate }
			else { "Never" }
			[PSCustomObject]@{
				Name			  = $_.Name
				LastLogonDate	  = $lastLogon
				Enabled		      = $_.Enabled
				DistinguishedName = $_.DistinguishedName
			}
		}
		
		# Construct the CSV filename with the Domain Name and Timestamp
		$csvFileNameStaleComputerData = ".\StaleComputerData_$($DaysInactive)days_$($label_Information_DomainNameText.Text)_$timestamp.csv"
		
		# Export the data to the CSV file
		$Computers | Export-Csv -Path $csvFileNameStaleComputerData -NoTypeInformation
	}
	# Catch specific types of exceptions thrown by one of those commands
	catch [System.Exception] {
		Show-MsgBox -Prompt "Error exporting stale computer data to .csv. Exception: " + $_.Exception.Message -Title "Error" -Icon Exclamation -BoxType OKOnly
	}
	# Catch all other exceptions thrown by one of those commands
	catch
	{
	}
}