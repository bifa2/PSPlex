function Remove-PlexPlaylist
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
	
	if($PlexConfigData.PlexServer -eq $Null)
	{
		# User has either not run Get-PlexAuthentication or imported the config.
		throw "You must call 'Import-PlexConfiguration' before calling this function."
	}

    $RestEndpoint   = "playlists/$ID"

	try 
	{
		if($AlternativeToken) { $Token = $AlternativeToken} else { $Token = $PlexConfigData.Token }
		Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$Token" -Method DELETE -ErrorAction Stop
    }
    catch
    {
        throw $_
    }

    return $results
}