function Find-PlexItem
{
	<#
		.SYNOPSIS
			This function uses the search ability of Plex find items on your Plex server.
		.DESCRIPTION
			This function uses the search ability of Plex find items on your Plex server.
			As objects returned have different properties depending on the type, there is
			an option to refine this by type.
		.PARAMETER ItemName
			Name of what you wish to find.
		.PARAMETER ItemType
			Refines the output by type.
		.PARAMETER ExactMatch
			Return only items matching exactly what is specified as ItemName
		.EXAMPLE
			Find-PlexItem -ItemName 'The Dark Knight' -ItemType 'movie' -ExactMatch
	#>
	
	[CmdletBinding()]
	param(		
		[Parameter(Mandatory=$true)]
		[String]
		$ItemName,

		[Parameter(Mandatory=$false)]
		[ValidateSet('movie','episode')]
		[String]
		$ItemType,

		[Parameter(Mandatory=$false)]
		[String]
		$LibraryName,

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
		if($ItemType)
		{
			$ItemTypeResults = $data.MediaContainer.Hub | Where-Object { $_.type -eq $ItemType -and $_.Size -gt 0 }
		}
		else 
		{
			$ItemTypeResults = $data.MediaContainer.Hub | Where-Object { $_.Size -gt 0 }
		}

		# Example return object:
		<#
			title         : Movies
			type          : movie
			hubIdentifier : movie
			size          : 2
			more          : 0
			Video         : {Video, Video}
		#>


		if($ItemTypeResults)
		{
			# Note: This will be an issue if a user wants to find photos/audio but I don't and I'm not catering for that at the moment.
			[Array]$Results = $ItemTypeResults | Select-Object -ExpandProperty Video

			# Refine by library name:
			if($LibraryName)
			{
				[Array]$Results = $Results | Where-Object { $_.librarySectionTitle -eq $LibraryName }
			}		

			# Refine by the ItemName to attempt an exact match:
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