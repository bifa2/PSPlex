

function Import-PlexConfiguration
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[String]
		$FileName = 'PSPlexConfig.json'
    )

    # PowerShell Core has IsWindows, IsLinux, IsMac, but previous versions do not:
    if($IsWindows -or ( [version]$PSVersionTable.PSVersion -lt [version]"5.99.0" )) 
    {
        $ConfigFile = "$env:appdata\PSPlex\$FileName"
    }
    elseif($IsLinux -or $IsMacOS)
    {
        $ConfigFile = "$HOME/.PSPlex/$FileName"
	}
	else
	{
        throw "Unknown Platform"
    }
	
	# Known issue that this will not work on Linux/MacOS. Will adapt later.
	if(Test-Path $ConfigFile)
	{
		Write-Verbose -Message "Importing configuration from $ConfigFile"
		$script:PlexConfigData = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json
		# Decode the token in memory:
		$script:PlexConfigData.Token = $(
			$SP = ConvertTo-SecureString -String $PlexConfigData.Token
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SP)
			[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		)
		$script:ImportedConfig = $true
	}
	else
	{
        throw 'No saved configuration information. Run Get-PlexAuthenticationToken, then Save-PlexConfiguration.'
    }
}