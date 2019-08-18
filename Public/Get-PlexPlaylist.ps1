function Get-PlexPlaylist
{
	[CmdletBinding()]
	param(		
        [Parameter(Mandatory=$false)]
        [String]
        $ID,
		
        [Parameter(Mandatory=$false)]
        [String]
        $AlternativeToken
	)
	
	if(!$PlexConfigData)
	{
		throw "You must call 'Import-PlexConfiguration' before calling this function."
	}

    $RestEndpoint   = "playlists/$ID"

	try 
	{
		if($AlternativeToken) { $Token = $AlternativeToken} else { $Token = $PlexConfigData.Token }
		[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$Token" -ErrorAction Stop
		if($ID)	
		{
			[array]$results = $data.MediaContainer.Playlist
		}
		else {
			[array]$results = $data.MediaContainer.Playlist
		}
    }
    catch
    {
        throw $_
    }

    return $results
}