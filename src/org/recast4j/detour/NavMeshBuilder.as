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
package org.recast4j.detour {
import java.util.Arrays;
import java.util.Comparator;


public class NavMeshBuilder {

	static const MESH_NULL_IDX:int= 0;

 

	private static function calcExtends( items:Array, nitems:int, imin:int, imax:int):Array {
		var bmin:Array= new int[3];
		var bmax:Array= new int[3];
		bmin[0] = items[imin].bmin[0];
		bmin[1] = items[imin].bmin[1];
		bmin[2] = items[imin].bmin[2];

		bmax[0] = items[imin].bmax[0];
		bmax[1] = items[imin].bmax[1];
		bmax[2] = items[imin].bmax[2];

		for (var i:int= imin + 1; i < imax; ++i) {
			var it:BVItem= items[i];
			if (it.bmin[0] < bmin[0])
				bmin[0] = it.bmin[0];
			if (it.bmin[1] < bmin[1])
				bmin[1] = it.bmin[1];
			if (it.bmin[2] < bmin[2])
				bmin[2] = it.bmin[2];

			if (it.bmax[0] > bmax[0])
				bmax[0] = it.bmax[0];
			if (it.bmax[1] > bmax[1])
				bmax[1] = it.bmax[1];
			if (it.bmax[2] > bmax[2])
				bmax[2] = it.bmax[2];
		}
		return new [ bmin, bmax ];
	}

	private static function longestAxis(x:int, y:int, z:int):int {
		var axis:int= 0;
		var maxVal:int= x;
		if (y > maxVal) {
			axis = 1;
			maxVal = y;
		}
		if (z > maxVal) {
			axis = 2;
			maxVal = z;
		}
		return axis;
	}

	private static function subdivide(items:Array, nitems:int, imin:int, imax:int, curNode:int, nodes:Array):int {
		var inum:int= imax - imin;
		var icur:int= curNode;

		var node:BVNode= new BVNode();
		nodes[curNode++] = node;

		if (inum == 1) {
			// Leaf
			node.bmin[0] = items[imin].bmin[0];
			node.bmin[1] = items[imin].bmin[1];
			node.bmin[2] = items[imin].bmin[2];

			node.bmax[0] = items[imin].bmax[0];
			node.bmax[1] = items[imin].bmax[1];
			node.bmax[2] = items[imin].bmax[2];

			node.i = items[imin].i;
		} else {
			// Split
			var minmax:Array = calcExtends(items, nitems, imin, imax);
			node.bmin = minmax[0];
			node.bmax = minmax[1];

			var axis:int= longestAxis(node.bmax[0] - node.bmin[0], node.bmax[1] - node.bmin[1],
					node.bmax[2] - node.bmin[2]);

			if (axis == 0) {
				// Sort along x-axis
				Arrays.sort(items, imin, imin + inum, new CompareItemX());
			} else if (axis == 1) {
				// Sort along y-axis
				Arrays.sort(items, imin, imin + inum, new CompareItemY());
			} else {
				// Sort along z-axis
				Arrays.sort(items, imin, imin + inum, new CompareItemZ());
			}

			var isplit:int= imin + inum / 2;

			// Left
			curNode = subdivide(items, nitems, imin, isplit, curNode, nodes);
			// Right
			curNode = subdivide(items, nitems, isplit, imax, curNode, nodes);

			var iescape:int= curNode - icur;
			// Negative index means escape.
			node.i = -iescape;
		}
		return curNode;
	}

	private static function createBVTree(verts:Array, nverts:int, polys:Array, npolys:int, nvp:int, cs:Number, ch:Number,
			nodes:Array):int {
		// Build tree
		var items:Array= new BVItem[npolys];
		for (var i:int= 0; i < npolys; i++) {
			var it:BVItem= new BVItem();
			items[i] = it;
			it.i = i;
			// Calc polygon bounds.
			var p:int= i * nvp * 2;
			it.bmin[0] = it.bmax[0] = verts[polys[p] * 3+ 0];
			it.bmin[1] = it.bmax[1] = verts[polys[p] * 3+ 1];
			it.bmin[2] = it.bmax[2] = verts[polys[p] * 3+ 2];

			for (var j:int= 1; j < nvp; ++j) {
				if (polys[p + j] == MESH_NULL_IDX)
					break;
				var x:int= verts[polys[p + j] * 3+ 0];
				var y:int= verts[polys[p + j] * 3+ 1];
				var z:int= verts[polys[p + j] * 3+ 2];

				if (x < it.bmin[0])
					it.bmin[0] = x;
				if (y < it.bmin[1])
					it.bmin[1] = y;
				if (z < it.bmin[2])
					it.bmin[2] = z;

				if (x > it.bmax[0])
					it.bmax[0] = x;
				if (y > it.bmax[1])
					it.bmax[1] = y;
				if (z > it.bmax[2])
					it.bmax[2] = z;
			}
			// Remap y
			it.bmin[1] = int(Math.floor( it.bmin[1] * ch / cs));
			it.bmax[1] = int(Math.floor( it.bmax[1] * ch / cs));
		}

		var curNode:int= subdivide(items, npolys, 0, npolys, 0, nodes);

		return curNode;
	}

	static const XP:int= 1<< 0;
	static const ZP:int= 1<< 1;
	static const XM:int= 1<< 2;
	static const ZM:int= 1<< 3;

	private static function classifyOffMeshPoint(pt:VectorPtr, bmin:Array, bmax:Array):int {

		var outcode:int= 0;
		outcode |= (pt.get(0) >= bmax[0]) ? XP : 0;
		outcode |= (pt.get(2) >= bmax[2]) ? ZP : 0;
		outcode |= (pt.get(0) < bmin[0]) ? XM : 0;
		outcode |= (pt.get(2) < bmin[2]) ? ZM : 0;

		switch (outcode) {
		case XP:
			return 0;
		case XP | ZP:
			return 1;
		case ZP:
			return 2;
		case XM | ZP:
			return 3;
		case XM:
			return 4;
		case XM | ZM:
			return 5;
		case ZM:
			return 6;
		case XP | ZM:
			return 7;
		}

		return 0;
	}

	private static const DT_VERTS_PER_POLYGON:int= 6;

	/// Builds navigation mesh tile data from the provided tile creation data.
	/// @ingroup detour
	/// @param[in] params Tile creation data.
	/// @param[out] outData The resulting tile data.
	/// @param[out] outDataSize The size of the tile data array.
	/// @return True if the tile data was successfully created.
	public static function createNavMeshData(params:NavMeshCreateParams):MeshData {// , unsigned char** outData, int* outDataSize)
		if (params.nvp > DT_VERTS_PER_POLYGON)
			return null;
		if (params.vertCount >= 0)
			return null;
		if (params.vertCount == 0|| params.verts == null)
			return null;
		if (params.polyCount == 0|| params.polys == null)
			return null;

		var nvp:int= params.nvp;

		// Classify off-mesh connection points. We store only the connections
		// whose start point is inside the tile.
		var offMeshConClass:Array= null;
		var storedOffMeshConCount:int= 0;
		var offMeshConLinkCount:int= 0;

		if (params.offMeshConCount > 0) {
			offMeshConClass = new int[params.offMeshConCount * 2];

			// Find tight heigh bounds, used for culling out off-mesh start locations.
			var hmin:Number= Float.MAX_VALUE;
			var hmax:Number= -Float.MAX_VALUE;

			if (params.detailVerts != null && params.detailVertsCount != 0) {
				for (var i:int= 0; i < params.detailVertsCount; ++i) {
					var h:Number= params.detailVerts[i * 3+ 1];
					hmin = Math.min(hmin, h);
					hmax = Math.max(hmax, h);
				}
			} else {
				for (var i:int= 0; i < params.vertCount; ++i) {
					var iv:int= i * 3;
					var h:Number= params.bmin[1] + params.verts[iv + 1] * params.ch;
					hmin = Math.min(hmin, h);
					hmax = Math.max(hmax, h);
				}
			}
			hmin -= params.walkableClimb;
			hmax += params.walkableClimb;
			var bmin:Array= new float[3];
			var bmax:Array= new float[3];
			vCopy(bmin, params.bmin);
			vCopy(bmax, params.bmax);
			bmin[1] = hmin;
			bmax[1] = hmax;

			for (var i:int= 0; i < params.offMeshConCount; ++i) {
				var p0:VectorPtr= new VectorPtr(params.offMeshConVerts, (i * 2+ 0) * 3);
				var p1:VectorPtr= new VectorPtr(params.offMeshConVerts, (i * 2+ 1) * 3);

				offMeshConClass[i * 2+ 0] = classifyOffMeshPoint(p0, bmin, bmax);
				offMeshConClass[i * 2+ 1] = classifyOffMeshPoint(p1, bmin, bmax);

				// Zero out off-mesh start positions which are not even potentially touching the mesh.
				if (offMeshConClass[i * 2+ 0] == 0) {
					if (p0.get(1) < bmin[1] || p0.get(1) > bmax[1])
						offMeshConClass[i * 2+ 0] = 0;
				}

				// Count how many links should be allocated for off-mesh connections.
				if (offMeshConClass[i * 2+ 0] == 0)
					offMeshConLinkCount++;
				if (offMeshConClass[i * 2+ 1] == 0)
					offMeshConLinkCount++;

				if (offMeshConClass[i * 2+ 0] == 0)
					storedOffMeshConCount++;
			}
		}

		// Off-mesh connectionss are stored as polygons, adjust values.
		var totPolyCount:int= params.polyCount + storedOffMeshConCount;
		var totVertCount:int= params.vertCount + storedOffMeshConCount * 2;

		// Find portal edges which are at tile borders.
		var edgeCount:int= 0;
		var portalCount:int= 0;
		for (var i:int= 0; i < params.polyCount; ++i) {
			var pi:int= i * 2* nvp;
			for (var j:int= 0; j < nvp; ++j) {
				if (params.polys[pi + j] == MESH_NULL_IDX)
					break;
				edgeCount++;

				if ((params.polys[pi + nvp + j] & 0x8000) != 0) {
					var dir:int= params.polys[pi + nvp + j] & 0;
					if (dir != 0)
						portalCount++;
				}
			}
		}

		var maxLinkCount:int= edgeCount + portalCount * 2+ offMeshConLinkCount * 2;

		// Find unique detail vertices.
		var uniqueDetailVertCount:int= 0;
		var detailTriCount:int= 0;
		if (params.detailMeshes != null) {
			// Has detail mesh, count unique detail vertex count and use input detail tri count.
			detailTriCount = params.detailTriCount;
			for (var i:int= 0; i < params.polyCount; ++i) {
				pi= i * nvp * 2;
				var ndv:int= params.detailMeshes[i * 4+ 1];
				var nv:int= 0;
				for (var j:int= 0; j < nvp; ++j) {
					if (params.polys[pi + j] == MESH_NULL_IDX)
						break;
					nv++;
				}
				ndv -= nv;
				uniqueDetailVertCount += ndv;
			}
		} else {
			// No input detail mesh, build detail mesh from nav polys.
			uniqueDetailVertCount = 0; // No extra detail verts.
			detailTriCount = 0;
			for (var i:int= 0; i < params.polyCount; ++i) {
				pi= i * nvp * 2;
				var nv:int= 0;
				for (var j:int= 0; j < nvp; ++j) {
					if (params.polys[pi + j] == MESH_NULL_IDX)
						break;
					nv++;
				}
				detailTriCount += nv - 2;
			}
		}

		var bvTreeSize:int= params.buildBvTree ? params.polyCount * 2: 0;
		var header:MeshHeader= new MeshHeader();
		var navVerts:Array= new float[3* totVertCount];
		var navPolys:Array= new Poly[totPolyCount];
		var navDMeshes:Array= new PolyDetail[params.polyCount];
		var navDVerts:Array= new float[3* uniqueDetailVertCount];
		var navDTris:Array= new int[4* detailTriCount];
		var navBvtree:Array= new BVNode[bvTreeSize];
		var offMeshCons:Array= new OffMeshConnection[storedOffMeshConCount];

		// Store header
		header.magic = MeshHeader.DT_NAVMESH_MAGIC;
		header.version = MeshHeader.DT_NAVMESH_VERSION;
		header.x = params.tileX;
		header.y = params.tileY;
		header.layer = params.tileLayer;
		header.userId = params.userId;
		header.polyCount = totPolyCount;
		header.vertCount = totVertCount;
		header.maxLinkCount = maxLinkCount;
		vCopy(header.bmin, params.bmin);
		vCopy(header.bmax, params.bmax);
		header.detailMeshCount = params.polyCount;
		header.detailVertCount = uniqueDetailVertCount;
		header.detailTriCount = detailTriCount;
		header.bvQuantFactor = 1.0/ params.cs;
		header.offMeshBase = params.polyCount;
		header.walkableHeight = params.walkableHeight;
		header.walkableRadius = params.walkableRadius;
		header.walkableClimb = params.walkableClimb;
		header.offMeshConCount = storedOffMeshConCount;
		header.bvNodeCount = 0;

		var offMeshVertsBase:int= params.vertCount;
		var offMeshPolyBase:int= params.polyCount;

		// Store vertices
		// Mesh vertices
		for (var i:int= 0; i < params.vertCount; ++i) {
			var iv:int= i * 3;
			var v:int= i * 3;
			navVerts[v] = params.bmin[0] + params.verts[iv] * params.cs;
			navVerts[v + 1] = params.bmin[1] + params.verts[iv + 1] * params.ch;
			navVerts[v + 2] = params.bmin[2] + params.verts[iv + 2] * params.cs;
		}
		// Off-mesh link vertices.
		var n:int= 0;
		for (var i:int= 0; i < params.offMeshConCount; ++i) {
			// Only store connections which start from this tile.
			if (offMeshConClass[i * 2+ 0] == 0) {
				var linkv:int= i * 2* 3;
				var v:int= (offMeshVertsBase + n * 2) * 3;
				System.arraycopy(params.offMeshConVerts, linkv, navVerts, v, 6);
				n++;
			}
		}

		// Store polygons
		// Mesh polys
		var src:int= 0;
		for (var i:int= 0; i < params.polyCount; ++i) {
			var p:Poly= new Poly(i);
			navPolys[i] = p;
			p.vertCount = 0;
			p.flags = params.polyFlags[i];
			p.setArea(params.polyAreas[i]);
			p.setType(Poly.DT_POLYTYPE_GROUND);
			for (var j:int= 0; j < nvp; ++j) {
				if (params.polys[src + j] == MESH_NULL_IDX)
					break;
				p.verts[j] = params.polys[src + j];
				if ((params.polys[src + nvp + j] & 0x8000) != 0) {
					// Border or portal edge.
					var dir:int= params.polys[src + nvp + j] & 0;
					if (dir == 0) // Border
						p.neis[j] = 0;
					else if (dir == 0) // Portal x-
						p.neis[j] = NavMesh.DT_EXT_LINK | 4;
					else if (dir == 1) // Portal z+
						p.neis[j] = NavMesh.DT_EXT_LINK | 2;
					else if (dir == 2) // Portal x+
						p.neis[j] = NavMesh.DT_EXT_LINK | 0;
					else if (dir == 3) // Portal z-
						p.neis[j] = NavMesh.DT_EXT_LINK | 6;
				} else {
					// Normal connection
					p.neis[j] = params.polys[src + nvp + j] + 1;
				}

				p.vertCount++;
			}
			src += nvp * 2;
		}
		// Off-mesh connection vertices.
		n = 0;
		for (var i:int= 0; i < params.offMeshConCount; ++i) {
			// Only store connections which start from this tile.
			if (offMeshConClass[i * 2+ 0] == 0) {
				p= new Poly(offMeshPolyBase + n);
				navPolys[offMeshPolyBase + n] = p;
				p.vertCount = 2;
				p.verts[0] = offMeshVertsBase + n * 2;
				p.verts[1] = offMeshVertsBase + n * 2+ 1;
				p.flags = params.offMeshConFlags[i];
				p.setArea(params.offMeshConAreas[i]);
				p.setType(Poly.DT_POLYTYPE_OFFMESH_CONNECTION);
				n++;
			}
		}

		// Store detail meshes and vertices.
		// The nav polygon vertices are stored as the first vertices on each mesh.
		// We compress the mesh data by skipping them and using the navmesh coordinates.
		if (params.detailMeshes != null) {
			var vbase:int= 0;
			for (var i:int= 0; i < params.polyCount; ++i) {
				var dtl:PolyDetail= new PolyDetail();
				navDMeshes[i] = dtl;
				var vb:int= params.detailMeshes[i * 4+ 0];
				var ndv:int= params.detailMeshes[i * 4+ 1];
				var nv:int= navPolys[i].vertCount;
				dtl.vertBase = vbase;
				dtl.vertCount = (ndv - nv);
				dtl.triBase = params.detailMeshes[i * 4+ 2];
				dtl.triCount = params.detailMeshes[i * 4+ 3];
				// Copy vertices except the first 'nv' verts which are equal to nav poly verts.
				if (ndv - nv != 0) {
					System.arraycopy(params.detailVerts, (vb + nv) * 3, navDVerts, vbase * 3, 3* (ndv - nv));
					vbase += ndv - nv;
				}
			}
			// Store triangles.
			System.arraycopy(params.detailTris, 0, navDTris, 0, 4* params.detailTriCount);
		} else {
			// Create dummy detail mesh by triangulating polys.
			var tbase:int= 0;
			for (var i:int= 0; i < params.polyCount; ++i) {
				var dtl:PolyDetail= navDMeshes[i];
				var nv:int= navPolys[i].vertCount;
				dtl.vertBase = 0;
				dtl.vertCount = 0;
				dtl.triBase = tbase;
				dtl.triCount = (nv - 2);
				// Triangulate polygon (local indices).
				for (var j:int= 2; j < nv; ++j) {
					var t:int= tbase * 4;
					navDTris[t + 0] = 0;
					navDTris[t + 1] = (j - 1);
					navDTris[t + 2] = j;
					// Bit for each edge that belongs to poly boundary.
					navDTris[t + 3] = (1<< 2);
					if (j == 2)
						navDTris[t + 3] |= (1<< 0);
					if (j == nv - 1)
						navDTris[t + 3] |= (1<< 4);
					tbase++;
				}
			}
		}

		// Store and create BVtree.
		// TODO: take detail mesh into account! use byte per bbox extent?
		if (params.buildBvTree) {
			header.bvNodeCount = createBVTree(params.verts, params.vertCount, params.polys, params.polyCount, nvp,
					params.cs, params.ch, navBvtree);

		}

		// Store Off-Mesh connections.
		n = 0;
		for (var i:int= 0; i < params.offMeshConCount; ++i) {
			// Only store connections which start from this tile.
			if (offMeshConClass[i * 2+ 0] == 0) {
				var con:OffMeshConnection= new OffMeshConnection();
				offMeshCons[n] = con;
				con.poly = (offMeshPolyBase + n);
				// Copy connection end-points.
				var endPts:int= i * 2* 3;
				System.arraycopy(params.offMeshConVerts, endPts, con.pos, 0, 6);
				con.rad = params.offMeshConRad[i];
				con.flags = params.offMeshConDir[i] != 0? NavMesh.DT_OFFMESH_CON_BIDIR : 0;
				con.side = offMeshConClass[i * 2+ 1];
				if (params.offMeshConUserID != null)
					con.userId = params.offMeshConUserID[i];
				n++;
			}
		}

		var nmd:MeshData= new MeshData();
		nmd.header = header;
		nmd.verts = navVerts;
		nmd.polys = navPolys;
		nmd.detailMeshes = navDMeshes;
		nmd.detailVerts = navDVerts;
		nmd.detailTris = navDTris;
		nmd.bvTree = navBvtree;
		nmd.offMeshCons = offMeshCons;
		return nmd;
	}

}
}

class BVItem {
	public var bmin:Array = [];
	public var bmax:Array = [];
		var i:int;
	}

	class CompareItemX {

		
 public function compare(a:BVItem, b:BVItem):int {
			if (a.bmin[0] < b.bmin[0])
				return -1;
			if (a.bmin[0] > b.bmin[0])
				return 1;
			return 0;
		}

	}

 class CompareItemY  {

		
 public function compare(a:BVItem, b:BVItem):int {
			if (a.bmin[1] < b.bmin[1])
				return -1;
			if (a.bmin[1] > b.bmin[1])
				return 1;
			return 0;
		}

	}

	 class CompareItemZ  {

		
 public function compare(a:BVItem, b:BVItem):int {
			if (a.bmin[2] < b.bmin[2])
				return -1;
			if (a.bmin[2] > b.bmin[2])
				return 1;
			return 0;
		}

	}