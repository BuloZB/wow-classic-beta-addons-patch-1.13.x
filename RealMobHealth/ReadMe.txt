Real Mob Health
by SDPhantom
https://www.wowinterface.com/forums/member.php?u=34145
===============================================================================

All Rights Reserved - Use at your own risk
UnZip contents into the "Interface\AddOns" folder in your WoW instalation directory

API Usage:
	RealMobHealth.IsMobGUID(guid)
	RealMobHealth.IsUnitMob(unit)
		Checks if unit/guid is a Mob, NPC, or Rare

	RealMobHealth.GetHealth(unit[, speculate])
		[string] unit		Unit to query health for
		[bool] speculate	Enables speculation for max health (calculation based off percentage and damage taken) [default: false]
	Returns:	currenthealth, maxhealth, currentisspeculated, maxisspeculated
		[number] currenthealth	Current calculated health based on damage taken	[nilable]
		[number] maxhealth	Max health, prefers to return recorded over speculated [nilable]
		[bool] currentisspeculated	true if currenthealth is based off percentage instead of damage taken
		[bool] maxisspeculated		true if maxhealth is based off percentage and damage taken
	Note:	currenthealth and maxhealth will be nil if there is not enough data to return a value.
===============================================================================

Versions:
1.0	(2019-05-19)
	-Classic release
	-Records damage taken of nearby mobs from the CombatLog
	-Obtains mob level using mouseover/target/partytarget/raidtarget and if enabled, nameplates
	-TargetFrame and Nameplates show text values for health, TargetFrame also shows mana/rage/energy
	-Gametooltip shows which mobs have had their health recorded
