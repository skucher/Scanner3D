
#import <Foundation/Foundation.h>
#import "SculptData.h"

typedef struct SculptData SculptData;

/**UIMage extension that holds SculpData in it*/
@interface SculpImage : UIImage {    
@public
    /**sculptData of the image
     @see SculptData*/
    SculptData sculptData;
}
/**is sculped*/
@property(nonatomic) BOOL sculpted;
/**init with cgiref and _sculpdata
 @param cgi - cgiref
 @param _sculpdata - sculpting data*/
-(id)initWithCGImage:(CGImageRef)cgi :(SculptData) _sculptData;

@end
