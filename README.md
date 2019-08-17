# About

This project started out as a script to copy a playlist from my account as a Plex Server owner to another user's account (on the same server). Slowly it got broken up into separate functions and become a simple PowerShell module.

# Getting Started:

1. Save the folder `PSPlex` into a module path for PowerShell.
    * Example: `C:\Users\YourUsername\Documents\WindowsPowerShell\Modules`
2. Open PowerShell.
3. Run `Get-PlexAuthenticationToken`. You will be prompted to enter your Plex account name and password.
4. Run `Save-PlexConfiguration` and provide your Plex server name, the Plex hostname, protocol and port.
    * Example: `Save-PlexConfiguration -PlexServer myserver -PlexServerHostname namaste.yourdomain.com -protocol https -port 32400`

After this step, in future you can just run `Import-PlexConfiguration` to work with your Plex server.

In the event that your token should become invalid and you receive `401` errors, try running steps 3 and 4 again. It is step 3 that retrieves an access token from Plex.

# Examples:

Get a list of users with access to your server:

> `Get-PlexUser`

Copy Playlists from your account to another:

> `Copy-PlexPlaylist -PlaylistName 'Family' -Username 'steveo@contoso.com' -verbose`

Copy Playlists from your account to all accounts:

> `Get-PlexPlaylist | Foreach-Object { Copy-PlexPlaylist -PlaylistName $_.title -Username 'yourfriend@theiremail.com' -verbose }`

# Limitations:

* Currently only written to work against a single Plex Server.

# To do:

* Syntax block for all functions.
* Write the following playlist functions: New-PlexPlaylist. Add `name` parameter support to all?
* Write the following collection: Get-PlexCollection, Add-PlexItemToCollection.
* Write Helper Script to create IMDB Top 250 (where present in the library).