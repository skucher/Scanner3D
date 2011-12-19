#include "Mesh.h"

//ColorRGB colors[] = {{255,0,0,255},{0,255,0,255},{0,0,255,255}};

ColorRGB colors[] = {{255,0,0,255},{220,0,0,255},{200,0,0,255}};

ColorRGB& getNextColor()
{
	static int currentColorIndex = 0;
	return colors[currentColorIndex++ % sizeof(colors)];
}

Mesh::Mesh():numberOfVertices(0)
{
}

Mesh::~Mesh(void)
{
    Clear();
}

void Mesh::Clear()
{
    for (list<Triangle*>::iterator it = triangles.begin(); it != triangles.end(); it++)
	{
		Triangle* currentTriangle = *it;
		delete(currentTriangle);
	}
	triangles.clear();
	
    for(list<Vertex3D*>::iterator it = vertexList.begin(); it != vertexList.end() ; it++)
	{
		delete(*it);
	}
	vertexList.clear();
    
	vertexMap.clear();
    centerOfMass.Clear();
    numberOfVertices = 0;
}
void Mesh::AddEdge(const EdgeEx& edge, Triangle* meshTriangle)
{
    map<EdgeEx,EdgesInfo>::iterator currentEdge = edgesMap.find(edge);
    
    if(currentEdge == edgesMap.end())
    {
        currentEdge = edgesMap.find(edge.invert());
    }
    
    if(currentEdge == edgesMap.end())
    {
        EdgesInfo info;
        info.triangles.push_back(meshTriangle);
        edgesMap.insert(pair<EdgeEx,EdgesInfo >(edge,info));
    }
    else
    {
       currentEdge->second.triangles.push_back(meshTriangle);
    }
    
}
void Mesh::AddTriangle(Triangle* meshTriangle)
{
    AddEdge(meshTriangle->edges[0],meshTriangle);
    AddEdge(meshTriangle->edges[1],meshTriangle);
    AddEdge(meshTriangle->edges[2],meshTriangle);
    
	for(int pointIndexInTriangle = 0; pointIndexInTriangle < 3 ; pointIndexInTriangle++)
	{
		Vector3DEx currentPoint = meshTriangle->p[pointIndexInTriangle];
		map<Vector3DEx,Vertex3DInfo>::iterator currentVertex = vertexMap.find(currentPoint);
		if(currentVertex == vertexMap.end())
		{
			Vertex3D* newVertex = new Vertex3D(currentPoint,getNextColor(),meshTriangle->normal);
			vertexList.push_back(newVertex);
            
			Vertex3DInfo vertexInfo = {newVertex,numberOfVertices,1};
            //vertexInfo.triangles.push_back(meshTriangle); // Normal fix
			
            vertexMap.insert(pair<Vector3DEx,Vertex3DInfo>(currentPoint,vertexInfo));
            
			numberOfVertices++;
            centerOfMass += currentPoint;
		}
        else
        {
            //currentVertex->second.triangles.push_back(meshTriangle); // Normal fix
            currentVertex->second.vertex->_normal += meshTriangle->normal;
            currentVertex->second.numberOfPoints++;
        }
	}
	triangles.push_back(meshTriangle);
}

void Mesh::FixTrianglesByEdgeRec(const EdgeEx& edge)
{
    map<EdgeEx,EdgesInfo>::iterator currentEdge = edgesMap.find(edge);
    
    if(currentEdge == edgesMap.end())
    {
        currentEdge = edgesMap.find(edge.invert());
    }
    if(currentEdge == edgesMap.end())
    {
        return;
    }

    list<Triangle*>& neighbours = currentEdge->second.triangles;
    
    for (list<Triangle*>::iterator triangleIt = neighbours.begin() 
         ; triangleIt != neighbours.end(); triangleIt++)
    {
        if((*triangleIt)->isFixed) continue;
        
        if ((*triangleIt)->IsEdgeContainedInSameDirection(edge)) 
        {
            (*triangleIt)->invertNormal();
        }
        NormalFixRec(*triangleIt);
    } 
}

void Mesh::NormalFixRec(Triangle* triangle)
{
    triangle->isFixed = true;
    
    FixTrianglesByEdgeRec(triangle->edges[0]);
    
    FixTrianglesByEdgeRec(triangle->edges[1]);
    
    FixTrianglesByEdgeRec(triangle->edges[2]);
}


void Mesh::ToShape(float scaleConstant)
{
    //NormalFixRec(triangles.front());
    Shape::getInstance().Clear();
    
    centerOfMass /= numberOfVertices;
    
	int numVertices = vertexList.size();
	Vertex3D* temppoints = new Vertex3D[numVertices];

	int numIndices = triangles.size() * 3;
	unsigned short* tempshape = new  unsigned short[numIndices];
	int pointIndex = 0;
	for (list<Triangle*>::iterator triangleIt = triangles.begin() 
		; triangleIt != triangles.end(); triangleIt++)
	{
		Triangle* currTriangle = *triangleIt;
		tempshape[pointIndex ++ ] = vertexMap[currTriangle->p[0]].position;
		tempshape[pointIndex ++ ] = vertexMap[currTriangle->p[1]].position;
		tempshape[pointIndex ++ ] = vertexMap[currTriangle->p[2]].position;
	}
	int vertexIndex = 0;
	for (list<Vertex3D*>::iterator it = vertexList.begin(); it != vertexList.end(); it++,vertexIndex++)
	{
		float numberOfPointsPerVertex = vertexMap.find(Vector3DEx((*it)->_position))->second.numberOfPoints;
		(**it)._normal /= numberOfPointsPerVertex;
        //(**it)._normal -= centerOfMass;
        
        (**it)._position -= centerOfMass;
        (**it)._position*=scaleConstant;
		temppoints[vertexIndex] = Vertex3D(**it);
	}
    
    Shape& shape = Shape::getInstance();
	shape.indices = tempshape;
	shape.numIndices = numIndices;
	shape.vertices = temppoints;
	shape.numVertices =  numVertices;
}

