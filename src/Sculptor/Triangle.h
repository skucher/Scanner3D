#pragma once

#include "Vector3DEx.h"
#include "EdgeEx.h"
/**is triangle representation
*containes 3 points, normal of the triangle,and its edges
*@see Vector3DEx,Edge
*/
class Triangle
{
public:
	/**triangle poins
	*@see Vector3DEx*/
	Vector3DEx p[3];
	/**triangle normal
	*@see Vector3DEx*/
	Vector3DEx normal;
    /**triangle edges
	*@see Edge*/
	EdgeEx edges[3];
	/**determines if the triangle was fixed already initial state is false*/
	bool isFixed;
	
	/**constructor:
	*the order of the points defines normal direction
	*@param first: first point
	*@param second: second point
	*@param third: third point
	*@see Vector3DEx
	*/
	Triangle(Vector3DEx first,Vector3DEx second,Vector3DEx third);
	
	~Triangle(void);
	/**copy constructor*/
	Triangle(const Triangle& other);
	/**print triangle to ostream*/
	void print(ostream& os) const;
    
    /**
	*@param other: the other triangle to perform operation with
	*@returns if this triangle equals to other first and second and third points in given order*/
    bool operator==(const Triangle& other);
    
   /**
	*@param edge: the Edge to perform operation with
	*@returns if the edge contanied in in triangle as it is not inverted*/
    bool IsEdgeContainedInSameDirection(const EdgeEx& edge);
    /**inverts triangle normal changes relative position of triangle points*/
    void invertNormal();
private:
	void CalculateNormal();
    void createEdges();
};