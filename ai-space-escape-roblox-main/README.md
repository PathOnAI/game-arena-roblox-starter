# game-arena-space
This is a minimal backbone code implementation for a GameArena project.
It's set in a space station where the user is trying to escape a self-destruction.

Here is the link to the game: https://www.roblox.com/games/114904064694961/AI-Space-Escape

# Setup
You need Rojo in order to use this codebase. Rojo is a Roblox Development plugin that enables you to sync code from your file system (which has Git/GitHub version control) into RobloxStudio. **This is a typically a one-way sync.**

## Download Rojo here:

- RobloxStudio Plugin: https://create.roblox.com/store/asset/6415005344?externalSource=www&assetType=Plugin
- VSCode extension: https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo
- Luau LSP (optional language server): https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp
- StyLua (optional code formatter): https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua

- More info and documentation here: https://rojo.space
- A guided tutorial here: https://devforum.roblox.com/t/how-to-setup-and-use-rojo-may-2023/2322815

## To set up the codebase:

1. You need Rojo first (see above)
2. Clone this repository, and open it in VSCode
3. In RobloxStudio, open the game you would like to sync code to.

(⚠️ **Note:** If you try to sync code into the master game, it will show up for everyone that is working on the master game. For that reason, it is recommended that you make a separate/personal/local copy of the game to work on and sync code to, or else you may conflict with someone else.)

## To sync code (one-way from VSC to RS):

1. In VSCode, open the Rojo plugin using the command palette, and start the project server.
2. In RobloxStudio, open the Rojo plugin in the desired game, and press Connect to start syncing.
3. Your code will now be applied to the desired game.
4. ⚠️ Other people can't sync to the same game while you're connected, so it's recommended that you connect only briefly when syncing to a shared game. Disconnect Rojo plugin (or stop the Rojo server) when you're done syncing.
