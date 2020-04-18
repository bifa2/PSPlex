function Get-PlexUser
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$false)]
        [String]
		$Username,

		[Parameter(Mandatory=$false)]
        [Switch]
		$IncludeToken
    )

	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	try 
	{
		$data = Invoke-RestMethod -Uri "https://plex.tv/api/users`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET
		if($Username)
		{
			[array]$results = $data.MediaContainer.User | Where-Object { $_.username -eq $Username }
		}
		else {
			[array]$results = $data.MediaContainer.User
		}

		if($IncludeToken)
		{
			$CurrentPlexServer = Get-PlexServer -name $PlexConfigData.PlexServer -ErrorAction Stop
			$results | ForEach-Object { 
				$UserToken = Get-PlexUserToken -machineIdentifier $CurrentPlexServer.machineIdentifier -Username $_.username -ErrorAction Stop
				$_ | Add-Member -NotePropertyName 'token' -NotePropertyValue $UserToken.token -Force
			}
		}


    }
    catch
    {
        throw $_
    }

	$results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.User") }
    return $results
}