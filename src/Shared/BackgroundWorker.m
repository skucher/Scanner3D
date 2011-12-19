//
//  BackgroundWorker.m
//  Scanner
//
//  Created by admin on 10/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BackgroundWorker.h"
#import "Event.h"

@interface BackgroundWorker()
- (void)threadDoWork;
@end

@implementation BackgroundWorker
@synthesize onBeforeWork,onDoWork,onRunWorkerCompleted;

- (id)init
{
    self = [super init];
    if(self)
    {
        onBeforeWork = [[Event alloc] init];
        onDoWork = [[Event alloc] init];
        onRunWorkerCompleted = [[Event alloc] init];
    }
    return self;
}

- (void)reset
{
    [onBeforeWork clear];
    [onDoWork clear];
    [onRunWorkerCompleted clear];
}
/*
- (void)setOnBeforeWork:(Event *)_onBeforeWork
{
    [self.onBeforeWork release];
    onBeforeWork = [_onBeforeWork retain];
}

- (void)setOnDoWork:(Event *)_onDoWork
{
    [onDoWork release];
    onDoWork = [_onDoWork retain];
}

- (void)setOnRunWorkerCompleted:(Event *)_onRunWorkerCompleted
{
    [onRunWorkerCompleted release];
    onRunWorkerCompleted = [_onRunWorkerCompleted retain];
}*/

- (void)dealloc
{
    [onBeforeWork release];
    [onDoWork release];
    [onRunWorkerCompleted release];
    [super dealloc];
}

- (bool)runWorkerAsync
{
    if(backgroundWorker != nil)
    {
        if(![backgroundWorker isFinished])
        {
            NSLog(@"Please wait until current operation finished");
            return false;
        }
        [backgroundWorker release];
    }
    backgroundWorker = [[NSThread alloc] initWithTarget:self selector:@selector(threadDoWork) 
                                                 object:nil];
    [backgroundWorker start];
    return true;
}

- (void)cancelRunWorkerAsync
{
    [backgroundWorker cancel];
    [backgroundWorker release];
    backgroundWorker = nil; 
}

- (void)threadDoWork
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [onBeforeWork performSelectorOnMainThread:@selector(invoke) withObject:nil 
                        waitUntilDone:NO];    
    [onDoWork invoke];
    [onRunWorkerCompleted performSelectorOnMainThread:@selector(invoke) withObject: nil
                        waitUntilDone:YES];
    [self reset];
    [pool release]; 
}

- (bool)isFinished
{
    return backgroundWorker == nil || [backgroundWorker isFinished];
}
@end

