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
		.PARAMETER ExactNameMatch
			Return only items matching exactly what is specified as ItemName
		.EXAMPLE
			Find-PlexItem -ItemName 'The Dark Knight' -ItemType 'movie' -ExactNameMatch
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
		[Int]
		$Year,

		[Parameter(Mandatory=$false)]
		[Switch]
		$ExactNameMatch
    )

	if($Null -eq $PlexConfigData.PlexServer)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	$RestEndpoint   = "/hubs/search/"

	Write-Verbose -Message "Searching for $ItemName."
	try 
	{	
		[array]$global:data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`includeCollections=0&sectionId=&query=$($ItemName)&limit=50&X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
		
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

			# Refine by the ItemName to attempt an exact match:
			if($ExactNameMatch)
			{
				[Array]$Results = $Results | Where-Object { $_.title -eq $ItemName }
				# There could still be more than one result with an exact title match due to the same item being in multiple libraries
				# or even in the same library!
				if($Results.count -gt 1)
				{
					Write-Warning -Message "Exact match was specified but there was more than 1 result for $ItemName."
				}
			}

			# Refine by library name:
			if($LibraryName)
			{
				# When multiple results are returned from the API they are given a 'librarySectionTitle' property so we can use that to
				# easily refine results. EDIT: Ok, sometimes they come back with 'reasonTitle'. Makes sense, not.
				if($Results.Count -gt 1)
				{
					Write-Verbose "Refining multiple results by library"
					[Array]$Results = $Results | Where-Object { $_.librarySectionTitle -eq $LibraryName -or $_.reasonTitle -eq $LibraryName }
				}
				else
				{
					<# If there's only 1 result we need to determine if it's in the library specified and I can't see a way to do this.

						Example object return:
					
						ratingKey             : 17423
						key                   : /library/metadata/17423
						guid                  : com.plexapp.agents.imdb://tt0110912?lang=en
						studio                : Miramax
						type                  : movie
						title                 : Pulp Fiction
						contentRating         : R
						rating                : 9.4
						audienceRating        : 9.6
						year                  : 1994
						tagline               : Just because you are a character doesn't mean you have character.
						thumb                 : /library/metadata/17423/thumb/1551357231
						art                   : /library/metadata/17423/art/1551357231
						duration              : 9163154
						originallyAvailableAt : 1994-09-10
						addedAt               : 1551355150
						updatedAt             : 1551357231
						audienceRatingImage   : rottentomatoes://image.rating.upright
						chapterSource         : media
						primaryExtraKey       : /library/metadata/17532
						ratingImage           : rottentomatoes://image.rating.ripe
						Media                 : Media
						Genre                 : {Genre, Genre}
						Director              : Director
						Writer                : Writer
						Country               : Country
						Role                  : {Role, Role, Role}
					#>

					# For now, we'll not filter.
				}
			}		

			if($Year)
			{
				#[Array]$Results = $Results | Where-Object { ($_.originallyAvailableAt.split('-')[0]) -match $Year }
				Write-Verbose "Refining results by Year: $Year"
				[Array]$Results = $Results | Where-Object { $_.year -eq $Year }
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

	# Add datetime objects so we don't have to work with unixtimes...
	if($Results)
	{
		$Results | ForEach-Object { 
			$_ | Add-Member -NotePropertyName 'lastViewedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.lastViewedAt) -Force
			$_ | Add-Member -NotePropertyName 'addedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.addedAt) -Force
			$_ | Add-Member -NotePropertyName 'updatedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.updatedAt) -Force
		}

		return $Results
	}
}