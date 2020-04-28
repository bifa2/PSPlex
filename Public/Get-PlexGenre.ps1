function Get-PlexGenre
{  
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true)]
        [Int]
        $LibraryID,

        [Parameter(Mandatory=$false)]
        [PSObject]
		$ID
	)
	
	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	if($ID)
	{
		$RestEndpoint = "library/sections/$LibraryID/all?genre=$ID&X-Plex-Token=$($PlexConfigData.Token)"
	}
	else
	{
		$RestEndpoint = "library/sections/$LibraryID/genre`?`X-Plex-Token=$($PlexConfigData.Token)"
	}    

	try 
	{
		$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint" -Method GET -ErrorAction Stop
		if($data.MediaContainer.Size -eq 0)
		{
			return
		}
    }
    catch
    {
        throw $_
	}

	if($ID)
	{
		return $data.MediaContainer
	}
	else
	{
		return $data.MediaContainer.Directory
	}

}
