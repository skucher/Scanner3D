
#import "MeshForLibrary.h"

@implementation MeshForLibrary

@synthesize name = _name;

- (void)dealloc
{
    [_name release];
    
    [super dealloc];
}

+ (id)meshWithName:(NSString *)name
{
    MeshForLibrary *mesh = [[self alloc] initWithName:name];
    return [mesh autorelease];
}

- (id)init
{
    return [self initWithName:@"?"];
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    
    [self setName:name];
    
    return self;
}
@end
