function Get-PlexPlaylist
{
	[CmdletBinding()]
	param(		
        [Parameter(Mandatory=$false)]
        [String]
		$ID,
		
        [Parameter(Mandatory=$false)]
        [Switch]
        $IncludeItems,
		
        [Parameter(Mandatory=$false)]
        [String]
        $AlternativeToken
	)
	
	if($Null -eq $PlexConfigData.PlexServer)
	{
		throw "You must call 'Import-PlexConfiguration' before calling this function."
	}

    $RestEndpoint   = "playlists/$ID"

	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting playlist(s)"
	try 
	{
		if($AlternativeToken)
		{ 
			$Token = $AlternativeToken
		} 
		else
		{
			$Token = $PlexConfigData.Token
		}

		$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($Token)" -ErrorAction Stop
		if($data.MediaContainer.Size -eq 0)
		{
			return
		}

		[array]$results = $data.MediaContainer.Playlist
    }
    catch
    {
        throw $_
	}
	

	#############################################################################
	if($IncludeItems)
	{
		foreach($playlist in $results)
		{
			$RestEndpoint   = "playlists/$($playlist.ratingKey)/items"
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Appending playlist item(s)"
			try 
			{
				[array]$Items = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -ErrorAction Stop
				$playlist | Add-Member -NotePropertyName 'Videos' -NotePropertyValue $Items.MediaContainer.Video
			}
			catch
			{
				throw $_
			}
		}
	}



	#############################################################################
	# Append type and return results
	$results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Playlist") }
    return $results
}