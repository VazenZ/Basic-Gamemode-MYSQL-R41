/*
	Base Roleplay script by LuminouZ
	
	Credits:
	> SA:MP - Kalcor
	> MYSQL - pBlueG
	> sscanf2 - y_less
	> ZCMD - zeex
	
** V1 Changelog **

> Added Administrator system
> Added Some Player & Admin Commands
> Added Server Side Money system
*/


#include <a_samp>
#include <sscanf2>
#include <a_mysql>
#include <zcmd>
#include <foreach>

#define DATABASE_ADDRESS "localhost"
#define DATABASE_USERNAME "root"
#define DATABASE_PASSWORD ""
#define DATABASE_NAME "baseroleplay"

#define SERVER_NAME "Basic Roleplay"
#define NEWBIE_MONEY 100

#define SendServerMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_SERVER, "SERVER:{FFFFFF} "%1)

#define SendSyntaxMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_GREY, "SYNTAX:{FFFFFF} "%1)

#define SendErrorMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_GREY, "ERROR:{FFFFFF} "%1)
	
//Colors
#define COLOR_SERVER      (0xC6E2FFFF)
#define COLOR_WHITE       (0xFFFFFFFF)
#define COLOR_RED         (0xFF0000FF)
#define COLOR_CYAN        (0x33CCFFFF)
#define COLOR_LIGHTRED    (0xFF6347FF)
#define COLOR_LIGHTGREEN  (0x9ACD32FF)
#define COLOR_YELLOW      (0xFFFF00FF)
#define COLOR_GREY        (0xAFAFAFFF)
#define COLOR_HOSPITAL    (0xFF8282FF)
#define COLOR_PURPLE      (0xD0AEEBFF)
#define COLOR_LIGHTYELLOW (0xF5DEB3FF)
#define COLOR_DARKBLUE    (0x1394BFFF)
#define COLOR_ORANGE      (0xFFA500FF)
#define COLOR_LIME        (0x00FF00FF)
#define COLOR_GREEN       (0x33CC33FF)
#define COLOR_BLUE        (0x2641FEFF)
#define COLOR_FACTION     (0xBDF38BFF)
#define COLOR_RADIO       (0x8D8DFFFF)
#define COLOR_LIGHTBLUE   (0x007FFFFF)
#define COLOR_DEPARTMENT  (0xF0CC00FF)
#define COLOR_ADMINCHAT   (0x33EE33FF)
#define DEFAULT_COLOR     (0xFFFFFFFF)
//Dialog
#define DIALOG_REGISTER         1
#define DIALOG_LOGIN            2
#define DIALOG_AGE              3
#define DIALOG_GENDER           4
#define DIALOG_UNUSED           5

new MySQL:sqldata;

enum playerData
{
	pID,
	pPassword[32],
	pName[MAX_PLAYER_NAME],
	pAge,
	pGender,
	pCreated,
	pMoney,
	pScore,
	pSpawn,
	pSkin,
	pInjured,
	Float:pPos[3],
	Float:pHealth,
	pAdmin,
};

new PlayerData[MAX_PLAYERS][playerData];

new stock g_arrVehicleNames[][] = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
    "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "SWAT Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Streak", "Freight", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
    "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Car", "SFPD Car", "LVPD Car",
    "Police Rancher", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
    "Boxville", "Tiller", "Utility Trailer"
};
main()
{
	print("\n----------------------------------");
	print(" Basic Gamemode loaded!");
	print("----------------------------------\n");
}

GetVehicleModelByName(const name[])
{
	if (IsNumeric(name) && (strval(name) >= 400 && strval(name) <= 611))
	    return strval(name);

	for (new i = 0; i < sizeof(g_arrVehicleNames); i ++)
	{
	    if (strfind(g_arrVehicleNames[i], name, true) != -1)
	    {
	        return i + 400;
		}
	}
	return 0;
}

stock SendNearbyMessage(playerid, Float:radius, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 16)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 16); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit CONST.alt 4
		#emit SUB
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (IsPlayerNearPlayer(i, playerid, radius))
			{
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (IsPlayerNearPlayer(i, playerid, radius))
		{
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

IsNumeric(const str[])
{
	for (new i = 0, l = strlen(str); i != l; i ++)
	{
	    if (i == 0 && str[0] == '-')
			continue;

	    else if (str[i] < '0' || str[i] > '9')
			return 0;
	}
	return 1;
}

ReturnVehicleModelName(model)
{
	new
	    name[32] = "None";

    if (model < 400 || model > 611)
	    return name;

	format(name, sizeof(name), g_arrVehicleNames[model - 400]);
	return name;
}

stock IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
	static
		Float:fX,
		Float:fY,
		Float:fZ;

	GetPlayerPos(targetid, fX, fY, fZ);

	return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}


stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	/*
     *  Custom function that uses #emit to format variables into a string.
     *  This code is very fragile; touching any code here will cause crashing!
	*/
	if ((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

stock SendClientMessageToAllEx(color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	/*
     *  Custom function that uses #emit to format variables into a string.
     *  This code is very fragile; touching any code here will cause crashing!
	*/
	if ((args = numargs()) == 2)
	{
	    SendClientMessageToAll(color, text);
	}
	else
	{
		while (--args >= 2)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessageToAll(color, str);

		#emit RETN
	}
	return 1;
}

stock LoadMYSQL()
{
	sqldata = mysql_connect(DATABASE_ADDRESS,DATABASE_USERNAME,DATABASE_PASSWORD,DATABASE_NAME);
	
	if(mysql_errno(sqldata) != 0)
	{
	    print("[SQL] - Connection Failed!");
	}
	else
	{
		print("[SQL] - Connection Estabilished!");
	}
}

stock SetPlayerValidScore(playerid, amount)
{
	PlayerData[playerid][pScore] += amount;
	SetPlayerScore(playerid, PlayerData[playerid][pScore]);
	return 1;
}

stock GiveMoney(playerid, amount)
{
	PlayerData[playerid][pMoney] += amount;
	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
	return 1;
}

stock GetMoney(playerid)
{
	return PlayerData[playerid][pMoney];
}

stock SaveFirstPlayer(playerid)
{
	PlayerData[playerid][pMoney] = NEWBIE_MONEY;
	PlayerData[playerid][pScore] = 0;
	PlayerData[playerid][pPos][0] = 1769.6141;
	PlayerData[playerid][pPos][1] = 1862.0129;
	PlayerData[playerid][pPos][2] = 13.5768;
	SetPlayerValidScore(playerid, PlayerData[playerid][pScore]);
	GivePlayerMoney(playerid, NEWBIE_MONEY);
	print("SaveFirstPlayer Called");
	return 1;
}

stock GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
 	GetPlayerName(playerid,name,sizeof(name));
	return name;
}

stock CheckPlayerAccount(playerid)
{
	new query[256];
	mysql_format(sqldata, query, sizeof(query), "SELECT * FROM `characters` WHERE `PlayerName` = '%e' LIMIT 1",GetName(playerid));
	mysql_tquery(sqldata, query, "OnQueryFinished", "d", playerid);
}

stock ThreadPlayer(playerid)
{
	new query[512];
	mysql_format(sqldata,query,sizeof(query),"INSERT INTO `characters` (`PlayerName`,`PlayerPassword`) VALUES('%e','%s')",GetName(playerid),PlayerData[playerid][pPassword]);
	mysql_tquery(sqldata,query);
	print("Thread Player Called");
	return 1;
}

forward OnQueryFinished(playerid);
public OnQueryFinished(playerid)
{
	new string[512];
	if(cache_num_rows() > 0)
	{
	    cache_get_value_name_int(0, "pID", PlayerData[playerid][pID]);
	    
	    cache_get_value_name(0, "PlayerPassword", PlayerData[playerid][pPassword], 32);

	    format(string,sizeof(string),"Welcome back to "SERVER_NAME" %s\nPlease input your password to continue:",GetName(playerid));
	    ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Account Login",string,"Login","Cancel");
	}
	else
	{
	    format(string,sizeof(string),"Welcome to "SERVER_NAME" %s\nYour account is doesn't exists on this server\nPlease input your Password for Register:",GetName(playerid));
	    ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"Account Register",string,"Register","Cancel");
	}
	return 1;
}
public OnGameModeInit()
{
	LoadMYSQL();
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);

	SetNameTagDrawDistance(10.0);
	ShowPlayerMarkers(0);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_REGISTER)
	{
	    if(!response)
	        return Kick(playerid);

        if(strlen(inputtext) < 7)
			return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,"Account Register","ERROR: You must Specify more than 7 Character for Password.","Register","Quit");

        if(strlen(inputtext) > 32)
			return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,"Account Register","ERROR: You Can't specify more than 32 Character for password.","Register","Quit");
			
		format(PlayerData[playerid][pPassword], 32, "%s", inputtext);

		SaveFirstPlayer(playerid);
		ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Character Age", "Please Insert your Character Age", "Continue", "Cancel");
	}
	if(dialogid == DIALOG_AGE)
	{
	    if(!response)
	        return Kick(playerid);
	        
		if(strlen(inputtext) >= 70)
		    return ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Character Age", "ERROR: Cannot more than 70 years old!", "Continue", "Cancel");

		PlayerData[playerid][pAge] = strval(inputtext);
		ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, "Character Gender", "Male\nFemale", "Continue", "Cancel");
	}
	if(dialogid == DIALOG_GENDER)
	{
	    if(!response)
	        return Kick(playerid);
	        
		if(listitem == 0)
		{
		    PlayerData[playerid][pGender] = 1;
			PlayerData[playerid][pSkin] = 240;
		    ThreadPlayer(playerid);
		    SetSpawnInfo(playerid, 0, 240, 1769.6141, -1862.0129, 13.5768, 0.0, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
			PlayerData[playerid][pPos][0] = 1769.6141;
			PlayerData[playerid][pPos][1] = 1862.0129;
			PlayerData[playerid][pPos][2] = 13.5768;
			PlayerData[playerid][pHealth] = 100;
            SavePlayerData(playerid);
		}
		if(listitem == 1)
		{
		    PlayerData[playerid][pGender] = 2;
		    PlayerData[playerid][pSkin] = 172;
		    ThreadPlayer(playerid);
		    SetSpawnInfo(playerid, 0, 172, 1769.6141,-1862.0129,13.5768, 0.0, 0, 0, 0, 0, 0, 0);
			SpawnPlayer(playerid);
			PlayerData[playerid][pPos][0] = 1769.6141;
			PlayerData[playerid][pPos][1] = 1862.0129;
			PlayerData[playerid][pPos][2] = 13.5768;
			PlayerData[playerid][pHealth] = 100;
			SavePlayerData(playerid);
		}
	}
	if(dialogid == DIALOG_LOGIN)
	{
        if(!response)
			return Kick(playerid);
			
        if(!strcmp(inputtext,PlayerData[playerid][pPassword],false,32))
        {
            new query[256];
            mysql_format(sqldata, query, sizeof(query), "SELECT * FROM `characters` WHERE `PlayerName`='%e' LIMIT 1",GetName(playerid));
            mysql_tquery(sqldata, query, "ThreadLogin", "d", playerid);
        }
        else
        {
            new
                string[128];
		    format(string,sizeof(string),"Invalid Passowrd!\nWelcome back to "SERVER_NAME" %s\nPlease input your password to continue:",GetName(playerid));
		    ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Account Login",string,"Login","Cancel");
		}
	}
	return 1;
}

stock SavePlayerData(playerid)
{
	new Float:health;
	GetPlayerHealth(playerid, health);
	PlayerData[playerid][pHealth] = health;
	GetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]);
	new query[1012];
	mysql_format(sqldata,query,sizeof(query),"UPDATE `characters` SET `PlayerPosX`='%.4f',`PlayerPosY`='%.4f',`PlayerPosZ`='%.4f', `PlayerSkin` = '%d', `PlayerGender` = '%d', `PlayerAge` = '%d', `PlayerMoney` = '%d', `PlayerScore` = '%d'",
	PlayerData[playerid][pPos][0],
	PlayerData[playerid][pPos][1],
	PlayerData[playerid][pPos][2],
	PlayerData[playerid][pSkin],
	PlayerData[playerid][pGender],
	PlayerData[playerid][pAge],
	PlayerData[playerid][pMoney],
	PlayerData[playerid][pScore],
	GetName(playerid)
	);
	mysql_format(sqldata,query,sizeof(query),"%s, `PlayerCreated` = '%d', `PlayerHealth` = '%.4f', `PlayerAdmin` = '%d' WHERE `PlayerName` = '%s'",
	query,
	PlayerData[playerid][pCreated],
	PlayerData[playerid][pHealth],
	PlayerData[playerid][pAdmin],
	GetName(playerid)
	);
	mysql_pquery(sqldata,query);
	print("SavePlayerData Called");
	return 1;
}

forward ThreadLogin(playerid);
public ThreadLogin(playerid)
{
	cache_get_value_name_int(0, "pID", PlayerData[playerid][pID]);
	
	cache_get_value_name_float(0,"PlayerHealth",PlayerData[playerid][pHealth]);
	cache_get_value_name_int(0,"PlayerMoney",PlayerData[playerid][pMoney]);
	cache_get_value_name_int(0,"PlayerSkin",PlayerData[playerid][pSkin]);
	cache_get_value_name_int(0,"PlayerLevel",PlayerData[playerid][pScore]);
	cache_get_value_name_float(0,"PlayerPosX",PlayerData[playerid][pPos][0]);
	cache_get_value_name_float(0,"PlayerPosY",PlayerData[playerid][pPos][1]);
	cache_get_value_name_float(0,"PlayerPosZ",PlayerData[playerid][pPos][2]);
	cache_get_value_name_int(0,"PlayerGender",PlayerData[playerid][pGender]);
    cache_get_value_name_int(0,"PlayerAge",PlayerData[playerid][pAge]);
    cache_get_value_name_int(0,"PlayerCreated",PlayerData[playerid][pCreated]);
    cache_get_value_name_int(0,"PlayerAdmin",PlayerData[playerid][pAdmin]);
    SetSpawnInfo(playerid, 0, PlayerData[playerid][pSkin], PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2], 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	PlayerData[playerid][pSpawn] = 1;
	print("Thread Login Called");
	SetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	CheckPlayerAccount(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SavePlayerData(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if (!IsPlayerInAnyVehicle(playerid))
	{
		ApplyAnimation(playerid, "GANGS", "prtial_gngtlkA", 4.1, 0, 1, 1, 1, strlen(text) * 100, 1);
        SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "%s says: %s", GetName(playerid), text);
		SetTimerEx("StopChatting", strlen(text) * 100, false, "d", playerid);
		return 0;
	}
	return 1;
}

forward StopChatting(playerid);
public StopChatting(playerid)
{
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if (GetPlayerMoney(playerid) != PlayerData[playerid][pMoney])
	{
	    ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
	}
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

//Player Commands
CMD:savedata(playerid, params[])
{
	SavePlayerData(playerid);
	return 1;
}
CMD:pay(playerid, params[])
{
	static
	    userid,
	    amount;

	if (sscanf(params, "ud", userid, amount))
	    return SendSyntaxMessage(playerid, "/pay [playerid/name] [amount]");

	if (userid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, userid, 5.0))
	    return SendErrorMessage(playerid, "That player is disconnected or not near you.");

	if (amount < 1)
	    return SendErrorMessage(playerid, "Please specify an amount above 1 dollar.");

	if (amount > GetMoney(playerid))
	    return SendErrorMessage(playerid, "You don't have that much money.");

	GiveMoney(playerid, -amount);
	GiveMoney(userid, amount);

	SendClientMessageEx(userid, COLOR_YELLOW, "PAYINFO: {FFFFFF}You've received $%d from %s", amount, GetName(playerid));

	SendClientMessageEx(playerid, COLOR_YELLOW, "PAYINFO: {FFFFFF}You've given $%d to %s", amount, GetName(userid));
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	PlayerPlaySound(userid, 1052, 0.0, 0.0, 0.0);
	
    ApplyAnimation(playerid, "DEALER", "shop_pay", 4.0, 0, 0, 0, 0, 0);
    ApplyAnimation(userid, "DEALER", "shop_pay", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

CMD:items(playerid, params[])
{
    new String[1012], Items[1012];
	if(GetMoney(playerid) > 0)
    {
    	format(String, sizeof(String), "Money\t\t($%d)\n{FFFFFF}", GetMoney(playerid));
     	strcat(Items, String);
	}
    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_LIST, "Inventory", Items, "Close", "");
    return 1;
}
//Admin Commands
CMD:kick(playerid, params[])
{
	static
	    userid,
	    reason[128];

    if (PlayerData[playerid][pAdmin] < 1)
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "us[128]", userid, reason))
	    return SendSyntaxMessage(playerid, "/kick [playerid/name] [reason]");

	if (userid == INVALID_PLAYER_ID)
	    return SendErrorMessage(playerid, "You have specified an invalid player.");

	SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s has kicked %s for: %s.", GetName(playerid), GetName(userid), reason);

	Kick(userid);
	return 1;
}

CMD:veh(playerid, params[])
{
	static
	    model[32],
		color1,
		color2;

    if (PlayerData[playerid][pAdmin] < 1)
	    return SendErrorMessage(playerid, "You don't have permission to use this command.");

	if (sscanf(params, "s[32]I(-1)I(-1)", model, color1, color2))
	    return SendSyntaxMessage(playerid, "/veh [model id/name] <color 1> <color 2>");

	if ((model[0] = GetVehicleModelByName(model)) == 0)
	    return SendErrorMessage(playerid, "Invalid model ID.");

	static
	    Float:x,
	    Float:y,
	    Float:z,
	    Float:a,
		vehicleid;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	vehicleid = CreateVehicle(model[0], x, y + 2, z, a, color1, color2, 0);

	if (GetPlayerInterior(playerid) != 0)
	    LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));

	if (GetPlayerVirtualWorld(playerid) != 0)
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
		
	SendServerMessage(playerid, "You have spawned a %s.", ReturnVehicleModelName(model[0]));
	return 1;
}

//Hiden Commands
CMD:beadmin(playerid, params[])
{
	PlayerData[playerid][pAdmin] = 10;
	return 1;
}
