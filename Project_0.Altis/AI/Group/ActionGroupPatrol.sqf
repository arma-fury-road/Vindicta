#include "common.hpp"

/*
Class: ActionGroup.ActionGroupPatrol
*/

#define pr private

CLASS("ActionGroupPatrol", "ActionGroup")
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hG = GETV(_thisObject, "hG");
		
		// Regroup
		(units _hG) commandFollow (leader _hG);
		
		// Set behaviour
		_hG setBehaviour "SAFE";
		
		// Set combat mode
		_hG setCombatMode "RED"; // Open fire, engage at will
		
		// Assign patrol waypoints
		pr _AI = GETV(_thisObject, "AI");
		pr _group = GETV(_AI, "agent");
		diag_log format ["[ActionGroupPatrol::activate] Info: Started for AI: _AI"];
		pr _gar = CALLM0(_group, "getGarrison");
		pr _loc = CALLM0(_gar, "getLocation");
		
		// Check if there is a location
		pr _waypoints = if (_loc != "") then {
			CALLM0(_loc, "getPatrolWaypoints");
		} else {
			// Generate some random patrol waypoints
			pr _angle = 0;
			pr _wp = [];
			while {_angle < 360} do {
				pr _newPos = (leader _hG) getPos [100 + random 40, _angle];
				_wp pushBack _newPos;
				_angle = _angle + 30;
			};
			_wp
		};
		
		// Remove assigned waypoints first
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		// Give waipoints to the group
		pr _direction = selectRandom [false, true];
		pr _count = count _waypoints;
		pr _indexStart = floor (random _count);
		pr _index = _indexStart;
		pr _i = 0;
		pr _wpIDs = []; // Array with waypoint IDs
		private _closestWPID = 0;
		private _minDist = 666666;
		while {_i < _count} do {
			pr _wp = _hG addWaypoint [_waypoints select _index, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "SAFE"; //"AWARE"; //"SAFE";
			//_wp setWaypointForceBehaviour true; //"AWARE"; //"SAFE";
			_wp setWaypointSpeed "LIMITED"; //"FULL"; //"LIMITED";
			_wp setWaypointFormation "WEDGE";
			_wpIDs pushback (_wp select 1);
			
			// Also find the closest waypoint
			private _dist = (leader _hG) distance (_waypoints select _index);
			if(_dist < _minDist) then {
				_closestWPID = (_wp select 1);
				_minDist = _dist;
			};
			
			if(_direction) then	{ // Clockwise
				_index = _index + 1;
				if(_index == _count) then{_index = 0;};
			} else { //Counterclockwise
				_index = _index - 1;
				if(_index  < 0) then {_index = _count-1;};
			};
			_i = _i + 1;
		};
		
		// Add cycle waypoint
		pr _wp = _hG addWaypoint [_waypoints select _indexStart, 0]; //Cycle the waypoints
		_wp setWaypointType "CYCLE";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointSpeed "LIMITED";
		_wp setWaypointFormation "WEDGE";
		
		//Set the closest WP as current
		_hG setCurrentWaypoint [_hG, _closestWPID];
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM0(_thisObject, "failIfEmpty");
		
		CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _hG = GETV(_thisObject, "hG");
		
		// Delete all waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		
	} ENDMETHOD;

ENDCLASS;