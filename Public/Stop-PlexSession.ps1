function Stop-PlexSession
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true,ParameterSetName='SessionId')]
        [String]$SessionId,

		[Parameter(Mandatory=$true,ParameterSetName='SessionObject',ValueFromPipeline = $true)]
        $SessionObject,

        [Parameter(Mandatory=$false)]
        [String]$Reason = 'Apologies! This is temporary. Message your Plex contact, or try again later!'
	)
	
	begin{

		if($PlexConfigData.PlexServer -eq $Null)
		{
			throw "You must call 'Get-PlexAuthenticationToken' or 'Import-PlexConfiguration' before calling this function."
		}
	
		$RestEndpoint   = "status/sessions/terminate"

		# If the user passed an ID, create an object using the same structure as the session object
		if($PSCmdlet.ParameterSetName -eq 'SessionId')
		{
			[Array]$SessionObject = [PSCustomObject]@{
				Session = @{
					Id = $SessionId
				}
			}
		}
		else {
		}
	}
	process
	{
		foreach($Session in $SessionObject)
		{
			try 
			{
				Write-Verbose -Message "Terminating session: $($Session.Id)"
				[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?`X-Plex-Token=$($PlexConfigData.Token)&reason=$Reason&sessionId=$($Session.Session.Id)" -Method GET -ErrorAction Stop
				$ItemType = ($data.MediaContainer | Get-Member -MemberType Property | Select-Object -Last 1).Name
				[array]$results = $data.MediaContainer.$ItemType
			}
			catch
			{
				throw $_
			}	
		}
	}
	end {
		return $results
	}


}