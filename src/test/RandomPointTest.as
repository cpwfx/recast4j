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
package test {
	import org.recast4j.detour.FindRandomPointResult;
	import org.recast4j.detour.FRand;
	import org.recast4j.detour.QueryFilter;
	import org.recast4j.detour.Status;
	import org.recast4j.detour.Tupple2;
	import test.AbstractDetourTest;

public class RandomPointTest extends AbstractDetourTest {

	public function RandomPointTest() 
	{
		setUp();
		testRandom();
	}
	
	public function testRandom():void {
		var f:FRand= new FRand();
		var filter:QueryFilter= new QueryFilter();
		for (var i:int= 0; i < 1000; i++) {
			var point:FindRandomPointResult= query.findRandomPoint(filter, f);
			assertEquals(Status.SUCCSESS, point.getStatus());
			var tileAndPoly:Tupple2 = navmesh.getTileAndPolyByRef(point.getRandomRef());
			var bmin:Array= []//new float[2];
			var bmax:Array= []//new float[2];
			for (var j:int= 0; j < tileAndPoly.second.vertCount; j++) {
				var v:int= tileAndPoly.second.verts[j] * 3;
				bmin[0] = j == 0? tileAndPoly.first.data.verts[v] : Math.min(bmin[0], tileAndPoly.first.data.verts[v]);
				bmax[0] = j == 0? tileAndPoly.first.data.verts[v] : Math.max(bmax[0], tileAndPoly.first.data.verts[v]);
				bmin[1] = j == 0? tileAndPoly.first.data.verts[v + 2] : Math.min(bmin[1], tileAndPoly.first.data.verts[v + 2]);
				bmax[1] = j == 0? tileAndPoly.first.data.verts[v + 2] : Math.max(bmax[1], tileAndPoly.first.data.verts[v + 2]);
			}
			assertTrue(point.getRandomPt()[0] >= bmin[0]);
			assertTrue(point.getRandomPt()[0] <= bmax[0]);
			assertTrue(point.getRandomPt()[2] >= bmin[1]);
			assertTrue(point.getRandomPt()[2] <= bmax[1]);
		}
	}

	public function testRandomInCircle():void {
		var f:FRand= new FRand();
		var filter:QueryFilter= new QueryFilter();
		var point:FindRandomPointResult= query.findRandomPoint(filter, f);
		for (var i:int= 0; i < 1000; i++) {
			point = query.findRandomPointAroundCircle(point.getRandomRef(), point.getRandomPt(), 5, filter, f);
			assertEquals(Status.SUCCSESS, point.getStatus());
			var tileAndPoly:Tupple2 = navmesh.getTileAndPolyByRef(point.getRandomRef());
			var bmin:Array= []//new float[2];
			var bmax:Array= []//new float[2];
			for (var j:int= 0; j < tileAndPoly.second.vertCount; j++) {
				var v:int= tileAndPoly.second.verts[j] * 3;
				bmin[0] = j == 0? tileAndPoly.first.data.verts[v] : Math.min(bmin[0], tileAndPoly.first.data.verts[v]);
				bmax[0] = j == 0? tileAndPoly.first.data.verts[v] : Math.max(bmax[0], tileAndPoly.first.data.verts[v]);
				bmin[1] = j == 0? tileAndPoly.first.data.verts[v + 2] : Math.min(bmin[1], tileAndPoly.first.data.verts[v + 2]);
				bmax[1] = j == 0? tileAndPoly.first.data.verts[v + 2] : Math.max(bmax[1], tileAndPoly.first.data.verts[v + 2]);
			}
			assertTrue(point.getRandomPt()[0] >= bmin[0]);
			assertTrue(point.getRandomPt()[0] <= bmax[0]);
			assertTrue(point.getRandomPt()[2] >= bmin[1]);
			assertTrue(point.getRandomPt()[2] <= bmax[1]);
		}
	}
}
}