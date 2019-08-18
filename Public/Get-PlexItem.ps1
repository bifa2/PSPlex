function Get-PlexItem
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true,ParameterSetName='ItemID')]
        [String]
		$ItemID
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "You must call 'Get-PlexAuthenticationToken' or 'Import-PlexConfiguration' before calling this function."
	}

	$RestEndpoint   = "library/metadata/$ItemID"

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