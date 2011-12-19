#pragma once

#include "Mesh.h"
#include "SculptData.h"
#include "Vector2D.h"
#include "MeshMargins.h"
#include "Edge.h"

#define FULLCELL	(0xFF)

#define INSHAPE		(1.0f)
#define OUTSAHPE	(0.0f)

#define TO_SHAPE_THRESHOLD  1

typedef enum {
    BLACK = 1, BLUE = 2,
    WHITE = 3, RED = 4,
    OUTSIDE = 5
} VoxelStatus;

typedef enum
{
    FAST,
    ACCURATE
}SculptorMode;

static char pointOffsetArray[8][3] =
{
	{0,0,0},
	{0,1,0},
	{1,1,0},
	{1,0,0},
	{0,0,1},
	{0,1,1},
	{1,1,1},
	{1,0,1},
};

/**Sculptor: is template class where template argument is its size<br>
*Sculptor holds 3D shape representation and responsible to :<br>
*1. Sculp it using SculpData
*2. Convert it to 3D mesh 
*@see Mesh, SculpData
*/
template<int Size>
class Sculptor
{
public:
	/** The sculpture is initialised to be SIZE * SIZE * SIZE cube
	*  @param _scaleRate  : defines the ditance between voxels in suplture
	*  @param translation : defines the position of the shape in 3D world
	*/
	Sculptor(float _scaleRate, const Vector3D& translation)
	{
        scaleRate = _scaleRate / Size;//0.2463 ;
        translationRateX = translation.getX();//-0.1307;
        translationRateY = translation.getY();//-0.1307;
        translationRateZ = translation.getZ();//-0.7483;
        
		Reset();
	}


	~Sculptor(void) 
	{
	}
    
	/**@param sculpData  : picture and its position marix to perform sculp with
	*  @param mode       : the mode of sculpting
	*  @see SculptData
	* @see SculptorMode
	*/
    void Sculp(SculptData* sculpData, SculptorMode mode = ACCURATE)
    {
        if(mode == ACCURATE)
        {
            SculpAccurate(sculpData);
            return;
        }
        if(mode == FAST)
        {
            SculpFast(sculpData);
            return;
        }
    }
    
	/**Resets the structure to full cube*/
    void Reset()
    {
        for(unsigned char x = 0; x < Size ; x++)
			for(unsigned char y = 0; y < Size ; y++)
				for(unsigned char z = 0; z < Size >> 3; z++)
					sculpture[x][y][z] = FULLCELL;
        meshMargins.Reset();
    }
    
	/**Generate triangle mesh from 3D object*/
	void ToShape(SculptorMode mode = ACCURATE,float scaleConstant = 1)
	{
        mesh.Clear();
        byte minX = meshMargins.GetMinX();
        byte maxX = meshMargins.GetMaxX();
        
		for(char x = GetMin(minX,mode); x <= GetMax(maxX,mode); x++)
		{
            byte minYPerX = meshMargins.GetMinYPerX(x);
            byte maxYPerX = meshMargins.GetMaxYPerX(x);
            
			for(char y = GetMin(minYPerX,mode); y <= GetMax(maxYPerX,mode); y++)
			{
                byte minZPerXY = meshMargins.GetMinZPerXY(x,y);
                byte maxZPerXY = meshMargins.GetMaxZPerXY(x,y);
                
				for(char z = GetMin(minZPerXY,mode); z <= GetMax(maxZPerXY,mode); z++)
				{
					PoligolizeCell(x,y,z,mode);	
				}
			}
		}
        mesh.ToShape(scaleConstant);
	}
    
	/**Gets the outline of the cube*/
    void CreateOutline()
    {
        int size = 12;
        Edge* edges = new Edge[size];
        
        edges[0].first  = GetVectorPosition(0       ,   0       ,   0       ); 
        edges[0].second = GetVectorPosition(0       ,   Size - 1,   0       ); 
        
        edges[1].first  = GetVectorPosition(0       ,   0       ,   0       ); 
        edges[1].second = GetVectorPosition(Size - 1,   0       ,   0       );
        
        edges[2].first  = GetVectorPosition(0       ,   0       ,   0       ); 
        edges[2].second = GetVectorPosition(0       ,   0       ,   Size - 1);
        
        edges[3].first  = GetVectorPosition(Size - 1,   Size - 1,   0       ); 
        edges[3].second = GetVectorPosition(0       ,   Size - 1,   0       );
        
        edges[4].first  = GetVectorPosition(Size - 1,   Size - 1,   0       ); 
        edges[4].second = GetVectorPosition(Size - 1,   0       ,   0       );
        
        edges[5].first  = GetVectorPosition(Size - 1,   Size - 1,   0       ); 
        edges[5].second = GetVectorPosition(Size - 1,   Size - 1,   Size - 1);
        
        edges[6].first  = GetVectorPosition(Size - 1,   0       ,   Size - 1); 
        edges[6].second = GetVectorPosition(Size - 1,   0       ,   0       );
        
        edges[7].first  = GetVectorPosition(Size - 1,   0       ,   Size - 1); 
        edges[7].second = GetVectorPosition(Size - 1,   Size - 1,   Size - 1);
        
        edges[8].first  = GetVectorPosition(Size - 1,   0       ,   Size - 1); 
        edges[8].second = GetVectorPosition(0       ,   0       ,   Size - 1);
        
        edges[9].first  = GetVectorPosition(0       ,   Size - 1,   Size - 1); 
        edges[9].second = GetVectorPosition(0       ,   Size - 1,   0       );
        
        edges[10].first  = GetVectorPosition(0       ,   Size - 1,   Size - 1); 
        edges[10].second = GetVectorPosition(Size - 1,   Size - 1,   Size - 1);
        
        edges[11].first  = GetVectorPosition(0       ,   Size - 1,   Size - 1); 
        edges[11].second = GetVectorPosition(0       ,   0       ,   Size - 1);
        
        Shape::getInstance().setOutline(edges,size);   
    }
    
	protected:
		
		unsigned char sculpture[Size][Size][Size>>3];
        MeshMargins<Size> meshMargins;
		Mesh mesh;
		
        float scaleRate;
        float translationRateX;
        float translationRateY;
        float translationRateZ;
            
        void SculpFast(SculptData* sculpData)
        {
            byte minX = meshMargins.GetMinX();
            byte maxX = meshMargins.GetMaxX();
            
            byte minXnew = meshMargins.GetMinX();
            byte maxXnew = meshMargins.GetMaxX();
            
            bool minXDirty = false;
            
            for(unsigned char x = minX; x <= maxX ; x++)
            {
                byte minYPerX = meshMargins.GetMinYPerX(x);
                byte maxYPerX = meshMargins.GetMaxYPerX(x);
                
                byte minYPerXnew = meshMargins.GetMinYPerX(x);
                byte maxYPerXnew = meshMargins.GetMaxYPerX(x);
                
                bool minYPerXDirty = false;
                
                for(unsigned char y = minYPerX; y <= maxYPerX ; y++)
                {
                    byte minZPerXY = meshMargins.GetMinZPerXY(x,y);
                    byte maxZPerXY = meshMargins.GetMaxZPerXY(x,y);
                    
                    byte minZPerXYnew = meshMargins.GetMinZPerXY(x,y);
                    byte maxZPerXYnew = meshMargins.GetMaxZPerXY(x,y);
                    
                    bool minZPerXYDirty = false;
                    
                    for(unsigned char z = minZPerXY; z <= maxZPerXY ; z++)
                    {
                        float transformedX = Transform(x, translationRateX);
                        float transformedY = Transform(y, translationRateY);
                        float transformedZ = Transform(z, translationRateZ);
                        
                        Vector3DEx xyz = Vector3DEx(transformedX,transformedY,transformedZ);
                        Vector2D xy = Project(xyz,sculpData->projection);
                        VoxelStatus vStatus = isInMap(xy,sculpData->map,sculpData->sizeXmap,sculpData->sizeYmap);

                        if(vStatus == BLACK)
                        {
                            TurnOff(x,y,z);
                            if(!minXDirty) 
                            {
                                minXnew = x;
                            }
                            if(!minYPerXDirty)
                            {
                                minYPerXnew = y;
                            }
                            if(!minZPerXYDirty)
                            {
                                minZPerXYnew = z;
                            }
                        }
                        else 
                        {
                            minXDirty = true;
                            minYPerXDirty = true;
                            minZPerXYDirty = true;
                            
                            maxXnew = x;
                            maxYPerXnew = y;
                            maxZPerXYnew = z;
                        }                        
                        
                    }
                    meshMargins.SetMinZPerXY(x,y,minZPerXYnew);
                    meshMargins.SetMaxZPerXY(x,y,maxZPerXYnew);
                }
                meshMargins.SetMinYPerX(x,minYPerXnew);
                meshMargins.SetMaxYPerX(x,maxYPerXnew); 
            }
            
            meshMargins.SetMinX(minXnew);
            meshMargins.SetMaxX(maxXnew);
            
        }
        
        void SculpAccurate(SculptData* sculpData)
        {
            for(unsigned char x = 0; x < Size; x++)
            {
                for(unsigned char y = 0; y < Size; y++)
                {
                    for(unsigned char z = 0; z < Size; z++)
                    {
                        float transformedX = Transform(x, translationRateX);
                        float transformedY = Transform(y, translationRateY);
                        float transformedZ = Transform(z, translationRateZ);
                        
                        Vector3DEx xyz = Vector3DEx(transformedX,transformedY,transformedZ);
                        Vector2D xy = Project(xyz,sculpData->projection);
                        VoxelStatus vStatus = isInMap(xy,sculpData->map,sculpData->sizeXmap,sculpData->sizeYmap);
                        
                        if(vStatus == BLACK)
                        {
                            
                            TurnOff(x,y,z);
                        }
                    }
                }
            }
        }

        inline char GetMin(char min, SculptorMode mode)
        {
            return mode == FAST ? min - TO_SHAPE_THRESHOLD : -1;
            //return 0;
        }
        
        inline char GetMax(char max, SculptorMode mode)
        {
            return mode == FAST ? max + TO_SHAPE_THRESHOLD : Size;
            //return Size - 1;
        }
    
        inline void BuildCell(char x, char y, char z, GRIDCELL* cell,SculptorMode mode)
        {
            for(char pointIndex = 0; pointIndex < 8 ; pointIndex++)
            {
                char currentX =  x + pointOffsetArray[pointIndex][0];
                char currentY =  y + pointOffsetArray[pointIndex][1];
                char currentZ =  z + pointOffsetArray[pointIndex][2];
                
                float transformedX = Transform(currentX, translationRateX);
                float transformedY = Transform(currentY, translationRateY);
                float transformedZ = Transform(currentZ, translationRateZ);
                
                cell->p[pointIndex] = Vector3DEx(transformedX,transformedY,transformedZ);
                
                
                byte minX = meshMargins.GetMinX();
                byte maxX = meshMargins.GetMaxX();
                byte minYPerX = meshMargins.GetMinYPerX(x);
                byte maxYPerX = meshMargins.GetMaxYPerX(x);
                byte minZPerXY = meshMargins.GetMinZPerXY(x,y);
                byte maxZPerXY = meshMargins.GetMaxZPerXY(x,y);
                
                if(currentX <= GetMin(minX, mode) || currentX >= GetMax(maxX, mode) ||
                        currentY <= GetMin(minYPerX, mode) || currentY >=  GetMax(maxYPerX, mode) ||
                            currentZ <= GetMin(minZPerXY, mode) || currentZ >= GetMax(maxZPerXY, mode))
                
                {
                    cell->val[pointIndex] = OUTSAHPE;
                }
                else
                {
                    cell->val[pointIndex] = IsOn(currentX,currentY,currentZ) ? INSHAPE : OUTSAHPE;
                }
            }
        }
    
        inline float Transform(char pointIndex, float translate)
        {
            return pointIndex*scaleRate + translate;
        }
    
		inline void PoligolizeCell(char x, char y, char z,SculptorMode mode)
		{
			GRIDCELL cell;
			BuildCell(x,y,z,&cell,mode);
			Triangle** triangles = new Triangle*[5];
			int numberOfTriangles = Polygonise(cell,1,triangles);
			for(int triangelIndex = 0; triangelIndex < numberOfTriangles ; triangelIndex++)
			{
				mesh.AddTriangle(triangles[triangelIndex]);
			}
			delete(triangles);
		}

		inline void TurnOn(unsigned char x, unsigned char y, unsigned char z)
		{
			sculpture[x][y][z>>3] |= ( 1 << (z & 7));
		}

		inline void TurnOff(unsigned char x, unsigned char y, unsigned char z)
		{
			sculpture[x][y][z>>3] &= ~( 1 << (z & 7));
		}

		inline unsigned char IsOn(unsigned char x, unsigned char y, unsigned char z)
		{
			return sculpture[x][y][z>>3] & ( 1 << (z & 7));
		}

		inline Vector2D Project(Vector3DEx& vector,float projection[3*4])
		{
            float x = vector.getX() * GetProjectionCell(projection,0,0) + 
                      vector.getY() * GetProjectionCell(projection,0,1) + 
                      vector.getZ() * GetProjectionCell(projection,0,2) +  
                      1             * GetProjectionCell(projection,0,3);

			float y = vector.getX() * GetProjectionCell(projection,1,0) + 
                      vector.getY() * GetProjectionCell(projection,1,1) + 
                      vector.getZ() * GetProjectionCell(projection,1,2) +  
                      1             * GetProjectionCell(projection,1,3);

			float z = vector.getX() * GetProjectionCell(projection,2,0) + 
                      vector.getY() * GetProjectionCell(projection,2,1) + 
                      vector.getZ() * GetProjectionCell(projection,2,2) + 
                      1             * GetProjectionCell(projection,2,3);

			return Vector2D(x/z,y/z);
		}

		inline VoxelStatus isInMap(Vector2D& xy,unsigned char* _map, size_t sizeX, size_t sizeY)
		{
            int x = (int)xy.getX();
            int y = (int)xy.getY();
            //if (x < 1 || x > sizeX || y < 1 || y > sizeY)
            if (x < 0 || x >= sizeX || y < 0 || y >= sizeY)
            {
                //NSLog(@"index is OUtside !!!!");
                return OUTSIDE;
                
            }
            
			int index = x + (sizeX) * y;
            
            //TODO remove 
            if (index < 0)
            {
                //NSLog(@"index is negative !!!!");
            }
            
            if (_map[index] == 0 || _map[index] == BLUE)
            {
                //NSLog(@"index is black !!!!");
                _map[index] = BLUE;
                return BLACK;
            }
            //NSLog(@"index is White !!!!");
            _map[index] = RED;
            return WHITE;
		}
    
        inline float GetProjectionCell(float projection[3*4], int x, int y)
        {
            float result =  projection[4*x + y];
            return result;
        }
    
        inline Vector3D GetVectorPosition(byte x, byte y, byte z)
        {
            return Vector3D(Transform(x,translationRateX),Transform(y,translationRateY),Transform(z,translationRateZ));
        }
        inline Vertex3D GetVertexPosition(byte x, byte y, byte z, float transpancy)
        {
            Vector3D position = GetVectorPosition(x,y,z);
            ColorRGB color = {255,0,0,transpancy};
            return Vertex3D(position,color,position);
        }

        
};