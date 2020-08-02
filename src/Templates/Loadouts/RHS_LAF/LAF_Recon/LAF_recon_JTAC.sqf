removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "rhsgref_helmet_pasgt_flecktarn";
_RandomGoggles = selectRandom ["G_Balaclava_blk", "G_Bandanna_blk"];
this addGoggles _RandomGoggles;
this forceAddUniform "rhsgref_uniform_gorka_1_f";
this addVest "V_TacVestIR_blk";
this addBackpack "B_TacticalPack_blk";

this addWeapon "rhs_weap_m4a1_blockII_M203_bk";
this addPrimaryWeaponItem "rhsusf_acc_nt4_black";
this addPrimaryWeaponItem "acc_pointer_IR";
_RandomSight = selectRandom ["rhsusf_acc_su230a", "rhsusf_acc_su230a_mrds"];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_Mk262_Stanag_Pull";
this addPrimaryWeaponItem "rhs_mag_M433_HEDP";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_acc_omega9k";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";
this addWeapon "rhsusf_bino_lerca_1200_tan";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_mk84";};
this addItemToVest "rhs_mag_an_m14_th3";
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_30Rnd_556x45_Mk262_Stanag_Pull";};
this addItemToVest "rhs_mag_an_m8hc";
for "_i" from 1 to 10 do {this addItemToBackpack "rhs_mag_M433_HEDP";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m714_White";};
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_mag_M585_white";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_M397_HET";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m661_green";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m662_red";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m713_Red";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m715_Green";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_15";