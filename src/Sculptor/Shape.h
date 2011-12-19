#pragma once

#include "Vertex3D.h"
#include "Edge.h"
#include <sstream>

/**
Shape class: Singleton class representing shape that can be shown on OPENGL
*/
class Shape
{
public:
    /**Vertices of the shape
	@see Vertex3D
	*/
	Vertex3D* vertices;
	int numVertices;
	/**Indices of vertices ordered by shape triangles
		every three vertex indices represent triangle to show in OPENGL
	*/
	unsigned short* indices;
	int numIndices;

    Edge* outline;
    int outlineSize;
	/**getInstance method*/
    static Shape& getInstance()
    {
        static Shape instance;
        return instance;
    }
    
	/**check if the shape is initialized*/
    bool Initialized()
    {
        return vertices != NULL && indices != NULL;
    }
    
	/**Clear and dealloc all map contents*/
    void Clear()
    {
        if(vertices != NULL)
		{
			delete(vertices);
            vertices = NULL;
		}
		if(indices != NULL)
		{
			delete(indices);
            indices = NULL;
		}
    }
    
    
    void setOutline(Edge* _outline, int size)
    {
        if(outline != NULL)
        {
            delete[] outline;
        }
        outline = _outline;
        outlineSize = size;
    }
    
    /**Write Shape Data To File*/
    void WriteDataToFile(string filePath)
    {
        ofstream meshfile;
        meshfile.open (filePath.c_str());
        if (meshfile.is_open())
        {
            

            meshfile << numIndices << " " << numVertices << " ";
            
            for (int i=0; i<numIndices; i++)
            {
                meshfile << indices[i] << " ";
            }
            
            for (int i=0; i<numVertices; i++)
            {
                meshfile << vertices[i] << " ";
            }
            
            meshfile.close();
        }
        else cout << "ERROR: Unable to open file: " << filePath;
        
    }
    /**Read Shape Data From File*/
    void ReadDataFromFile(string filePath)
    {
        string data;
        ifstream myfile (filePath.c_str());
        if (myfile.is_open())
        {
            if ( myfile.good() )
            {
                
                getline (myfile,data);
                
                int index = 0;
                int subStrLen = 0;
               
                while (data[index+subStrLen] != ' ') subStrLen++;
                
                stringstream numIndicesSS(data.substr(index,subStrLen));
                numIndicesSS >> numIndices;
                
                index += subStrLen += 1;
                subStrLen = 0;
                
                while (data[index+subStrLen] != ' ') subStrLen++;
                
                stringstream numVerticesSS(data.substr(index,subStrLen));
                numVerticesSS >> numVertices;

                index += subStrLen += 1;
                subStrLen = 0;
                                
                indices = new unsigned short[numIndices];
                vertices = new Vertex3D[numVertices];
                
                int indicesCovered = 0;
                while (indicesCovered < numIndices)
                {
                    while (data[index+subStrLen] != ' ') subStrLen++;
                    
                    stringstream tempSS(data.substr(index,subStrLen));
                    tempSS >> indices[indicesCovered];
                    index += subStrLen += 1;
                    subStrLen = 0;
                    indicesCovered++;
                }
                
                int verticesCovered = 0;
                while (verticesCovered < numVertices)
                {
                    //find the position, color and normal 
                    int numOfSkips = 10;
                    while (numOfSkips != 0) 
                    {
                        while (data[index+subStrLen] != ' ') subStrLen++;
                        subStrLen++;
                        numOfSkips--;
                    }
                       
                    stringstream tempSS(data.substr(index,subStrLen));
                    tempSS >> vertices[verticesCovered];
                    index += subStrLen += 1;
                    subStrLen = 0;
                    verticesCovered++;
                }

            }
            myfile.close();
        }
        
        else
        {
            cout << "ERROR: Unable to open file" << filePath;
        }
    }

private:
    Shape():vertices(NULL),indices(NULL),outline(NULL)
	{
	}
    
    ~Shape()
	{
		Clear();
        if(outline != NULL)
        {
            delete[] outline;
        }
	}
    Shape(Shape const&);
    void operator=(Shape const&);
};
