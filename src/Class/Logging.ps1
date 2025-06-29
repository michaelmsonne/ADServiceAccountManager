#Logfile function
Function Claer-OldLogs
{
	# Set cleanup days
	$limit = (Get-Date).AddDays(-15)
	$path = $LogPath
	try
	{
		#Delete files older than the $limit.
		Write-Log -Level INFO -Message "Trying to delete log file(s) in path if any older then $limit (15) days in: $LogPath"
		Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
		Write-Log -Level INFO -Message "Trying to delete log file(s) in path if any older then $limit (15) days in: $LogPath - Done"
		
		#Delete any empty directories left behind after deleting the old files.
		Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and $null -eq (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) } | Remove-Item -Force -Recurse
	}
	# Catch specific types of exceptions thrown by one of those commands
	catch [System.Exception]
	{
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
	# Catch all other exceptions thrown by one of those commands
	catch
	{
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

#CheckLogPath function
Function CheckLogPath
{
<#
	.SYNOPSIS
		CheckLogPath returns the value if logfile path exits or not.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	try
	{
		$FolderName = $LogPath
		if (Test-Path $FolderName)
		{
			#Write to logfile if exists
			Write-Log -Level INFO -Message "The application log path exists: $LogPath"
		}
		else
		{
			#Create logfile of not exists
			New-Item $FolderName -ItemType Directory
			Write-Log -Level INFO -Message "The application log path does not exists and is created: $LogPath"
		}
	}
	# Catch specific types of exceptions thrown by one of those commands
	catch [System.Exception]
	{
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
	# Catch all other exceptions thrown by one of those commands
	catch
	{
		Write-Log -Level ERROR -Message $($Error[0].Exception.Message)
	}
}

#Logfile write log function
Function Write-Log
{
<#
	.SYNOPSIS
		Save the information to specified logfile
	
	.DESCRIPTION
		A detailed description of the Write-Log function.
	
	.PARAMETER Level
		Set the information level in the logfile.
	
	.PARAMETER Message
		The message to be logged in the logfile
	
	.PARAMETER logfile
		The selected logfile to write to (there is a default logfile)
	
	.EXAMPLE
		PS C:\> Write-Log -Level INFO -Message 'value1'
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $False)]
		[ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG")]
		[String]$Level = "INFO",
		[Parameter(Mandatory = $True)]
		[string]$Message,
		[Parameter(Mandatory = $False)]
		[string]$logfile = "$LogPath\$($ToolName)_Log_$($env:computername)" + "_" + (Get-Date -Format "dd/MM/yyyy") + ".log"
	)
	
	$Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
	$Line = "$Stamp : $Level : $UserName : $Message"
	If ($logfile)
	{
		Add-Content $logfile -Value $Line
	}
	
	#HOW TO ADD A LOG ENTRY: Write-Log -Level INFO -Message "The application is started"
}