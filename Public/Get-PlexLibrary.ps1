function Get-PlexLibrary
{
    <#
        .SYNOPSIS
        By default, returns a list of libraries on a Plex server.    
            
        .DESCRIPTION
        By default, returns a list of libraries on a Plex server. 
        If -ID is specified, a single library is returned with
        
        .PARAMETER PlexServerHostname
        Fully qualified hostname for the Plex server (e.g. myserver.mydomain.com)
        
        .PARAMETER Protocol
        http or https
        
        .PARAMETER Port
        Parameter description
        
        .PARAMETER ID
        If specified, returns a specific library.
        
        .EXAMPLE
        Get-PlexLibrary
    #>
    
	[CmdletBinding()]
	param(		
        [Parameter(Mandatory=$false)]
        [String]
        $ID
	)
	
	if($Null -eq $PlexConfigData.PlexServer)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

    $RestEndpoint   = "library/sections/$ID"

	try 
	{
		[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
		if($ID)	
		{
			[array]$results = $data.MediaContainer
		}
		else {
			[array]$results = $data.MediaContainer.Directory
		}

    }
    catch
    {
        throw $_
	}
	
	return $results
}