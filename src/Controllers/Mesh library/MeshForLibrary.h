
#import <Foundation/Foundation.h>

/**MeshForLibrary object in table view rows in MeshLibraryViewController table view
 *@see:MeshLibraryViewController
 */
@interface MeshForLibrary : NSObject 
{
    NSString *_name;
}

@property (nonatomic, retain) NSString *name;

/**class method - allocates new MeshForLibrary object, uses autorelease
 *@param name: name of the new MeshForLibrary object
 */

+ (id)meshWithName:(NSString *)name;


- (id)initWithName:(NSString *)name;
@end
