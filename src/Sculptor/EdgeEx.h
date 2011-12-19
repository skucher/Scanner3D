
#include "Vector3DEx.h"

/**Edge: Represents line connected between two Vector3DEx
 *@see Vector3DEx
 */
class EdgeEx
{
private:
    /**first vector
     */
    Vector3DEx first;
    /**second vector
     */
    Vector3DEx second;
public:
    /**Edge constructor
     * @param _first  - first vector
     * @param _second - second vector
     */
    EdgeEx(Vector3DEx _first,Vector3DEx _second):first(_first), second(_second){}
    
    EdgeEx(){}
    
    
    /**Equality operator is true iff there is order of vertices that both vectors of both 
     *Edge are equal
     *@see Vector3DEx
     */
    bool operator==(const EdgeEx& other)const
    {
        return (this->first == other.first && this->second == other.second) 
            || (this->first == other.second && this->second == other.first);
    }
    
    /**'<' operator is true (vector1,vector2) < (vector1,vector2)
     * with preference
     *@see Vector3DEx
     */
    bool operator < (const EdgeEx& other)const
    {
        if (this->first < other.first)
        {
            return true;
        }
        if (this->first > other.first) {
            return false;
        }
        if (this->second < other.second)
        {
            return true;
        }
        if (this->second > other.second) {
            return false;
        }
        return false;
    }
    /**Equality operator is true iff both vectors of both Edges are equal
     *in given order
     *@see Vector3DEx 
     */
    bool isInSameDirection(const EdgeEx& other)
    {
        return (this->first == other.first && this->second == other.second);
    }
    /**@return a copy of this with inverted order
     */
    EdgeEx invert()const
    {
        EdgeEx edge(second,first);
        return edge;
    }
};