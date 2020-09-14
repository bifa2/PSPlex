function Get-PlexConversion
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$false,ParameterSetName='SessionId')]
        [String]
		$SessionId
    )

	if($Null -eq $PlexConfigData.PlexServer)
	{
		throw "You must call 'Get-PlexAuthenticationToken' or 'Import-PlexConfiguration' before calling this function."
	}

	$RestEndpoint   = "status/sessions/background"

	try 
	{
		[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
		$ItemType = ($data.MediaContainer | Get-Member -MemberType Property | Select-Object -Last 1).Name
		[array]$results = $data.MediaContainer.$ItemType
    }
    catch
    {
        throw $_
	}
	
	return $results
}