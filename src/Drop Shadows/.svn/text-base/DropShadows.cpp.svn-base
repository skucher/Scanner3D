
#include "DropShadows.h"


#define ARRAY_LENGTH(arr)	(sizeof(arr)/sizeof(byte))


typedef enum 
{
    NONE = 0x00,
    LEFT = 0x01,
    RIGHT = 0x02,
    UP = 0x04,
    DOWN = 0x08
}EDirection;

#define THRESHOLD_LENGTH  30.0

#define THRESHOLD_ANGLE  45.0

void DropShadows::getCircle(byte round[], int radius)
{
    int delimiter = 2 * radius;
    int radiusSquare = radius * radius;
    for (int k = 0, i = 0; i < delimiter; i++)
        for (int j = 0; j < delimiter; j++, k++)
            if ((i - radius) * (i - radius) + (j - radius) * (j - radius) <= radiusSquare)
                round[k >> 3] |= (byte)(1 << (k & 7));

            else
                round[k >> 3] &= (byte)~(1 << (k & 7));
}

static int Max(int first, int second)
{
	return first > second ? first : second;
}

static int Min(int first, int second)
{
	return first < second ? first : second;
}


bool DropShadows::doErosionSquare(byte map[], int width, int height, int X, int Y, int radius)
{
	int xEnter = Max(0, X - radius);
	int xLeave = Min(width, X + radius);

	int yEnter = Max(0, Y - radius);
	int yLeave = Min(height, Y + radius);

	int xSegment = xLeave - xEnter;
	int ySegment = yLeave - yEnter;

	int kEnter = yEnter * width + xEnter;
	int kStride = width - xSegment;

	for (int k = kEnter, i = 0; i < ySegment; i++, k += kStride)
		for (int j = 0; j < xSegment; j++, k++)
			if ((map[k >> 3] & (1 << (k & 7))) == 0)
				return false;

	return true;

}

bool DropShadows::doDelutionSquare(byte map[], int width, int height, int X, int Y, int radius)
{
    int xEnter = Max(0, X - radius);
    int xLeave = Min(width, X + radius);

    int yEnter = Max(0, Y - radius);
    int yLeave = Min(height, Y + radius);

    int xSegment = xLeave - xEnter;
    int ySegment = yLeave - yEnter;

    int kEnter = yEnter * width + xEnter;
    int kStride = width - xSegment;

    for (int k = kEnter, i = 0; i < ySegment; i++, k += kStride)
        for (int j = 0; j < xSegment; j++, k++)
            if ((map[k >> 3] & (1 << (k & 7))) != 0)
                return true;

    return false;
}


void DropShadows::doErosionShape(byte map[], byte newMap[], int width, int height, int radius)
{
	int k = 0;
	for (int y = 0; y < height; y++)
		for (int x = 0; x < width; x++, k++)
			if (doErosionSquare(map, width, height, x, y, radius))
				newMap[k >> 3] |= (byte)(1 << (k & 7));

			else
				newMap[k >> 3] &= (byte)~(1 << (k & 7));
}


void DropShadows::doDelutionShape(byte map[], byte newMap[], int width, int height, int radius)
{
	int k = 0;
    for (int y = 0; y < height; y++)
        for (int x = 0; x < width; x++, k++)
            if (doDelutionSquare(map, width, height, x, y, radius))
                newMap[k >> 3] |= (byte)(1 << (k & 7));

            else
                newMap[k >> 3] &= (byte)~(1 << (k & 7));
}


void DropShadows::doCloseShape(byte map[], int width, int height, int radius)
{
    byte* newMap = new byte[ARRAY_LENGTH(map)];
    doDelutionShape(map, newMap, width, height, radius);
    doErosionShape(newMap, map, width, height, radius);
	delete newMap;
}


void DropShadows::doOpenShapeWithMask(byte map[], int width, int height, int radius)
{
    doOpenShapeWithMask(map, width, height, radius, radius);
}


void DropShadows::doCloseShapeWithMask(byte map[], int width, int height, int radius)
{
    doCloseShapeWithMask(map, width, height, radius, radius);
}


void DropShadows::doCloseShapeWithMask(byte map[], int width, int height, int erosionRadius, int delutionRadius)
{
    byte* newMap = new byte[ARRAY_LENGTH(map)];
    doDelutionShapeWithMask(map, newMap, width, height, delutionRadius);
    doErosionShapeWithMask(newMap, map, width, height, erosionRadius);
}


void DropShadows::doOpenShapeWithMask(byte map[], int width, int height, int erosionRadius, int delutionRadius)
{
    byte* newMap = new byte[ARRAY_LENGTH(map)];
    doErosionShapeWithMask(map, newMap, width, height, erosionRadius);
    doDelutionShapeWithMask(newMap, map, width, height, delutionRadius);
}


PixelVector DropShadows::getVectorFromMap(byte map[], int x, int y, int width)
{
    int offset = 4 * (y * width + x);
	return PixelVector(map[offset + 0], map[offset + 1], map[offset + 2]);
}

PixelVector** allocatePixelVector(int width,int hight)
{
	PixelVector** vectors = new PixelVector*[width];
	for(int i = 0 ; i < width ; i++)
	{
		vectors[i] = new PixelVector[hight];
	}
	return vectors;
}

int** allocateEDirection(int width,int hight)
{
	int** vectors = new int*[width];
	for(int i = 0 ; i < width ; i++)
	{
		vectors[i] = new int[hight]();
	}
	for(int i = 0 ; i < width ; i++)
	{
		for(int j = 0 ; j < hight ; j++)
		{
			vectors[i][j] = 0;
		}
	}
	return vectors;
}

void deAllocatePixelVector(int width,int hight,PixelVector** vectors)
{
	for(int i = 0 ; i < width ; i++)
	{
		delete vectors[i];
	}
	delete[] vectors ;
}

void deAllocateEDirection(int width,int hight,int** vectors)
{
	for(int i = 0 ; i < width ; i++)
	{
		delete vectors[i];
	}
	delete[] vectors;
}

void DropShadows::doSmartDropShadows(byte* map, byte* flat, int width, int height, PixelVector bgColor)
{
	PixelVector** vectors = allocatePixelVector(width,height);

    for (int y = 0; y < height; y++)
        for (int x = 0; x < width; x++)
            vectors[x][y] = getVectorFromMap(map, x, y, width);

    PixelVector** deltas = allocatePixelVector(width,height);
    for (int y = 1; y < height - 1; y++)
        for (int x = 1; x < width - 1; x++)
        {
            PixelVector up = vectors[x][ y - 1];
            PixelVector down = vectors[x][ y + 1];
            PixelVector left = vectors[x - 1][ y];
            PixelVector right = vectors[x + 1][ y];

            float dx = (left - right)._length;
            float dy = (up - down)._length;

            deltas[x][ y] = PixelVector(dx, dy, 0);
        }

	int** directions = allocateEDirection(width,height);

    int offset = 3 * (width + 1);
    for (int y = 1; y < (height - 1); y++)
        for (int x = 1; x < (width - 1); x++)
        {
            int k = y * width + x;
            if (deltas[x][ y]._length >= THRESHOLD_LENGTH)
            {
				float up = (vectors[x][ y - 1].angle(bgColor));
                if (up < THRESHOLD_ANGLE)
					directions[x][ y] |= UP;

				float down = (vectors[x][ y + 1].angle(bgColor));
                if (down < THRESHOLD_ANGLE)
                    directions[x][ y] |= DOWN;

				float left = (vectors[x - 1][ y].angle(bgColor));

                if (left < THRESHOLD_ANGLE)
                    directions[x][ y] |= LEFT;

				float right = (vectors[x + 1][ y].angle(bgColor));

                if (right < THRESHOLD_ANGLE)
                    directions[x][ y] |= RIGHT;
            }

            if (directions[x][ y] != NONE)
            {
                flat[k >> 3] |= (byte)(1 << (k & 7));
            }
            else
                flat[k >> 3] &= (byte)~(1 << (k & 7));
        }

    float THRESHOLD_CLOSE = 180.0f;
    offset = 3 * (width + 1);
    for (int y = 1; y < (height - 1); y++)
        for (int x = 1; x < (width - 1); x++)
        {
            int k = y * width + x;

            if ((vectors[x][ y] - bgColor)._length >= (THRESHOLD_CLOSE / 4.0f))
            {
                if ((vectors[x][ y] - vectors[x][ y - 1])._length <= THRESHOLD_CLOSE && ((directions[x][ y - 1] & UP) != 0) 
					&& ((directions[x][ y] & DOWN) == 0))
                {
                    flat[k >> 3] |= (byte)(1 << (k & 7));
                    directions[x][ y] |= (directions[x][ y - 1] & (UP | DOWN));
                }

                if ((vectors[x][ y] - vectors[x - 1][ y])._length <= THRESHOLD_CLOSE && ((directions[x - 1][ y] & LEFT) != 0) 
					&& ((directions[x][ y] & RIGHT) == 0))
                {
                    flat[k >> 3] |= (byte)(1 << (k & 7));
                    directions[x][ y] |= (directions[x - 1][ y] & (LEFT |RIGHT));
                }
            }
        }
	deAllocateEDirection(width,height, directions);
	deAllocatePixelVector(width,height,vectors);
	deAllocatePixelVector(width,height,deltas);
}

void DropShadows::toFlat(byte oldMap[], byte newMap[], int bytes)
{
	for (int i = 0, k = 0; k < bytes; k++, i++)
    {
        if (oldMap[k   ] == 255)
			newMap[i >> 3] |= (byte)(1 << (i & 7));
        
		else
			newMap[i >> 3] &= (byte)~(1 << (i & 7));
    }
		
}

inline bool IsBlack(byte flat[],int index)
{
    return  (flat[index >> 3] & (1 << (index & 7))) != 0;
}

void DropShadows::toImage(byte bwNonFlat[], byte bwFlat[], int bytes)
{
	for (int i = 0; i < bytes;  i++)
    {
		if (IsBlack(bwFlat, i))
		{
			bwNonFlat[i] = 255;
		}
		else
		{
			bwNonFlat[i] = 0;
		}
    }
}

void DropShadows::toRgbx(byte rgbx[], byte bwNonFlat[], int bytes)
{
    for (int i = 0, k = 0 ; i < bytes;  i++,k+=4)
    {
        switch (bwNonFlat[i]) {
            case 255:
                rgbx[k] = 255;
                rgbx[k+1] = 255;
                rgbx[k+2] = 255;
                break;
                
            case 0:
                rgbx[k] = 0;
                rgbx[k+1] = 0;
                rgbx[k+2] = 0;
                break;
                
            case 2:
                rgbx[k] = 0;
                rgbx[k+1] = 0;
                rgbx[k+2] = 255;
                break;
                
            case 4:
                rgbx[k] = 255;
                rgbx[k+1] = 0;
                rgbx[k+2] = 0;
                break;
        }
    }
}

PixelVector DropShadows::getCommonColor(byte rgbx[], int bytes)
{
    int *counters = new int[360];
    
    PixelVector * sumColors = new PixelVector[360];
    for (int i = 0; i < 360; i++)
    {
        counters[i] = 0;
        sumColors[i] = PixelVector();
    }
    PixelVector u = PixelVector(1, 0, 0);
    for (int i = 0; i < bytes; i += 4)
    {
        PixelVector v = PixelVector(rgbx[i + 0], rgbx[i + 1], rgbx[i + 2]);
        if (v.length() > 100.0f)
        {
            int idx = (int)roundf(v.angle(u)) % 360;
            
            counters[idx]++;
            sumColors[idx] = sumColors[idx] + v;
        }
    }
    
    int max = 0;
    for (int i = 1; i < 360; i++)
        if (counters[i] > counters[max])
            max = i;
    
    PixelVector result = sumColors[max]* (1.0f / (float) counters[max]);
    
    delete [] counters;
    delete [] sumColors;
    
    return result;

}

void DropShadows::doErosionShapeWithMask(byte oldFlat[], byte newFlat[], int width, int height, int radius)
{
    int delimiter = 2* radius;
    byte* mask = new byte[delimiter * delimiter];
    getCircle(mask,radius);
    
    int k = 0;
    for (int y = 0; y < height; y++)
        for (int x = 0; x < width; x++, k++)
            if (doErosionSquareWithMask(oldFlat, width, height, x, y, mask, radius))
                newFlat[k >> 3] |= (byte)(1 << (k & 7));
    
            else
                newFlat[k >> 3] &= (byte)~(1 << (k & 7));
	delete[] mask;
}


void DropShadows::doDelutionShapeWithMask(byte oldFlat[], byte newFlat[], int width, int height, int radius)
{
    int diameter = 2 * radius;
    byte* mask = new byte[diameter*diameter];
    getCircle(mask,radius);
    
    int k = 0;
    for (int y = 0; y < height; y++)
        for (int x = 0; x < width; x++, k++)
            if (doDelusionSquareWithMask(oldFlat, width, height, x, y, mask, radius))
                newFlat[k >> 3] |= (byte)(1 << (k & 7));
    
            else
                newFlat[k >> 3] &= (byte)~(1 << (k & 7));
    
	delete[] mask;
}

bool DropShadows::doDelusionSquareWithMask(byte map[], int width, int height, int X, int Y, byte mask[], int radius)
{
    int xEnter = Max(0, X - radius) - X;   // -radius <= t <= 0
    int xLeave = Min(width, X + radius) - X;   // 0 <= t <= +radius
    
    int yEnter = Max(0, Y - radius) - Y;   // // -radius <= t <= 0
    int yLeave = Min(height, Y + radius) - Y;  // 0 <= t <= +radius
    
    int xSegment = xLeave - xEnter;
    //int ySegment = yLeave - yEnter;
    
    int kEnter = (Y + yEnter) * width + (X + xEnter);
    int kStride = width - xSegment;
    
    int mEnter = (radius + yEnter) * (2 * radius) + (radius + xEnter);
    int mStride = 2 * radius - (xLeave - xEnter);
    
    for (int k = kEnter, m = mEnter, i = yEnter; i < yLeave; i++, k += kStride, m += mStride)
        for (int j = xEnter; j < xLeave; j++, k++, m++)
            if ((mask[m >> 3] & (1 << (m & 7))) != 0)
                if ((map[k >> 3] & (1 << (k & 7))) != 0)
                    return true;
    
    return false;
}

bool DropShadows::doErosionSquareWithMask(byte map[], int width, int height, int X, int Y, byte mask[], int radius)
{
    int xEnter = Max(0, X - radius) - X;   // -radius <= t <= 0
    int xLeave = Min(width, X + radius) - X;   // 0 <= t <= +radius
    
    int yEnter = Max(0, Y - radius) - Y;   // // -radius <= t <= 0
    int yLeave = Min(height, Y + radius) - Y;  // 0 <= t <= +radius
    
    int xSegment = xLeave - xEnter;
    //int ySegment = yLeave - yEnter;
    
    int kEnter = (Y + yEnter) * width + (X + xEnter);
    int kStride = width - xSegment;
    
    int mEnter = (radius + yEnter) * (2 * radius) + (radius + xEnter);
    int mStride = 2 * radius - (xLeave - xEnter);
    
    for (int k = kEnter, m = mEnter, i = yEnter; i < yLeave; i++, k += kStride, m += mStride)
        for (int j = xEnter; j < xLeave; j++, k++, m++)
            if ((mask[m >> 3] & (1 << (m & 7))) == 0)
                if ((map[k >> 3] & (1 << (k & 7))) == 0)
                    return false;
    return true;
}

