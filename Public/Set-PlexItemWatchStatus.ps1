
function Set-PlexItemWatchStatus
{
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $id,

        [Parameter(Mandatory=$true)]
        [ValidateSet('played','unplayed')]
        [String]
        $Status
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}
	
    
    if($Status -eq 'played')
    {
        $RestEndpoint   = ":/scrobble"
    }
    else {
        $RestEndpoint   = ":/unscrobble"
    }

    try {
        Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?identifier=com.plexapp.plugins.library&key=$($id)&X-Plex-Token=$($PlexConfigData.Token)" -Method "GET" | Out-Null
    }
    catch
    {
        throw $_
    }
}