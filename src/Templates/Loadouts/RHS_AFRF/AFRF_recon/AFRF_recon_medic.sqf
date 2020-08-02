removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_6b47_ess","rhs_6b47","rhs_6b47_bala","rhs_6b47_ess_bala"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "rhs_uniform_gorka_r_g";
this addVest "rhs_6b13_EMR_6sh92";
this addBackpack "rhs_medic_bag";

this addWeapon "rhs_weap_ak74m_zenitco01_b33_grip1";
this addPrimaryWeaponItem "rhs_acc_tgpa";
this addPrimaryWeaponItem "rhs_acc_perst3";
_RandomSight = selectRandom ["rhs_acc_rakursPM", "rhs_acc_1p87", "rhs_acc_ekp8_18"];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N22_AK";
this addPrimaryWeaponItem "rhs_acc_grip_ffg2";
this addWeapon "rhs_weap_pya";
this addHandgunItem "rhs_mag_9x19_17";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x19_17";};
this addItemToUniform "O_R_IR_Grenade";
for "_i" from 1 to 6 do {this addItemToVest "rhs_30Rnd_545x39_7N22_AK";};
this addItemToVest "rhs_mag_rdg2_black";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_fakel";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_fakels";};
this addItemToVest "rhs_mag_rgn";
this addItemToVest "rhs_mag_rgo";
this addItemToBackpack "Medikit";
for "_i" from 1 to 2 do {this addItemToBackpack "FirstAidKit";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";