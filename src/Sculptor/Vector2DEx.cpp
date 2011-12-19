#include "Vector2DEx.h"
#include <math.h>

Vector2DEx::Vector2DEx(void)
{
}

Vector2DEx::Vector2DEx(float x,float y) : Vector2D(x,y)
{
	vectorLength = sqrtf(x*x+y*y);
}

Vector2DEx::~Vector2DEx(void)
{
}


float Vector2DEx::angle(Vector2DEx& other)
{
	float cosAngle = operator*(other)/(length()*other.length());
	float ang = acosf(cosAngle);
	return ang;
}
float Vector2DEx::length()
{
	return vectorLength;
}
Vector2DEx Vector2DEx::normalize()
{
	float vecMag = length();
	if ( vecMag == 0.0 )
	{
		return Vector2DEx(1.0,0);
	}
	return Vector2DEx(_x /= vecMag,_y /= vecMag);
}

bool	 Vector2DEx::operator < (const Vector2DEx & other) const
{
	if(_x > other._x)
	{
		return false;
	}
	if(_x == other._x)
	{
		if(_y >= other._y)
		{
			return false;
		}
	}
	return true;
}
bool	 Vector2DEx::operator ==(const Vector2DEx & other) const
{
	return _x == other._x && _y == other._y;
}
bool	 Vector2DEx::operator !=(const Vector2DEx & other) const
{
	return !(*this == other);
}
bool     Vector2DEx::operator > (const Vector2DEx & other) const
{
	return (*this != other) && !(*this < other);
}

Vector2DEx Vector2DEx::operator - (const Vector2DEx & other) const
{
	Vector2DEx xyz;
	xyz._x = _x-other._x;
	xyz._y = _y-other._y;
	return xyz;
}
Vector2DEx Vector2DEx::operator + (const Vector2DEx & other) const
{
	Vector2DEx xyz;
	xyz._x = _x+other._x;
	xyz._y = _y+other._y;
	return xyz;
}
float Vector2DEx::operator		* (const Vector2DEx & other) const
{
	return _x*other._x + _y*other._y;
}
Vector2DEx Vector2DEx::operator * (float alpha) const
{
	return Vector2DEx(_x*alpha,_y*alpha);
}

