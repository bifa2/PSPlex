function Get-PlexCollection
{  
	[CmdletBinding()]
	param(		
        [Parameter(Mandatory=$false)]
        [PSObject]
		$ID,

		[Parameter(Mandatory=$false)]
        [Switch]
        $IncludeItems
	)
	
	if($Null -eq $PlexConfigData.PlexServer)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	# When making a lookup for a specific collection with an ID number, whilst the returned object contains the videos
	# within collection, it does not contain the *name*. This is annoying and problematic.

	# When making a lookup to the all collections endpoint, we get collection names but no videos.

	# As it's incredibly quick to lookup all collections, I'm making a design decision to 

	if($ID)
	{
		$RestEndpoint   = "library/sections/2/all?collection=$ID&X-Plex-Token=$($PlexConfigData.Token)"
	}
	else
	{
		$RestEndpoint   = "library/sections/2/collection`?`X-Plex-Token=$($PlexConfigData.Token)"
	}    

	try 
	{
		$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint" -Method GET -ErrorAction Stop
		if($data.MediaContainer.Size -eq 0)
		{
			return
		}
    }
    catch
    {
        throw $_
	}



	if($ID)
	{
		<#
		
			If we've made a direct lookup, the $data.MediaContainer looks like this:
		
			size                : 5
			allowSync           : 1
			art                 : /:/resources/movie-fanart.jpg
			identifier          : com.plexapp.plugins.library
			librarySectionID    : 2
			librarySectionTitle : Films
			librarySectionUUID  : d678c85f-31df-4a2d-abf1-7124d6a00499
			mediaTagPrefix      : /system/bundle/media/flags/
			mediaTagVersion     : 1585174144
			thumb               : /:/resources/movie.png
			title1              : Films
			title2              : All Films
			viewGroup           : movie
			viewMode            : 65592
			Video               : {Video, Video, Video, Video...}
		
			Notice that we have the videos already, but no 'title' for the playlist. As we are performing a lookup by ID
			there's no 

		#>

		return $data.MediaContainer
	}
	else
	{
	
		if($IncludeItems)
		{
			foreach($collection in $data.MediaContainer.Directory)
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Appending collection item(s) for collection $($collection.title)"
				try 
				{
					[array]$Items = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -ErrorAction Stop
					$collection | Add-Member -NotePropertyName 'Videos' -NotePropertyValue $Items.MediaContainer.Video
				}
				catch
				{
					throw $_
				}
			}
		}		
		
		return $data.MediaContainer.Directory
	} 
	
	
}