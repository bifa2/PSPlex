function Get-PlexUserToken
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true)]
        [String]
        $machineIdentifier,

        [Parameter(Mandatory=$false)]
        [String]
        $Username
    )

    # Use the machine ID to get the Server Access Tokens for the users:
    try 
    {
        Write-Verbose -Message "Getting all server access tokens"
        $data = Invoke-RestMethod -Uri "https://plex.tv/api/servers/$($machineIdentifier)/access_tokens.xml?auth_token=$($PlexConfigData.Token)&includeProfiles=1&includeProviders=1" -ErrorAction Stop
        
        # Get data for the user we wish to copy to:
        <#
            Example object:
            token                : their-server-access-token
            username             : their-username
            thumb                : https://plex.tv/users/426798c426fed6ea/avatar?c=1551449703
            title                : their-email@domain.com
            id                   : 18658724
            owned                : 0
            allow_sync           : 0
            allow_camera_upload  : 0
            allow_channels       : 0
            allow_tuners         : 0
            allow_subtitle_admin : 0
            filter_all           : 
            filter_movies        : 
            filter_music         : 
            filter_photos        : 
            filter_television    : 
            scrobble_types       : 
            profile_settings     : profile_settings
            library_section      : {library_section, library_section, library_section}
        #>
        if($Username)
        {
            $data.access_tokens.access_token | Where-Object { $_.username -eq $Username }
            return
        }
        else 
        {
            return $data.access_tokens.access_token
        }
    }
    catch 
    {
        throw $_
    }
}