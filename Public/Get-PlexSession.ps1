function Get-PlexSession
{
	[CmdletBinding()]
	param(
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "You must call 'Get-PlexAuthenticationToken' or 'Import-PlexConfiguration' before calling this function."
	}

	$RestEndpoint   = "status/sessions"

	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting all sessions"
	try 
	{
		$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
		if($data.MediaContainer.Size -eq 0)
		{
			return
		}
		
		$ItemType = ($data.MediaContainer | Get-Member -MemberType Property | Select-Object -Last 1).Name
		[array]$results = $data.MediaContainer.$ItemType
    }
    catch
    {
        throw $_
	}

	#############################################################################
	# Append type and return results
	$results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Session") }
    return $results
}