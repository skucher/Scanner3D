#pragma once

#include "Vector3D.h"

/**Vector3DEx is extendex Vector3D: needed for performance improval 
*its lenght calculated only once on creation*/
class Vector3DEx : public Vector3D
{
public:
	/**parameterless constructor*/
	Vector3DEx(void);
	/**constructor:
	*@param x: x location
	*@param y: y location
	*@param z: z location
	*/
	Vector3DEx(float x,float y,float z);
	/**copy constuctor*/
	Vector3DEx(const Vector3D& other);
	/**destructor*/
	~Vector3DEx(void);
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns angle between this and other*/
	float angle(Vector3DEx& other);
	/**@returns vector length*/
	float length();
	/**normalizes the vector*/
	Vector3DEx normalize();
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns cross product Vector3DEx between this and other*/
	Vector3DEx crossProduct(Vector3DEx& other);


	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this less the other in (x,y,z) preference order*/
	bool	 operator < (const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this equal other x and y and z*/
	bool	 operator ==(const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this not equal to other in x or y or z*/
	bool	 operator !=(const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this greater the other in (x,y,z) preference order*/
	bool     operator > (const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this-other x1-x2,y1-y2,z1-z2*/
	Vector3DEx  operator - (const Vector3DEx & other) const;
	
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this+other x1+x2,y1+y2,z1+z2*/
	Vector3DEx  operator + (const Vector3DEx & other) const;
	
	/**this = this+other 
	*@param other: the Vector3DEx to perform the operation
	*@returns this*/
	Vector3DEx& operator +=(const Vector3DEx& other);
    /**this = this-other 
	*@param other: the Vector3DEx to perform the operation
	*@returns this*/
	Vector3DEx& operator -=(const Vector3DEx& other);
    /**this = this * alpha
	*@param other: the Vector3DEx to perform the operation
	*@returns this*/
	Vector3DEx& operator *=(float alpha);
    /**
	*@param other: the Vector3DEx to perform the operation
	*@returns this  product other */
	float	 operator	* (const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this * alpha. (x*alpha,y*alpha,z*alpha)*/
	Vector3DEx operator * (float alpha) const;
	
	float getX();
	float getY();
	float getZ();

protected:
	float vectorLength;
};

