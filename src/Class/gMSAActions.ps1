function Add-SPNtoGMSA
{
<#
	.SYNOPSIS
		Add ServicePrincipalName to a gMSA account.
	
	.DESCRIPTION
		Add a ServicePrincipalName to the selected gMSA account, then validate it is added correct.
	
	.PARAMETER ServicePrincipalName
		The ServicePrincipalName to add to gMSA account.
	
	.PARAMETER gMSA
		gMSA to add ServicePrincipalName to.
	
	.EXAMPLE
		PS C:\> Add-SPNtoGMSA -ServicePrincipalName 'value1' -gMSA 'gMSA1'
	
	.NOTES
		Additional information about the function.
#>
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$ServicePrincipalName,
		[Parameter(Mandatory = $true)]
		[string]$gMSA
	)
	
	Try
	{
		If ($ServicePrincipalName -ne "")
		{
			If ($(Get-ADServiceAccount -Identity $gMSA -Properties ServicePrincipalNames | Select-Object ServicePrincipalNames).ServicePrincipalNames -contains "$ServicePrincipalName")
			{
				Show-MsgBox -Prompt "[$ServicePrincipalName] is already added to gMSA [$gMSA]" -Title "Already added" -Icon Information -BoxType OKOnly -DefaultButton '1'
				Write-Log -Level INFO -Message "[$ServicePrincipalName] is already added to gMSA [$gMSA]"
			}
			Else
			{
				# TRY TO APPLY CHANGE
				Set-ADServiceAccount -Identity $gMSA -ServicePrincipalNames @{ add = "$ServicePrincipalName" }
				
				#Check if done
				If ($(Get-ADServiceAccount -Identity $gMSA -Properties ServicePrincipalNames | Select-Object ServicePrincipalNames).ServicePrincipalNames -contains "$ServicePrincipalName")
				{
					#If success
					return $true
					Show-MsgBox -Prompt "Successful added [$ServicePrincipalName] to gMSA [$gMSA]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level INFO -Message "Successful added [$ServicePrincipalName] to gMSA [$gMSA]"
				}
				Else
				{
					#If not success
					Show-MsgBox -Prompt "Failed adding [$ServicePrincipalName] to gMSA [$gMSA]" -Title "Failure" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level ERROR -Message "Failed adding [$ServicePrincipalName] to gMSA [$gMSA]"
				}
			}
		}
		else
		{
			#Get input form user if not entered that - cant get job done without - try again
			Show-MsgBox -Prompt "Please enter a SPN" -Title "Failure" -Icon Information -BoxType OKOnly -DefaultButton '1'
		}
	}
	Catch
	{
		#If error show it to the user
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
	}
}

function Remove-SPNfromGMSA
{
<#
	.SYNOPSIS
		Remove ServicePrincipalName from a gMSA account.
	
	.DESCRIPTION
		Remove a ServicePrincipalName from the selected gMSA account, then validate it is removed correct.
	
	.PARAMETER ServicePrincipalName
		The ServicePrincipalName to remove from the gMSA account.
	
	.PARAMETER gMSA
		gMSA to remove ServicePrincipalName from.
	
	.EXAMPLE
		PS C:\> Remove-SPNfromGMSA -ServicePrincipalName 'value1' -gMSA 'gMSA1'
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$ServicePrincipalName,
		[Parameter(Mandatory = $true)]
		[string]$gMSA
	)
	
	Try
	{
		If ($ServicePrincipalName -ne "")
		{
			If (!($(Get-ADServiceAccount -Identity $gMSA -Properties ServicePrincipalNames | Select-Object ServicePrincipalNames).ServicePrincipalNames -contains "$ServicePrincipalName"))
			{
				Show-MsgBox -Prompt "[$ServicePrincipalName] was not found added to gMSA [$gMSA]" -Title "Not found" -Icon Information -BoxType OKOnly -DefaultButton '1'
				Write-Log -Level INFO -Message "[$ServicePrincipalName] was not found added to gMSA [$gMSA]"
			}
			Else
			{
				$Confirmation = Show-MsgBox -Prompt "Remove [$ServicePrincipalName] from gMSA [$gMSA]`?" -Title "Remove SPN?" -Icon Question -BoxType "YesNo" -DefaultButton '2'
				If ($Confirmation -eq "YES")
				{
					# TRY TO APPLY CHANGE
					Set-ADServiceAccount -Identity $gMSA -ServicePrincipalNames @{ remove = "$ServicePrincipalName" }
					
					#Check if done
					If ($(Get-ADServiceAccount -Identity $gMSA -Properties ServicePrincipalNames | Select-Object ServicePrincipalNames).ServicePrincipalNames -contains "$ServicePrincipalName")
					{
						#If not a success
						Show-MsgBox -Prompt "Failed to remove [$ServicePrincipalName] from gMSA [$gMSA]" -Title "Failure" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
						Write-Log -Level ERROR -Message "Failed to remove [$ServicePrincipalName] from [$gMSA]"
					}
					else
					{
						#If success
						Show-MsgBox -Prompt "Successful removed [$ServicePrincipalName] from gMSA [$gMSA]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
						Write-Log -Level INFO -Message "Successful removed [$ServicePrincipalName] from gMSA [$gMSA]"
					}
				}
			}
		}
	}
	Catch
	{
		#Show error to user
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

function Remove-GMSAfromGroup
{
<#
	.SYNOPSIS
		Remove gMSA account from a group.
	
	.DESCRIPTION
		Remove the selected gMSA account from the selected group.
	
	.PARAMETER gMSA
		The gMSA account to remove from a group.
	
	.PARAMETER Group
		The group to remove the gMSA account from.
	
	.EXAMPLE
		PS C:\> Remove-GMSAfromGroup -gMSA 'gMSA1' -Group 'value2'
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$gMSA,
		[Parameter(Mandatory = $true)]
		[string]$Group
	)
	
	Try
	{
		If ($Group -ne "")
		{
			$Confirmation = Show-MsgBox -Prompt "Remove gMSA [$gMSA] from group [$Group]?" -Title "Remove gMSA from group?" -Icon Question -BoxType "YesNo" -DefaultButton '2'
			If ($Confirmation -eq "YES")
			{
				Write-Log -Level INFO -Message "Trying to remove gMSA [$gMSA] from group [$Group] - confirmed by user"
				# TRY TO REMOVE FROM GROUP
				Remove-ADGroupMember -Identity $Group -Members $gMSA -Confirm:$false
				
				# CHECK IF REMOVED FROM GROUP OR NOT
				$gMsaAcctObj = Get-ADServiceAccount $gMSA
				$members = Get-ADGroupMember -Identity $Group -Recursive | Select-Object -ExpandProperty SID
				If ($members -contains $gMsaAcctObj.SID.Value)
				{
					#If not a success
					Show-MsgBox -Prompt "Failed to remove gMSA [$gMSA] from group [$Group]" -Title "Failure" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level ERROR -Message "Failed to remove gMSA [$gMSA] from group [$Group]"
				}
				Else
				{
					#If a success
					Show-MsgBox -Prompt "Successful removed gMSA [$gMSA] from group [$Group]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level INFO -Message "Successful removed gMSA [$gMSA] from group [$Group]"
				}
			}
		}
	}
	Catch
	{
		#Show error to user
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

function Add-PrincipalsAllowedToRetrievePassword
{
<#
	.SYNOPSIS
		Add Principals Allowed To Retrieve Password to a gMSA account.
	
	.DESCRIPTION
		Add Principals Allowed To Retrieve Password to a gMSA account then validate if was added.
	
	.PARAMETER gMSA
		The gMSA to add Principals Allowed To Retrieve Password to.
	
	.PARAMETER PrincipalToAdd
		The device/group allowed to To Retrieve Password for the gMSA account.
	
	.EXAMPLE
		PS C:\> Add-PrincipalsAllowedToRetrievePassword -gMSA 'gMSA1' -PrincipalToAdd 'Computer2'
	
	.NOTES
		Additional information about the function.
#>
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$gMSA,
		[Parameter(Mandatory = $true)]
		[string]$PrincipalToAdd
	)
	
	Try
	{
		If ($PrincipalToAdd -ne "")
		{
			# GET THE DISTINGUISHED NAME OF THE SELECTED PRINCIPAL
			$SelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToAdd) -and ((ObjectClass -eq "User") -or (ObjectClass -eq "Group")) }).DistinguishedName
			
			# CHECK IF ADDED TO GMSA ALREADY
			If ($(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword -contains $SelectedPrinicipalName)
			{
				#Show user if already added to selected gMSA
				Show-MsgBox -Prompt "[$PrincipalToAdd] is already added to gMSA [$gMSA]" -Title "Already added" -Icon Information -BoxType OKOnly -DefaultButton '1'
				Write-Log -Level INFO -Message "[$PrincipalToAdd] is already added to gMSA [$gMSA]"
			}
			Else
			{
				#If not already added to selected gMSA
				Write-Log -Level INFO -Message "Trying to add [$PrincipalToAdd] to gMSA [$gMSA] - confirmed by user"
				
				# IF NOT ADDED TO GMSA ALREADY ADD IT
				$CumulativePrincipals = $(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword
				$CumulativePrincipals += (Get-ADObject -filter { (Name -eq $PrincipalToAdd) -and ((ObjectClass -eq "User") -or (ObjectClass -eq "Group")) }).DistinguishedName
				Set-ADServiceAccount -Identity $gMSA -PrincipalsAllowedToRetrieveManagedPassword $CumulativePrincipals
				
				# GET THE DISTINGUISHED NAME OF THE SELECTED PRINCIPAL
				$SelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToAdd) -and ((ObjectClass -eq "User") -or (ObjectClass -eq "Group")) }).DistinguishedName
				
				# CHECK IF ADDED TO GMSA
				If ($(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword -contains $SelectedPrinicipalName)
				{
					#If success
					Show-MsgBox -Prompt "Successfully added [$PrincipalToAdd] to gMSA [$gMSA]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level INFO -Message "Successfully added [$PrincipalToAdd] to gMSA [$gMSA]"
				}
				else
				{
					#If not success
					Show-MsgBox -Prompt "Failed adding [$PrincipalToAdd] to gMSA [$gMSA]" -Title "Error" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level ERROR -Message "Failed adding [$PrincipalToAdd] to gMSA [$gMSA]"
				}
				
				# SEE IF $PrincipalToAdd IS A COMPUTER
				$ComputerSelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToAdd) -and (ObjectClass -eq "Computer") }).DistinguishedName
				if ($ComputerSelectedPrinicipalName)
				{
					# ASK IF THE USER WILL INSTALL THE GMSA TO THE SERVER ADDED ALLOWED TO RETRIEVE PASSWORD
					$ConfirmInstallOnServerForGMSA = Show-MsgBox -Prompt "Will you install the gMSA [$SelectedGMSA] on server [$SelectedADObject] now you had added it the the gMSA [$SelectedGMSA]?`r`n`r`nThis will use the current user (make sure you have the right permissions before) and firewall rules allow it" -Title "Install gMSA $SelectedGMSA on server $SelectedADObject?" -Icon Question -BoxType YesNo -DefaultButton 1
					# IF YES
					If ($ConfirmInstallOnServerForGMSA -eq "Yes")
					{
						Try
						{
							# MODIFY THE GMSA PROPERTIES
							Write-Log -Level INFO -Message "User pressed on button to Install gMSA [$SelectedGMSA] on the Server [$SelectedADObject] - confirmed by user"
							
							# Install gMSA on the Server
							Invoke-Command -ComputerName $SelectedADObject -ScriptBlock { Add-WindowsFeature RSAT-AD-Powershell; Import-Module ActiveDirectory; Install-ADServiceAccount $SelectedGMSA };
							
							Write-Log -Level INFO -Message "Successfully installed gMSA [$SelectedGMSA] on the Server [$SelectedADObject]"
							Show-MsgBox -Prompt "Successfully installed gMSA [$SelectedGMSA] on the Server [$SelectedADObject]`r`n`r`nYou can test it if you run this on the server $SelectedADObject `r`n`r`nCommand: Test-ADServiceAccount -Identity $SelectedGMSA" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
						}
						Catch
						{
							Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
							Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
						}
					}
					# IF NO
					else
					{
						Show-MsgBox -Prompt "Installation for gMSA [$SelectedGMSA] on Server [$SelectedADObject] canceled by user, aborting installation on server" -Title "Aborting install" -Icon Information -BoxType OKOnly
						Write-Log -Level INFO -Message "Installation for gMSA [$SelectedGMSA] on Server [$SelectedADObject] canceled by user, aborting installation on server"
					}
				}
			}
		}
		else
		{
			#If no input from user - try again
			Show-MsgBox -Prompt "Please enter a Principal To Add" -Title "Failure" -Icon Information -BoxType OKOnly -DefaultButton '1'
		}
	}
	Catch
	{
		#Show info to user if error
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

function Remove-PrincipalsAllowedToRetrievePassword
{
<#
	.SYNOPSIS
		Remove Principals Allowed To Retrieve Password for a gMSA account.
	
	.DESCRIPTION
		Remove Principals Allowed To Retrieve Password for a gMSA account then validate if was removed.
	
	.PARAMETER gMSA
		The gMSA to remove Principals Allowed To Retrieve Password for.
	
	.PARAMETER PrincipalToAdd
		The device/group removed to To Retrieve Password for the gMSA account.
	
	.EXAMPLE
		PS C:\> Remove-PrincipalsAllowedToRetrievePassword -gMSA 'gMSA1' -PrincipalToRemove 'Computer2'
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$gMSA,
		[Parameter(Mandatory = $true)]
		[string]$PrincipalToRemove
	)
	Try
	{
		# REMOVE PRINCIPALS ALLOWED TO RETRIEVE MANAGED PASSWORD		
		If ($PrincipalToRemove -ne "")
		{
			$Confirmation = Show-MsgBox -Prompt "Remove [$PrincipalToRemove] from gMSA [$gMSA]?" -Title "Remove Principal Allowed to Retrieve Password?" -Icon Question -BoxType "YesNo" -DefaultButton '2'
			
			If ($Confirmation -eq "YES")
			{
				$ConfirmationCheckIfUsed = Show-MsgBox -Prompt "Before you remove [$PrincipalToRemove] from gMSA [$gMSA], will you check if a service is using it on $PrincipalToRemove (Recommended)?" -Title "Remove Principal Allowed to Retrieve Password - Check if used?" -Icon Question -BoxType "YesNo" -DefaultButton '1'
				
				If ($ConfirmationCheckIfUsed -eq "YES")
				{
					$services = $null;
					$services = Get-WmiObject win32_service -computer $PrincipalToRemove -ErrorAction SilentlyContinue | Where-Object { ($_.startname -like "*$gMSA*") };
					if ($null -ne $services)
					{
						foreach ($service in $services)
						{
							$MessageServiceUsingText = $service.caption;
							Show-MsgBox -Prompt "Service(s) on $PrincipalToRemove there is using gMSA [$gMSA] is: $MessageServiceUsingText `n`nPlese check this service before remove $PrincipalToRemove from gMSA [$gMSA]" -Title "Remove Principal Allowed to Retrieve Password - Used in Services" -Icon Exclamation -BoxType "OKOnly" -DefaultButton '1'
						}
					}
					# Invoke-Command -ComputerName $SelectedADObject -ScriptBlock { Add-WindowsFeature RSAT-AD-Powershell; Import-Module ActiveDirectory; Install-ADServiceAccount $SelectedGMSA };
					# Invoke-Command -ComputerName pc1 -scriptblock {Get-Service} 
					
					else
					{
						$ConfirmationNotUsed = Show-MsgBox -Prompt "[$PrincipalToRemove] is not using gMSA [$gMSA] (For services), will you still remove the account on $PrincipalToRemove from the gMSA [$gMSA]?" -Title "Remove Principal Allowed to Retrieve Password - Confirm - Not used in Services" -Icon Question -BoxType "YesNo" -DefaultButton '1'
						
						If ($ConfirmationNotUsed -eq "YES")
						{
							## SYNC WITH: If ($ConfirmationNotUsed -eq "YES") ##
							Write-Log -Level INFO -Message "Trying to remove [$PrincipalToAdd] from gMSA [$gMSA] - confirmed by user"
							
							# GET THE CURRENT PRINCIPALS ALLOWED TO RETRIEVE MANAGED PASSWORD
							$CurrentPrincipalName = $(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword
							
							# GET THE DISTINGUISHED NAME OF THE SELECTED PRINCIPAL
							$SelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToRemove) -and ((ObjectClass -eq "User") -or (ObjectClass -eq "Group")) }).DistinguishedName
							
							# GET ONLY CURRENT PRINCIPALS THAT DO NOT MATCH THE SELECTED PRINCIPAL
							$DesiredPrincipals = $CurrentPrincipalName -ne $SelectedPrinicipalName
							
							# APPLY ONLY THE REMOANING PRINCIPALS
							Set-ADServiceAccount -Identity $gMSA -PrincipalsAllowedToRetrieveManagedPassword $DesiredPrincipals
							
							# CHECK IF REMOVED FROM GMSA
							If ($(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword -notcontains $SelectedPrinicipalName)
							{
								Show-MsgBox -Prompt "Successfully removed [$PrincipalToRemove] from gMSA [$gMSA]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
								Write-Log -Level INFO -Message "Successfully removed [$PrincipalToRemove] from gMSA [$gMSA]"
							}
							else
							{
								Show-MsgBox -Prompt "Failed to removed [$PrincipalToRemove] from gMSA [$gMSA]" -Title "Error" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
								Write-Log -Level ERROR -Message "Failed to removed [$PrincipalToRemove] from gMSA [$gMSA]"
							}
							
							# SEE IF $PrincipalToRemove IS A COMPUTER
							$ComputerSelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToRemove) -and (ObjectClass -eq "Computer") }).DistinguishedName
							if ($ComputerSelectedPrinicipalName)
							{
								# ASK IF THE USER WILL UNINSTALL THE GMSA FROM THE SERVER ADDED ALLOWED TO RETRIEVE PASSWORD
								$ConfirmUnInstallOnServerForGMSA = Show-MsgBox -Prompt "Will you uninstall the gMSA [$gMSA] on server [$PrincipalToRemove] now you had removed it the the gMSA [$gMSA]?`r`n`r`nThis will use the current user (make sure you have the right permissions before) and firewall rules allow it" -Title "Uninstall gMSA $SelectedGMSA from server $PrincipalToRemove?" -Icon Question -BoxType YesNo -DefaultButton 1
								# IF YES
								If ($ConfirmUnInstallOnServerForGMSA -eq "Yes")
								{
									Try
									{
										# MODIFY THE GMSA PROPERTIES
										Write-Log -Level INFO -Message "User pressed on button to uninstall gMSA [$gMSA] on the Server [$PrincipalToRemove] - confirmed by user"
										
										# Install gMSA on the Server
										Invoke-Command -ComputerName $PrincipalToRemove -ScriptBlock { Add-WindowsFeature RSAT-AD-Powershell; Import-Module ActiveDirectory; Uninstall-ADServiceAccount $gMSA };
										
										Write-Log -Level INFO -Message "Successfully uninstalled gMSA [$gMSA] on the Server [$PrincipalToRemove]"
										Show-MsgBox -Prompt "Successfully uninstalled gMSA [$gMSA] on the Server [$PrincipalToRemove]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
									}
									Catch
									{
										Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
										Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
									}
								}
								# IF NO
								else
								{
									Show-MsgBox -Prompt "Uninstallation for gMSA [$gMSA] on Server [$PrincipalToRemove] canceled by user, Aborting Change for Apply changes" -Title "Aborting uninstall" -Icon Information -BoxType OKOnly
									Write-Log -Level INFO -Message "Uninstallation for gMSA [$gMSA] on Server [$PrincipalToRemove] canceled by user, Aborting Change for Apply changes"
								}
							}
						}
						# IF NO
						else
						{
							Show-MsgBox -Prompt "Remove [$PrincipalToRemove] from gMSA [$gMSA] canceled by user, aborting removal of server $PrincipalToRemove from gMSA [$gMSA]" -Title "Aborting remove" -Icon Information -BoxType OKOnly
							Write-Log -Level INFO -Message "Remove [$PrincipalToRemove] from gMSA [$gMSA] canceled by user, aborting removal of server $PrincipalToRemove from gMSA [$gMSA]"
						}
					}
				}
				else
				{
					## SYNC WITH: If ($ConfirmationNotUsed -eq "YES") ##
					Write-Log -Level INFO -Message "Trying to remove [$PrincipalToAdd] from gMSA [$gMSA] - confirmed by user"
					
					# GET THE CURRENT PRINCIPALS ALLOWED TO RETRIEVE MANAGED PASSWORD
					$CurrentPrincipalName = $(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword
					
					# GET THE DISTINGUISHED NAME OF THE SELECTED PRINCIPAL
					$SelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToRemove) -and ((ObjectClass -eq "User") -or (ObjectClass -eq "Group")) }).DistinguishedName
					
					# GET ONLY CURRENT PRINCIPALS THAT DO NOT MATCH THE SELECTED PRINCIPAL
					$DesiredPrincipals = $CurrentPrincipalName -ne $SelectedPrinicipalName
					
					# APPLY ONLY THE REMOANING PRINCIPALS
					Set-ADServiceAccount -Identity $gMSA -PrincipalsAllowedToRetrieveManagedPassword $DesiredPrincipals
					
					# CHECK IF REMOVED FROM GMSA
					If ($(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword -notcontains $SelectedPrinicipalName)
					{
						Show-MsgBox -Prompt "Successfully removed [$PrincipalToRemove] from gMSA [$gMSA]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
						Write-Log -Level INFO -Message "Successfully removed [$PrincipalToRemove] from gMSA [$gMSA]"
					}
					else
					{
						Show-MsgBox -Prompt "Failed to removed [$PrincipalToRemove] from gMSA [$gMSA]" -Title "Error" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
						Write-Log -Level ERROR -Message "Failed to removed [$PrincipalToRemove] from gMSA [$gMSA]"
					}
					
					# SEE IF $PrincipalToRemove IS A COMPUTER
					$ComputerSelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToRemove) -and (ObjectClass -eq "Computer") }).DistinguishedName
					if ($ComputerSelectedPrinicipalName)
					{
						# ASK IF THE USER WILL UNINSTALL THE GMSA FROM THE SERVER ADDED ALLOWED TO RETRIEVE PASSWORD
						$ConfirmUnInstallOnServerForGMSA = Show-MsgBox -Prompt "Will you uninstall the gMSA [$gMSA] on server [$PrincipalToRemove] now you had removed it the the gMSA [$gMSA]?`r`n`r`nThis will use the current user (make sure you have the right permissions before) and firewall rules allow it" -Title "Uninstall gMSA $SelectedGMSA from server $PrincipalToRemove?" -Icon Question -BoxType YesNo -DefaultButton 1
						# IF YES
						If ($ConfirmUnInstallOnServerForGMSA -eq "Yes")
						{
							Try
							{
								# MODIFY THE GMSA PROPERTIES
								Write-Log -Level INFO -Message "User pressed on button to uninstall gMSA [$gMSA] on the Server [$PrincipalToRemove] - confirmed by user"
								
								# Install gMSA on the Server
								Invoke-Command -ComputerName $PrincipalToRemove -ScriptBlock { Add-WindowsFeature RSAT-AD-Powershell; Import-Module ActiveDirectory; Uninstall-ADServiceAccount $gMSA };
								
								Write-Log -Level INFO -Message "Successfully uninstalled gMSA [$gMSA] on the Server [$PrincipalToRemove]"
								Show-MsgBox -Prompt "Successfully uninstalled gMSA [$gMSA] on the Server [$PrincipalToRemove]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
							}
							Catch
							{
								Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
								Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
							}
						}
						# IF NO
						else
						{
							Show-MsgBox -Prompt "Uninstallation for gMSA [$gMSA] on Server [$PrincipalToRemove] canceled by user, Aborting Change for Apply changes" -Title "Aborting uninstall" -Icon Information -BoxType OKOnly
							Write-Log -Level INFO -Message "Uninstallation for gMSA [$gMSA] on Server [$PrincipalToRemove] canceled by user, Aborting Change for Apply changes"
						}
					}
				}
				<#
				## SYNC WITH: If ($ConfirmationNotUsed -eq "YES") ##
				Write-Log -Level INFO -Message "Trying to remove [$PrincipalToAdd] from gMSA [$gMSA] - confirmed by user"
				
				# GET THE CURRENT PRINCIPALS ALLOWED TO RETRIEVE MANAGED PASSWORD
				$CurrentPrincipalName = $(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword
				
				# GET THE DISTINGUISHED NAME OF THE SELECTED PRINCIPAL
				$SelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToRemove) -and ((ObjectClass -eq "User") -or (ObjectClass -eq "Group")) }).DistinguishedName
				
				# GET ONLY CURRENT PRINCIPALS THAT DO NOT MATCH THE SELECTED PRINCIPAL
				$DesiredPrincipals = $CurrentPrincipalName -ne $SelectedPrinicipalName
				
				# APPLY ONLY THE REMOANING PRINCIPALS
				Set-ADServiceAccount -Identity $gMSA -PrincipalsAllowedToRetrieveManagedPassword $DesiredPrincipals
				
				# CHECK IF REMOVED FROM GMSA
				If ($(Get-ADServiceAccount -Identity $gMSA -Properties * | Select-Object PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword -notcontains $SelectedPrinicipalName)
				{
					Show-MsgBox -Prompt "Successfully removed [$PrincipalToRemove] from gMSA [$gMSA]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level INFO -Message "Successfully removed [$PrincipalToRemove] from gMSA [$gMSA]"
				}
				else
				{
					Show-MsgBox -Prompt "Failed to removed [$PrincipalToRemove] from gMSA [$gMSA]" -Title "Error" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level ERROR -Message "Failed to removed [$PrincipalToRemove] from gMSA [$gMSA]"
				}
				
				# SEE IF $PrincipalToRemove IS A COMPUTER
				$ComputerSelectedPrinicipalName = $(Get-ADObject -Filter { (Name -eq $PrincipalToRemove) -and (ObjectClass -eq "Computer") }).DistinguishedName
				if ($ComputerSelectedPrinicipalName)
				{
					# ASK IF THE USER WILL UNINSTALL THE GMSA FROM THE SERVER ADDED ALLOWED TO RETRIEVE PASSWORD
					$ConfirmUnInstallOnServerForGMSA = Show-MsgBox -Prompt "Will you uninstall the gMSA [$gMSA] on server [$PrincipalToRemove] now you had removed it the the gMSA [$gMSA]?`r`n`r`nThis will use the current user (make sure you have the right permissions before) and firewall rules allow it" -Title "Uninstall gMSA $SelectedGMSA from server $PrincipalToRemove?" -Icon Question -BoxType YesNo -DefaultButton 1
					# IF YES
					If ($ConfirmUnInstallOnServerForGMSA -eq "Yes")
					{
						Try
						{
							# MODIFY THE GMSA PROPERTIES
							Write-Log -Level INFO -Message "User pressed on button to uninstall gMSA [$gMSA] on the Server [$PrincipalToRemove] - confirmed by user"
							
							# Install gMSA on the Server
							Invoke-Command -ComputerName $PrincipalToRemove -ScriptBlock { Add-WindowsFeature RSAT-AD-Powershell; Import-Module ActiveDirectory; Uninstall-ADServiceAccount $gMSA };
							
							Write-Log -Level INFO -Message "Successfully uninstalled gMSA [$gMSA] on the Server [$PrincipalToRemove]"
							Show-MsgBox -Prompt "Successfully uninstalled gMSA [$gMSA] on the Server [$PrincipalToRemove]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
						}
						Catch
						{
							Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
							Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
						}
					}
					# IF NO
					else
					{
						Show-MsgBox -Prompt "Uninstallation for gMSA [$gMSA] on Server [$PrincipalToRemove] canceled by user, Aborting Change for Apply changes" -Title "Aborting uninstall" -Icon Information -BoxType OKOnly
						Write-Log -Level INFO -Message "Uninstallation for gMSA [$gMSA] on Server [$PrincipalToRemove] canceled by user, Aborting Change for Apply changes"
					}
				}#>
			}
		}
	}
	Catch
	{
		#Show info to user if error
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

function Add-GMSAGroupsToDGV
{
<#
	.SYNOPSIS
		Add gMSA to a group.
	
	.DESCRIPTION
		Add a gMSA account to an group and validate it is added.
	
	.PARAMETER gMSA
		The gMSA to add to a group.
	
	.PARAMETER Group
		The group to ad gMSA to
	
	.EXAMPLE
		PS C:\> Add-GMSAGroupsToDGV -gMSA 'gMSA1' -Group 'Group2'
	
	.NOTES
		Additional information about the function.
#>
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$gMSA,
		[Parameter(Mandatory = $true)]
		[string]$Group
	)
	
	Try
	{
		Write-Log -Level INFO -Message "Trying to add gMSA [$gMSA] to group [$Group] - confirmed by user"
		
		# ADD TO GROUP
		$gMsaAcctObj = Get-ADServiceAccount $gMSA
		Add-ADGroupMember -Members $gMsaAcctObj.SID.Value -Identity $Group
		
		# CHECK IF ADDED TO GROUP
		$members = Get-ADGroupMember -Identity $Group -Recursive | Select-Object -ExpandProperty SID
		If ($members -contains $gMsaAcctObj.SID.Value)
		{
			#If success
			Show-MsgBox -Prompt "Successful added gMSA [$gMSA] to group [$Group]" -Title "Sucess" -Icon Information -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level INFO -Message "Successfully added gMSA [$gMSA] to group [$Group]"
		}
		Else
		{
			#If not success
			Show-MsgBox -Prompt "Failed to add gMSA [$gMSA] to group [$Group]" -Title "Failure" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level ERROR -Message "Failed added gMSA [$gMSA] to group [$Group]"
		}
	}
	Catch
	{
		#Show info to user if error
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

function Add-SSAGroupsToDGV
{
<#
	.SYNOPSIS
		Add Standard Service Account ( Active Directory user) to a group.
	
	.DESCRIPTION
		Add Standard Service Account ( Active Directory user) to a group and validate its added.
	
	.PARAMETER SSA
		The Standard Service Account (Active Directory user) to add to a group.
	
	.PARAMETER Group
		The group to add Standard Service Account (Active Directory user) to.
	
	.EXAMPLE
		PS C:\> Add-SSAGroupsToDGV -SSA 'SSA1' -Group 'Group2'
	
	.NOTES
		Additional information about the function.
#>
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$SSA,
		[Parameter(Mandatory = $true)]
		[string]$Group
	)
	
	Try
	{
		Write-Log -Level INFO -Message "Trying to add SSA [$SSA] to group [$Group] - confirmed by user"
		
		# ADD TO GROUP
		$SSAAcctObj = Get-ADUser $SSA
		Add-ADGroupMember -Members $SSAAcctObj.SID.Value -Identity $Group
		
		# CHECK IF ADDED TO GROUP
		$user = Get-ADGroupMember -Identity $group | Where-Object { $_.name -eq $SSA }
		if ($user)
		{
			#If success
			Show-MsgBox -Prompt "Successfully added SSA [$SSA] to group [$Group]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level INFO -Message "Successfully added SSA [$SSA] to group [$Group]"
		}
		else
		{
			#If not success
			Show-MsgBox -Prompt "Failed to add SSA [$SSA] to group [$Group]" -Title "Error" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level ERROR -Message "Failed to add SSA [$SSA] to group [$Group]"
		}
	}
	Catch
	{
		#Show info to user if error
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

function Test-GMSAPropertyChange
{
<#
	.SYNOPSIS
		Check if all Property for gMSA change is Green.
	
	.DESCRIPTION
		Check if all Property for gMSA change is Green in GUI and allow save.
	
	.NOTES
		Additional information about the function.
#>
	# CHECK IF OKAY
	If (($textbox_GMSA_Description.ForeColor -eq 'Green') -or
		($combobox_GMSA_FunctionalOwner.ForeColor -eq 'Green') -or
		($textbox_GMSA_DNSName.ForeColor -eq 'Green') -or
		($checkbox_GMSA_DES.ForeColor -eq 'Green') -or
		($checkbox_GMSA_RC4.ForeColor -eq 'Green') -or
		($checkbox_GMSA_AES128.ForeColor -eq 'Green') -or
		($checkbox_GMSA_AES256.ForeColor -eq 'Green') -or
		($radiobutton_GMSA_EnabledNo.ForeColor -eq 'Green'))
	{
		$button_GMSA_Apply.Enabled = $true
	}
	else
	{
		$button_GMSA_Apply.Enabled = $false
	}
}

function Remove-GMSA
{
<#
	.SYNOPSIS
		Remove a gMSA account from Active Directory.
	
	.DESCRIPTION
		Remove a gMSA account from Active Directory - selected in overview. Validate the user are sure and check if deleted from Active Directory. 
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param ()
	
	$SelectGMSAtoremove = $dgv_GMSA_Select.SelectedRows | ForEach-Object { $_.Cells['Name'].value }
	
	$Confirm = Show-InputBox -message "Enter the following to remove the gMSA account:`r`n`r`n$SelectGMSAtoremove" -title "Confirm to delete" -default "Type Account Name here to confim"
	
	If ($Confirm -eq $SelectGMSAtoremove)
	{
		Write-Log -Level INFO -Message "Trying to remove gMSA [$SelectGMSAtoremove] - confirmed by user"
		
		#TRY TO REMOVE GMSA
		Remove-ADServiceAccount -Identity $SelectGMSAtoremove -Confirm:$false
		
		#CHECK IF REMOVED		
		$script:GMSA_ServiceAccountToRemove = Get-ADServiceAccount -Identity $SelectGMSAtoremove
		If ([string]::IsNullOrEmpty($GMSA_ServiceAccountToRemove))
		{
			# Show Success message, and then close the form
			Show-MsgBox -Prompt "Deleted gMSA [$SelectGMSAtoremove] successfully from Active Directory" -Title "Success" -Icon Information -BoxType "OkOnly" -DefaultButton 1
			Write-Log -Level INFO -Message "Deleted gMSA [$SelectGMSAtoremove] successfully from Active Directory"
		}
		else
		{
			#If not success
			Show-MsgBox -Prompt "Failed to delete gMSA [$SelectGMSAtoremove] from Active Directory" -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
			Write-Log -Level ERROR -Message "Failed to delete gMSA [$SelectGMSAtoremove] from Active Directory"
		}
	}
	else
	{
		#Show info to user if entry does not match - aborting
		Show-MsgBox -Prompt "The entry does not match. Aborting the removal of gMSA [$SelectGMSAtoremove] from Active Directory" -Title "Aborting Removal" -Icon Information -BoxType OKOnly
		Write-Log -Level WARN -Message "The entry does not match. Aborting the removal of gMSA [$SelectGMSAtoremove] from Active Directory"
	}
}

function Modify-GMSA
{
<#
	.SYNOPSIS
		Modify a gMSA account.
	
	.DESCRIPTION
		Modify the selected gMSA account and validate changes.
	
	.PARAMETER gMSA
		The gMSA to edit.
	
	.EXAMPLE
		PS C:\> Modify-GMSA -gMSA 'gMSA1'
	
	.NOTES
		Additional information about the function.
#>
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$gMSA
	)
	
	# MODIFY THE GMSA PROPERTIES
	
	# ENABLED
	If ($radiobutton_GMSA_EnabledNo.ForeColor -eq 'Green')
	{
		$radiobutton_GMSA_EnabledNo.ForeColor = 'Black'
		$radiobutton_GMSA_EnabledYes.ForeColor = 'Black'
		
		If ($radiobutton_GMSA_EnabledNo.Checked -eq $true)
		{
			#Try to disable gMSA
			try
			{
				Set-ADServiceAccount -Identity $gMSA -Enabled $false
			}
			# Catch specific types of exceptions thrown by one of those commands
			catch [System.Exception]
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to disable gMSA $gMSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to disable gMSA $gMSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			# Catch all other exceptions thrown by one of those commands
			catch
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to disable gMSA $gMSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to disable gMSA $gMSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			
			#Write-Log -Level INFO -Message "Disabled gMSA [$gMSA] in Active Directory"
		}
		else
		{
			#Try to enabled gMSA
			try
			{
				Set-ADServiceAccount -Identity $gMSA -Enabled $true
			}
			# Catch specific types of exceptions thrown by one of those commands
			catch [System.Exception]
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to enable gMSA $gMSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to enable gMSA $gMSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			# Catch all other exceptions thrown by one of those commands
			catch
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to enable gMSA $gMSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to enable gMSA $gMSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			
			#Write-Log -Level INFO -Message "Enabled gMSA [$gMSA] in Active Directory"
		}
		
		# CHECK IF CHANGED
		If (Get-ADServiceAccount -Identity $gMSA | Where-Object { $_.Enabled -eq $true })
		{
			Show-MsgBox -Prompt "Successful enabled gMSA [$gMSA] in Active Directory" -Title "Sucess" -Icon Information -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level INFO -Message "Successfully enabled gMSA [$gMSA] in Active Directory"
		}
		Else
		{
			Show-MsgBox -Prompt "Successful disabled gMSA [$gMSA] in Active Directory" -Title "Sucess" -Icon Information -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level INFO -Message "Successful disabled gMSA [$gMSA] in Active Directory"
		}
	}
	
	# SET DESCRIPTION ON GMSA
	If ($textbox_GMSA_Description.ForeColor -eq 'Green')
	{
		If ($textbox_GMSA_Description.Text -eq "")
		{
			Set-ADServiceAccount -Identity $gMSA -Clear Description
			
			Write-Log -Level INFO -Message "Cleared Description for gMSA [$gMSA] in Active Directory"
		}
		else
		{
			Set-ADServiceAccount -Identity $gMSA -Description $textbox_GMSA_Description.Text
			
			Write-Log -Level INFO -Message "Has set Description for gMSA [$gMSA] to $($textbox_GMSA_Description.Text) in Active Directory"
		}
	}
	
	# SET FUNCTIONAL OWNER ON GMSA
	If ($combobox_GMSA_FunctionalOwner.ForeColor -eq 'Green')
	{
		If ($combobox_GMSA_FunctionalOwner.Text -eq "")
		{
			Set-ADServiceAccount -Identity $gMSA -Clear Department
			
			Write-Log -Level INFO -Message "Cleared Functional Owner for gMSA [$gMSA] in Active Directory"
		}
		else
		{
			Set-ADServiceAccount -Identity $gMSA -Replace @{ "Department" = $($combobox_GMSA_FunctionalOwner.Text) }
			
			Write-Log -Level INFO -Message "Has set Functional Owner for gMSA [$gMSA] to $($combobox_GMSA_FunctionalOwner.Text) in Active Directory"
		}
	}
	
	# SET DNS HOSTNAME ON GMSA
	If ($textbox_GMSA_DNSName.ForeColor -eq 'Green')
	{
		If ($textbox_GMSA_DNSName.Text -eq "")
		{
			Set-ADServiceAccount -Identity $gMSA -Clear DNSHostName
			
			Write-Log -Level INFO -Message "Cleared DNSHostName for gMSA [$gMSA] in Active Directory"
		}
		Else
		{
			Set-ADServiceAccount -Identity $gMSA -DNSHostName $textbox_GMSA_DNSName.Text
			
			Write-Log -Level INFO -Message "Has set DNSHostName for gMSA [$gMSA] to $($textbox_GMSA_DNSName.Text) in Active Directory"
		}
	}
	
	$EncryptionTypes = @()
	# DES
	If ($checkbox_GMSA_DES.Checked -eq $true)
	{
		$EncryptionTypes += "DES"
	}
	
	# RC4
	If ($checkbox_GMSA_RC4.Checked -eq $true)
	{
		$EncryptionTypes += "RC4"
	}
	
	#AES128
	If ($checkbox_GMSA_AES128.Checked -eq $true)
	{
		$EncryptionTypes += "AES128"
	}
	
	#AES256
	If ($checkbox_GMSA_AES256.Checked -eq $true)
	{
		$EncryptionTypes += "AES256"
	}
	
	If (($checkbox_GMSA_DES.ForeColor -eq 'Green') -or ($checkbox_GMSA_RC4.ForeColor -eq 'Green') -or ($checkbox_GMSA_AES128.ForeColor -eq 'Green') -or ($checkbox_GMSA_AES256.ForeColor -eq 'Green'))
	{
		If (($checkbox_GMSA_DES.Checked -eq $true) -or ($checkbox_GMSA_RC4.Checked -eq $true) -or ($checkbox_GMSA_AES128.Checked -eq $true))
		{
			$Confirm = Show-InputBox -message "THIS IS NOT RECOMMENDED: You have selected one or more less secure encryption types.`r`n`r`nCancel to change, or enter the following to continue (case-sensitive):`r`n`r`n`tThisIsUnsafe" -title "Confirm Weak Encryption Type(s)"
		}
		else
		{
			$Confirm = "NA"
		}
		
		If (($Confirm -ceq "ThisIsUnsafe") -or ($Confirm -eq "NA"))
		{
			Set-ADServiceAccount -Identity $gMSA -KerberosEncryptionType $($EncryptionTypes -join ",")
			
			Write-Log -Level WARN -Message "Had set Weak Encryption Type(s) for gMSA [$gMSA] in Active Directory - confirmed by user"
		}
		else
		{
			Show-MsgBox -Prompt "Operation canceled, or input value doesn't match.`r`n`r`nPlease try again." -Title "Aborting Change" -Icon Information -BoxType OKOnly
			
			Write-Log -Level WARN -Message "Set encryption types gMSA [$gMSA] canceled by user, Aborting Change in Active Directory"
		}
	}
}