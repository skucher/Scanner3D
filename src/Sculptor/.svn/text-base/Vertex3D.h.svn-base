#pragma once

#include "ColorRGB.h"
#include "Vector3D.h"
#include <sstream>

/**struct that represents Vertex in 3D, location, normal and color of the point
*@see Vector3D,ColorRGB
*/
struct Vertex3D
{
	/**position of the vertex*/
	Vector3D _position;
	/**color of the vertex*/
	ColorRGB _color;
	/**surface normal at vertex location*/
	Vector3D _normal;
    
	/**parameterless constructor*/
	Vertex3D(){}

	/**copy constructor*/
    Vertex3D(const Vertex3D& other)
    {
        _position = other._position;
        _color = other._color;
        _normal = other._normal;
    }
	
	/**constructor
	*@param position: the vertex position
	*@param color: the vertex color
	*@param normal: surface normal at vertex location
	*/
	Vertex3D(Vector3D& position, ColorRGB& color,Vector3D& normal)
    : _position(position),_color(color),_normal(normal){}
      
	/**serialize*/
    friend ofstream& operator<<(ofstream &stream, Vertex3D vertex) 
    {
        stringstream x1,y1,z1,x2,y2,z2;
        x1 << vertex._position.getX();
        y1 << vertex._position.getY();
        z1 << vertex._position.getZ();
        
        x2 << vertex._normal.getX();
        y2 << vertex._normal.getY();
        z2 << vertex._normal.getZ();
        
        stream << x1.str() << " " << y1.str() << " " << z1.str() << " "                
        << (short)vertex._color.R   << " " 
        << (short)vertex._color.G   << " " 
        << (short)vertex._color.B   << " " 
        << (short)vertex._color.T   << " "
        << x2.str() << " " << y2.str() << " " << z2.str() << " ";
        
        return stream;
    }
    
	/**deserialize*/
    friend void operator>>(stringstream& ss, Vertex3D& vertex)
    {
        string data = ss.str();
        int index = 0;
        int numbersCovered = 0;
        int subStrLen = 0;
        
        float tempVectorPosition[3];
        while (numbersCovered < 3)
        {
            while (data[index+subStrLen] != ' ') subStrLen++;
            
            stringstream tempSS(data.substr(index,subStrLen));
            tempSS >> tempVectorPosition[numbersCovered];
            index += subStrLen += 1;
            subStrLen = 0;
            numbersCovered++;
        }
        
        unsigned short tempVectorColor[4];
        while (numbersCovered < 7)
        {
            while (data[index+subStrLen] != ' ') subStrLen++;
            stringstream tempSS(data.substr(index,subStrLen));        
            tempSS >> tempVectorColor[numbersCovered-3];
            index += subStrLen += 1;
            subStrLen = 0;
            numbersCovered++;
        }
        
        float tempVectorNormal[3];
        while (numbersCovered < 10)
        {
            while (data[index+subStrLen] != ' ') subStrLen++;
            stringstream tempSS(data.substr(index,subStrLen));        
            tempSS >> tempVectorNormal[numbersCovered-7];
            index += subStrLen += 1;
            subStrLen = 0;
            numbersCovered++;
        }
        
        vertex._position.setX(tempVectorPosition[0]);
        vertex._position.setY(tempVectorPosition[1]);
        vertex._position.setZ(tempVectorPosition[2]);
        
        vertex._color.R = (unsigned char)tempVectorColor[0];
        vertex._color.G = (unsigned char)tempVectorColor[1];
        vertex._color.B = (unsigned char)tempVectorColor[2];
        vertex._color.T = (unsigned char)tempVectorColor[3];
        
        vertex._normal.setX(tempVectorNormal[0]);
        vertex._normal.setY(tempVectorNormal[1]);
        vertex._normal.setZ(tempVectorNormal[2]);
    }
};









