#ifndef MARCHINGCUBES_H
#define MARCHINGCUBES_H

#include "Triangle.h"

/**GRIDCELL represents 2*2*2 in grid*/
struct GRIDCELL{
	Vector3DEx p[8];
	float val[8];
};

/**
*   Given a grid cell and an isolevel, calculate the triangular
*   facets required to represent the isosurface through the cell.
*   Return the number of triangular facets, the array "triangles"
*   will be loaded up with the vertices at most 5 triangular facets.
*	0 will be returned if the grid cell is either totally above
*   of totally below the isolevel.
*/
int Polygonise(GRIDCELL grid,float isolevel,Triangle** triangles);


#endif