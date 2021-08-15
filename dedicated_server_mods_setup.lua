--There are two functions that will install mods, ServerModSetup and ServerModCollectionSetup. Put the calls to the functions in this file and they will be executed on boot.

--ServerModSetup takes a string of a specific mod's Workshop id. It will download and install the mod to your mod directory on boot.
	--The Workshop id can be found at the end of the url to the mod's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=350811795
	--ServerModSetup("350811795")

--ServerModCollectionSetup takes a string of a specific mod's Workshop id. It will download all the mods in the collection and install them to the mod directory on boot.
	--The Workshop id can be found at the end of the url to the collection's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=379114180
	--ServerModCollectionSetup("379114180")
ServerModSetup("1185229307")
ServerModSetup("1378549454")
ServerModSetup("1758907750")
ServerModSetup("1839858501")
ServerModSetup("1868443140")
ServerModSetup("1872958406")
ServerModSetup("1880012014")
ServerModSetup("2187805379")
ServerModSetup("2339167956")
ServerModSetup("2376883615")
ServerModSetup("378160973")
ServerModSetup("501385076")
ServerModSetup("543945797")
ServerModSetup("631648169")
ServerModSetup("666155465")
ServerModSetup("758532836")
ServerModSetup("875994715")
ServerModSetup("1938752683")
ServerModSetup("2038128735")
