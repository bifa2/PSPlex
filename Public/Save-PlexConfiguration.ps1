function Save-PlexConfiguration
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true)]
        [String]
		$PlexServer,

        [Parameter(Mandatory=$true)]
        [String]
		$PlexServerHostname,
		
		[Parameter(Mandatory=$true)]
		[ValidateSet('http','https')]
        [String]
		$Protocol,

        [Parameter(Mandatory=$false)]
		[Int]
		$Port = 32400,

        [Parameter(Mandatory=$false)]
		[String]
		$FileName = 'PSPlexConfig.json'
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	# We already have a script scoped $PlexConfigData created from Get-PlexAuthenticationToken
	# containing some of the data we wish to store on disk. Let's add some more data before
	# storing it.
	$PlexConfigData | Add-Member -MemberType NoteProperty -Name 'PlexServer' -Value $PlexServer -Force
	$PlexConfigData | Add-Member -MemberType NoteProperty -Name 'PlexServerHostname' -Value $PlexServerHostname -Force
	$PlexConfigData | Add-Member -MemberType NoteProperty -Name 'Protocol' -Value $Protocol -Force
	$PlexConfigData | Add-Member -MemberType NoteProperty -Name 'Port' -Value $Port -Force

	$ConfigFile = "$env:appdata\PSPlex\$FileName"
	if(-not (Test-Path (Split-Path $ConfigFile))) 
	{
		New-Item -ItemType Directory -Path (Split-Path $ConfigFile) | Out-Null
	}

	# Create a new object with the required data, and encrypt the token so it's not plain text at least:
	$PlexConfigDataToStore = [PSCustomObject]@{
		'Username'= $PlexConfigData.username
		'Base64Password' = $PlexConfigData.Base64Password
		'Token' = ($(ConvertTo-SecureString -string $PlexConfigData.Token -AsPlainText -Force) | ConvertFrom-SecureString)
		'PlexServer' = $PlexServer
		'PlexServerHostname' = $PlexServerHostname
		'Protocol' = $Protocol
		'Port' = $Port
	}

	# Save to disk:
	$PlexConfigDataToStore | ConvertTo-Json | Out-File -FilePath $ConfigFile
}