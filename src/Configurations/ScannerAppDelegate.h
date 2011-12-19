/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH.
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import <UIKit/UIKit.h>
//#import "EAGLViewQCAR.h"
//#import "ButtonOverlay.h"
//#import "QCARViewController.h"


@interface ScannerAppDelegate : NSObject <UIApplicationDelegate> {
//    UIWindow* window;
//    QCARViewController* qcarViewController;
//    ButtonOverlay* buttonOverlay;
//    EAGLViewQCAR* qcarView;
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
