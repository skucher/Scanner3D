//
//  Delegate.m
//  Scanner
//
//  Created by אדמין on 1/20/72.
//  Copyright 5772 __MyCompanyName__. All rights reserved.
//

#import "Delegate.h"

@implementation Delegate


-(id)init:(id)_callie:(SEL)_selector
{
    if(![_callie respondsToSelector:_selector])
    {
        NSLog(@"Callie doesnt respond to selector");
        return nil;
    }
    callie = _callie;
    selector = _selector;
    self = [super init];
    return self;
}

-(void)run
{
    NSLog(@"** Delegate ** %@ -> %@ started ***",[[callie class] description], NSStringFromSelector(selector));
    [callie performSelector:selector];
    NSLog(@"** Delegate ** %@ -> %@ ended   ***",[[callie class] description], NSStringFromSelector(selector));
}

-(void)run:(id)parameter 
{
    NSLog(@"** Delegate ** %@ -> %@ started ***",[[callie class] description], NSStringFromSelector(selector));
    [callie performSelector:selector withObject:parameter];
    NSLog(@"** Delegate ** %@ -> %@ ended   ***",[[callie class] description], NSStringFromSelector(selector));
}
@end
