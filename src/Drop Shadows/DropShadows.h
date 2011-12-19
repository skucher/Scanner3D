#pragma once

#include "PixelVector.h"

class DropShadows
{
public:
	void getCircle(byte round[],int radius);

	bool doErosionSquare(byte map[], int width, int height, int X, int Y, int radius);


	bool doErosionSquareWithMask(byte map[], int width, int height, int X, int Y, byte mask[], int radius);


	bool doDelutionSquare(byte map[], int width, int height, int X, int Y, int radius);


	bool doDelusionSquareWithMask(byte map[], int width, int height, int X, int Y, byte mask[], int radius);


	void doErosionShape(byte map[], byte newMap[], int width, int height, int radius);


	void doDelutionShape(byte map[], byte newMap[], int width, int height, int radius);


	void doCloseShape(byte map[], int width, int height, int radius);


	void doOpenShapeWithMask(byte map[], int width, int height, int radius);


	void doCloseShapeWithMask(byte map[], int width, int height, int radius);


	void doCloseShapeWithMask(byte map[], int width, int height, int erosionRadius, int delutionRadius);


	void doOpenShapeWithMask(byte map[], int width, int height, int erosionRadius, int delutionRadius);


	PixelVector getVectorFromMap(byte map[], int x, int y, int width);

	void toFlat(byte oldMap[], byte newMap[], int bytes);

    // relevant methods
	void doSmartDropShadows(byte* map, byte* flat, int width, int height, PixelVector bgColor);
    
	void toImage(byte newMap[], byte oldMap[],int bytes);
    
    void toRgbx(byte rgbx[], byte oldMap[],int bytes);
    
	void doErosionShapeWithMask(byte oldFlat[], byte newFlat[], int width, int height, int radius);
    
	void doDelutionShapeWithMask(byte oldFlat[], byte newFlat[], int width, int height, int radius);
    
    PixelVector getCommonColor(byte rgbx[], int size);
};