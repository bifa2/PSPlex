function Find-PlexItem
{
	[CmdletBinding()]
	param(		
		[Parameter(Mandatory=$true)]
		[String]
		$ItemName,

		[Parameter(Mandatory=$true)]
		[ValidateSet('movie','episode')]
		[String]
		$ItemType,

		[Parameter(Mandatory=$false)]
		[Switch]
		$ExactMatch
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	$RestEndpoint   = "/hubs/search/"

	Write-Verbose -Message "Searching for $ItemName."
	try 
	{
		
		[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`includeCollections=0&sectionId=&query=$($ItemName)&limit=50&X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
		[array]$results = $data.MediaContainer.Hub | Where-Object { $_.type -eq $ItemType }
		if($results.size -gt 0)
		{
			$results = $results | Select-Object -Expand Video
			if($ExactMatch)
			{
				$results = $results | Where-Object { $_.title -eq $ItemName }
			}
		}
		else
		{
			Write-Verbose -Message "No result found."
			return
		}
		
    }
    catch
    {
        throw $_
	}
	
	return $results
}