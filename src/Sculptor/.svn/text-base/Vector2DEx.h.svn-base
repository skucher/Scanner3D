#pragma once
#include "Vector2D.h"

/**Vector2D is extended vector 2D representation: needed for performance improval 
*its lenght calculated only once on creation*/
class Vector2DEx : public Vector2D
{
public:
	/**parameterless constructor*/
	Vector2DEx(void);
	/**constructor:
	*@param x: x location
	*@param y: y location
	*/
	Vector2DEx(float x,float y);
	~Vector2DEx(void);
	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns angle between this and other*/
	float angle(Vector2DEx& other);
	/**@returns vector length*/
	float length();
	/**normalizes the vector*/
	Vector2DEx normalize();
	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns if this less the other in (x,y) preference order*/	
	bool	 operator < (const Vector2DEx & other) const;
	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns if this equal other x and y*/
	bool	 operator ==(const Vector2DEx & other) const;
	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns if this not equal to other in x or y*/
	bool	 operator !=(const Vector2DEx & other) const;
	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns if this greater the other in (x,y) preference order*/
	bool     operator > (const Vector2DEx & other) const;
	
	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns this-other x1-x2,y1-y2*/
	Vector2DEx operator - (const Vector2DEx & other) const;

	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns this+other x1+x2,y1+y2*/
	Vector2DEx operator + (const Vector2DEx & other) const;

    /**
	*@param other: the Vector2DEx to perform the operation
	*@returns this  product other */
	float	 operator	* (const Vector2DEx & other) const;
	
	/**
	*@param other: the Vector2DEx to perform the operation
	*@returns this * alpha. (x*alpha,y*alpha)*/
	Vector2DEx operator * (float alpha) const;

protected:
	float vectorLength;
};

