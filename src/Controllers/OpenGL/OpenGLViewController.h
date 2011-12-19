//
//  OpenGLViewController.h
//  Scanner


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


#import "Shape.h"
#import "ScannerCommon.h"
#import "HSImageSidebarView.h"

@class BackgroundWorker;

/**OpenGLViewController: Controller responsible for displaying the mesh of the 3D object
 */
@interface OpenGLViewController : UIViewController 
<UIGestureRecognizerDelegate, UIActionSheetDelegate, HSImageSidebarViewDelegate, UIPopoverControllerDelegate> 
{
@private
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;

    bool drawFrameIsRunning;
    bool stopDraw;
    
    struct
    {    
        GLfloat rotationX;
        GLfloat rotationY;
        GLfloat rotationZ;
        GLfloat rotationAngle;
        
        GLfloat defoultRotationX;
        GLfloat defoultRotationY;
        GLfloat defoultRotationZ;
        GLfloat defoultRotationAngle;
        
        GLfloat translateX;
        GLfloat translateY;
        GLfloat translateZ;
        
        GLfloat defoultTranslateX;
        GLfloat defoultTranslateY;
        GLfloat defoultTranslateZ;
        
        GLfloat scalefactor;
        GLfloat defoultScalefactor;

    } OGLDisplayData;
    
    struct 
    {       
        CGPoint startTouchPositionOneFinger;
        CGPoint startTouchPositionTwoFingers;
        NSDate* startTouchTime;
        float startRotaionAngle;
        
        
    } GestureData;
    
    HSImageSidebarView *_sidebarButtons;
    NSMutableArray* buttons;//for _sidebarButtons
    
    BackgroundWorker* backgroundWorker;
    BOOL buttonsDisabled;
    UILabel *test;
    
    NSString* meshNameGivenByUser;
}

/**label used to desplay masseges to the user*/
@property (nonatomic, retain) IBOutlet UILabel *logMesageLabel;
/**static lable on the view*/
@property (nonatomic, retain) IBOutlet UILabel *staticLabel;

/**controller properties for animathion*/
@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

/**text field where user gives the name to the mesh file*/
@property (nonatomic, retain) IBOutlet UITextField *nameGivenByUser;

/**Activity Indicator*/
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

/**right sidebar of images - buttons*/
@property (nonatomic, retain) IBOutlet HSImageSidebarView *sidebarButtons;

//IBActions
/**executed when the user pressed 'done' button on iPhone\iPad keyboard
 */
- (IBAction)textFieldDoneEditing:(id)sender;

@end
