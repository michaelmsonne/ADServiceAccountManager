function Remove-SSAfromGroup
{
<#
	.SYNOPSIS
		Remove account from a group.
	
	.DESCRIPTION
		Remove a standard service account from a group.
	
	.PARAMETER SSA
		The Standard Service Acoount (Active Directory user) to remove from a group.
	
	.PARAMETER Group
		The group to remove the Standard Service Acoount (Active Directory user) from.
	
	.EXAMPLE
		PS C:\> Remove-SSAfromGroup -SSA 'SSA1' -Group 'value2'
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$SSA,
		[Parameter(Mandatory = $true)]
		[string]$Group
	)
	
	Try
	{
		If ($Group -ne "")
		{
			# Prompt user for confirmation
			$Confirmation = Show-MsgBox -Prompt "Remove SSA [$SSA] from group [$Group]?" -Title "Remove SSA from group?" -Icon Question -BoxType "YesNo" -DefaultButton '2'
			If ($Confirmation -eq "YES")
			{
				Write-Log -Level INFO -Message "Trying to remove SSA [$SSA] from group [$Group] - confirmed by user"
				
				# Remove the account from the group
				Remove-ADGroupMember -Identity $Group -Members $SSA -Confirm:$false
				
				# Check if the account was removed
				If ($(Get-ADGroupMember -Identity $Group) -contains $SSA)
				{
					# If not a success
					Show-MsgBox -Prompt "Failed to remove SSA [$SSA] from group [$Group]" -Title "Failure" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level ERROR -Message "Failed to remove SSA [$SSA] from group [$Group]"
				}
				If ($(Get-ADGroupMember -Identity $Group) -notcontains $SSA)
				{
					# If a success
					Show-MsgBox -Prompt "Successful removed SSA [$SSA] from group [$Group]" -Title "Sucess" -Icon Information -BoxType OKOnly -DefaultButton '1'
					Write-Log -Level INFO -Message "Successful removed SSA [$SSA] from group [$Group]"
				}
			}
		}
	}
	Catch
	{
		# Show error to user and log it
		Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Error" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

function Test-SSAPropertyChange
{
<#
	.SYNOPSIS
		Check if all Property for SSA change is Green.
	
	.DESCRIPTION
		Check if all Property for SSA change is Green in GUI and allow save.
	
	.NOTES
		Additional information about the function.
#>
	# CHECK IF OKAY
	If (($textbox_SSA_Description.ForeColor -eq 'Green') -or
		($combobox_SSA_FunctionalOwner.ForeColor -eq 'Green') -or
		($textbox_SSA_Password.ForeColor -eq 'Green') -or
		($checkbox_SSA_DES.ForeColor -eq 'Green') -or
		($checkbox_SSA_RC4.ForeColor -eq 'Green') -or
		($checkbox_SSA_AES128.ForeColor -eq 'Green') -or
		($checkbox_SSA_AES256.ForeColor -eq 'Green') -or
		($radiobutton_SSA_EnabledNo.ForeColor -eq 'Green'))
	{
		$button_SSA_Apply.Enabled = $true
	}
	else
	{
		$button_SSA_Apply.Enabled = $false
	}
}

function Remove-SSA
{
<#
	.SYNOPSIS
		Remove a SSA account from Active Directory.
	
	.DESCRIPTION
		Remove a SSA account from Active Directory - selected in overview. Validate the user are sure and check if deleted from Active Directory. 
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param ()
	
	$SelectSSAtoremoveSAM = $dgv_SSA_Select.SelectedRows | ForEach-Object { $_.Cells['SAM Account Name'].value }
	$SelectSSAtoremoveDisplayName = $dgv_SSA_Select.SelectedRows | ForEach-Object { $_.Cells['Name'].value }
	
	$Confirm = Show-InputBox -message "Enter the following username to remove the account:`r`n`r`nUsername for the account is: $SelectSSAtoremoveSAM`r`nDisplayname for the account is: $SelectSSAtoremoveDisplayName" -title "Confirm" -default "Type username here to confirm"
	
	If ($Confirm -eq $SelectSSAtoremoveSAM)
	{
		Write-Log -Level INFO -Message "Trying to remove SSA [$SelectSSAtoremoveDisplayName] - confirmed by user"
		
		#REMOVE SSA ACCOUNT
		Remove-ADUser -Identity $SelectSSAtoremoveSAM -Confirm:$false
		
		# CHECK IF USER IS REMOVED FROM AD
		$Name = $SelectSSAtoremoveSAM
		$User = $(try { Get-ADUser $Name }
			catch { $null })
		If ($Null -ne $User)
		{
			#If not success
			Show-MsgBox -Prompt "Failed to delete SSA [$SelectSSAtoremoveDisplayName] from Active Directory" -Title "Failure" -Icon Exclamation -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level ERROR -Message "Failed to delete SSA [$SelectSSAtoremoveDisplayName] from Active Directory"
		}
		Else
		{
			#If success
			Show-MsgBox -Prompt "Deleted SSA [$SelectSSAtoremoveDisplayName] successfully from Active Directory" -Title "Sucess" -Icon Information -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level INFO -Message "Deleted SSA [$SelectSSAtoremoveDisplayName] successfully from Active Directory"
		}
	}
	else
	{
		#Show info to user if entry does not match - aborting
		Show-MsgBox -Prompt "The entry does not match. Aborting the removal of SSA [$SelectSSAtoremoveDisplayName] from Active Directory" -Title "Aborting Removal" -Icon Information -BoxType OKOnly
		Write-Log -Level WARN -Message "The entry does not match. Aborting the removal of SSA [$SelectSSAtoremoveDisplayName] from Active Directory"
	}
}

function Modify-SSA
{
	<#
	.SYNOPSIS
		Modify a SSA account.
	
	.DESCRIPTION
		Modify the selected SSA account and validate changes.
	
	.PARAMETER SSA
		The SAA to edit.
	
	.EXAMPLE
		PS C:\> Modify-SSA -SSA 'SSA1'
	
	.NOTES
		Additional information about the function.
#>
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$SSA
	)
	
	# MODIFY THE SSA PROPERTIES
	
	# ENABLED
	If ($radiobutton_SSA_EnabledNo.ForeColor -eq 'Green')
	{
		$radiobutton_SSA_EnabledNo.ForeColor = 'Black'
		$radiobutton_SSA_EnabledYes.ForeColor = 'Black'
		
		If ($radiobutton_SSA_EnabledNo.Checked -eq $true)
		{
			#Try to disable SSA
			try
			{
				Set-ADUser -Identity $SSA -Enabled $false
			}
			# Catch specific types of exceptions thrown by one of those commands
			catch [System.Exception]
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to disable SSA $SSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to disabled SSA $SSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			# Catch all other exceptions thrown by one of those commands
			catch
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to disable SSA $SSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to disable SSA $SSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			
			#Write-Log -Level INFO -Message "Disabled SSA [$SSA] in Active Directory"
		}
		else
		{
			#Try to enabled SSA
			try
			{
				Set-ADUser -Identity $SSA -Enabled $true
			}
			# Catch specific types of exceptions thrown by one of those commands
			catch [System.Exception]
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to enable SSA $SSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to enable SSA $SSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			# Catch all other exceptions thrown by one of those commands
			catch
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to enable SSA $SSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to enable SSA $SSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			
			#Write-Log -Level INFO -Message "Enabled SSA [$SSA] in Active Directory"
		}
		
		# CHECK IF CHANGED
		If (Get-Aduser -Identity $SSA | Where-Object { $_.Enabled -eq $true })
		{
			Show-MsgBox -Prompt "Successful enabled SSA [$SSA] in Active Directory" -Title "Sucess" -Icon Information -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level INFO -Message "Successfully enabled SSA [$SSA] in Active Directory"
		}
		Else
		{
			Show-MsgBox -Prompt "Successful disabled SSA [$SSA] in Active Directory" -Title "Sucess" -Icon Information -BoxType OKOnly -DefaultButton '1'
			Write-Log -Level ERROR -Message "Successful disabled SSA [$SSA] in Active Directory"
		}
	}
	
	# DESCRIPTION
	If ($textbox_SSA_Description.ForeColor -eq 'Green')
	{
		If ($textbox_SSA_Description.Text -eq "")
		{
			Set-ADUser -Identity $SSA -Clear Description
			
			Write-Log -Level INFO -Message "Cleared Description for SSA [$SSA] in Active Directory"
		}
		else
		{
			Set-ADUser -Identity $SSA -Description $textbox_SSA_Description.Text
			
			Write-Log -Level INFO -Message "Has set Description for SSA [$SSA] to $($textbox_SSA_Description.Text) in Active Directory"
		}
	}
	
	# FUNCTIONAL OWNER
	If ($combobox_SSA_FunctionalOwner.ForeColor -eq 'Green')
	{
		If ($combobox_SSA_FunctionalOwner.Text -eq "")
		{
			Set-ADUser -Identity $SSA -Clear Department
			
			Write-Log -Level INFO -Message "Cleared Functional Owner for SSA [$SSA] in Active Directory"
		}
		else
		{
			Set-ADUser -Identity $SSA -Replace @{ "Department" = $($combobox_SSA_FunctionalOwner.Text) }
			
			Write-Log -Level INFO -Message "Has set Functional Owner for SSA [$SSA] to $($combobox_SSA_FunctionalOwner.Text) in Active Directory"
		}
	}
	
	$EncryptionTypes = @()
	# DES
	If ($checkbox_SSA_DES.Checked -eq $true)
	{
		$EncryptionTypes += "DES"
	}
	
	# RC4
	If ($checkbox_SSA_RC4.Checked -eq $true)
	{
		$EncryptionTypes += "RC4"
	}
	
	#AES128
	If ($checkbox_SSA_AES128.Checked -eq $true)
	{
		$EncryptionTypes += "AES128"
	}
	
	#AES256
	If ($checkbox_SSA_AES256.Checked -eq $true)
	{
		$EncryptionTypes += "AES256"
	}
	
	If (($checkbox_SSA_DES.ForeColor -eq 'Green') -or ($checkbox_SSA_RC4.ForeColor -eq 'Green') -or ($checkbox_SSA_AES128.ForeColor -eq 'Green') -or ($checkbox_SSA_AES256.ForeColor -eq 'Green'))
	{
		If (($checkbox_SSA_DES.Checked -eq $true) -or ($checkbox_SSA_RC4.Checked -eq $true) -or ($checkbox_SSA_AES128.Checked -eq $true))
		{
			$Confirm = Show-InputBox -message "THIS IS NOT RECOMMENDED: You have selected one or more less secure encryption types.`r`n`r`nCancel to change, or enter the following to continue (case-sensitive):`r`n`r`n`tThisIsUnsafe" -title "Confirm Weak Encryption Type(s)"
		}
		else
		{
			$Confirm = "NA"
		}
		
		If (($Confirm -ceq "ThisIsUnsafe") -or ($Confirm -eq "NA"))
		{
			#If user confirm unsafe encryptions types for SSA set it
			Set-ADUser -Identity $SSA -KerberosEncryptionType $($EncryptionTypes -join ",")
			
			#Show info to the user
			Show-MsgBox -Prompt "Had set Weak Encryption Type(s) for SSA [$SSA] in Active Directory" -Title "Success" -Icon Information -BoxType OKOnly
			Write-Log -Level WARN -Message "Had set Weak Encryption Type(s) for SSA [$SSA] in Active Directory - confirmed by user"
		}
		else
		{
			#If user not confirm unsafe encryptions types for SSA show it to the user
			Show-MsgBox -Prompt "Operation canceled, or input value doesn't match.`r`n`r`nPlease try again." -Title "Aborting Change" -Icon Information -BoxType OKOnly
			Write-Log -Level WARN -Message "Set encryption types SSA [$SSA] canceled by user, Aborting Change in Active Directory"
		}
	}
	
	# PASSWORD
	If ($textbox_SSA_Password.ForeColor -eq 'Green')
	{
		# ASK IF THE USER HAS RECORDED THE PASSWORD - LAST CHANCE
		If ($textbox_SSA_Password.Text -ne "")
		{
			$ConfirmRecordedPassword = Show-MsgBox -Prompt "Have you recorded the requested password?`r`n`r`nIt will not be available again after changed!" -Title 'Password Change Confirmation' -Icon Question -BoxType YesNo -DefaultButton 1
		}
		If ($ConfirmRecordedPassword -eq "Yes")
		{
			#Get password as SecureString and set on account
			$sec_password = ConvertTo-SecureString $textbox_SSA_Password.Text -AsPlainText -Force
			
			#Set the password the account
			try
			{
				Set-ADAccountPassword -Identity $SSA -Reset -NewPassword $sec_password
				
				#Show info to the user if not fail
				Show-MsgBox -Prompt "The password has been changed for SSA [$SSA] in Active Directory" -Title "Success" -Icon Information -BoxType OKOnly
				Write-Log -Level INFO -Message "The password has been changed for SSA [$SSA] in Active Directory"
			}
			# Catch specific types of exceptions thrown by one of those commands
			catch [System.Exception]
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to set new password for SSA $SSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to set new password for SSA $SSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
			# Catch all other exceptions thrown by one of those commands
			catch
			{
				Show-MsgBox -Prompt $($Error[0].Exception.Message) -Title "Failed to set new password for SSA $SSA" -Icon Exclamation -BoxType "OkOnly" -DefaultButton 1
				Write-Log -Level ERROR -Message "Failed to set new password for SSA $SSA"
				Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
			}
		}
		else
		{
			#If user canceled set password show it to the user
			Show-MsgBox -Prompt "Operation canceled for SSA [$SSA]" -Title "Aborting Change" -Icon Information -BoxType OKOnly
			Write-Log -Level INFO -Message "Operation canceled for SSA [$SSA] canceled by user, Aborting Change in Active Directory"
			
			return
		}
	}
	
	Show-MsgBox -Prompt "Successfully set changes to SSA [$SelectedSSA]" -Title "Success" -Icon Information -BoxType OKOnly -DefaultButton '1'
	Write-Log -Level INFO -Message "User has pressed Apply for SSA [$SelectedSSA] - confirmed by user"
}