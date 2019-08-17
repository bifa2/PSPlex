function Get-PlexServer
{
	<#
		.SYNOPSIS
		Returns a list of online Plex Servers that you have access to.
		
		.DESCRIPTION
		Returns a list of online Plex Servers that you have access to.
		
		.EXAMPLE
		Get-PlexServer

		.OUTPUTS
		accessToken       : abcd123456ABCDEFG
		name              : thor
		address           : 87.50.66.123
		port              : 32400
		version           : 1.16.0.1226-7eb2c8f6f
		scheme            : http
		host              : 87.50.66.123
		localAddresses    : 172.18.0.2
		machineIdentifier : 8986j4286yl055szhtjx1bytgibsgpv93neb8yv4
		createdAt         : 1550665837
		updatedAt         : 1562328805
		owned             : 1
		synced            : 0

		accessToken       : HIJKLMNO098765431
		name              : friendserver
		address           : 94.12.145.10
		port              : 32400
		version           : 1.16.1.1291-158e5b199
		scheme            : http
		host              : 94.12.145.10
		localAddresses    : 
		machineIdentifier : 534vgrzhrrp47oojircfdz9qxeqav4gkmqqnu1at
		createdAt         : 1520613024
		updatedAt         : 1562330172
		owned             : 0
		synced            : 0
		sourceTitle       : username_of_friend
		ownerId           : 6728195
		home              : 0
	#>
		
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
        [String]
        $name
    )

	if(!$PlexConfigData)
	{
		throw "You must call 'Get-PlexAuthenticationToken' before calling this function."
	}
	
	try 
	{
		$data = Invoke-RestMethod -Uri "https://plex.tv/api/servers`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET
		if($name)
		{
			[array]$results = $data.MediaContainer.Server | Where-Object { $_.name -eq $name }
		}
		else {
			[array]$results = $data.MediaContainer.Server
		}
    }
    catch
    {
        throw $_
    }

    return $results
}