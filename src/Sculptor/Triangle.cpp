#include "Triangle.h"

Triangle::Triangle(Vector3DEx first,Vector3DEx second,Vector3DEx third)
{
	p[0] = first;
	p[1] = second;
	p[2] = third;
    createEdges();
	CalculateNormal();
}

void Triangle::createEdges()
{
    edges[0] = EdgeEx(p[0],p[1]);
    edges[1] = EdgeEx(p[1],p[2]);
    edges[2] = EdgeEx(p[2],p[0]);
}

Triangle::~Triangle(void)
{
}

Triangle::Triangle(const Triangle& other):isFixed(false)
{
	p[0] = other.p[0];
	p[1] = other.p[1];
	p[2] = other.p[2];
    createEdges();
	CalculateNormal();
}

bool Triangle::IsEdgeContainedInSameDirection(const EdgeEx& edge)
{
    for (int edgeIndex = 0; edgeIndex < 3; edgeIndex++) {
        if(edges[edgeIndex] == edge)
        {
            return edges[edgeIndex].isInSameDirection(edge); 
        }
    }
    return false;
}

void Triangle::CalculateNormal()
{
	Vector3DEx vector1 = p[0] - p[1];
	Vector3DEx vector2 = p[0] - p[2];
	normal = vector2.crossProduct(vector1);
}

bool Triangle::operator==(const Triangle& other)
{
    return p[0] == other.p[0] && p[1] == other.p[1] && p[2] == other.p[2];
}

void Triangle::invertNormal()
{
    Vector3DEx temp = p[1];
    p[1] = p[2];
    p[2] = temp;
    createEdges();
}
