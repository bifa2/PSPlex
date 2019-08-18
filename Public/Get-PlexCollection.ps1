function Get-PlexCollection
{  
	[CmdletBinding()]
	param(		
        [Parameter(Mandatory=$false)]
        [PSObject]
        $ID
	)
	
	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

    $RestEndpoint   = "library/sections/2/collection/$ID"

	try 
	{
		[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
    }
    catch
    {
        throw $_
	}
	
	return $data.MediaContainer.Directory
}