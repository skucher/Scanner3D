#pragma once

#include <iostream>
#include <fstream>
using namespace std;

/**Vector3D is vector 3D representation*/
class Vector3D
{
protected:
	float _x;
	float _y;
	float _z;
public:
	/**parameterless constructor*/
	Vector3D();
	/**constructor:
	*@param x: x location
	*@param y: y location
	*@param z: z location
	*/
	Vector3D(float x,float y,float z);
	/**copy constuctor*/
    Vector3D(const Vector3D& other);
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this+other x1+x2,y1+y2,z1+z2*/
	Vector3D operator + (const Vector3D & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this * alpha. (x*alpha,y*alpha,z*alpha)*/
	Vector3D operator * (float alpha) const;
    
	/**sets vector to center of axis*/
    void Clear()
    {
        _x = 0;
        _y = 0;
        _z = 0;
    }
	/**this = this+other 
	*@param other: the Vector3D to perform the operation
	*@returns this*/
    Vector3D& operator +=(const Vector3D& other);
    /**this = this-other 
	*@param other: the Vector3D to perform the operation
	*@returns this*/
	Vector3D& operator -=(const Vector3D& other);
    /**this = *this = this * alpha
	*@param alpha: the alpha to perform the operation
	*@returns this*/   
	Vector3D& operator *=(float alpha);
    /**this = *this = this / alpha
	*@param alpha: the alpha to perform the operation
	*@returns this*/  
    Vector3D& operator /=(float alpha);
  
    float getX() const {return _x;}
    float getY() const {return _y;}
    float getZ() const {return _z;}
    
    void setX(float x) {_x = x;}
    void setY(float y) {_y = y;}
    void setZ(float z) {_z = z;}
};

