function Get-PlexUser
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$false)]
        [String]
        $username
    )

	if(!$PlexConfigData)
	{
		throw "You must call 'Get-PlexAuthenticationToken' before calling this function."
	}

	try 
	{
		$data = Invoke-RestMethod -Uri "https://plex.tv/api/users`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET
		if($username)
		{
			[array]$results = $data.MediaContainer.User | Where-Object { $_.username -eq $username }
		}
		else {
			[array]$results = $data.MediaContainer.User
		}
    }
    catch
    {
        throw $_
    }

    return $results
}