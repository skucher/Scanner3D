#pragma once

/**The struct represents data to be sculped*/
struct SculptData
{
	/**creates sculp data struct*/
    SculptData():map(NULL){}
    
	/**checks if the map initialized*/
    bool Initialized()
    {
        return map != NULL;
    }
    
	/**clears all the data oif the class*/
    void Clear()
    {
        if(Initialized())
        {
            delete [] map;
            map = NULL;

        }    
    }

	/**projection matrix 3 * 4 in row leading order*/
	float projection[3*4];
	/**map represents bw image in bitmap format*/
	unsigned char* map;
    
    SculptData& operator =(const SculptData& other)
    {
        if(this == &other)
        {
            return *this;
        }
        for (int i = 0; i < 12; i++) {
            projection[i] = other.projection[i];
        }
        sizeXmap = other.sizeXmap;
        sizeYmap = other.sizeYmap;
        
        int size = sizeXmap * sizeYmap;
        if(map != nil)
        {
            delete [] map;
        }
        map = new unsigned char[size];
        for (int i = 0; i < size; i++) {
            map[i] = other.map[i];
        }
        return *this;
        
    }
    
	size_t sizeXmap;
	size_t sizeYmap;
};