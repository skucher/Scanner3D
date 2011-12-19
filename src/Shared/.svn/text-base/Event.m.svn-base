//
//  Event.m
//  Scanner

#import "Event.h"
#import "Delegate.h"

@implementation Event


-(id)init
{
    self = [super init];
    if(self)
    {
        methodArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self clear];
    [methodArray release];
    [super dealloc];
}

- (void)signMethod:(id)_caliie:(SEL)_selector
{
    Delegate* delegate = [[Delegate alloc] init:_caliie:_selector];
    if(delegate != nil)
    {
        [methodArray addObject:delegate];
        [delegate release];
    }
}

- (void)clear
{
    [methodArray removeAllObjects];
}

-(void)invoke
{
    for (Delegate* delegate in methodArray) 
    {
        [delegate run];
    }
}

@end
