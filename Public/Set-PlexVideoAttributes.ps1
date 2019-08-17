
function Set-PlexVideoAttributes
{
    param(
        [Parameter(Mandatory=$false)]
        [String]
        $LibraryID,

        [Parameter(Mandatory=$true)]
        [String]
        $id,

        [Parameter(Mandatory=$false)]
        [String]
        $title,

        [Parameter(Mandatory=$false)]
        [String]
        $sortTitle,

        [Parameter(Mandatory=$false)]
        [String]
        $originallyAvailableAt,

        [Parameter(Mandatory=$false)]
        [String]
        $studio
    )

	if(!$PlexConfigData)
	{
		throw "You must call 'Get-PlexAuthenticationToken' before calling this function."
	}
	
	$RestEndpoint   = "library/sections/9/all"

    try {
        $Excluded = 'PlexServer','LibraryID','id','Verbose','Confirm','Force','WhatIf','AuthToken'
        $ParameterArray = @("X-Plex-Token=$($PlexConfigData.Token)","id=$($id)")
		$PSBoundParameters.GetEnumerator() | Where-Object { $Excluded -notcontains $_.Key} | ForEach-Object { $ParameterArray += "$($_.Key).value=$($_.Value)" }
        $ParamString = $ParameterArray -join '&'
		$ParamString
		
        Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$PlexServer`:$($PlexConfigData.Port)/$RestEndpoint`?type=1&includeExternalMedia=1&$ParamString" -Method "PUT"
    }
    catch
    {
        throw $_
    }
}