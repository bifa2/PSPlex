function Update-PlexItemMetadata
{
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $ItemID
    )

    $RestEndpoint   = "library/metadata/$ItemID/refresh"

	try 
	{	
		Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -Method PUT -Erroraction Stop
    }
    catch
    {
        throw $_
    }
}