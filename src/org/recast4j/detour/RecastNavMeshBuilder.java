package org.recast4j.detour;

import org.recast4j.recast.InputGeom;
import org.recast4j.detour.ObjImporter;
import org.recast4j.recast.PolyMesh;
import org.recast4j.recast.PolyMeshDetail;
import org.recast4j.recast.RecastBuilder;
import org.recast4j.recast.RecastConstants.PartitionType;

public class RecastNavMeshBuilder {

	private MeshData meshData;

	public static void main(String[] args) {
		//new RecastNavMeshBuilder();
		System.out.print(1);
	}
	public RecastNavMeshBuilder() {
		this(new ObjImporter().load(RecastBuilder.class.getResourceAsStream("dungeon.obj")), PartitionType.WATERSHED,
				0.3f, 0.2f, 2.0f, 0.6f, 0.9f, 45.0f, 8, 20, 12.0f, 1.3f, 6, 6.0f, 1.0f);
	}

	public RecastNavMeshBuilder(InputGeom m_geom, PartitionType m_partitionType, float m_cellSize, float m_cellHeight,
			float m_agentHeight, float m_agentRadius, float m_agentMaxClimb, float m_agentMaxSlope, int m_regionMinSize,
			int m_regionMergeSize, float m_edgeMaxLen, float m_edgeMaxError, int m_vertsPerPoly,
			float m_detailSampleDist, float m_detailSampleMaxError) {
		RecastBuilder rcBuilder = new RecastBuilder(m_geom, m_partitionType, m_cellSize, m_cellHeight, m_agentHeight, m_agentRadius, m_agentMaxClimb, m_agentMaxSlope, m_regionMinSize, m_regionMergeSize, m_edgeMaxLen, m_edgeMaxError, m_vertsPerPoly, m_detailSampleDist, m_detailSampleMaxError);
		rcBuilder.build();
		PolyMesh m_pmesh = rcBuilder.getMesh();
		for (int i = 0; i < m_pmesh.npolys; ++i) {
			m_pmesh.flags[i] = 1;
		}
		PolyMeshDetail m_dmesh = rcBuilder.getMeshDetail();
		NavMeshCreateParams params = new NavMeshCreateParams();
		params.verts = m_pmesh.verts;
		params.vertCount = m_pmesh.nverts;
		params.polys = m_pmesh.polys;
		params.polyAreas = m_pmesh.areas;
		params.polyFlags = m_pmesh.flags;
		params.polyCount = m_pmesh.npolys;
		params.nvp = m_pmesh.nvp;
		params.detailMeshes = m_dmesh.meshes;
		params.detailVerts = m_dmesh.verts;
		params.detailVertsCount = m_dmesh.nverts;
		params.detailTris = m_dmesh.tris;
		params.detailTriCount = m_dmesh.ntris;
		params.walkableHeight = m_agentHeight;
		params.walkableRadius = m_agentRadius;
		params.walkableClimb = m_agentMaxClimb;
		params.bmin = m_pmesh.bmin;
		params.bmax = m_pmesh.bmax;
		params.cs = m_cellSize;
		params.ch = m_cellHeight;
		params.buildBvTree = true;
		
		params.offMeshConVerts = new float[6];
		params.offMeshConVerts[0] = 0.1f;
		params.offMeshConVerts[1] = 0.2f;
		params.offMeshConVerts[2] = 0.3f;
		params.offMeshConVerts[3] = 0.4f;
		params.offMeshConVerts[4] = 0.5f;
		params.offMeshConVerts[5] = 0.6f;
		params.offMeshConRad = new float[1];
		params.offMeshConRad[0] = 0.1f;
		params.offMeshConDir = new int[1];
		params.offMeshConDir[0] = 1;
		params.offMeshConAreas = new int[1];
		params.offMeshConAreas[0] = 2;
		params.offMeshConFlags = new int[1];
		params.offMeshConFlags[0] = 12;
		params.offMeshConUserID = new int[1];
		params.offMeshConUserID[0] = 0x4567;
		params.offMeshConCount = 1;
		meshData = NavMeshBuilder.createNavMeshData(params);
	}

	public MeshData getMeshData() {
		return meshData;
	}
}
