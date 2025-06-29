function Get-LatestReleaseFromGitHub
{
	$repo = "michaelmsonne/ADServiceAccountManager"
	$file = "ADServiceAccountManager.exe"
	$releasesUrl = "https://api.github.com/repos/$repo/releases"
	
	Write-Log -Level INFO -Message "Determining latest release..."
	$tag = (Invoke-WebRequest -Uri $releasesUrl -UseBasicParsing | ConvertFrom-Json)[0].tag_name
	
	$downloadUrl = "https://github.com/$repo/releases/download/$tag/$file"
	Write-Log -Level INFO -Message "Downloading latest release from GitHub API at: '$downloadUrl'"
	
	# Get the current execution location
	$currentLocation = Get-Location
	
	# Get the path
	$outputFile = Join-Path -Path $env:USERPROFILE\Downloads -ChildPath $file #$($currentLocation.Path)
	Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile
	
	# Ask user
	$ConfirmStartLAstDownloadedVFromGitHub = Show-MsgBox -Prompt "Latest release v. $tag on GitHub is downloaded successfully to the path:`r`n`r`n'$outputFile'.`r`n`r`nDo you want to restart the application with the new version?" -Title "Download Complete" -Icon Question -BoxType YesNo -DefaultButton 1
	
	# If user comfirmed
	If ($ConfirmStartLAstDownloadedVFromGitHub -eq "Yes")
	{
		# Log
		Write-Log -Level INFO -Message "Restarting application with the new version $tag ... - confirmed by user"
		
		# Start
		Start-Process -FilePath $outputFile
		$formManagedIdentityPermi.Close()
		Stop-Process -Id $PID
	}
	else
	{
		# Log
		Write-Log -Level INFO -Message "The new version $tag is downloaded to: $outputFile'"
		
		Show-MsgBox -Title "Download location" -Prompt "The new version '$tag' is downloaded to:`r`n`r`n'$outputFile'`r`n`r`nHere you can start it later when needed :)" -Icon Information -BoxType OKOnly
	}
}