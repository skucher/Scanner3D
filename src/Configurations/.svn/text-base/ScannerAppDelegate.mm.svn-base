/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH.
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import <QuartzCore/QuartzCore.h>
#import "ScannerAppDelegate.h"
#import "ScannerCommon.h"


@implementation ScannerAppDelegate
@synthesize window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    CGRect screenBounds = [[UIScreen mainScreen] bounds];
//    
//    window = [[UIWindow alloc] initWithFrame: screenBounds];
//    
//    // We are going to rotate our EAGLView by 90 degrees, so its width must be
//    // equal to the screen's height, and height to width
//    CGRect viewBounds;
//    viewBounds.origin.x = 0;
//    viewBounds.origin.y = 0;
//    viewBounds.size.width = screenBounds.size.height;
//    viewBounds.size.height = screenBounds.size.width;
//    qcarView = [[EAGLViewQCAR alloc] initWithFrame: viewBounds];
//    
//    // Create an auto-rotating overlay view and its view controller (used for
//    // displaying UI objects, such as the camera control menu)
//    qcarViewController = [[QCARViewController alloc] init];
//    
//    buttonOverlay = [[ButtonOverlay alloc] initWithNibName:@"ButtonOverlay" bundle:nil];
//    [qcarViewController setView:buttonOverlay.view];
//
//    
//    // Set the EAGLView's position (its centre) to be the centre of the window
//    CGPoint pos;
//    pos.x = screenBounds.size.width / 2;
//    pos.y = screenBounds.size.height / 2;
//    [[qcarView layer] setPosition:pos];
//    
//    // Rotate the EAGLView by 90 degress (landscape to portrait)
//    CGAffineTransform rotate = CGAffineTransformMakeRotation(90 * M_PI  / 180);
//    qcarView.transform = rotate;
//    
//    // Add the EAGLView and the overlay view to the window
//    [window addSubview:qcarView];
//    [window addSubview: qcarViewController.view];
//    [window makeKeyAndVisible];
//    
//    // Perform actions on the EAGLView now it has been created
//    [qcarView onCreate];
//    
    if (displayMyNSLog) NSLog(@"OpenGLAppDelegate.m - application:didFinishLaunchingWithOptions");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:const_MeshFolderPath];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSLog(@"application didFinishLaunchingWithOptions - trying to create directory at path %@",documentsDirectory);
    if (![fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"application didFinishLaunchingWithOptions - failed to create directory at path %@",documentsDirectory);
    }
    
    // Override point for customization after application launch.
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // AR-specific actions
    //[qcarView onPause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // AR-specific actions
    //[qcarView onResume];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // AR-specific actions
    //[qcarView onDestroy];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
    //[qcarView release];
    //[buttonOverlay release];
    //[qcarViewController release];
    
    [navigationController release];    
    [window release];
    [super dealloc];
}

@end
