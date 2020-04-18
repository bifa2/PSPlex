function Stop-PlexConversion
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true)]
        [String]
		$clientIdentifier,
		
        [Parameter(Mandatory=$true)]
        [String]
		$syncItemId
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "You must call 'Get-PlexAuthenticationToken' or 'Import-PlexConfiguration' before calling this function."
	}

	try 
	{
		# Delete the conversion:
		Invoke-RestMethod -Uri "https://plex.tv/devices/$clientIdentifier/sync_items/$($syncItemId)?X-Plex-Token=$($PlexConfigData.Token)" -Method "DELETE" | Out-Null
		# Refresh the sync status page:
		Invoke-WebRequest -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/sync/refreshSynclists?X-Plex-Token=$($PlexConfigData.Token)" -Method "PUT" | Out-Null
    }
    catch
    {
        throw $_
	}
	
	return $results
}