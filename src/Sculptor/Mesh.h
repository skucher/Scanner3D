#pragma once

#include "MarchingCubes.h"
#include "Triangle.h"
#include "Shape.h"

#include <list>
#include <map>
#include <iostream>
using namespace std;

struct Vertex3DInfo
{
	Vertex3D* vertex;
	int position;
	int numberOfPoints;
};

struct EdgesInfo
{
    list<Triangle*> triangles;
};


/**Mesh is a class that holds 3D mesh
 */
class Mesh
{
public:
public:
    /**Constructor
     */
    Mesh();
    //Mesh(int size);
    
    /**Destructor
     */
    ~Mesh(void);
    
    /**Clear mesh contents
     */
    void Clear();
    
    /**Add triangle to the mesh
     */
    void AddTriangle(Triangle* meshTriangle);
    
    /** Converts the mesh to Shape format
     *that can be displayed in OPENGL
     */
    void ToShape(float scaleConstant = 1);
    
private:
    /**The list of mesh triangles*/
    list<Triangle*> triangles;
    /**The list of mesh vertces*/
    list<Vertex3D*> vertexList;
    /**The numberOfVertices in mesh*/
    int numberOfVertices;
    /**map of the vertex indices in Mesh#vertexList*/
    map<Vector3DEx,Vertex3DInfo> vertexMap;
    /**map of the Edges*/
    map<EdgeEx, EdgesInfo > edgesMap;
    /**Mesh center*/
    Vector3D centerOfMass;
    /**fix normals recurcive*/
    void NormalFixRec(Triangle* triangle);
    /**adds adge to Mesh#edgesMap*/
    void AddEdge(const EdgeEx& edge, Triangle* meshTriangle);
    /**Fix Triangles By Edge recurcive*/
    void FixTrianglesByEdgeRec(const EdgeEx& edge);
};