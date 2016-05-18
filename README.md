## GMPermaWorld

![Title Image](https://cloud.githubusercontent.com/assets/2367602/13025048/6e15b2f8-d253-11e5-9954-0cda4e8b3567.jpg)

#### About:
Garry's Mod by default has a built in function to make persistent entities however the feature only works in Sandbox and Sandbox derived gamemodes.
GMPermaWorld or Permanent World is a simple script to keep entities persistent on a game/server without using Sandbox.
It is a highly modified version of a [script](https://facepunch.com/showthread.php?t=735138) written by FPtje in 2009.

#### Installation:
Simple place the file sv_PermaWorld.lua into your *garrysmod/lua/autorun/server/* folder.

You could also put it into a gamemode module if the code supports it. For example: *gamemodes/DarkRP/gamemode/modules/permaworld/sv_PermaWorld.lua*

#### Configuration:
- DBprefix \> *SQL database name prefix. Default: "gmpw"*
- LoadOnStart \> *Auto-load entities when you start a game/server. Default: true*
- SaveIndicator \> *Flash entities green/red on addition/removal to/from the database. Default: false*
- DeleteOnRemove \> *Delete entities from the map after removal from database. Default: false*

#### Usage:
To add an entity you wish to make persistent to the database, look at it and run: **PermaWorld_Add**

To make an entity no-longer persistent and remove it from the database, look at it and run: **PermaWorld_Remove**

To reload the persistent entities for any reason (see: accidental deletion), run: **PermaWorld_Restore**

To purge the persistent world database of all entities, run: **PermaWorld_Purge**

To remove all persistent world entities from the map, run: **PermaWorld_CleanMap**

#### Notes:
- If the colour or material of an entity has been modified it will keep these changes. 
- I have added a toolgun for ease of use when using sandbox derived gamemodes. 
 
 
If you do not know how to open the console or run a console command, please read [this article](https://developer.valvesoftware.com/wiki/Developer_Console).

#### Links:
[Steam Workshop](http://steamcommunity.com/sharedfiles/filedetails/?id=622773812)
[Garrysmods.org](https://garrysmods.org/download/57312/gmpermaworld)

#### Support:
**Please direct all your questions to the GitHub issue tracker:** 
https://github.com/mattkrins/GMPermaWorld/issues