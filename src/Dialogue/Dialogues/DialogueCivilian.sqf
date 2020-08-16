#include "..\common.hpp"
#include "..\..\Location\Location.hpp"
#include "..\..\AI\Commander\LocationData.hpp"
#include "..\..\Undercover\UndercoverMonitor.hpp"
#include "..\..\Intel\Intel.hpp"

// Test dialogue class

#define OOP_CLASS_NAME DialogueCivilian
CLASS("DialogueCivilian", "Dialogue")

	// <Civilian> object handle
	VARIABLE("civ");

	// We can incite civilian only once during the dialogue
	// todo it must be stored in Civilian object
	VARIABLE("incited");

	METHOD(new)
		params [P_THISOBJECT,  P_OBJECT("_unit0"), P_OBJECT("_unit1"), P_NUMBER("_clientID")];
		T_SETV("incited", false);

		pr _civ = CALLSM1("Civilian", "getCivilianFromObjectHandle", _unit0);
		T_SETV("civ", _civ);
	ENDMETHOD;

	protected override METHOD(getNodes)
		params [P_THISOBJECT, P_OBJECT("_unit0"), P_OBJECT("_unit1")];
		
		pr _phrasesPlayerAskMilitaryLocations = [
			"Connaissez-vous des avant-postes militaires dans la région?",
			"Connaissez-vous des lieux militaires par ici?",
			"Hé, y a-t-il des... tu sais... des endroits militaires près d'ici?",
			"Avez-vous vu des activités militaires par ici?",
			"Connaissez-vous des emplacements militaires ici?"
		];

		pr _phrasesIncite = [
			"Putain de police, ils n'arrêtent pas d'arrêter des innocents!",
			"Ces porcs militaristes paieront pour leurs crimes!",
			"Hier, ils ont arrêté la famille de mes amis à cause d'une soit disant activité terroriste... Mais ça, c'est la police qui le dit!",
			"La police a emmené mon frère hier, tu es peut-être le prochain!",
			"Avez-vous entendu parler de ces camps de détention illégaux? Je connais un gars qui est revenu d'un endroit horrible!",
			"Nous devons rester unis, car la prochaine fois que la police prendra l'un de nous cela sera peut-être pour une fausse raison!",
			"La police a jeté de la drogue à l'un de mes amis et l'a arrêté! Des connards!",
			"Nous devons demander justice pour tous les crimes de guerre commis par l'armée ici!",
			"Les militaires sont tellement corrompus! Il n'y a plus d'autre solution que de prendre les armes!"
		];

		pr _phrasesCivilianInciteResponse = [
			"Merde, c'est horrible!", "Je suis choqué d'entendre ça!",
			"Vous avez tellement raison!", "C'est horrible!", "Nous devrions mettre fin à ça!",
			"Oui! La vérité doit être révélée!", "Oh vraiment, ils ne disent pas ça à la télé!",
			"Merde, je n'en ai jamais entendu parler de ça à la radio locale!",
			// Écrit par Jasperdoit:
			"Vous êtes carrément en train de cracher les faits, mon pote! Il est temps que quelqu'un y mette un terme, et je suis partant pour ça!",
			"Vous avez raison, ils sont vraiment corrompus. Mettons-nous au travail sur un vrai changement!",
			"Ils ont vraiment du bâton dans le cul, montrons-leur qui sont les vrais patrons!",
			"Eh bien, il y a une solution, et cela implique les armes et la libération. Je suis partante si vous me le demandez!",
			"Je connais peut-être un moyen de corriger leur attitude! Il est temps que je m'implique!",
			"Moins ils ont le contrôle, mieux c'est! Comptez sur moi!"
		];

		pr _phrasesScare = [
			"Sortez d'ici, vite!",
			"Quelque chose de grave va se passer ici. Mieux vaut s'éloigner!",
			"Ce n'est pas sûr ici, fuyez!",
			"Cet endroit n'est pas sûr, tu ferais mieux de t'enfuir!",
			"Monsieur, vous feriez mieux de sortir d'ici, vite!",
			"Sortez d'ici! Cet endroit n'est pas sûr!"
		];

		pr _phrasesIntel = [
			"Savez-vous s'il y aura des manœuvres militaires à proximité?",
			"Avez-vous une idée si les militaires prévoient quelque chose?",
			"Une idée si l'armée prépare quelque chose?"
		];

		pr _phrasesAskHelp = [
			"La résistance a besoin de votre aide! Avez-vous des matériaux de construction?",
			"Écoutez, la résistance a besoin de matériaux de construction, en avez-vous?"
		];

		pr _phrasesAgreeHelp = [
			"Tenez, prenez ces matériaux de construction, c'est tout ce que j'ai.",
			"Prenez ces matériaux de construction, c'est tout ce que je peux faire pour vous."
		];

		pr _phrasesDontSupportResistance = [
			"Je ne peux pas vous aider.",
			"Désolé, je ne peux pas vous aider.",
			"Je ne peux rien faire pour vous."
		];

		pr _phrasesDontKnowIntel = [
			"Je ne sais rien de tel.",
			"Je n'ai pas connaissance de telles informations.",
			"Désolé, je ne sais rien de ce genre."
		];

		pr _array = [
			//NODE_SENTENCE("", TALKER_PLAYER, g_phrasesPlayerStartDialogue),
			NODE_SENTENCE("", TALKER_NPC, ["Sûr!" ARG "Oui?" ARG "Comment puis-je vous aider?"]),
			
			// Options: 
			NODE_OPTIONS("node_options", ["opt_locations" ARG "opt_intel" ARG "opt_incite" ARG "opt_askContribute" ARG "opt_scare" ARG "opt_time" ARG "opt_bye"]),

			// Option: ask about military locations
			NODE_OPTION("opt_locations", _phrasesPlayerAskMilitaryLocations),
			NODE_CALL("", "subroutineTellLocations"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: ask about intel
			NODE_OPTION("opt_intel", selectRandom _phrasesIntel),
			NODE_JUMP_IF("", "node_tellIntel", "knowsIntel", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesDontKnowIntel),
			NODE_JUMP("", "node_anythingElse"),

			NODE_CALL("node_tellIntel", "subroutineTellIntel"),
			NODE_JUMP("", "node_options"),

			// Option: incite civilian
			NODE_OPTION("opt_incite", _phrasesIncite),
			NODE_JUMP_IF("", "node_alreadyIncited", "isIncited", []),	// If already incited
			NODE_SENTENCE("", TALKER_NPC, _phrasesCivilianInciteResponse),
			NODE_CALL_METHOD("", "inciteCivilian", []),
			NODE_SENTENCE("", TALKER_PLAYER, "Dites-le aux autres!"),
			NODE_JUMP("", "node_options"),

			NODE_SENTENCE("node_alreadyIncited", TALKER_NPC, "Je sais! C'est dangereux d'en discuter."),
			NODE_JUMP("", "node_options"),

			// Option: ask for contribution
			NODE_OPTION("opt_askContribute", selectRandom _phrasesAskHelp),
			NODE_JUMP_IF("", "node_alreadyContributed", "hasContributed", []),
			NODE_JUMP_IF("", "node_giveBuildResources", "supportsResistance", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesDontSupportResistance),
			NODE_JUMP("", "node_anythingElse"),

			NODE_CALL_METHOD("node_giveBuildResources", "giveBuildResources", []),
			NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesAgreeHelp),
			NODE_JUMP("", "node_anythingElse"),

			NODE_SENTENCE("node_alreadyContributed", TALKER_NPC, "Désolé j'ai déjà donné tout ce que je pouvais!"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: scare civilian
			NODE_OPTION("opt_scare", _phrasesScare),
			NODE_CALL_METHOD("", "scareCivilian", []),
			NODE_END(""),

			// Option: ask about time
			NODE_OPTION("opt_time", "Quelle heure est-il?"),
			NODE_SENTENCE_METHOD("", TALKER_NPC, "sentenceTime"),
			NODE_SENTENCE("", TALKER_PLAYER, "Merci!"),
			NODE_JUMP("", "node_anythingElse"),

			// Option: leave
			NODE_OPTION("opt_bye", "A plus! Je dois partir maintenant."),
			NODE_SENTENCE("", TALKER_NPC, ["A plus!" ARG "Au revoir!" ARG "A bientôt!"]),
			NODE_END(""),

			// Genertic 'Anything else?' reply after the end of some option branch
			NODE_SENTENCE("node_anythingElse", TALKER_NPC, "Rien d'autre?"),
			NODE_JUMP("", "node_options") // Go back to options
		];

		T_CALLM1("generateLocationsNodes", _array); // Extra nodes are appended to the end
		pr _civ = T_GETV("civ");
		pr _loc = GETV(_civ, "loc");
		T_CALLM2("generateIntelNodes", _array, _loc);

		_array;
	ENDMETHOD;

	METHOD(generateLocationsNodes)
		params [P_THISOBJECT, P_ARRAY("_nodes")];

		OOP_INFO_0("generateLocationsNodes");

		// Resolve which locations are known
		pr _unit = T_GETV("unit0");
		private _locs = CALLSM0("Location", "getAll");
		private _locsNear = _locs select {
			pr _type = CALLM0(_x, "getType");
			pr _dist = CALLM0(_x, "getPos") distance _unit;
			(_dist < 4000) &&
			(_type != LOCATION_TYPE_CITY)
		};

		OOP_INFO_1("  Nearby locations: %1", _locsNear);

		_locsCivKnows = _locsNear select {
			pr _type = CALLM0(_x, "getType");
			pr _dist = CALLM0(_x, "getPos") distance _unit;
			// Civilian can't tell about everything, but they surely know about police stations and locations which are very close
			(!(_type in [LOCATION_TYPE_CAMP, LOCATION_TYPE_RESPAWN])) && // Array of types the civilian can't know about
			{
				(random 10 < 5) ||
				{_type == LOCATION_TYPE_POLICE_STATION}
				// If it's very close, civilians will surely tell about it
			}
		};

		OOP_INFO_1("  Locations known by civilian: %1", _locsCivKnows);

		_a = [];
		_a pushBack NODE_SENTENCE("subroutineTellLocations", TALKER_NPC, ["Laisse-moi réfléchir ..." ARG "Donnez-moi une seconde ..." ARG "Un instant. Laissez-moi réfléchir ..."]);
		
		if (count _locsCivKnows == 0) then {
			pr _str = "Non, il n'y en a pas à des kilomètres à la ronde.";
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _str);
		} else {
			pr _str = "Oui, je connais quelques endroits comme ça ...";
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _str);

			{ // forEach _locsCivKnows;
				pr _loc = _x;
				pr _type = CALLM0(_loc, "getType");
				pr _locPos = CALLM0(_loc, "getPos");
				pr _bearing = _unit getDir _locPos;
				pr _distance = _unit distance2D _locPos;
				pr _bearings = ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"];
				pr _bearingID = (round (_bearing/45)) % 8;

				// Strings
				pr _typeString = CALLSM1("Location", "getTypeString", _type);
				pr _bearingString = _bearings select _bearingID;
				pr _distanceString = if(_distance < 400) then {
					selectRandom ["tout près.", "à moins de 400 mètres.", "juste par ici.", "à cinq minutes à pied d'ici."]
				} else {
					if (_distance < 1000) then {
						selectRandom ["pas trop loin d'ici.", "à moins d'un kilomètre.", "10 minutes à pied d'ici.", "pas loin d'ici du tout."];
					} else {
						selectRandom ["très loin.", "assez loin.", "plus d'un kilomètre d'ici.", "assez loin d'ici."];
					};
				};
				pr _intro = selectRandom [	"Il y a un",
											"Je sais pour un",
											"Je pense qu'il y a un",
											"Il y a quelque temps, j'en ai vu un",
											"Un ami m'a parlé d'un",
											"Les gens sont nerveux à propos d'un",
											"Les gens parlent d'un",
											"Il y a longtemps, il y avait un",
											"Pas sûr des coordonnées, il y a un"];

				pr _posString = if (_type == LOCATION_TYPE_POLICE_STATION) then {
					pr _locCities = CALLSM1("Location", "getLocationsAtPos", _locPos) select {
						CALLM0(_x, "getType") == LOCATION_TYPE_CITY
					};
					if (count _locCities > 0) then {
						format ["at %1", CALLM0(_locCities select 0, "getName")];
					} else {
						format ["to the %1", _bearingString];
					};
				} else {
					format ["to the %1", _bearingString];
				};

				pr _text = format ["%1 %2 %3, %4", _intro, _typeString, _posString, _distanceString];
				
				_a pushBack NODE_SENTENCE("", TALKER_NPC, _text);
				// todo add player's suspiciousness

				// After this sentence is said, reveal the location
				pr _args = [_loc, _type, _distance];
				_a pushBack NODE_CALL_METHOD("", "revealLocation", _args);

			} forEach _locsCivKnows;

			// Civilian: I must go
			_strMustGo = selectRandom [
				"C'est tout ce que je peux vous dire.",
				"Je ne sais rien d'autre.",
				"C'est tout ce que je sais."
			];
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _strMustGo);
		};

		// This dialogue part is called as a subroutine
		// Therefore we must return back
		_a pushBack NODE_RETURN("");

		// Combine the node arrays
		_nodes append _a;

	ENDMETHOD;

	METHOD(generateIntelNodes)
		params [P_THISOBJECT, P_ARRAY("_nodes"), P_OOP_OBJECT("_loc")];

		OOP_INFO_2("generateIntelNodes: location: %1 %2", _loc, CALLM0(_loc, "getName"));

		_a = [];
		_a pushBack NODE_SENTENCE("subroutineTellIntel", TALKER_NPC, ["Laisse-moi réfléchir..." ARG "Donnez-moi une seconde..." ARG "Un instant. Laissez-moi réfléchir..."]);

		pr _phrasesIntelSource = [
			"Un ami m'a parlé d'un",
			"Un ami a dit qu'il avait entendu quelqu'un parler d'un",
			"J'ai entendu des gars parler d'un",
			"Je pense avoir entendu des policiers parler d'un",
			"Mon ami m'a parlé d'un",
			"Il y a quelque temps, j'ai entendu des soldats parler d'un"
		];

		pr _intelArray = CALLM0(_loc, "getIntel");
		if (count _intelArray > 0) then {
			{
				pr _intel = _x;
				pr _intelState = GETV(_intel, "state");
				// Check if it's a future event
				// If it's stil lactive or inactive, but not ended
				if (_intelState != INTEL_ACTION_STATE_END) then {					
					pr _departDate = GETV(_intel, "dateDeparture");
					// Fir for minutes being above 60 sometimes
					pr _year = _departDate#0;
					_departDate = numberToDate [_year, (dateToNumber _departDate)];
					pr _intelNameStr = CALLM0(_intel, "getShortName");
					pr _dateStr = _departDate call misc_fnc_dateToISO8601;
					pr _text = format ["%1 %2 at %3", selectRandom _phrasesIntelSource, _intelNameStr, _dateStr];
					_a pushBack NODE_SENTENCE("", TALKER_NPC, _text);
					_a pushBack NODE_CALL_METHOD("", "revealIntel", [_intel]);
				};
			} forEach _intelArray;

			// Civilian: I must go
			_strMustGo = selectRandom [
				"Qu'est-ce que tu vas faire de cette information de toute façon?",
				"Au fait, pourquoi demandez-vous cela?",
				"Ne me dis pas pourquoi tu demandes, d'accord?",
				"Je ne veux pas savoir ce que vous allez faire de ces informations!",
				"Ne leur dis pas que je t'ai dit ça!",
				"J'ai un mauvais pressentiment à propos de ça."


			];
			_a pushBack NODE_SENTENCE("", TALKER_NPC, _strMustGo);
		} else {
			_a pushBack NODE_SENTENCE("", TALKER_NPC, selectRandom _phrasesDontKnowIntel);
		};

		// This dialogue part is called as a subroutine
		// Therefore we must return back
		_a pushBack NODE_RETURN("");

		// Combine the node arrays
		_nodes append _a;

	ENDMETHOD;

	METHOD(revealLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc"), P_STRING("_type"), P_NUMBER("_distance")];

		OOP_INFO_1("revealLocation: %1", _this);

		// Also reveal the location to player's side
		private _updateLevel = -6;
		private _accuracyRadius = 0;
		private _dist = _distance;
		private _distCoeff = 0.22; // How much accuracy radius increases with  distance
		//diag_log format ["   %1 %2", _x, _type];

		switch (_type) do {
			case LOCATION_TYPE_CITY: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
			case LOCATION_TYPE_POLICE_STATION: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
			case LOCATION_TYPE_ROADBLOCK: {
				_updateLevel = CLD_UPDATE_LEVEL_SIDE;
				_accuracyRadius = 50+_dist*_distCoeff;
			};
			// We don't report camps to player
			// case LOCATION_TYPE_CAMP: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
			case LOCATION_TYPE_BASE: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
			case LOCATION_TYPE_OUTPOST: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
			case LOCATION_TYPE_AIRPORT: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; _accuracyRadius = 50+_dist*_distCoeff; };
		};

		if (_updateLevel != -6) then {
			//diag_log format ["    adding to database"];
			private _commander = CALLSM1("AICommander", "getAICommander", side group T_GETV("unit1"));
			CALLM2(_commander, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false ARG false ARG _accuracyRadius]);
		};
	ENDMETHOD;

	METHOD(revealIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];
		OOP_INFO_1("revealIntel: %1", _intel);
		pr _player = T_GETV("unit1");
		pr _cmdr = CALLSM1("AICommander", "getAICommander", side group _player);
		CALLM2(_cmdr, "postMethodAsync", "inspectIntel", [_intel]);
	ENDMETHOD;

	METHOD(sentenceTime)
		params [P_THISOBJECT];
		if (random 10 < 2) then {
			selectRandom
				[
					"Êtes-vous sérieux? Vous avez une montre à la main!",
					"Tu n'as pas de téléphone?",
					"Tu n'as pas de montre toi-même?"
				];
		} else {
			format ["It is %1", [_time, "HH:MM"] call BIS_fnc_timeToString];
		};
	ENDMETHOD;

	METHOD(isIncited)
		params [P_THISOBJECT];
		pr _civ = T_GETV("unit0");
		T_GETV("incited") || UNDERCOVER_IS_UNIT_SUSPICIOUS(_civ);
	ENDMETHOD;

	METHOD(hasContributed)
		params [P_THISOBJECT];
		pr _civ = T_GETV("civ");
		GETV(_civ, "hasContributed");
	ENDMETHOD;

	METHOD(knowsIntel)
		params [P_THISOBJECT];
		pr _civ = T_GETV("civ");
		GETV(_civ, "knowsIntel");
	ENDMETHOD;

	METHOD(supportsResistance)
		params [P_THISOBJECT];
		pr _civ = T_GETV("civ");
		GETV(_civ, "supportsResistance");
	ENDMETHOD;

	METHOD(inciteCivilian)
		params [P_THISOBJECT];
		if (!T_CALLM0("isIncited")) then {

			pr _pos = getPos T_GETV("unit0");
			CALLSM("AICommander", "addActivity", [CALLM0(gGameMode, "getEnemySide") ARG _pos ARG (7+random(7))]);
			pr _civ = T_GETV("unit0");
			UNDERCOVER_SET_UNIT_SUSPICIOUS(_civ, true);
			T_SETV("incited", true);

			// Notify game mode
			CALLM2(gGameMode, "postMethodAsync", "civilianIncited", [_pos]);
		};
	ENDMETHOD;

	METHOD(scareCivilian)
		params [P_THISOBJECT];
		pr _civ = T_GETV("unit0");
		CALLSM1("AIUnitCivilian", "dangerEventHandler", _civ);
	ENDMETHOD;

	METHOD(giveBuildResources)
		params [P_THISOBJECT];

		SETV(T_GETV("civ"), "hasContributed", true);

		pr _civ = T_GETV("unit0");
		pr _player = T_GETV("unit1");
		pr _count = round (10 + random 10);

		pr _canAdd = _player canAddItemToBackpack ["vin_build_res_0", _count];

		if (_canAdd) then {
			(unitbackpack _player) addMagazineCargoGlobal ["vin_build_res_0", _count];
		} else {
			pr _holder = createVehicle ["WeaponHolderSimulated", getPosATL _civ, [], 0, "CAN_COLLIDE"]; 
			_holder addBackpackCargoGlobal ["B_FieldPack_khk", 1];
			(firstbackpack _holder) addMagazineCargoGlobal ["vin_build_res_0", _count];
		};


	ENDMETHOD;

ENDCLASS;