#include "PixelVector.h"

/**MeshMargins represents margines for 3D structure:
* 1. margins of x
* 2. margins of y for every x
* 3. margines of z for every (x,y)
* where template parameter is Size
*/
template<int Size>
class MeshMargins
{
public:
    /**constructor*/
	MeshMargins()
    {
        Reset();
    }
    
	/**reset all margines*/
	void Reset()
    {
        minX = 0;
        maxX = Size - 1;
        for(byte x = 0; x  < Size ;x++)
        {
            minYPerX[x] = 0;            
            maxYPerX[x] = Size - 1;
            for(byte y = 0; y  < Size ;y++)
            {
                minZPerXY[x][y] = 0;
                maxZPerXY[x][y] = Size - 1;                
            }    
        } 
    }
    
	/**gets min x in structure*/
	byte GetMinX()
    {
        return minX;
    }
    
	/**sets min x in structure*/
    void SetMinX(byte x)
    {
        minX = x;
    }
    
	/**gets max x in structure*/
    byte GetMaxX()
    {
        return maxX;
    }

    /**sets max x in structure*/
    void SetMaxX(byte x)
    {
        maxX = x;
    }
    
	/**gets min y per x in structure*/
    byte GetMinYPerX(byte x)
    {
        byte roundedX = GetXInBounds(x);
        return minYPerX[roundedX];
    }
    
	/**sets min y per x in structure*/
    void SetMinYPerX(byte x, byte y)
    {
        if(IsXInBounds(x))
        {
            minYPerX[x] = y;   
        }
    }
    
	/**gets max y per x in structure*/
    byte GetMaxYPerX(byte x)
    {
        byte roundedX = GetXInBounds(x);
        return maxYPerX[roundedX];
    }
    
	/**sets max y per x in structure*/
    void SetMaxYPerX(byte x, byte y)
    {
        if(IsXInBounds(x))
        {
            maxYPerX[x] = y;   
        }
    }
    
	/**gets min z per (x,y) in structure*/
    byte GetMinZPerXY(byte x, byte y)
    {
        byte roundedX = GetXInBounds(x);
        byte roundedY = GetYPerXInBounds(roundedX,y);
        return minZPerXY[roundedX][roundedY];
    }
    
	/**sets min z per (x,y) in structure*/
    void SetMinZPerXY(byte x, byte y, byte z)
    {
        if(IsXInBounds(x) && IsYInBounds(x, y))
        {
            minZPerXY[x][y] = z;   
        }
    }
    
	/**gets max z per (x,y) in structure*/
    byte GetMaxZPerXY(byte x, byte y)
    {
        byte roundedX = GetXInBounds(x);
        byte roundedY = GetYPerXInBounds(roundedX,y);
        return maxZPerXY[roundedX][roundedY];
    }
    
	/**sets max z per (x,y) in structure*/
    void SetMaxZPerXY(byte x, byte y, byte z)
    {
        if(IsXInBounds(x) && IsYInBounds(x, y))
        {
            maxZPerXY[x][y] = z;   
        }
    }

private:
    byte minX;
    byte maxX;
    byte minYPerX[Size];
    byte maxYPerX[Size];
    byte minZPerXY[Size][Size];
    byte maxZPerXY[Size][Size];

    byte GetXInBounds(byte x)
    {
        if(x < minX)
        {
            return minX;
        }
        if(x > maxX)
        {
            return maxX;
        }
        return x;
    }
    
    bool IsXInBounds(byte x)
    {
        return GetXInBounds(x) == x; 
    }
    
    byte GetYPerXInBounds(byte x, byte y)
    {
        if(y < minYPerX[x])
        {
            return minYPerX[x];
        }
        if(y > maxYPerX[x])
        {
            return maxYPerX[x];
        }
        return y;  
    }
    
    bool IsYInBounds(byte x, byte y)
    {
        return GetYPerXInBounds(x,y) == y; 
    }
    
};