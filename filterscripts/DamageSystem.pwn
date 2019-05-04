//=====================INCLUDES=====================

#include 	<a_samp>
#define FILTERSCRIPT

#include	<izcmd>
#include	<sscanf2>

//=====================DIALOGS======================

#define	DIALOG_DAMAGE 1927

//==================CONTROL PANEL===================

#define	MAX_DAMAGES	1000

enum {
	BODY_PART_TORSO = 3,
	BODY_PART_GROIN,
	BODY_PART_RIGHT_ARM,
	BODY_PART_LEFT_ARM,
	BODY_PART_RIGHT_LEG,
	BODY_PART_LEFT_LEG,
	BODY_PART_HEAD
}

main() { }
//===================ENUMERATORS====================

enum dmgInfo
{
	dmgDamage,
	dmgWeapon,
	dmgBodypart,
	dmgKevlarhit,
	dmgSeconds,
}
new DamageInfo[MAX_PLAYERS][MAX_DAMAGES][dmgInfo];

public OnFilterScriptInit()
{
	print("\n ======================================");
	print(" |          Damage System               |");
	print(" | By Hreesang with help from infin1tyy |");
	print(" ========================================\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	ResetPlayerDamages(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	ResetPlayerDamages(playerid);
	return 1;
}

CMD:damages(playerid, params[])
{
	new id, Float: pPos[3];
	
	if(sscanf(params, "u", id)) 
		return SendClientMessage(playerid, 0xFF6347FF, "USAGE: {FFFFFF}/damages [playerid/PartOfName]");

	if(!IsPlayerConnected(id)) 
		return SendClientMessage(playerid, 0xFF6347FF, "Playerid is not an active player.");
	
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);

	if(IsPlayerInRangeOfPoint(playerid, 7.0, pPos[0], pPos[1], pPos[2]))
		ShowPlayerDamages(id, playerid);
		
	else 
		return SendClientMessage(playerid, 0xB8BAC6FF, "You're too far away.");

	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart)
{
	if(IsPlayerConnected(playerid))
	{
		new id, Float: pHP, Float: pArm;

		GetPlayerHealth(playerid, pHP);
		GetPlayerArmour(playerid, pArm);

		for(new i = 0; i < MAX_DAMAGES; i++)
		{
			if(!DamageInfo[playerid][i][dmgDamage])
			{
				id = i;
				break;
			}
		}
		
		DamageInfo[playerid][id][dmgDamage] = floatround(amount, floatround_round);
		DamageInfo[playerid][id][dmgWeapon] = weaponid;
		DamageInfo[playerid][id][dmgBodypart] = bodypart;

		if(pArm > 0) DamageInfo[playerid][id][dmgKevlarhit] = 1;
		else if(pArm < 1) DamageInfo[playerid][id][dmgKevlarhit] = 0;

		DamageInfo[playerid][id][dmgSeconds] = gettime();
	}
	return 1;
}

GetWeaponNameEx(weaponid)
{
	new weaponname[60];
	GetWeaponName(weaponid, weaponname, sizeof(weaponname));
	return weaponname;
}

GetBodypartName(bodypart)
{
	new bodyname[11];
	switch(bodypart)
	{
		case BODY_PART_TORSO: bodyname = "TORSO";
		case BODY_PART_GROIN: bodyname = "GROIN";
		case BODY_PART_RIGHT_ARM: bodyname = "RIGHT ARM";
		case BODY_PART_LEFT_ARM: bodyname = "LEFT ARM";
		case BODY_PART_RIGHT_LEG: bodyname = "RIGHT ARM";
		case BODY_PART_LEFT_LEG: bodyname = "LEFT LEG";
		case BODY_PART_HEAD: bodyname = "HEAD";
		default: bodyname = "UNKNOWN";
	}
	return bodyname;
}

ResetPlayerDamages(playerid)
{
	for(new id = 0; id < MAX_DAMAGES; id++)
	{
		if(DamageInfo[playerid][id][dmgDamage] != 0)
		{
			DamageInfo[playerid][id][dmgDamage] = 0;
			DamageInfo[playerid][id][dmgWeapon] = 0;
			DamageInfo[playerid][id][dmgBodypart] = 0;
			DamageInfo[playerid][id][dmgKevlarhit] = 0;
			DamageInfo[playerid][id][dmgSeconds] = 0;
		}
	}
	return 1;
}

ShowPlayerDamages(playerid, toid)
{
	new str[1000], str1[500], count = 0, name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));

	for(new id = 0; id < MAX_DAMAGES; id++)
	{
		if(DamageInfo[playerid][id][dmgDamage] != 0) count++;
	}

	if(count == 0) return ShowPlayerDialog(toid, DIALOG_DAMAGE, DIALOG_STYLE_LIST, name, "There is no damage to display...", "Close", "");
	else if(count > 0)
	{
		for(new id = 0; id < MAX_DAMAGES; id++)
		{
			if(DamageInfo[playerid][id][dmgDamage] != 0)
			{
				format(str1, sizeof str1, "%d dmg from %s to %s (Kevlarhit: %d) %d s ago\n", 
					DamageInfo[playerid][id][dmgDamage], 
					GetWeaponNameEx(DamageInfo[playerid][id][dmgWeapon]), 
					GetBodypartName(DamageInfo[playerid][id][dmgBodypart]), 
					DamageInfo[playerid][id][dmgKevlarhit], gettime() - DamageInfo[playerid][id][dmgSeconds]
				);	

				strcat(str, str1);
			}
		}
		ShowPlayerDialog(toid, DIALOG_DAMAGE, DIALOG_STYLE_LIST, name, str, "Close", "");
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if (dialogid == DIALOG_DAMAGE) {
		if (response || !response)
			return 1;
	}
	return 1;
}