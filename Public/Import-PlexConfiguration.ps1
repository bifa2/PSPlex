

function Import-PlexConfiguration
{
	[CmdletBinding()]
	param(
    )

    # PowerShell Core has IsWindows, IsLinux, IsMac, but previous versions do not:
    if($IsWindows -or ( [version]$PSVersionTable.PSVersion -lt [version]"5.99.0" )) 
    {
        $ConfigFile = "$env:appdata\PSPlex\PSPlexConfig.json"
    }
    elseif($IsLinux -or $IsMacOS)
    {
        $ConfigFile = "$HOME/.psgitlab/PSGitLabConfiguration.xml"
	}
	else
	{
        throw "Unknown Platform"
    }
	
	if(Test-Path $ConfigFile)
	{
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
        Write-Warning 'No saved configuration information. Run Save-PlexConfiguration.'
        break
    }
}




