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

	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting all users"
	try 
	{
		$data = Invoke-RestMethod -Uri "https://plex.tv/api/users`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
		if($data.MediaContainer.Size -eq 0)
		{
			return
		}
    }
    catch
    {
        throw $_
	}
	

	#############################################################################
	# Managed users have no username property (only title). As this module uses 'username', copy title to username:
	$data.MediaContainer.user | Where-Object { $null -eq $_.username } | ForEach-Object { 
		$_ | Add-Member -NotePropertyName 'username' -NotePropertyValue $_.title -Force
	}


	#############################################################################
	if($Username)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering by username"
		[array]$results = $data.MediaContainer.User | Where-Object { $_.username -eq $Username }
	}
	else
	{
		[array]$results = $data.MediaContainer.User
	}


	#############################################################################
	if($IncludeToken)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting access token(s)"
		try {
			$CurrentPlexServer = Get-PlexServer -name $PlexConfigData.PlexServer -ErrorAction Stop
			$results | ForEach-Object { 
				$UserToken = Get-PlexUserToken -machineIdentifier $CurrentPlexServer.machineIdentifier -Username $_.username -ErrorAction Stop
				$_ | Add-Member -NotePropertyName 'token' -NotePropertyValue $UserToken.token -Force
			}
		}
		catch {
			throw $_
		}

	}

    
	#############################################################################
	# Append type and return results
	$results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.User") }
    return $results
}