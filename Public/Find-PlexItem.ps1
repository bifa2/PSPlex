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
		
		# Refine by type:
		$ItemTypeResults = $data.MediaContainer.Hub | Where-Object { $_.type -eq $ItemType }

		# Example return object:
		<#
			title         : Movies
			type          : movie
			hubIdentifier : movie
			size          : 2
			more          : 0
			Video         : {Video, Video}
		#>

		if($ItemTypeResults.size -gt 0)
		{
			[Array]$Results = $ItemTypeResults | Select-Object -ExpandProperty Video

			# Refine by the Item name to attempt an exact match:
			if($ExactMatch)
			{
				Write-Debug -Message "Exact match was specified"
				[Array]$Results = $Results | Where-Object { $_.title -eq $ItemName }
				
				# There could still be more than one result with an exact title match:
				if($Results.count -gt 1)
				{
					Write-Warning -Message "Exact match was specified but there was more than 1 result for $ItemName."
					$Results
					return
				}
				else 
				{
					Write-Verbose -Message "No exact match found for $ItemName"
				}			
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