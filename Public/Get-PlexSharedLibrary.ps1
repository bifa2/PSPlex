function Get-PlexSharedLibrary
{
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true)]
        [String]
        $machineIdentifier
    )

    try {
        $data = Invoke-RestMethod -Uri "https://plex.tv/api/servers/$machineIdentifier/shared_servers`?`X-Plex-Token=$($PlexConfigData.Token)" -Method GET -ErrorAction Stop
        if($data.MediaContainer.Size -eq 0)
		{
			return
        }

        #############################################################################
        <#
        STUPID: The SharedServer nodes / properties for each user contain username/email but no title. This means we get an empty 
        attribute for username with no way to link it to a managed user. Example:

        <SharedServer id="2343434" username="" email="" userID="56456546" accessToken="dfg34fh45gtfg3feg" name="servername" acceptedAt="1569601183" 
        invitedAt="1569601183" allowSync="0" allowCameraUpload="0" allowChannels="0" allowTuners="0" 
        allowSubtitleAdmin="0" owned="1" allLibraries="0" filterAll="" filterMovies="" filterMusic="" filterPhotos="" filterTelevision="">
        <Section id="34545454" key="2" title="Films" type="movie" shared="1"/>
        <Section id="34556456" key="14" title="Films (4K/HDR)" type="movie" shared="0"/>
        <Section id="86754645" key="3" title="TV" type="show" shared="1"/>
        </SharedServer>

        # Managed users have no username property (only title). As this module uses 'username', copy title to username:
        $data.MediaContainer.SharedServer | Where-Object { $null -eq $_.username } | ForEach-Object { 
            $_ | Add-Member -NotePropertyName 'username' -NotePropertyValue $_.title -Force
        }
        #>
        
        [array]$results = $data.MediaContainer.SharedServer
    }
    catch
    {
        throw $_
    }

    #############################################################################
	# Append type and return results
	$results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.SharedLibrary") }
    return $results
}