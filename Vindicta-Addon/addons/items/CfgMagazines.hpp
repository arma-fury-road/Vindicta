#include "\z\vindicta\addons\main\classFactory.hpp"

class CfgMagazines
{
	class CA_Magazine;
	class vin_document_0: CA_Magazine
	{
		mass=0;
		scope=2;
		count = 1;
		displayName="Military documents";
		descriptionShort = "A few military documents. Pick it up to study the intel.";
		picture = QPATHTOF(icons\inv_ic_mildocs1.paa);
		model = "\A3\Structures_F_EPC\Items\Documents\Document_01_F.p3d";
	};

	class vin_document_1: CA_Magazine
	{
		mass=0;
		scope=2;
		count = 1;
		displayName="Military documents";
		descriptionShort = "Some military documents. Pick it up to study the intel.";
		picture = QPATHTOF(icons\inv_ic_mildocs2.paa);
		model = "\A3\Structures_F\Items\Documents\FilePhotos_F.p3d";
	};

	class vin_tablet_0: CA_Magazine
	{
		mass = 0.1;
		scope=2;
		count = 1;
		displayName="Tactical tablet";
		descriptionShort = "A military tactical tablet. Pick it up to study the intel.";
		picture = QPATHTOF(icons\inv_ic_tabletTactical.paa);
		model = "\A3\Props_F_Exp_A\Military\Equipment\Tablet_02_F.p3d";
	};

	class vin_tablet_1: CA_Magazine
	{
		mass = 0.1;
		scope=2;
		count = 1;
		displayName="Personal tablet";
		descriptionShort = "A personal tablet. Pick it up to study the intel";
		picture = QPATHTOF(icons\inv_ic_tabletWhite.paa);
		model = "\A3\Structures_F_Heli\Items\Electronics\Tablet_01_F.p3d";
	};
	
	
	COPY_CLASS_512(vin_document_0, vin_document_0)
	COPY_CLASS_512(vin_document_1, vin_document_1)
	COPY_CLASS_512(vin_tablet_0, vin_tablet_0)
	COPY_CLASS_512(vin_tablet_1, vin_tablet_1)

	class vin_build_res_0: CA_Magazine
	{
		buildResource = 1; // Amount of build resources, used by the scenario
		count = 1; // Ammount of bullets, we make it so that one box = one box in the arsenal, ok?
		mass = 8; // In arma it's really volume, not mass
		scope=2;
		displayName="Construction resources";
		descriptionShort = "Resources to build different things";
		picture = "\A3\EditorPreviews_F_Orange\Data\CfgVehicles\Land_Brick_01_F.jpg";
		hiddenSelections[] = {};
		hiddenSelectionsTextures[] = {};
		model = "\a3\Props_F_Orange\Civilian\Constructions\Brick_01_F.p3d";
	};

	class vin_pills: CA_Magazine
	{
		count = 1;
		mass = 0.1;
		scope = 2;
		displayName="Strange pills";
		descriptionShort = "!! Don't use it if you can't tolerate flashing images !! Double-click to use. Carefully.";
		picture = QPATHTOF(icons\inv_ic_pills.paa);
		model = "\A3\Structures_F_EPA\Items\Medical\Antibiotic_F.p3d";
	};
};