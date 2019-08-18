function Copy-PlexPlaylist
{
	<#
		.SYNOPSIS
		This function will copy a playlist from your account to another user account on your server.
		
		.DESCRIPTION
		This function will copy a playlist from your account to another user account on your server.
		Alternatively, if you wish to overwrite the destination playlist, use the -Force switch.
		
		.PARAMETER PlexServer
		The name of your Plex Server as you name it, within Plex Media Server (not the hostname of the machine it's running on).

		.PARAMETER PlaylistName
		Parameter description
		
		.PARAMETER NewPlayListName
		Create the playlist with a different name.

		.PARAMETER User
		The user you wish to copy the playlist to. Note: This can sometimes be a username, but at other times it will be an
		email address.
		
		.PARAMETER Force
		Overwrite the contents of the destination playlist.
		
		.EXAMPLE
		Copy-PlexPlaylist -PlaylistName 'MARVEL' -User 'user@domain.com'
	#>
	
	
	param(
		[Parameter(Mandatory=$true)]
        [String]
		$PlaylistName,

		[Parameter(Mandatory=$false)]
        [String]
		$NewPlaylistName,

		[Parameter(Mandatory=$true)]
        [String]
        $Username,
		
		[Parameter(Mandatory=$false)]
		[Switch]
		$Force
	)
	
	if($PlexConfigData.PlexServer -eq $Null)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	# Get a list of servers that we have access to:
	try 
	{
		Write-Verbose -Message "Getting list of Plex servers"
		$CurrentPlexServer = Get-PlexServer -name $PlexConfigData.PlexServer -ErrorAction Stop
		if(!$CurrentPlexServer) 
		{
			throw "Could not find $CurrentPlexServer in $($Servers -join ', ')"
		}
	}
	catch 
	{
		throw $_
	}


	# Use the machine ID to get the Server Access Tokens for the users:
	try 
	{
		Write-Verbose -Message "Getting server access token for user $Username"
		$UserServerToken = Get-PlexUserToken -machineIdentifier $CurrentPlexServer.machineIdentifier -Username $Username
		if(!$UserServerToken) 
		{
			throw "Could not find an access token for user $Username on server $($PlexConfigData.PlexServer). Check the username/email and whether they have access."
		}
	}
	catch 
	{
		throw $_
	}
	

	# Get the Playlist we want to copy:
	try 
	{
		Write-Verbose -Message "Finding playlist $PlaylistName"
		$Playlist = Get-PlexPlaylist -ErrorAction Stop | Where-Object { $_.title -eq $PlaylistName }
		if(!$Playlist) 
		{
			throw "Could not find playlist $PlaylistName."
		}
	}
	catch 
	{
		throw $_
	}


	if($NewPlaylistName)
	{
		$PlaylistTitle = $NewPlaylistName
	}
	else
	{
		$PlaylistTitle = $Playlist.title
	}

	# Check whether the user already has a playlist by this name:
	try 
	{
		Write-Verbose -Message "Checking $Username account for existing playlist"
		[array]$data = Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/playlists`?`X-Plex-Token=$($UserServerToken.Token)" -ErrorAction Stop

		$ExistingPlaylistsWithSameName = $data.MediaContainer.Playlist | Where-Object { $_.title -eq $PlaylistTitle }
		if($ExistingPlaylistsWithSameName)
		{
			Write-Verbose -Message "Removing existing Playlist."
			foreach($PL in $ExistingPlaylistsWithSameName)
			{
				try
				{
					Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/playlists/$($PL.ratingKey)`?`X-Plex-Token=$($UserServerToken.Token)" -Method DELETE -ErrorAction Stop | Out-Null
				}
				catch
				{
					Write-Warning -Message "Could not delete existing playlist."
					throw $_
				}
			}
		}
	}
	catch 
	{
		throw $_
	}

	
	# Establish whether the playlist is smart or not; this will determine how we create it:

	# If playlist is not smart:
	if($Playlist.smart -eq 0)
	{
		Write-Verbose -Message "Original playlist is NOT smart."

		# Get the Playlist items:
		try 
		{
			Write-Verbose -Message "Getting playlist items"
			$PlaylistItems = Get-PlexPlaylistItem -PlaylistID $Playlist.ratingKey -ErrorAction Stop
		}
		catch 
		{
			throw $_
		}

		if(!$PlaylistItems)
		{
			throw "Could not get playlist items."
		}

		# Create a new playlist on the server, under the user's account:
		try 
		{
			Write-Verbose -Message "Creating playlist"
			$Data = Invoke-RestMethod -Uri "http://$($CurrentPlexServer.address)`:$($CurrentPlexServer.port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$(($PlaylistItems.ratingKey) -join ',')&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($UserServerToken.Token)" -Method "POST" -Erroraction Stop
			return $Data.MediaContainer.Playlist
		}
		catch 
		{
			throw $_
		}
	}
	elseif($Playlist.smart -eq 1)
	{
		Write-Verbose -Message "Original playlist is smart."

		# Make an additional lookup to get the playlist object as this contains what parameters define how it is smart:
		$PlaylistData = Invoke-RestMethod -Uri "http://$($CurrentPlexServer.address)`:$($CurrentPlexServer.port)/playlists/$($Playlist.ratingKey)?X-Plex-Token=$($PlexConfigData.Token)" -Method Get
		$Playlist = $PlaylistData.MediaContainer.Playlist

		# Parse the data in the playlist to establish what parameters were used to create the smart playlist.

		# Split on the 'all?':
		$SmartPlaylistParams = ($Playlist.content -split 'all%3F')[1]

		try
		{
			Write-Verbose -Message "Creating playlist"
			$Data = Invoke-RestMethod -Uri "http://$($CurrentPlexServer.address)`:$($CurrentPlexServer.port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/sections/2/all?$SmartPlaylistParams&title=$PlaylistTitle&smart=1&type=video&X-Plex-Product=Plex%20Web&X-Plex-Version=3.95.2&X-Plex-Client-Identifier=ni91ijrs5miuwc37d5esdrr3&X-Plex-Platform=Chrome&X-Plex-Platform-Version=75.0&X-Plex-Sync-Version=2&X-Plex-Model=bundled&X-Plex-Device=Windows&X-Plex-Device-Name=Chrome&X-Plex-Device-Screen-Resolution=1088x937%2C1920x1080&X-Plex-Token=$($UserServerToken.Token)&X-Plex-Language=en&X-Plex-Text-Format=plain" -Method "POST"  -Erroraction Stop
			return $Data.MediaContainer.Playlist
		}
		catch
		{
			throw $_
		}

	}
	else 
	{
		Write-Warning -Message "No work done."
	}
}