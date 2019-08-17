function Get-PlexPlaylistItem
{
	[CmdletBinding()]
	param(		
		[Parameter(Mandatory=$true)]
        [String]
        $PlaylistID
	)
	
	if(!$PlexConfigData)
	{
		throw "You must call 'Get-PlexAuthenticationToken' before calling this function."
	}

	$RestEndpoint   = "playlists/$PlaylistID/items"
	try 
	{
        [array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -ErrorAction Stop
    }
    catch
    {
        throw $_
    }

    return $data.MediaContainer.Video
}