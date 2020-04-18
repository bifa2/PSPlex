function Get-PlexSession
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$false,ParameterSetName='SessionId')]
        [String]
		$SessionId
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "You must call 'Get-PlexAuthenticationToken' or 'Import-PlexConfiguration' before calling this function."
	}

	$RestEndpoint   = "status/sessions"

	try 
	{
		[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
		if ($data.MediaContainer.Size -gt 0)
		{
			$ItemType = ($data.MediaContainer | Get-Member -MemberType Property | Select-Object -Last 1).Name
			[array]$results = $data.MediaContainer.$ItemType
		}
		else
		{
			return
		}
    }
    catch
    {
        throw $_
	}

	$results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Session") }
    return $results
}