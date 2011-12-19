#pragma once

#include <math.h>

typedef unsigned char byte;
#define PI 3.14159265

/**vector that represents pixel*/
class PixelVector
{
protected:
	float x;
    float y;
    float z;

	bool isDirty;



public:

	float _length;
    float length()
    {
		return sqrtf(x*x+y*y+z*z);
    }
	/**constructor
     @param X - x
     @param Y - y
     @param Z - z*/
	PixelVector(float X = 0 , float Y = 0, float Z = 0 )
    {
        x = X;
        y = Y;
        z = Z;

        _length = length();
        isDirty = true;
    }
    /**normalize*/
    PixelVector normalize()
    {
        return  (*this) * (1.0f / _length);
    }
    /**perform projection on 
     @param u*/
    float project(PixelVector u)
    {
		float result = (*this * u) / u._length;
        return result;
    }
    /**check angle with 
     @param u*/
    float angle(PixelVector u)
    {
		float result = (float)(acosf(project(u) / _length)* 360.0f);
		return  (float)(result / (2.0f * PI));
    }
    /**returns this + u 
     @param u*/
    PixelVector operator +(PixelVector u)
    {
        return PixelVector(x + u.x, y + u.y, z + u.z);
    }
    /**returns this - u 
     @param u*/
    PixelVector operator -(PixelVector u)
    {
        return PixelVector(x - u.x, y - u.y, z - u.z);
    }
    /**returns this*alpha
     @param u*/
    PixelVector operator *(float alpha)
    {
        return PixelVector((int)(alpha * x), (int)(alpha * y), (int)(alpha * z));
    }
    /**performs dot operation
     @param u*/
    float operator *(PixelVector u)
    {
        return x * u.x + y * u.y + z * u.z;
    }
};

