/*
Script for managine units in a convoy

_extraParams:
	[_armedVehGroups, _unarmedVehGroups, _destPos]
		_armedVehGroups - array of [_vehUnitData, _crewUnitData, _infGroupID] per every vehicle that can shoot with crew:
			_vehGroupID - _groupID of the vehicle group
			_infGroupID - the groupID of the infantry this vehicle is carrying, or -1 if it carries no inf. groups
		_unarmedVehGroups - the sama as _armedVehArray but for vehicles that can't shoot (trucks, ...)
		_destPos - the position of the destination
		
	//TODO: add management of killed units and damaged vehicles. Add reallocation of units from a broken vehicle to a new one.
*/

#define DEBUG

params ["_scriptObject", "_extraParams"];

convoy_fnc_getUnitHandles =
{
	//A function that helps manage _armedVehGroups and _unarmedVehGroups
	params ["_vehData", "_getCrew", "_getPassengers"];

	private _vehHandle = _vehData select 0;
	private _crewHandles = [];
	private _infHandles = [];
	//Check if the vehicle can actually move
	if(canMove _vehHandle) then
	{
		_crewHandles = if(_getCrew) then {_vehData select 1} else {[]};
		_infHandles = if(_getPassengers) then {units(_vehData select 2)} else {[]};
	}
	else
	{
		_crewHandles = [];
		_infHandles = [];
	};
	private _unitHandles = _crewHandles + _infHandles;
	
	_unitHandles
};

//Reorganize the convoy garrison
_extraParams params ["_armedVehGroups", "_unarmedVehGroups", "_destPos"];
#ifdef DEBUG
	diag_log format ["AI_fnc_landConvoy.sqf: _armedVehGroups: %1, _unarmedVehGroups: %2", _armedVehGroups, _unarmedVehGroups];
#endif
//Read other things
private _gar = _scriptObject getVariable ["AI_garrison", objNull];

//Merge the vehicle groups into one VEHICLE-MEGA-GROUP!
//Create a new group
private _rarray = [];
private _rid = [_gar, G_GT_veh_non_static, _rarray] call gar_fnc_addNewEmptyGroup;
waitUntil {sleep 0.01; [_gar, _rid] call gar_fnc_requestDone};
private _vehGroupID = _rarray select 0;

//Fill arrays and move vehicles and their crew to the new group
private _armedVehArray =[]; //[]
private _unarmedVehArray = []; //[]
{ // forEach _armedVehGroups
	private _groupUnits = ([_gar, _x select 0] call gar_fnc_getGroupUnits);
	//Get vehicle unit handle
	private	_vehUnitData = _groupUnits select 0;
	private _vehUnitHandle = [_gar, _vehUnitData] call gar_fnc_getUnitHandle;
	//Get crew unit handles
	private _crewUnitData = _groupUnits - [_vehUnitData];
	private _crewUnitHandles = [];
	{
		_crewUnitHandles pushBack ([_gar, _x] call gar_fnc_getUnitHandle);
	} forEach _crewUnitData;
	//Get infantry group handle
	private _infGroupID = _x select 1;
	private _infGroupHandle = if(_infGroupID != -1) then
	{ [_gar, _infGroupID] call gar_fnc_getGroupHandle; } else { grpNull };
	_armedVehArray pushBack [_vehUnitHandle, _crewUnitHandles, _infGroupHandle];
	{ //forEach _groupUnits;
		[_gar, _x, _vehGroupID, false] call gar_fnc_joinGroup;
	} forEach _groupUnits;
} forEach _armedVehGroups;
private _rid = 0;
{ // forEach _unarmedVehGroups
	private _groupUnits = ([_gar, _x select 0] call gar_fnc_getGroupUnits);
	//Get vehicle unit handle
	private	_vehUnitData = _groupUnits select 0;
	private _vehUnitHandle = [_gar, _vehUnitData] call gar_fnc_getUnitHandle;
	//Get crew unit handles
	private _crewUnitData = _groupUnits - [_vehUnitData];
	private _crewUnitHandles = [];
	{
		_crewUnitHandles pushBack ([_gar, _x] call gar_fnc_getUnitHandle);
	} forEach _crewUnitData;
	//Get infantry group handle
	private _infGroupID = _x select 1;
	private _infGroupHandle = if(_infGroupID != -1) then
	{ [_gar, _infGroupID] call gar_fnc_getGroupHandle; } else { grpNull };
	_unarmedVehArray pushBack [_vehUnitHandle, _crewUnitHandles, _infGroupHandle];
	{ //forEach _groupUnits;
		_rid = [_gar, _x, _vehGroupID, false] call gar_fnc_joinGroup;
	} forEach _groupUnits;
} forEach _unarmedVehGroups;
//Wait until the last request is finished
waitUntil {sleep 0.01; [_gar, _rid] call gar_fnc_requestDone};

private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;
_vehGroupHandle deleteGroupWhenEmpty false; //If all crew dies, inf groups might take their seats

//Spawn a script
private _hScript = [_scriptObject, _vehGroupHandle, _armedVehArray, _unarmedVehArray, _destPos] spawn
{
	//Read input parameters
	params ["_scriptObject", "_vehGroupHandle", "_armedVehArray", "_unarmedVehArray", "_destPos"];
	
	private _gar = _scriptObject getVariable ["AI_garrison", objNull];
	
	#ifdef DEBUG
		diag_log format ["AI_fnc_landConvoy.sqf: _armedVehArray: %1, _unarmedVehArray: %2", _armedVehArray, _unarmedVehArray];
	#endif
	
	//We need the power of the Finite State Machine!
	private _state = "MOUNT";
	private _stateChanged = true;
	while {true} do
	{
		sleep 2;
		switch (_state) do
		{
			case "MOUNT":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered MOUNT state"];
					//Order drivers of unarmed vehicles to stop so that infantry can mount
					doStop (units _vehGroupHandle);
					_stateChanged = false;
				};
				
				//Order the crew to get in
				private _infAndCrewHandles = [];
				{
					private _crewHandles = [_x, true, false] call convoy_fnc_getUnitHandles;
					private _passHandles = [_x, false, true] call convoy_fnc_getUnitHandles;
					private _vehHandle = _x select 0;
					if(count _passHandles > 0) then
					{
						//Cargo seats can be FFVs, in which case they are actually turrets, not cargo seats!
						private _fullCrew = _vehHandle call misc_fnc_getFullCrew;
						private _psgTurrets = _fullCrew select 3;
						private _npt = count _psgTurrets;
						private _nCargo = _fullCrew select 4;
						{
							//First assign units as FFV turrets, then as cargo
							if (_forEachIndex < _npt) then
							{ _x assignAsTurret [_vehHandle, _psgTurrets select _forEachIndex]; } else
							{ _x assignAsCargo _vehHandle; };
						} forEach _passHandles;
					};
					_infAndCrewHandles append _crewHandles;
					_infAndCrewHandles append _passHandles;
				} forEach (_armedVehArray + _unarmedVehArray);
				_infAndCrewHandles orderGetIn true;
				
				//Check if all the infantry has boarded their vehicles
				private _infAndCrewInVehHandles = _infAndCrewHandles select {!(vehicle _x isEqualTo _x)};
				diag_log format ["AI_fnc_landConvoy: waiting for units to get in: %1 / %2", count _infAndCrewInVehHandles, count _infAndCrewHandles];
				//Also check behaviour
				private _beh = behaviour (leader _vehGroupHandle);
				#ifdef DEBUG
					diag_log format ["AI_fnc_landConvoy.sqf: behaviour: %1", _beh];
				#endif
				call
				{
					if (_beh == "COMBAT") exitWith
					{
						_state = "DISMOUNT";
						_stateChanged = true;
					};
					if(count _infAndCrewInVehHandles == count _infAndCrewHandles) exitWith
					{
						//Switch to "MOVE" state
						_state = "MOVE";
						_stateChanged = true;
					};
				};

			};
			case "MOVE":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered MOVE state"];
					units _vehGroupHandle doFollow (leader _vehGroupHandle);
					while {(count (waypoints _vehGroupHandle)) > 0} do
					{
						deleteWaypoint [_vehGroupHandle, ((waypoints _vehGroupHandle) select 0) select 1];
					};
					//Add new waypoint
					private _wp0 = _vehGroupHandle addWaypoint [_destPos, 100, 0, "Destination"];
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					//Set convoy separation
					{
						private _vehHandle = _x select 0;
						_vehHandle limitSpeed 666666; //Set the speed of all vehicles to unlimited
						_vehHandle setConvoySeparation 35;
						_vehHandle forceFollowRoad true;
					} forEach (_armedVehArray + _unarmedVehArray);
					//Limit the speed of the leading vehicle
					(vehicle (leader _vehGroupHandle)) limitSpeed 40; //Speed in km/h
					_stateChanged = false;
				};
				//Check that all the units are inside their vehicles
				private _infAndCrewHandles = [];
				{
					_infAndCrewHandles append ([_x, true, true] call convoy_fnc_getUnitHandles);
				} forEach (_armedVehArray + _unarmedVehArray);
				private _infAndCrewInVehHandles = _infAndCrewHandles select {!(vehicle _x isEqualTo _x)};				
				//Check the behaviour of the group
				private _beh = behaviour (leader _vehGroupHandle);
				#ifdef DEBUG
					diag_log format ["AI_fnc_landConvoy.sqf: behaviour: %1", _beh];
				#endif
				call
				{
					if (_beh == "COMBAT") exitWith
					{
						_state = "DISMOUNT";
						_stateChanged = true;
					};
					if(count _infAndCrewInVehHandles != count _infAndCrewHandles) exitWith
					{
						//Just why the hell did you jump out???
						#ifdef DEBUG
							diag_log "AI_fns_landConvoy: not all units are in vehicles during MOVE state!";
						#endif
						_state = "MOUNT";
						_stateChanged = true;
					};
				};
			};
			case "DISMOUNT":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered DISMOUNT state"];
					while {(count (waypoints _vehGroupHandle)) > 0} do
					{
						deleteWaypoint [_vehGroupHandle, ((waypoints _vehGroupHandle) select 0) select 1];
					};
					private _wp0 = _vehGroupHandle addWaypoint [getPos leader _vehGroupHandle, 15, 0, "Hold"];
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					_stateChanged = false;
					//Order drivers of all vehicles to stop
					{
						private _vehHandle = _x select 0;						
						_vehHandle forceFollowRoad false;
						if(!isNull (_x select 2)) then //If this vehicle is carrying an infantry group
						{
							private _crewHandles = [_x, true, false] call convoy_fnc_getUnitHandles;
							doStop _crewHandles;
						};
					} forEach (_unarmedVehArray + _armedVehArray);
				};
				
				//Order infantry units to dismount
				private _infHandles = [];
				{ //Dismount passengers of armed vehicles
					_infHandles append ([_x, false, true] call convoy_fnc_getUnitHandles);
				} forEach _armedVehArray;
				{ //Dismount drivers and passengers of unarmed vehicles
					_infHandles append ([_x, true, true] call convoy_fnc_getUnitHandles);
				} forEach _unarmedVehArray;
				_infHandles orderGetIn false;

				//Check if all the infantry has dismounted
				private _infOnFootHandles = _infHandles select {(vehicle _x) isEqualTo _x};
				diag_log format ["AI_fnc_landConvoy: waiting for units to get out: %1 / %2", count _infOnFootHandles, count _infHandles];
				if(count _infOnFootHandles == count _infHandles) then
				{
					//Switch to "COMBAT" state
					_state = "COMBAT";
					_stateChanged = true;
				};
			};
			case "COMBAT":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered COMBAT state"];
					_stateChanged = false;
				};
				private _beh = behaviour (leader _vehGroupHandle);
				#ifdef DEBUG
					diag_log format ["AI_fnc_landConvoy.sqf: behaviour: %1", _beh];
				#endif
				if (_beh == "AWARE") then
				{
					_state = "MOUNT";
					_stateChanged = true;
				};
			};
		};
	};
};

//Return the script handle
_hScript