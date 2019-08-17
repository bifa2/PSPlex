function Get-PlexCollection
{  
	[CmdletBinding()]
	param(		
        [Parameter(Mandatory=$false)]
        [PSObject]
        $ID
	)
	
	if(!$PlexConfigData)
	{
		throw "You must call 'Get-PlexAuthenticationToken' before calling this function."
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