/*
Copyright (c) 2009-2010 Mikko Mononen memon@inside.org
Recast4J Copyright (c) 2015 Piotr Piastucki piotr@jtilia.org

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
1. The origin of this software must not be misrepresented; you must not
 claim that you wrote the original software. If you use this software
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
*/
package org.recast4j.detour.crowd {
import static org.recast4j.detour.DetourCommon.*;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.recast4j.detour.ClosesPointOnPolyResult;
import org.recast4j.detour.FindNearestPolyResult;
import org.recast4j.detour.FindPathResult;
import org.recast4j.detour.NavMesh;
import org.recast4j.detour.NavMeshQuery;
import org.recast4j.detour.QueryFilter;
import org.recast4j.detour.Status;
import org.recast4j.detour.VectorPtr;
import org.recast4j.detour.crowd.CrowdAgent.CrowdAgentState;
import org.recast4j.detour.crowd.ObstacleAvoidanceQuery.ObstacleAvoidanceParams;


/*


struct dtCrowdAgentAnimation
{
	bool active;
	float initPos[3], startPos[3], endPos[3];
	dtPolyRef polyRef;
	float t, tmax;
};

/// Crowd agent update flags.
/// @ingroup crowd
/// @see dtCrowdAgentParams::updateFlags
enum UpdateFlags
{
	DT_CROWD_ANTICIPATE_TURNS = 1,
	DT_CROWD_OBSTACLE_AVOIDANCE = 2,
	DT_CROWD_SEPARATION = 4,
	DT_CROWD_OPTIMIZE_VIS = 8,			///< Use #dtPathCorridor::optimizePathVisibility() to optimize the agent path.
	DT_CROWD_OPTIMIZE_TOPO = 16,		///< Use dtPathCorridor::optimizePathTopology() to optimize the agent path.
};

struct dtCrowdAgentDebugInfo
{
	int idx;
	float optStart[3], optEnd[3];
	dtObstacleAvoidanceDebugData* vod;
};

/// Provides local steering behaviors for a group of agents. 
/// @ingroup crowd
class dtCrowd
{
	int m_maxAgents;
	dtCrowdAgent* m_agents;
	dtCrowdAgent** m_activeAgents;
	dtCrowdAgentAnimation* m_agentAnims;
	
	dtPathQueue m_pathq;

	dtObstacleAvoidanceParams m_obstacleQueryParams[DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS];
	dtObstacleAvoidanceQuery* m_obstacleQuery;
	
	dtProximityGrid* m_grid;
	
	dtPolyRef* m_pathResult;
	int m_maxPathResult;
	
	float m_ext[3];

	dtQueryFilter m_filters[DT_CROWD_MAX_QUERY_FILTER_TYPE];

	float m_maxAgentRadius;

	int m_velocitySampleCount;

	dtNavMeshQuery* m_navquery;

	void updateTopologyOptimization(dtCrowdAgent** agents, const int nagents, const float dt);
	void updateMoveRequest(const float dt);
	void checkPathValidity(dtCrowdAgent** agents, const int nagents, const float dt);

	inline int getAgentIndex(const dtCrowdAgent* agent) const  { return (int)(agent - m_agents); }

	void purge();
	
public:
	
	
	/// Submits a new move request for the specified agent.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	///  @param[in]		ref		The position's polygon reference.
	///  @param[in]		pos		The position within the polygon. [(x, y, z)]
	/// @return True if the request was successfully submitted.
	bool requestMoveTarget(const int idx, dtPolyRef ref, const float* pos);

	/// Submits a new move request for the specified agent.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	///  @param[in]		vel		The movement velocity. [(x, y, z)]
	/// @return True if the request was successfully submitted.
	bool requestMoveVelocity(const int idx, const float* vel);

	/// Resets any request for the specified agent.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	/// @return True if the request was successfully reseted.
	bool resetMoveTarget(const int idx);

	/// Gets the active agents int the agent pool.
	///  @param[out]	agents		An array of agent pointers. [(#dtCrowdAgent *) * maxAgents]
	///  @param[in]		maxAgents	The size of the crowd agent array.
	/// @return The number of agents returned in @p agents.
	int getActiveAgents(dtCrowdAgent** agents, const int maxAgents);

	/// Updates the steering and positions of all agents.
	///  @param[in]		dt		The time, in seconds, to update the simulation. [Limit: > 0]
	///  @param[out]	debug	A debug object to load with debug information. [Opt]
	void update(const float dt, dtCrowdAgentDebugInfo* debug);
	
	/// Gets the filter used by the crowd.
	/// @return The filter used by the crowd.
	inline const dtQueryFilter* getFilter(const int i) const { return (i >= 0 && i < DT_CROWD_MAX_QUERY_FILTER_TYPE) ? &m_filters[i] : 0; }
	
	/// Gets the filter used by the crowd.
	/// @return The filter used by the crowd.
	inline dtQueryFilter* getEditableFilter(const int i) { return (i >= 0 && i < DT_CROWD_MAX_QUERY_FILTER_TYPE) ? &m_filters[i] : 0; }

	/// Gets the search extents [(x, y, z)] used by the crowd for query operations. 
	/// @return The search extents used by the crowd. [(x, y, z)]
	const float* getQueryExtents() const { return m_ext; }
	
	/// Gets the velocity sample count.
	/// @return The velocity sample count.
	inline int getVelocitySampleCount() const { return m_velocitySampleCount; }
	
	/// Gets the crowd's proximity grid.
	/// @return The crowd's proximity grid.
	const dtProximityGrid* getGrid() const { return m_grid; }

	/// Gets the crowd's path request queue.
	/// @return The crowd's path request queue.
	const dtPathQueue* getPathQueue() const { return &m_pathq; }

	/// Gets the query object used by the crowd.
	const dtNavMeshQuery* getNavMeshQuery() const { return m_navquery; }
}
}

import staticorg.recast4j.detour.DetourCommon.
import java.util.Collections;
import org.recast4j.detour.crowd.ObstacleAvoidanceQuery.ObstacleAvoidanceParams;
import org.recast4j.detour.FindPathResult;
import org.recast4j.detour.NavMeshQuery;
import java.util.List;
import org.recast4j.detour.crowd.CrowdAgent.CrowdAgentState;
import org.recast4j.detour.NavMesh;
import org.recast4j.detour.FindNearestPolyResult;
import org.recast4j.detour.QueryFilter;
import java.util.ArrayList;
import org.recast4j.detour.ClosesPointOnPolyResult;
import java.util.Set;
import org.recast4j.detour.Status;
;

#endif // DETOURCROWD_H



*/
/**
 * Members in this module implement local steering and dynamic avoidance features.
 * 
 * The crowd is the big beast of the navigation features. It not only handles a lot of the path management for you, but
 * also local steering and dynamic avoidance between members of the crowd. I.e. It can keep your agents from running
 * into each other.
 * 
 * Main class: Crowd
 * 
 * The #dtNavMeshQuery and #dtPathCorridor classes provide perfectly good, easy to use path planning features. But in
 * the end they only give you points that your navigation client should be moving toward. When it comes to deciding
 * things like agent velocity and steering to avoid other agents, that is up to you to implement. Unless, of course, you
 * decide to use Crowd.
 * 
 * Basically, you add an agent to the crowd, providing various configuration settings such as maximum speed and
 * acceleration. You also provide a local target to move toward. The crowd manager then provides, with every update, the
 * new agent position and velocity for the frame. The movement will be constrained to the navigation mesh, and steering
 * will be applied to ensure agents managed by the crowd do not collide with each other.
 * 
 * This is very powerful feature set. But it comes with limitations.
 * 
 * The biggest limitation is that you must give control of the agent's position completely over to the crowd manager.
 * You can update things like maximum speed and acceleration. But in order for the crowd manager to do its thing, it
 * can't allow you to constantly be giving it overrides to position and velocity. So you give up direct control of the
 * agent's movement. It belongs to the crowd.
 * 
 * The second biggest limitation revolves around the fact that the crowd manager deals with local planning. So the
 * agent's target should never be more than 256 polygons away from its current position. If it is, you risk your agent
 * failing to reach its target. So you may still need to do long distance planning and provide the crowd manager with
 * intermediate targets.
 * 
 * Other significant limitations:
 * 
 * - All agents using the crowd manager will use the same #dtQueryFilter. - Crowd management is relatively expensive.
 * The maximum agents under crowd management at any one time is between 20 and 30. A good place to start is a maximum of
 * 25 agents for 0.5ms per frame.
 * 
 * @note This is a summary list of members. Use the index or search feature to find minor members.
 * 
 * @struct dtCrowdAgentParams
 * @see CrowdAgent, Crowd::addAgent(), Crowd::updateAgentParameters()
 * 
 * @var dtCrowdAgentParams::obstacleAvoidanceType
 * @par
 * 
 * 		#dtCrowd permits agents to use different avoidance configurations. This value is the index of the
 *      #dtObstacleAvoidanceParams within the crowd.
 * 
 * @see dtObstacleAvoidanceParams, dtCrowd::setObstacleAvoidanceParams(), dtCrowd::getObstacleAvoidanceParams()
 * 
 * @var dtCrowdAgentParams::collisionQueryRange
 * @par
 * 
 * 		Collision elements include other agents and navigation mesh boundaries.
 * 
 *      This value is often based on the agent radius and/or maximum speed. E.g. radius * 8
 * 
 * @var dtCrowdAgentParams::pathOptimizationRange
 * @par
 * 
 * 		Only applicalbe if #updateFlags includes the #DT_CROWD_OPTIMIZE_VIS flag.
 * 
 *      This value is often based on the agent radius. E.g. radius * 30
 * 
 * @see dtPathCorridor::optimizePathVisibility()
 * 
 * @var dtCrowdAgentParams::separationWeight
 * @par
 * 
 * 		A higher value will result in agents trying to stay farther away from each other at the cost of more difficult
 *      steering in tight spaces.
 *
 */
/**
This is the core class of the @ref crowd module.  See the @ref crowd documentation for a summary
of the crowd features.
A common method for setting up the crowd is as follows:
-# Allocate the crowd using #dtAllocCrowd.
-# Initialize the crowd using #init().
-# Set the avoidance configurations using #setObstacleAvoidanceParams().
-# Add agents using #addAgent() and make an initial movement request using #requestMoveTarget().
A common process for managing the crowd is as follows:
-# Call #update() to allow the crowd to manage its agents.
-# Retrieve agent information using #getActiveAgents().
-# Make movement requests using #requestMoveTarget() when movement goal changes.
-# Repeat every frame.
Some agent configuration settings can be updated using #updateAgentParameters().  But the crowd owns the
agent position.  So it is not possible to update an active agent's position.  If agent position
must be fed back into the crowd, the agent must be removed and re-added.
Notes: 
- Path related information is available for newly added agents only after an #update() has been
  performed.
- Agent objects are kept in a pool and re-used.  So it is important when using agent objects to check the value of
  #dtCrowdAgent::active to determine if the agent is actually in use or not.
- This class is meant to provide 'local' movement. There is a limit of 256 polygons in the path corridor.  
  So it is not meant to provide automatic pathfinding services over long distances.
@see dtAllocCrowd(), dtFreeCrowd(), init(), dtCrowdAgent
*/
public class Crowd {

	static const MAX_ITERS_PER_UPDATE:int= 100;

	static const MAX_PATHQUEUE_NODES:int= 4096;
	static const MAX_COMMON_NODES:int= 512;

	/// The maximum number of neighbors that a crowd agent can take into account
	/// for steering decisions.
	/// @ingroup crowd
	static const DT_CROWDAGENT_MAX_NEIGHBOURS:int= 6;

	/// The maximum number of corners a crowd agent will look ahead in the path.
	/// This value is used for sizing the crowd agent corner buffers.
	/// Due to the behavior of the crowd manager, the actual number of useful
	/// corners will be one less than this number.
	/// @ingroup crowd
	static const DT_CROWDAGENT_MAX_CORNERS:int= 4;

	/// The maximum number of crowd avoidance configurations supported by the
	/// crowd manager.
	/// @ingroup crowd
	/// @see dtObstacleAvoidanceParams, dtCrowd::setObstacleAvoidanceParams(), dtCrowd::getObstacleAvoidanceParams(),
	///		 dtCrowdAgentParams::obstacleAvoidanceType
	static const DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS:int= 8;

	/// The maximum number of query filter types supported by the crowd manager.
	/// @ingroup crowd
	/// @see dtQueryFilter, dtCrowd::getFilter() dtCrowd::getEditableFilter(),
	///		dtCrowdAgentParams::queryFilterType
	static const DT_CROWD_MAX_QUERY_FILTER_TYPE:int= 16;

	/// Provides neighbor data for agents managed by the crowd.
	/// @ingroup crowd
	/// @see dtCrowdAgent::neis, dtCrowd
	
internal class CrowdNeighbour
	{
		var idx:int;		///< The index of the neighbor in the crowd.
		var dist:Number;		///< The distance between the current agent and the neighbor.
	};

	public enum MoveRequestState
	{
		DT_CROWDAGENT_TARGET_UNKNOWN,
		DT_CROWDAGENT_TARGET_NONE,
		DT_CROWDAGENT_TARGET_FAILED,
		DT_CROWDAGENT_TARGET_VALID,
		DT_CROWDAGENT_TARGET_REQUESTING,
		DT_CROWDAGENT_TARGET_WAITING_FOR_QUEUE,
		DT_CROWDAGENT_TARGET_WAITING_FOR_PATH,
		DT_CROWDAGENT_TARGET_VELOCITY
	};


	var m_maxAgents:int;
	var m_agents:Array;
	List<CrowdAgent> m_activeAgents;
	var m_agentAnims:Array;
	var m_pathq:PathQueue;

	var m_obstacleQueryParams:Array= new ObstacleAvoidanceParams[DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS];
	var m_obstacleQuery:ObstacleAvoidanceQuery;
	
	var m_grid:ProximityGrid;
	
	List<Long> m_pathResult;
	var m_ext:Array= new float[3];

	var m_filters:Array= new QueryFilter[DT_CROWD_MAX_QUERY_FILTER_TYPE];

	var m_maxAgentRadius:Number;

	var m_velocitySampleCount:int;

	var m_navquery:NavMeshQuery;

	function tween(t:Number, t0:Number, t1:Number):Number {
		return clamp((t - t0) / (t1 - t0), 0.0, 1.0);
	}

	public List<CrowdNeighbour> getNeighbours(var pos:Array, var height:Number, var range:Number, var skip:CrowdAgent,
			List<CrowdAgent> agents, var grid:ProximityGrid) {

		List<CrowdNeighbour> result = new ArrayList<>();
		Set<Integer> ids = grid.queryItems(pos[0] - range, pos[2] - range, pos[0] + range, pos[2] + range);

		for (int id : ids) {
			var ag:CrowdAgent= agents.get(id);

			if (ag == skip)
				continue;

			// Check for overlap.
			var diff:Array= vSub(pos, ag.npos);
			if (Math.abs(diff[1]) >= (height + ag.params.height) / 2.0)
				continue;
			diff[1] = 0;
			var distSqr:Number= vLenSqr(diff);
			if (distSqr > sqr(range))
				continue;

			addNeighbour(id, distSqr, result);
		}
		return result;

	}

	function addNeighbour(idx:int, dist:Number, List<CrowdNeighbour> neis):void {
		// Insert neighbour based on the distance.
		var nei:CrowdNeighbour= new CrowdNeighbour();
		nei.idx = idx;
		nei.dist = dist;
		neis.add(nei);
		Collections.sort(neis, (o1, o2) -> Float.compare(o1.dist, o2.dist));
	}

	public function addToOptQueue(newag:CrowdAgent, List<CrowdAgent> agents):void {
		// Insert neighbour based on greatest time.
		var slot:int= Collections.binarySearch(agents, newag,
				(a1, a2) -> Float.compare(a2.topologyOptTime, a1.topologyOptTime));
		if (slot < 0) {
			slot = -slot - 1;
		}
		agents.add(slot, newag);
	}

	public List<CrowdAgent> addToPathQueue(var newag:CrowdAgent, List<CrowdAgent> agents) {
		// Insert neighbour based on greatest time.
		var slot:int= Collections.binarySearch(agents, newag,
				(a1, a2) -> Float.compare(a2.targetReplanTime, a1.targetReplanTime));
		if (slot < 0) {
			slot = -slot - 1;
		}
		agents.add(slot, newag);
		return agents;
	}

	///
	/// Initializes the crowd.  
	/// May be called more than once to purge and re-initialize the crowd.
	///  @param[in]		maxAgents		The maximum number of agents the crowd can manage. [Limit: >= 1]
	///  @param[in]		maxAgentRadius	The maximum radius of any agent that will be added to the crowd. [Limit: > 0]
	///  @param[in]		nav				The navigation mesh to use for planning.
	/// @return True if the initialization succeeded.
	public function init(maxAgents:int, maxAgentRadius:Number, nav:NavMesh):void {

		m_maxAgents = maxAgents;
		m_maxAgentRadius = maxAgentRadius;
		vSet(m_ext, m_maxAgentRadius * 2.0, m_maxAgentRadius * 1.5, m_maxAgentRadius * 2.0);

		m_grid = new ProximityGrid(m_maxAgents * 4, maxAgentRadius * 3);
		m_obstacleQuery = new ObstacleAvoidanceQuery();
		m_obstacleQuery.init(6, 8);

		for (var i:int= 0; i < DT_CROWD_MAX_QUERY_FILTER_TYPE; i++) {
			m_filters[i] = new QueryFilter();
		}
		// Init obstacle query params.
		for (var i:int= 0; i < DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS; ++i) {
			var params:ObstacleAvoidanceParams= m_obstacleQueryParams[i] = new ObstacleAvoidanceParams();
			params.velBias = 0.4;
			params.weightDesVel = 2.0;
			params.weightCurVel = 0.75;
			params.weightSide = 0.75;
			params.weightToi = 2.5;
			params.horizTime = 2.5;
			params.gridSize = 33;
			params.adaptiveDivs = 7;
			params.adaptiveRings = 2;
			params.adaptiveDepth = 5;
		}

		// Allocate temp buffer for merging paths.
		m_pathResult = new ArrayList<>();
		m_pathq = new PathQueue();
		m_pathq.init(MAX_PATHQUEUE_NODES, nav);
		m_agents = new CrowdAgent[m_maxAgents];
		m_activeAgents = new ArrayList<>();
		m_agentAnims = new CrowdAgentAnimation[m_maxAgents];
		for (var i:int= 0; i < m_maxAgents; ++i) {
			m_agents[i] = new CrowdAgent();
			m_agents[i].active = false;
			m_agents[i].corridor.init();
		}

		for (var i:int= 0; i < m_maxAgents; ++i) {
			m_agentAnims[i] = new CrowdAgentAnimation();
			m_agentAnims[i].active = false;
		}

		// The navquery is mostly used for local searches, no need for large
		// node pool.
		m_navquery = new NavMeshQuery(nav);
	}

	/// Sets the shared avoidance configuration for the specified index.
	///  @param[in]		idx		The index. [Limits: 0 <= value < #DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS]
	///  @param[in]		params	The new configuration.
	public function setObstacleAvoidanceParams(idx:int, params:ObstacleAvoidanceParams):void {
		if (idx >= 0&& idx < DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS) {
			m_obstacleQueryParams[idx] = params;
		}
	}

	/// Gets the shared avoidance configuration for the specified index.
	///  @param[in]		idx		The index of the configuration to retreive. 
	///							[Limits:  0 <= value < #DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS]
	/// @return The requested configuration.
	public function getObstacleAvoidanceParams(idx:int):ObstacleAvoidanceParams {
		if (idx >= 0&& idx < DT_CROWD_MAX_OBSTAVOIDANCE_PARAMS)
			return m_obstacleQueryParams[idx];
		return null;
	}

	/// The maximum number of agents that can be managed by the object.
	/// @return The maximum number of agents.
	function getAgentCount():int {
		return m_maxAgents;
	}

	/// Gets the specified agent from the pool.
	///	 @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	/// @return The requested agent.
	/// Agents in the pool may not be in use.  Check #dtCrowdAgent.active before using the returned object.
	public function getAgent(idx:int):CrowdAgent {
		return idx < 0|| idx >= m_agents.length ? null : m_agents[idx];
	}

	/// 
	/// Gets the specified agent from the pool.
	///	 @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	/// @return The requested agent.
	/// Agents in the pool may not be in use.  Check #dtCrowdAgent.active before using the returned object.
	public function getEditableAgent(idx:int):CrowdAgent {
		return idx < 0|| idx >= m_agents.length ? null : m_agents[idx];
	}

	/// Updates the specified agent's configuration.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	///  @param[in]		params	The new agent configuration.
	public function updateAgentParameters(idx:int, params:CrowdAgentParams):void {
		if (idx < 0|| idx >= m_maxAgents)
			return;
		m_agents[idx].params = params;
	}

	/// Adds a new agent to the crowd.
	///  @param[in]		pos		The requested position of the agent. [(x, y, z)]
	///  @param[in]		params	The configutation of the agent.
	/// @return The index of the agent in the agent pool. Or -1 if the agent could not be added.
	/// The agent's position will be constrained to the surface of the navigation mesh.
	public function addAgent(pos:Array, params:CrowdAgentParams):int {
		// Find empty slot.
		var idx:int= -1;
		for (var i:int= 0; i < m_maxAgents; ++i) {
			if (!m_agents[i].active) {
				idx = i;
				break;
			}
		}
		if (idx == -1)
			return -1;

		var ag:CrowdAgent= m_agents[idx];

		updateAgentParameters(idx, params);

		// Find nearest position on navmesh and place the agent there.
		var nearest:FindNearestPolyResult= m_navquery.findNearestPoly(pos, m_ext, m_filters[ag.params.queryFilterType]);

		ag.corridor.reset(nearest.getNearestRef(), nearest.getNearestPos());
		ag.boundary.reset();
		ag.partial = false;

		ag.topologyOptTime = 0;
		ag.targetReplanTime = 0;
		ag.nneis = 0;

		vSet(ag.dvel, 0, 0, 0);
		vSet(ag.nvel, 0, 0, 0);
		vSet(ag.vel, 0, 0, 0);
		vCopy(ag.npos, nearest.getNearestPos());

		ag.desiredSpeed = 0;

		if (nearest.getNearestRef() != 0)
			ag.state = CrowdAgentState.DT_CROWDAGENT_STATE_WALKING;
		else
			ag.state = CrowdAgentState.DT_CROWDAGENT_STATE_INVALID;

		ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_NONE;

		ag.active = true;

		return idx;
	}


	/// Removes the agent from the crowd.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	///
	/// The agent is deactivated and will no longer be processed.  Its #dtCrowdAgent object
	/// is not removed from the pool.  It is marked as inactive so that it is available for reuse.
	function removeAgent(idx:int):void {
		if (idx >= 0&& idx < m_maxAgents) {
			m_agents[idx].active = false;
		}
	}

	protected function requestMoveTargetReplan(idx:int, ref:Number, pos:Array):Boolean {
		if (idx < 0|| idx >= m_maxAgents)
			return false;

		var ag:CrowdAgent= m_agents[idx];

		ag.setTarget(ref, pos);
		ag.targetReplan = true;

		return true;
	}


	/// Submits a new move request for the specified agent.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	///  @param[in]		ref		The position's polygon reference.
	///  @param[in]		pos		The position within the polygon. [(x, y, z)]
	/// @return True if the request was successfully submitted.
	/// 
	/// This method is used when a new target is set.
	/// 
	/// The position will be constrained to the surface of the navigation mesh.
	///
	/// The request will be processed during the next #update().
	public function requestMoveTarget(idx:int, ref:Number, pos:Array):Boolean {
		if (idx < 0|| idx >= m_maxAgents)
			return false;
		if (ref == 0)
			return false;

		var ag:CrowdAgent= m_agents[idx];
		
		// Initialize request.
		ag.setTarget(ref, pos);
		ag.targetReplan = true;

		return true;
	}

	/// Submits a new move request for the specified agent.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	///  @param[in]		vel		The movement velocity. [(x, y, z)]
	/// @return True if the request was successfully submitted.
	public function requestMoveVelocity(idx:int, vel:Array):Boolean {
		if (idx < 0|| idx >= m_maxAgents)
			return false;

		var ag:CrowdAgent= m_agents[idx];

		// Initialize request.
		ag.targetRef = 0;
		vCopy(ag.targetPos, vel);
		ag.targetPathqRef = PathQueue.DT_PATHQ_INVALID;
		ag.targetReplan = false;
		ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_VELOCITY;

		return true;
	}
	

	/// Resets any request for the specified agent.
	///  @param[in]		idx		The agent index. [Limits: 0 <= value < #getAgentCount()]
	/// @return True if the request was successfully reseted.
	public function resetMoveTarget(idx:int):Boolean {
		if (idx < 0|| idx >= m_maxAgents)
			return false;

		var ag:CrowdAgent= m_agents[idx];

		// Initialize request.
		ag.targetRef = 0;
		vSet(ag.targetPos, 0, 0, 0);
		vSet(ag.dvel, 0, 0, 0);
		ag.targetPathqRef = PathQueue.DT_PATHQ_INVALID;
		ag.targetReplan = false;
		ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_NONE;
		return true;
	}

	/// Gets the active agents int the agent pool.
	///  @param[out]	agents		An array of agent pointers. [(#dtCrowdAgent *) * maxAgents]
	///  @param[in]		maxAgents	The size of the crowd agent array.
	/// @return The number of agents returned in @p agents.
	public List<CrowdAgent> getActiveAgents() {
		List<CrowdAgent> agents = new ArrayList<>m_maxAgents();
		for (var i:int= 0; i < m_maxAgents; ++i) {
			if (m_agents[i].active) {
				agents.add(m_agents[i]);
			}
		}
		return agents;
	}


	public function updateMoveRequest(dt:Number):void {
		List<CrowdAgent> queue = new ArrayList<>();

		// Fire off new requests.
		for (var i:int= 0; i < m_maxAgents; ++i) {
			var ag:CrowdAgent= m_agents[i];
			if (!ag.active)
				continue;
			if (ag.state == CrowdAgentState.DT_CROWDAGENT_STATE_INVALID)
				continue;
			if (ag.targetState == MoveRequestState.DT_CROWDAGENT_TARGET_NONE
					|| ag.targetState == MoveRequestState.DT_CROWDAGENT_TARGET_VELOCITY)
				continue;

			if (ag.targetState == MoveRequestState.DT_CROWDAGENT_TARGET_REQUESTING) {
				List<Long> path = ag.corridor.getPath();
				if (path.isEmpty()) {
					throw new IllegalArgumentException("Empty path");
				}
				// Quick search towards the goal.
				var MAX_ITER:int= 20;
				m_navquery.initSlicedFindPath(path.get(0), ag.targetRef, ag.npos, ag.targetPos,
						m_filters[ag.params.queryFilterType], 0);
				m_navquery.updateSlicedFindPath(MAX_ITER);
				var pathFound:FindPathResult;
				if (ag.targetReplan) // && npath > 10)
				{
					// Try to use existing steady path during replan if possible.
					pathFound = m_navquery.finalizeSlicedFindPathPartial(path);
				} else {
					// Try to move towards target when goal changes.
					pathFound = m_navquery.finalizeSlicedFindPath();
				}

				var reqPos:Array= new float[3];
				List<Long> reqPath = pathFound.getRefs();
				if (!pathFound.getStatus().isFailed() && !pathFound.getRefs().isEmpty()) {
					// In progress or succeed.
					if (reqPath.get(reqPath.size() - 1) != ag.targetRef) {
						// Partial path, constrain target position inside the last polygon.
						var closest:ClosesPointOnPolyResult= m_navquery.closestPointOnPoly(
								pathFound.getRefs().get(pathFound.getRefs().size() - 1), ag.targetPos);
						reqPos = closest.getClosest();
					} else {
						vCopy(reqPos, ag.targetPos);
					}
				} else {
					// Could not find path, start the request from current location.
					vCopy(reqPos, ag.npos);
					reqPath = new ArrayList<>();
					reqPath.add(path.get(0));
				}

				ag.corridor.setCorridor(reqPos, reqPath);
				ag.boundary.reset();
				ag.partial = false;

				if (reqPath.get(reqPath.size() - 1) == ag.targetRef) {
					ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_VALID;
					ag.targetReplanTime = 0.0;
				} else {
					// The path is longer or potentially unreachable, full plan.
					ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_WAITING_FOR_QUEUE;
				}
			}

			if (ag.targetState == MoveRequestState.DT_CROWDAGENT_TARGET_WAITING_FOR_QUEUE) {
				queue = addToPathQueue(ag, queue);
			}
		}

		for (var i:int= 0; i < queue.size(); ++i) {
			var ag:CrowdAgent= queue.get(i);
			ag.targetPathqRef = m_pathq.request(ag.corridor.getLastPoly(), ag.targetRef, ag.corridor.getTarget(),
					ag.targetPos, m_filters[ag.params.queryFilterType]);
			if (ag.targetPathqRef != PathQueue.DT_PATHQ_INVALID)
				ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_WAITING_FOR_PATH;
		}

		// Update requests.
		m_pathq.update(MAX_ITERS_PER_UPDATE);

		// Process path results.
		for (var i:int= 0; i < m_maxAgents; ++i) {
			var ag:CrowdAgent= m_agents[i];
			if (!ag.active)
				continue;
			if (ag.targetState == MoveRequestState.DT_CROWDAGENT_TARGET_NONE
					|| ag.targetState == MoveRequestState.DT_CROWDAGENT_TARGET_VELOCITY)
				continue;

			if (ag.targetState == MoveRequestState.DT_CROWDAGENT_TARGET_WAITING_FOR_PATH) {
				// Poll path queue.
				var status:Status= m_pathq.getRequestStatus(ag.targetPathqRef);
				if (status.isFailed()) {
					// Path find failed, retry if the target location is still valid.
					ag.targetPathqRef = PathQueue.DT_PATHQ_INVALID;
					if (ag.targetRef != 0)
						ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_REQUESTING;
					else
						ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_FAILED;
					ag.targetReplanTime = 0.0;
				} else if (status.isSuccess()) {
					List<Long> path = ag.corridor.getPath();
					if (path.isEmpty()) {
						throw new IllegalArgumentException("Empty path");
					}

					// Apply results.
					var targetPos:Array= new float[3];
					vCopy(targetPos, ag.targetPos);

					var valid:Boolean= true;
					var fpr:FindPathResult= m_pathq.getPathResult(ag.targetPathqRef);
					List<Long> res = fpr.getRefs();
					if (fpr.getStatus().isFailed() || res.isEmpty())
						valid = false;

					if (fpr.getStatus() == Status.PARTIAL_RESULT)
						ag.partial = true;
					else
						ag.partial = false;

					// Merge result and existing path.
					// The agent might have moved whilst the request is
					// being processed, so the path may have changed.
					// We assume that the end of the path is at the same location
					// where the request was issued.

					// The last ref in the old path should be the same as
					// the location where the request was issued..
					if (valid && path.get(path.size() - 1).longValue() != res.get(0).longValue())
						valid = false;

					if (valid) {
						// Put the old path infront of the old path.
						if (path.size() > 1) {
							res.addAll(0, path.subList(1, path.size()));
							// Remove trackbacks
							for (var j:int= 1; j < res.size() - 1; ++j) {
								if (res.get(j - 1) == res.get(j + 1)) {
									res.remove(j);
									res.remove(j + 1);
								}
							}

						}

						// Check for partial path.
						if (res.get(res.size() - 1) != ag.targetRef) {
							// Partial path, constrain target position inside the last polygon.
							var nearest:ClosesPointOnPolyResult= m_navquery.closestPointOnPoly(res.get(res.size() - 1),
									targetPos);
							vCopy(targetPos, nearest.getClosest());
						}
					}

					if (valid) {
						// Set current corridor.
						ag.corridor.setCorridor(targetPos, res);
						// Force to update boundary.
						ag.boundary.reset();
						ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_VALID;
					} else {
						// Something went wrong.
						ag.targetState = MoveRequestState.DT_CROWDAGENT_TARGET_FAILED;
					}

					ag.targetReplanTime = 0.0;
				}
			}
		}

	}

}