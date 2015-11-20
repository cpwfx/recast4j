/*
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
package org.recast4j.detour.io {
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;

import org.recast4j.detour.BVNode;
import org.recast4j.detour.MeshHeader;
import org.recast4j.detour.MeshData;
import org.recast4j.detour.OffMeshConnection;
import org.recast4j.detour.Poly;
import org.recast4j.detour.PolyDetail;

public class MeshReader {

	// C++ object sizeof
	static var DT_POLY_DETAIL_SIZE:int= 10;

	public function read(stream:InputStream):MeshData {
		var buf:ByteBuffer= toByteBuffer(stream);
		var data:MeshData= new MeshData();
		var header:MeshHeader= new MeshHeader();
		data.header = header;
		header.magic = buf.getInt();
		if (header.magic != MeshHeader.DT_NAVMESH_MAGIC) {
			throw new IOException("Invalid magic");
		}
		header.version = buf.getInt();
		if (header.version != MeshHeader.DT_NAVMESH_VERSION) {
			throw new IOException("Invalid version");
		}
		header.x = buf.getInt();
		header.y = buf.getInt();
		header.layer = buf.getInt();
		header.userId = buf.getInt();
		header.polyCount = buf.getInt();
		header.vertCount = buf.getInt();
		header.maxLinkCount = buf.getInt();
		header.detailMeshCount = buf.getInt();
		header.detailVertCount = buf.getInt();
		header.detailTriCount = buf.getInt();
		header.bvNodeCount = buf.getInt();
		header.offMeshConCount = buf.getInt();
		header.offMeshBase = buf.getInt();
		header.walkableHeight = buf.getFloat();
		header.walkableRadius = buf.getFloat();
		header.walkableClimb = buf.getFloat();
		for (var j:int= 0; j < 3; j++) {
			header.bmin[j] = buf.getFloat();
		}
		for (var j:int= 0; j < 3; j++) {
			header.bmax[j] = buf.getFloat();
		}
		header.bvQuantFactor = buf.getFloat();
		data.verts = readVerts(buf, header.vertCount);
		data.polys = readPolys(buf, header);
		data.detailMeshes = readPolyDetails(buf, header);
		align4(buf, header.detailMeshCount * DT_POLY_DETAIL_SIZE);
		data.detailVerts = readVerts(buf, header.detailVertCount);
		data.detailTris = readDTris(buf, header);
		data.bvTree = readBVTree(buf, header);
		data.offMeshCons = readOffMeshCons(buf, header);
		return data;
	}

	private float[] readVerts(var buf:ByteBuffer, var count:int) {
		var verts:Array = [];// new float[count * 3];
		for (var i:int= 0; i < verts.length; i++) {
			verts[i] = buf.getFloat();
		}
		return verts;
	}

	private Poly[] readPolys(var buf:ByteBuffer, var header:MeshHeader) {
		var polys:Array= new Poly[header.polyCount];
		for (var i:int= 0; i < polys.length; i++) {
			polys[i] = new Poly(i);
			polys[i].firstLink = buf.getInt();
			for (var j:int= 0; j < polys[i].verts.length; j++) {
				polys[i].verts[j] = buf.getShort() & 0xFFFF;
			}
			for (var j:int= 0; j < polys[i].neis.length; j++) {
				polys[i].neis[j] = buf.getShort() & 0xFFFF;
			}
			polys[i].flags = buf.getShort() & 0xFFFF;
			polys[i].vertCount = buf.get() & 0xFF;
			polys[i].areaAndtype = buf.get() & 0xFF;
		}
		return polys;
	}

	private PolyDetail[] readPolyDetails(var buf:ByteBuffer, var header:MeshHeader) {
		var polys:Array= new PolyDetail[header.detailMeshCount];
		for (var i:int= 0; i < polys.length; i++) {
			polys[i] = new PolyDetail();
			polys[i].vertBase = buf.getInt();
			polys[i].triBase = buf.getInt();
			polys[i].vertCount = buf.get() & 0xFF;
			polys[i].triCount = buf.get() & 0xFF;
		}
		return polys;
	}

	private int[] readDTris(var buf:ByteBuffer, var header:MeshHeader) {
		var tris:Array= []//4* header.detailTriCount];
		for (var i:int= 0; i < tris.length; i++) {
			tris[i] = buf.get() & 0xFF;
		}
		return tris;
	}

	private BVNode[] readBVTree(var buf:ByteBuffer, var header:MeshHeader) {
		var nodes:Array= new BVNode[header.bvNodeCount];
		for (var i:int= 0; i < nodes.length; i++) {
			nodes[i] = new BVNode();
			for (var j:int= 0; j < 3; j++) {
				nodes[i].bmin[j] = buf.getShort() & 0xFFFF;
			}
			for (var j:int= 0; j < 3; j++) {
				nodes[i].bmax[j] = buf.getShort() & 0xFFFF;
			}
			nodes[i].i = buf.getInt();
		}
		return nodes;
	}

	private OffMeshConnection[] readOffMeshCons(var buf:ByteBuffer, var header:MeshHeader) {
		var cons:Array= new OffMeshConnection[header.offMeshConCount];
		for (var i:int= 0; i < cons.length; i++) {
			cons[i] = new OffMeshConnection();
			for (var j:int= 0; j < 6; j++) {
				cons[i].pos[j] = buf.getFloat();
			}
			cons[i].rad = buf.getFloat();
			cons[i].poly = buf.getShort() & 0xFFFF;
			cons[i].flags = buf.get() & 0xFF;
			cons[i].side = buf.get() & 0xFF;
			cons[i].userId = buf.getInt();
		}
		return cons;
	}

	private function align4(buf:ByteBuffer, size:int):void {
		var toSkip:int= ((size + 3) & ~3) - size;
		for (var i:int= 0; i < toSkip; i++) {
			buf.get();
		}
	}

	private function toByteBuffer(inputStream:InputStream):ByteBuffer {
		var baos:ByteArrayOutputStream= new ByteArrayOutputStream();
		var buffer:Array= new byte[4096];
		var l:int;
		while ((l = inputStream.read(buffer)) != -1) {
			baos.write(buffer, 0, l);
		}
		return ByteBuffer.wrap(baos.toByteArray());
	}

}
}