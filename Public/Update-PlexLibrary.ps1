
function Update-PlexLibrary
{
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $LibraryID
    )

    $RestEndpoint   = "library/sections/$LibraryID/refresh"

	try 
	{
		Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -Erroraction Stop
    }
    catch
    {
        throw $_
    }
}