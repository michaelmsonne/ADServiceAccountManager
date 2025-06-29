#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

$global:darkModeStateUI

$global:FormVersion = "1.0.15.0"
$global:Author = "Michael Morten Sonne"
$global:ToolName = "AD ServiceAccount Manager"
$global:AuthorEmail = ""
$global:AuthorCompany = "Sonne´s Cloud"

$global:GitHubProfileURL = "https://github.com/michaelmsonne/"
$global:BlogURL = "https://blog.sonnes.cloud"
$global:WebsideURL = "https://sonnes.cloud"
$global:LinkedInURL = "https://www.linkedin.com/in/michaelmsonne/"
$global:BuyMeACoffieURL = "https://buymeacoffee.com/sonnes"
$global:GitHubRepoURL = "https://github.com/michaelmsonne/ADServiceAccountManager"

#Internal or public build
$global:InternalBuild = $false

#Logfile path
$LogPath = "$Env:USERPROFILE\AppData\Local\$global:ToolName"

#Get username and domain for account running this tool
$global:UserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Get current Windows colour theme (dard or light) TODO
function Test-WindowsInDarkMode
{
	# Path to the registry key
	$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
	$registryValueName = "AppsUseLightTheme"
	
	try
	{
		# Get the value of the registry key
		$useLightTheme = Get-ItemProperty -Path $registryPath -Name $registryValueName -ErrorAction Stop
		
		# Determine the theme mode based on the registry value
		if ($useLightTheme.$registryValueName -eq 0)
		{
			return $true # Dark mode
			
			Write-Log -Level INFO -Message "Detected Windows is running as Dark mode - setting application to this theme as default"
		}
		else
		{
			return $false # Light mode
			
			Write-Log -Level INFO -Message "Detected Windows is running as Light mode - setting application to this theme as default"
		}
	}
	catch
	{
		#Write-Error "Failed to determine Windows theme mode: $_"
		return $false
	}
}

#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory

function Update-ComboBox
{
	<#
	.SYNOPSIS
		This functions helps you load items into a ComboBox.
	
	.DESCRIPTION
		Use this function to dynamically load items into the ComboBox control.
	
	.PARAMETER ComboBox
		The ComboBox control you want to add items to.
	
	.PARAMETER Items
		The object or objects you wish to load into the ComboBox's Items collection.
	
	.PARAMETER DisplayMember
		Indicates the property to display for the items in this control.
	
	.PARAMETER ValueMember
		Indicates the property to use for the value of the control.
	
	.PARAMETER Append
		Adds the item(s) to the ComboBox without clearing the Items collection.
	
	.EXAMPLE
		Update-ComboBox $combobox1 "Red", "White", "Blue"
	
	.EXAMPLE
		Update-ComboBox $combobox1 "Red" -Append
		Update-ComboBox $combobox1 "White" -Append
		Update-ComboBox $combobox1 "Blue" -Append
	
	.EXAMPLE
		Update-ComboBox $combobox1 (Get-Process) "ProcessName"
	
	.NOTES
		Additional information about the function.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[System.Windows.Forms.ComboBox]$ComboBox,
		# The ComboBox control to which items will be added.
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		$Items,
		# The object or objects to be loaded into the ComboBox's Items collection.
		[Parameter(Mandatory = $false)]
		[string]$DisplayMember,
		# The property to display for the ComboBox items.
		[Parameter(Mandatory = $false)]
		[string]$ValueMember,
		# The property to use for the value of the ComboBox items.
		[switch]$Append # If used, adds items to the ComboBox without clearing the Items collection.
	)
	
	if (-not $Append)
	{
		# Clear the ComboBox's Items collection if not appending.
		$ComboBox.Items.Clear()
	}
	if ($Items -is [Object[]])
	{
		# Add multiple items from an array.
		$ComboBox.Items.AddRange($Items)
	}
	elseif ($Items -is [System.Collections.IEnumerable])
	{
		# Improve performance by temporarily suspending updates.
		$ComboBox.BeginUpdate()
		
		foreach ($obj in $Items)
		{
			# Add items one by one from an enumerable source.
			$ComboBox.Items.Add($obj)
		}
		
		# Resume normal updates.
		$ComboBox.EndUpdate()
	}
	else
	{
		# Add a single item to the ComboBox.
		$ComboBox.Items.Add($Items)
	}
	
	if ($DisplayMember)
	{
		# Set the DisplayMember property if specified.
		$ComboBox.DisplayMember = $DisplayMember
	}
	
	if ($ValueMember)
	{
		# Set the ValueMember property if specified.
		$ComboBox.ValueMember = $ValueMember
	}
}

function Update-DataGridView
{
	<#
	.SYNOPSIS
		This functions helps you load items into a DataGridView.

	.DESCRIPTION
		Use this function to dynamically load items into the DataGridView control.

	.PARAMETER  DataGridView
		The DataGridView control you want to add items to.

	.PARAMETER  Item
		The object or objects you wish to load into the DataGridView's items collection.
	
	.PARAMETER  DataMember
		Sets the name of the list or table in the data source for which the DataGridView is displaying data.

	.PARAMETER AutoSizeColumns
	    Resizes DataGridView control's columns after loading the items.
	#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		$Item,
		[Parameter(Mandatory = $false)]
		[string]$DataMember,
		[System.Windows.Forms.DataGridViewAutoSizeColumnsMode]$AutoSizeColumns = 'None'
	)
	$DataGridView.SuspendLayout()
	$DataGridView.DataMember = $DataMember
	
	if ($null -eq $Item)
	{
		$DataGridView.DataSource = $null
	}
	elseif ($Item -is [System.Data.DataSet] -and $Item.Tables.Count -gt 0)
	{
		$DataGridView.DataSource = $Item.Tables[0]
	}
	elseif ($Item -is [System.ComponentModel.IListSource]`
		-or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView])
	{
		$DataGridView.DataSource = $Item
	}
	else
	{
		$array = New-Object System.Collections.ArrayList
		
		if ($Item -is [System.Collections.IList])
		{
			$array.AddRange($Item)
		}
		else
		{
			$array.Add($Item)
		}
		$DataGridView.DataSource = $array
	}
	
	if ($AutoSizeColumns -ne 'None')
	{
		$DataGridView.AutoResizeColumns($AutoSizeColumns)
	}
	
	$DataGridView.ResumeLayout()
}

function ConvertTo-DataTable
{
	<#
		.SYNOPSIS
			Converts objects into a DataTable.
	
		.DESCRIPTION
			Converts objects into a DataTable, which are used for DataBinding.
	
		.PARAMETER  InputObject
			The input to convert into a DataTable.
	
		.PARAMETER  Table
			The DataTable you wish to load the input into.
	
		.PARAMETER RetainColumns
			This switch tells the function to keep the DataTable's existing columns.
		
		.PARAMETER FilterCIMProperties
			This switch removes CIM properties that start with an underline.
	
		.EXAMPLE
			$DataTable = ConvertTo-DataTable -InputObject (Get-Process)
	#>
	[OutputType([System.Data.DataTable])]
	param (
		$InputObject,
		[ValidateNotNull()]
		[System.Data.DataTable]$Table,
		[switch]$RetainColumns,
		[switch]$FilterCIMProperties)
	
	if ($null -eq $Table)
	{
		$Table = New-Object System.Data.DataTable
	}
	
	if ($null -eq $InputObject)
	{
		$Table.Clear()
		return @( ,$Table)
	}
	
	if ($InputObject -is [System.Data.DataTable])
	{
		$Table = $InputObject
	}
	elseif ($InputObject -is [System.Data.DataSet] -and $InputObject.Tables.Count -gt 0)
	{
		$Table = $InputObject.Tables[0]
	}
	else
	{
		if (-not $RetainColumns -or $Table.Columns.Count -eq 0)
		{
			# Clear out the Table Contents
			$Table.Clear()
			
			if ($null -eq $InputObject) { return } #Empty Data
			
			$object = $null
			#find the first non null value
			foreach ($item in $InputObject)
			{
				if ($null -ne $item)
				{
					$object = $item
					break
				}
			}
			
			if ($null -eq $object) { return } # All null then empty
			
			# Get all the properties in order to create the columns
			foreach ($prop in $object.PSObject.Get_Properties())
			{
				if (-not $FilterCIMProperties -or -not $prop.Name.StartsWith('__')) #filter out CIM properties
				{
					# Get the type from the Definition string
					$type = $null
					
					if ($null -ne $prop.Value)
					{
						try { $type = $prop.Value.GetType() }
						catch { Out-Null }
					}					
					if ($null -ne $type) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
					{
						[void]$table.Columns.Add($prop.Name, $type)
					}
					else # Type info not found
					{
						[void]$table.Columns.Add($prop.Name)
					}
				}
			}			
			if ($object -is [System.Data.DataRow])
			{
				foreach ($item in $InputObject)
				{
					$Table.Rows.Add($item)
				}
				return @( ,$Table)
			}
		}
		else
		{
			$Table.Rows.Clear()
		}
		
		foreach ($item in $InputObject)
		{
			$row = $table.NewRow()
			
			if ($item)
			{
				foreach ($prop in $item.PSObject.Get_Properties())
				{
					if ($table.Columns.Contains($prop.Name))
					{
						$row.Item($prop.Name) = $prop.Value
					}
				}
			}
			[void]$table.Rows.Add($row)
		}
	}	
	return @( ,$Table)
}

function Load-DataGridView
{
	<#
	.SYNOPSIS
		This functions helps you load items into a DataGridView.

	.DESCRIPTION
		Use this function to dynamically load items into the DataGridView control.

	.PARAMETER  DataGridView
		The DataGridView control you want to add items to.

	.PARAMETER  Item
		The object or objects you wish to load into the DataGridView's items collection.
	
	.PARAMETER  DataMember
		Sets the name of the list or table in the data source for which the DataGridView is displaying data.

	#>
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		$Item,
		[Parameter(Mandatory = $false)]
		[string]$DataMember
	)
	# Suspend the layout of the DataGridView for improved performance during data loading.
	$DataGridView.SuspendLayout()
	
	# Set the DataMember property if specified.
	$DataGridView.DataMember = $DataMember
	
	# Check the type of the provided item and set the DataSource accordingly.
	if ($Item -is [System.ComponentModel.IListSource]`
		-or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView])
	{
		$DataGridView.DataSource = $Item
	}
	else
	{
		# Create an ArrayList and add items to it, then set it as the DataSource.
		$array = New-Object System.Collections.ArrayList
		
		if ($Item -is [System.Collections.IList])
		{
			$array.AddRange($Item)
		}
		else
		{
			$array.Add($Item)
		}
		$DataGridView.DataSource = $array
	}
	
	# Resume the layout of the DataGridView after data loading.
	$DataGridView.ResumeLayout()
}

function Show-InputBox
{
	param
	(
		[string]$message = $(Throw "You must enter a prompt message"),
		[string]$title = "Input",
		[string]$default
	)
	
	[reflection.assembly]::loadwithpartialname("microsoft.visualbasic") | Out-Null
	[microsoft.visualbasic.interaction]::InputBox($message, $title, $default)
}

function Show-MsgBox
{
	[CmdletBinding()]
	param (
		# Define the message to be displayed in the message box.
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$Prompt,
		# Define the title for the message box (optional).
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$Title = "",
		# Define the icon type for the message box (optional).
		[Parameter(Position = 2, Mandatory = $false)]
		[ValidateSet("Information", "Question", "Critical", "Exclamation")]
		[string]$Icon = "Information",
		# Define the type of buttons in the message box (optional).
		[Parameter(Position = 3, Mandatory = $false)]
		[ValidateSet("OKOnly", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")]
		[string]$BoxType = "OkOnly",
		# Define the default button for the message box (optional).
		[Parameter(Position = 4, Mandatory = $false)]
		[ValidateSet(1, 2, 3)]
		[int]$DefaultButton = 1
	)
	
	# Load the Microsoft.VisualBasic assembly for MessageBox handling.
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
	
	# Map the provided $Icon to the corresponding VB.NET enum value.
	switch ($Icon)
	{
		"Question" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Question }
		"Critical" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Critical }
		"Exclamation" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Exclamation }
		"Information" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Information }
	}
	# Map the provided $BoxType to the corresponding VB.NET enum value.
	switch ($BoxType)
	{
		"OKOnly" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OKOnly }
		"OKCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OkCancel }
		"AbortRetryIgnore" { $vb_box = [microsoft.visualbasic.msgboxstyle]::AbortRetryIgnore }
		"YesNoCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNoCancel }
		"YesNo" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNo }
		"RetryCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::RetryCancel }
	}
	# Map the provided $DefaultButton to the corresponding VB.NET enum value.
	switch ($Defaultbutton)
	{
		1 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton1 }
		2 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton2 }
		3 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton3 }
	}
	
	# Combine the icon, button type, and default button values to determine the message box style.
	$popuptype = $vb_icon -bor $vb_box -bor $vb_defaultbutton
	
	# Show the message box with the provided parameters and capture the user's response.
	$ans = [Microsoft.VisualBasic.Interaction]::MsgBox($prompt, $popuptype, $title)
	
	# Return the user's response.
	return $ans
}

function Format-DataGridview
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		$DataGridViewName
	)
	# DO NOT EDIT: "ForEach-Object{"
	# Loop through the rows of the DataGridView
	$DataGridViewName.Rows |
	ForEach-Object{
		If ($_.Cells['Enabled'].Value -eq 'False')
		{
			$_.Cells['Enabled'] | ForEach-Object{ $_.Style.ForeColor = 'Red' }
		}
		elseif ($_.Cells['Enabled'].Value -eq 'True')
		{
			$_.Cells['Enabled'] | ForEach-Object{ $_.Style.ForeColor = 'Green' }
		}		
		If ($_.Cells['AES256 Only?'].Value -eq 'False')
		{
			$_.Cells['AES256 Only?'] | ForEach-Object{ $_.Style.ForeColor = 'Red' }
		}
		elseif ($_.Cells['AES256 Only?'].Value -eq 'True')
		{
			$_.Cells['AES256 Only?'] | ForEach-Object{ $_.Style.ForeColor = 'Green' }
		}
	}
}

#Validate Email function
function Validate-IsEmail ([string]$Email)
{
<#
	.SYNOPSIS
		Validate Email function.
	
	.DESCRIPTION
		A detailed description of the Validate-IsEmail function.
	
	.PARAMETER Email
		The email to validate.
	
	.EXAMPLE
		PS C:\> Validate-IsEmail -Email test@test.com
	
	.NOTES
		Additional information about the function.
#>
	return $Email -match "^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|" +`
	"[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))" +`
	"(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*" +`
	"[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$"
}