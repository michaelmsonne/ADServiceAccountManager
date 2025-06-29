# Generate Strong Password function
function GenerateStrongPassword
{
	param
	(
		# Specifies the desired length of the generated password.
		[Parameter(Mandatory = $true)]
		[int]$PasswordLength
	)
	
	# Load the System.Web assembly for password generation.
	Add-Type -AssemblyName System.Web
	
	# Initialize a variable to track password complexity check.
	$PassComplexCheck = $false
	
	# Generate a new password and check its complexity.
	do
	{
		$newPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, 1)
		# Check if the password meets complexity requirements:
		# 1. Contains at least one uppercase letter.
		# 2. Contains at least one lowercase letter.
		# 3. Contains at least one digit.
		# 4. Contains at least one non-alphanumeric character.
		If (
			($newPassword -cmatch "[A-Z\p{Lu}\s]") `
			-and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
			-and ($newPassword -match "[\d]") `
			-and ($newPassword -match "[^\w]")
		)
		{
			# Mark the password as complex.
			$PassComplexCheck = $True
		}
	}
	While (
		# Repeat until a complex password is generated.
		$PassComplexCheck -eq $false
	)
	return $newPassword
}