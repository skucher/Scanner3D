#include "Vector3DEx.h"
#include <math.h>

Vector3DEx::Vector3DEx(void):vectorLength(0)
{
}

Vector3DEx::Vector3DEx(const Vector3D& other):Vector3D(other)
{
    vectorLength = sqrtf(_x*_x + _y*_y + _z*_z);
}

Vector3DEx::Vector3DEx(float x,float y,float z) : Vector3D(x,y,z)
{
	vectorLength = sqrtf(_x*_x + _y*_y + _z*_z);
}

Vector3DEx::~Vector3DEx(void)
{
}

float Vector3DEx::angle(Vector3DEx& other)
{
	float cosAngle = (*this*other)/(length()*other.length());
	float ang = acosf(cosAngle);
	return ang;
}
float Vector3DEx::length()
{
	return vectorLength;
}
Vector3DEx Vector3DEx::normalize()
{
	float vecMag = length();
	if ( vecMag == 0.0 )
	{
		return Vector3DEx(1.0,0,0);
	}
	return Vector3DEx(_x /= vecMag,_y /= vecMag,_z /= vecMag);
}
Vector3DEx Vector3DEx::crossProduct(Vector3DEx& other)
{
	Vector3DEx ret;
	ret._x = (_y * other._z) - (_z * other._y);
	ret._y = (_z * other._x) - (_x * other._z);
	ret._z = (_x * other._y) - (_y * other._x);
	return ret;
}

Vector3DEx& Vector3DEx::operator +=(const Vector3DEx& other)
{
    _x += other._x;
    _y += other._y;
    _z += other._z;
    return *this;
}

Vector3DEx& Vector3DEx::operator -=(const Vector3DEx& other)
{
    _x -= other._x;
    _y -= other._y;
    _z -= other._z;
    return *this;
}

Vector3DEx& Vector3DEx::operator *=(float alpha)
{
    _x *= alpha;
    _y *= alpha;
    _z *= alpha;
    return *this;

}

bool	 Vector3DEx::operator <(const Vector3DEx & other) const
{
	if(_x > other._x)
	{
		return false;
	}
	if(_x == other._x)
	{
		if(_y > other._y)
		{
			return false;
		}
		if(_y == other._y)
		{
			if(_z >= other._z)
			{
				return false;
			}
		}
	}
	return true;
}
bool	 Vector3DEx::operator ==(const Vector3DEx & other) const
{
	return _x == other._x && _y == other._y && _z == other._z;
}
bool	 Vector3DEx::operator !=(const Vector3DEx & other) const
{
	return !(*this == other);
}
bool     Vector3DEx::operator > (const Vector3DEx & other) const
{
	return (*this != other) && !(*this < other);
}
	
Vector3DEx Vector3DEx::operator - (const Vector3DEx & other) const
{
	Vector3DEx xyz;
	xyz._x = _x-other._x;
	xyz._y = _y-other._y;
	xyz._z = _z-other._z;
	return xyz;
}
Vector3DEx Vector3DEx::operator + (const Vector3DEx & other) const
{
	Vector3DEx xyz;
	xyz._x = _x+other._x;
	xyz._y = _y+other._y;
	xyz._z = _z+other._z;
	return xyz;
}

float	 Vector3DEx::operator	* (const Vector3DEx & other) const
{
	float dot = _x*other._x + _y*other._y + _z*other._z;
	return dot;
}
Vector3DEx Vector3DEx::operator * (float alpha) const
{
	return Vector3DEx(_x*alpha,_y*alpha,_z*alpha);
}

float Vector3DEx::getX()
{
	return _x;
}

float Vector3DEx::getY()
{
	return _y;
}

float Vector3DEx::getZ()
{
	return _z;
}
