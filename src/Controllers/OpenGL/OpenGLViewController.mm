#import <QuartzCore/QuartzCore.h>

#import "OpenGLViewController.h"
#import "EAGLViewOGL.h"
#import "BackgroundWorker.h"
#import "Event.h"
#import "MeshLibraryViewController.h"
#import "RootViewController.h"
#import "QCARViewController.h"
#import "Messager.h"

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface OpenGLViewController ()

//EAGL
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
-(BOOL)linkProgram:(GLuint)prog;
-(BOOL)validateProgram:(GLuint)prog;
-(void)startAnimation;
-(void)stopAnimation;


//Controller
-(void)setupControllerInstances;
-(void)resetControllerInstances;
-(void)setupView:(EAGLViewOGL*)view withLightning:(BOOL)isLightningOn;
-(void)myDrawMeshNoVBOs;
-(void)drawFrame;
-(void)addGestureRecognizers;
-(void)callForKeyboard;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;

//Sidebar
@property (retain) UIPopoverController *popover;
@property (copy) void (^actionSheetBlock)(NSUInteger);
-(void)sideBarButtonsInsertButton:(NSNumber*)button atIndex:(NSInteger)index;
-(void)sidebarButtonsClearSelection;
-(void)sideBarDeleteRowAtIndex:(NSInteger)selectedIndex;
-(void)backButtonPushed;
-(void)resetButtonPushed;
-(void)saveButtonPushed;


@end

@implementation OpenGLViewController

@synthesize nameGivenByUser, staticLabel, logMesageLabel;

@synthesize activityIndicator;

@synthesize animating, context, displayLink;

@synthesize sidebarButtons = _sidebarButtons;
@synthesize popover;
@synthesize actionSheetBlock;



#pragma mark
#pragma Controller Methods ------------------------------------------------------------

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (displayMyNSLog) NSLog(@"OpenGLViewController.mm - initWithNibName:bundle");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        [self setupControllerInstances];
        [self setupView:(EAGLViewOGL*)self.view withLightning:YES];
        [self addGestureRecognizers];
        
        backgroundWorker = [[BackgroundWorker alloc] init];
        buttonsDisabled = NO;

    }
    return self;
}

-(void)dealloc
{
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [nameGivenByUser release];
    [activityIndicator release];
    
    [popover release];  
    [buttons removeAllObjects];
    [_sidebarButtons release];
    [buttons release];
    
    if(backgroundWorker != nil)
        [backgroundWorker release];
    
    [logMesageLabel release];;
    [staticLabel release];
        
    [super dealloc];
}

-(void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    stopDraw = false;
    
    //[self startAnimation];
    
    [self resetControllerInstances];
    
    [self drawFrame];

    [self.navigationController setNavigationBarHidden:YES animated:YES];  

}

-(void)viewWillDisappear:(BOOL)animated
{
    while (drawFrameIsRunning); // Busy wait until draw frame finished running
    stopDraw = true;
    
    [super viewWillDisappear:animated];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButtons.delegate = self;
    
    buttons = [[NSMutableArray alloc] init];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPad"])
    {
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:BACK_BUTTON]  atIndex:0];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON] atIndex:1];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON] atIndex:2];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:SAVE_BUTTON]  atIndex:3];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:RESET_BUTTON]  atIndex:4];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON]  atIndex:5];

    }
    else
    {
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:BACK_BUTTON]  atIndex:0];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:SAVE_BUTTON]  atIndex:1];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:RESET_BUTTON]  atIndex:2];
    };
    
    
    _sidebarButtons.selectedIndex = -1;
      
    CGRect tempRect;
    CGRect rectIpad = {{0,0},{1024,768}};
    CGRect rectIphone = [self.view bounds];
    
    deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"])
    {
        tempRect = rectIphone;
    }
    else
    {
       tempRect = rectIpad;
    };
    
    CGPoint centerPoint = CGPointMake(tempRect.origin.x + (tempRect.size.width / 2), tempRect.origin.y + (tempRect.size.height / 2));
    
    CGRect rect = CGRectMake(centerPoint.x, centerPoint.y, tempRect.size.height/10, tempRect.size.height/10);
    
    [activityIndicator setFrame:rect];
}

-(void)viewDidUnload
{
    [self setNameGivenByUser:nil];
    [self setStaticLabel:nil];
    [self setLogMesageLabel:nil];
    [self setActivityIndicator:nil];
    
    self.sidebarButtons = nil;
    
	
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
    
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (displayMyNSLog) NSLog(@"RootViewController.mm - shouldAutorotateToInterfaceOrientation");
    
    // Return YES for supported orientations
    return UIInterfaceOrientationLandscapeRight == interfaceOrientation;
}

-(NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

-(void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

-(void)startAnimation
{
    if (displayMyNSLog) NSLog(@"OpenGLViewController.mm - startAnimation");
    
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

-(void)stopAnimation
{
    if (displayMyNSLog) NSLog(@"OpenGLViewController.mm - stopAnimation");
    
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

#pragma mark
#pragma Draw Methods -----------------------------------------------------------------

-(void)setupView:(EAGLViewOGL*)view withLightning:(BOOL)isLightningOn
{
    if (displayMyNSLog) NSLog(@"OpenGLViewController.mm - setupView:withLightning");
    
    const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0; 
    //const GLfloat zNear = 1.0, zFar = 1000.0, fieldOfView = 45.0; 

    GLfloat size; 
    
    //If enabled, do depth comparisons and update the depth buffer
    glEnable(GL_DEPTH_TEST);
    
    
    
    size = zNear * tanf([ScannerCommon DegreesToRadians:((fieldOfView) / 2.0)]); 
    CGRect rect = view.bounds; 
    
    /*specify which matrix is the current matrix
     GL_MODELVIEW -
     GL_PROJECTION -
     GL_TEXTURE -
     GL_MODELVIEW -
     */
    glMatrixMode(GL_PROJECTION);
    
    /*multiply the current matrix by a perspective matrix
     2 ⁢      nearVal        right - left    0 
     A       0               0              2 ⁢ 
     nearVal top - bottom    B              0 
     0       0               C              D 
     0       0              -1              0
     */
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
               (rect.size.width / rect.size.height), zNear, zFar); 
    
    glViewport(0, 0, rect.size.width, rect.size.height);  
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    if (isLightningOn)
    {
        // Enable lighting
        glEnable(GL_LIGHTING);
        
        // Turn the first light on
        glEnable(GL_LIGHT0);
        
        // Define the ambient component of the first light
        const GLfloat light0Ambient[] = {0.1, 0.1, 0.1, 1.0};
        glLightfv(GL_LIGHT0, GL_AMBIENT, light0Ambient);
        
        // Define the diffuse component of the first light
        const GLfloat light0Diffuse[] = {0.7, 0.7, 0.7, 1.0};
        glLightfv(GL_LIGHT0, GL_DIFFUSE, light0Diffuse);
        
        // Define the specular component and shininess of the first light
        const GLfloat light0Specular[] = {0.7, 0.7, 0.7, 1.0};
        //    const GLfloat light0Shininess = 0.4;
        glLightfv(GL_LIGHT0, GL_SPECULAR, light0Specular);
        
        
        // Define the position of the first light
        const GLfloat light0Position[] = {1000.0, 0.0, 0.0, 0.0};//{0.0, 10.0, 10.0, 0.0}; 
        glLightfv(GL_LIGHT0, GL_POSITION, light0Position); 
        
        // Define a direction vector for the light, this one points right down the Z axis
        const GLfloat light0Direction[] = {-1.0,0.0,0.0};//{0.0, 0.0, -1.0};
        glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, light0Direction);
        
        // Define a cutoff angle. This defines a 90° field of vision, since the cutoff
        // is number of degrees to each side of an imaginary line drawn from the light's
        // position along the vector supplied in GL_SPOT_DIRECTION above
        glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 45.0);
    }
    
    
}

-(void)myDrawMeshNoVBOs
{
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
    glLoadIdentity();
    
    /*glTranslatef multyplies the current matrix by translation matrix
     1 0 0 x
     0 1 0 y
     0 0 1 z
     0 0 1 1
     */
    glTranslatef(OGLDisplayData.translateX,OGLDisplayData.translateY,OGLDisplayData.translateZ);
    
    glRotatef(OGLDisplayData.rotationAngle,OGLDisplayData.rotationX, OGLDisplayData.rotationY, OGLDisplayData.rotationZ);
    
    
    /*glScale produces a nonuniform scaling along the x, y, and z axes. The three parameters indicate the desired scale factor along each of the three axes.
     The current matrix (see glMatrixMode) is multiplied by this scale matrix, and the product replaces the current matrix as if glMultMatrix were called with the following matrix as its argument:
     x 0 0 0 
     0 y 0 0 
     0 0 z 0 
     0 0 0 1
     */
    glScalef(OGLDisplayData.scalefactor, OGLDisplayData.scalefactor, OGLDisplayData.scalefactor);    
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnable(GL_COLOR_MATERIAL);
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    
    Shape& shapeToDisplay = Shape::getInstance();
    if (shapeToDisplay.Initialized())
    {
        glVertexPointer(3, GL_FLOAT, sizeof(Vertex3D), &shapeToDisplay.vertices[0]._position);
        glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Vertex3D), &shapeToDisplay.vertices[0]._color);
        glNormalPointer(GL_FLOAT, sizeof(Vertex3D), &shapeToDisplay.vertices[0]._normal);
        
        glDrawElements(GL_TRIANGLES, shapeToDisplay.numIndices, GL_UNSIGNED_SHORT, shapeToDisplay.indices);
    }
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisable(GL_COLOR_MATERIAL);
    
    //Draw Axes
    {
        
        const GLfloat lineX[] = {
            -100.0f, 0.0f, 0.0f, //point A
            100.0f, 0.0f, 0.0f //point B
        };
        const GLfloat lineY[] = {
            0.0f, -100.0f, 0.0f, //point A
            0.0f, 100.0f, 0.0f //point B
        };
        const GLfloat lineZ[] = {
            0.0f, 0.0f, -100.0f, //point A
            0.0f, 0.0f, 100.0f //point B
        };
        
 
        
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // opaque red
        glVertexPointer(3, GL_FLOAT, 0, lineX);
        glDrawArrays(GL_LINES, 0, 2);
        
        glColor4f(0.0f, 1.0f, 0.0f, 1.0f); // opaque green
        
        glVertexPointer(3, GL_FLOAT, 0, lineY);
        glDrawArrays(GL_LINES, 0, 2);
        
        glColor4f(0.0f, 0.0f, 1.0f, 1.0f); // opaque blue
        
        glVertexPointer(3, GL_FLOAT, 0, lineZ);
        glDrawArrays(GL_LINES, 0, 2);
        
        glDisableClientState(GL_VERTEX_ARRAY);
        
        
        
    }
}

-(void)drawFrame
{
    //Note: An OpenGL ES-aware view should not implement a drawRect: method to render the view’s contents; instead, implement your own method to draw and present a new OpenGL ES frame and call it when your data changes. Implementing a drawRect: method causes other changes in how UIKit handles your view.
    
    if(stopDraw) return;
    drawFrameIsRunning = true; 
    
    [(EAGLViewOGL *)self.view setFramebuffer];
    
    [self myDrawMeshNoVBOs];
    
    [(EAGLViewOGL *)self.view presentFramebuffer];
    
    drawFrameIsRunning = false;
}


#pragma mark
#pragma UI Methods --------------------------------------------------------------------

-(void)resetPushed
{
    [self resetControllerInstances];
    [self drawFrame];
}

-(void)savePushed
{
    if (displayMyNSLog) NSLog(@"OpenGLViewController.mm - buttonPushed:SaveButton");
    
    NSArray *controllers = [self.navigationController viewControllers];
    NSUInteger indexOfPrevController = [controllers count] - 2;
    
    if ( [[controllers objectAtIndex:indexOfPrevController] isKindOfClass:[MeshLibraryViewController class]])
    {
        Messager* messager = [[Messager alloc] initWith:logMesageLabel];
        [messager showMessage:@"The mesh is allready loaded from the library" withFadeDuration:1.5 withShowDuration:2.0];
        [messager release];
        [self sidebarButtonsClearSelection];
        return;
    }
    [self callForKeyboard];
}

-(void)backPushed
{    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma Gesture Methods ----------------------------------------------------------------

-(void)addGestureRecognizers
{
    /*
     Create and configure the recognizers. Add each to the view as a gesture recognizer.
     */
	UIGestureRecognizer *recognizer;
    
    //Pan
    recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [recognizer addTarget:self action:@selector(drawFrame)];
    
    [(UIPanGestureRecognizer*)recognizer setMaximumNumberOfTouches:2];
    [(UIPanGestureRecognizer*)recognizer setDelegate:self];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
    //Pinch
    recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    [recognizer addTarget:self action:@selector(drawFrame)];
    
    [recognizer setDelegate:self];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
}

-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer 
{
    if ([recognizer numberOfTouches] == 1) 
    {
        NSLog(@"Pan - One finger Touch");
        
        if ([recognizer state] == UIGestureRecognizerStateBegan)
        {
            GestureData.startTouchPositionOneFinger = [recognizer locationInView:self.view];
            return;
            
        } 
        
        CGPoint point = [recognizer locationInView:self.view];
        float vecX = (point.x - GestureData.startTouchPositionOneFinger.x);
        float vecY = (point.y - GestureData.startTouchPositionOneFinger.y);
        
        // vecX and vecY are used to rotate the vector 
        OGLDisplayData.rotationX = vecY;       
        OGLDisplayData.rotationY = vecX; 
        OGLDisplayData.rotationZ = 0.0f;
        OGLDisplayData.rotationAngle = sqrt(vecX*vecX + vecY*vecY);

    } 
    else if ([recognizer numberOfTouches] == 2) 
    {        
        if ([recognizer state] == UIGestureRecognizerStateBegan)
        {
            GestureData.startTouchPositionTwoFingers = [recognizer locationInView:self.view];
            return;
        } 
        else if ([recognizer state] == UIGestureRecognizerStateEnded)
        {
            return;
        }
      
        CGPoint point = [recognizer locationInView:self.view];
        
        OGLDisplayData.translateX +=  point.x - GestureData.startTouchPositionTwoFingers.x;
        OGLDisplayData.translateY -=  point.y - GestureData.startTouchPositionTwoFingers.y;

 
        GestureData.startTouchPositionTwoFingers = point;
    }
}

-(void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer 
{
    NSLog(@"Pinch Scale : %f", recognizer.scale);
    
    
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        //locationInView:view returns the center point of the touches
        GestureData.startTouchPositionTwoFingers = [recognizer locationInView:self.view];
        
        OGLDisplayData.scalefactor += [recognizer scale] - 1;
        [recognizer setScale:1];
        return;
        
    } else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        return;
    }
    
    CGPoint point = [recognizer locationInView:self.view];
    
    
    OGLDisplayData.translateX += point.x - GestureData.startTouchPositionTwoFingers.x;
    OGLDisplayData.translateY -= point.y - GestureData.startTouchPositionTwoFingers.y;
    
    GestureData.startTouchPositionTwoFingers = point;
    
    OGLDisplayData.scalefactor += [recognizer scale] - 1;
    [recognizer setScale:1];
}

//-(void)handleRotateFrom:(UIRotationGestureRecognizer *)recognizer 
//{
//    NSLog(@"Rotation Angle : %f", recognizer.rotation);
//
//}

#pragma mark
#pragma Sidebar Methods ------------------------------------------------------------

-(void)sideBarDeleteRowAtIndex:(NSInteger)selectedIndex
{
	if (selectedIndex != -1) {
		BOOL isLastRow = (selectedIndex == ([buttons count] - 1));
		[buttons removeObjectAtIndex:selectedIndex];
        //TODO check if removeObjectAtIndex calls release
		[_sidebarButtons deleteRowAtIndex:selectedIndex];
		
		if ([buttons count] != 0) {
			NSUInteger newSelection = selectedIndex;
			if (isLastRow) {
				newSelection = [buttons count] - 1;
			}
			_sidebarButtons.selectedIndex = newSelection;
			[_sidebarButtons scrollRowAtIndexToVisible:newSelection];
		}
	}
}

-(void)sideBarButtonsInsertButton:(NSNumber*)button 
                          atIndex:(NSInteger)index
{
	[buttons insertObject:button atIndex:index];
	[_sidebarButtons insertRowAtIndex:index];
	[_sidebarButtons scrollRowAtIndexToVisible:index];
	_sidebarButtons.selectedIndex = index;
}

-(UIImage*)sidebar:(HSImageSidebarView *)sidebar 
     imageForIndex:(NSUInteger)anIndex 
{
    if (sidebar == _sidebarButtons)
    {
        int button = [[buttons objectAtIndex:anIndex] intValue];
        switch (button) 
        {
            case EMPTY_BUTTON:
                return [UIImage imageNamed:@"Empty Icon.png"];
                break;
                
            case BACK_BUTTON:
                return [UIImage imageNamed:@"GoBackButton.png"];
                break;     
                
            case SAVE_BUTTON:
                return [UIImage imageNamed:@"Save Square.png"];
                break; 
                
            case RESET_BUTTON:
                return [UIImage imageNamed:@"Reset Square.png"];
                break;
                
            default:
                return [UIImage imageNamed:@"Empty Icon.png"];
                break;  
        }
        
    }
    return nil;
}

-(void)sidebar:(HSImageSidebarView *)sidebar 
didTapImageAtIndex:(NSUInteger)anIndex 
{
    if (buttonsDisabled == YES) 
    {
        [self performSelectorOnMainThread:@selector(sidebarButtonsClearSelection) withObject:nil waitUntilDone:YES];
        return;
    }
    
    int button = [[buttons objectAtIndex:anIndex] intValue];
    switch (button) 
    {
        case EMPTY_BUTTON:            
            break;
            
        case BACK_BUTTON:
            [self backButtonPushed];
            break;
            
        case SAVE_BUTTON:
            [self saveButtonPushed];
            break;
            
        case RESET_BUTTON:
            [self resetButtonPushed];
            break;
            
        default:
            break;  
    }
    [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
    [backgroundWorker runWorkerAsync];
}

-(void)backButtonPushed
{
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
        [backgroundWorker.onDoWork signMethod:self :@selector(backPushed)];
        
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
        
        [backgroundWorker runWorkerAsync];
    }
}

-(void)resetButtonPushed
{   
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
        
        [backgroundWorker.onDoWork signMethod:self :@selector(resetPushed)];
        
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
        
        [backgroundWorker runWorkerAsync];
    }
}

-(void)saveButtonPushed
{
    [self savePushed];
}

-(void)disableButtons
{
    buttonsDisabled = YES;
}

-(void)enableButtons
{
    buttonsDisabled = NO;
}

-(void)sidebar:(HSImageSidebarView *)sidebar 
didMoveImageAtIndex:(NSUInteger)oldIndex 
       toIndex:(NSUInteger)newIndex 
{  
    NSLog(@"Image at index %d moved to index %d", oldIndex, newIndex);
    
    NSNumber *button = [[buttons objectAtIndex:oldIndex] retain];
    [buttons removeObjectAtIndex:oldIndex];
    [buttons insertObject:button atIndex:newIndex];
    [button release];
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onDoWork signMethod:self :@selector(sidebarButtonsClearSelection)];
        
        [backgroundWorker runWorkerAsync];
    }
    
    return;
}

-(void)sidebar:(HSImageSidebarView *)sidebar 
didRemoveImageAtIndex:(NSUInteger)anIndex {
    
    return;
}

-(void)actionSheet:(UIActionSheet *)actionSheet 
didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    actionSheetBlock(buttonIndex);
}

-(void)sidebarButtonsClearSelection
{
    _sidebarButtons.selectedIndex = -1;
}

-(NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar 
{
    return [buttons count];
}

#pragma mark
#pragma Additional Methods ------------------------------------------------------------

-(void)setupControllerInstances
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLViewOGL *)self.view setContext:context];
    [(EAGLViewOGL *)self.view setFramebuffer];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    
    OGLDisplayData.rotationX = 7.7f;
    OGLDisplayData.rotationY = 0.0;
    OGLDisplayData.rotationZ = 0.0f;
    OGLDisplayData.rotationAngle = 0.0f;
    
    OGLDisplayData.defoultRotationX = 7.7f;
    OGLDisplayData.defoultRotationY = 0.0;
    OGLDisplayData.defoultRotationZ = 0.0f;
    OGLDisplayData.defoultRotationAngle = 0.0f;
    
    
    OGLDisplayData.translateX = 0.0f;
    OGLDisplayData.translateY = 0.0f;
    OGLDisplayData.translateZ = -600.0f;
    
    OGLDisplayData.defoultTranslateX = 0.0f;
    OGLDisplayData.defoultTranslateY = 0.0f;
    OGLDisplayData.defoultTranslateZ = -600.0f;
    
    
    OGLDisplayData.scalefactor = 1.0f;
    OGLDisplayData.defoultScalefactor = 1.0f;  
    
}

-(void)resetControllerInstances
{
    OGLDisplayData.rotationX = OGLDisplayData.defoultRotationX;
    OGLDisplayData.rotationY = OGLDisplayData.defoultRotationY;
    OGLDisplayData.rotationZ = OGLDisplayData.defoultRotationZ;
    OGLDisplayData.rotationAngle = OGLDisplayData.defoultRotationAngle;
    
    OGLDisplayData.translateX = OGLDisplayData.defoultTranslateX;
    OGLDisplayData.translateY = OGLDisplayData.defoultTranslateY;
    OGLDisplayData.translateZ = OGLDisplayData.defoultTranslateZ;
    
    OGLDisplayData.scalefactor = OGLDisplayData.defoultScalefactor;    
}

-(BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

-(BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

-(IBAction)drawFrameAction:(id)sender
{
    [self drawFrame];
}

-(void)callForKeyboard
{
    if (!Shape::getInstance().Initialized())
    {
        UIActionSheet* actionSheetGetName = [[UIActionSheet alloc] initWithTitle:@"There is no mesh in display"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Back",nil];
        
        [actionSheetGetName showInView:self.view];
        [actionSheetGetName release];
        return;
        
    }
    [staticLabel setHidden:NO];
    [nameGivenByUser setHidden:NO];
    [nameGivenByUser becomeFirstResponder];
}

-(IBAction)textFieldDoneEditing:(id)sender 
{
    [nameGivenByUser setHidden:YES];
    [staticLabel setHidden:YES];
    [sender resignFirstResponder];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:const_MeshFolderPath];
    
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:nameGivenByUser.text];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory];
    if (fileExists == YES)
    {
        
        NSString* messageText = [NSString stringWithFormat:@"File with name: %@ , allready axists in the library", nameGivenByUser.text];
        
        Messager* messager = [[Messager alloc] initWith:logMesageLabel];
        [messager showMessage:messageText withFadeDuration:1.5 withShowDuration:2.0];
        [messager release];
        
        [self sidebarButtonsClearSelection];
        return;
    }
    
    meshNameGivenByUser = [[NSString alloc] initWithString:documentsDirectory];
    
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
        [backgroundWorker.onBeforeWork signMethod:self :@selector(startActivityIndicator)];
        [backgroundWorker.onBeforeWork signMethod:self :@selector(showSavingMessage)];
        
        [backgroundWorker.onDoWork signMethod:self :@selector(perforSaivingFileOperation)];
        
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(stopActivityIndicator)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(hideSavingMessage)];
        [backgroundWorker.onRunWorkerCompleted signMethod:meshNameGivenByUser :@selector(release)];
        
        [backgroundWorker runWorkerAsync];
    }
}

-(void)showSavingMessage
{
    logMesageLabel.hidden = NO;
    logMesageLabel.text = @"Saving Mesh Data";
}

-(void)hideSavingMessage
{
    logMesageLabel.hidden = YES;
}

-(void)perforSaivingFileOperation
{
    Shape::getInstance().WriteDataToFile([meshNameGivenByUser UTF8String]);
}

-(void)startActivityIndicator
{
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
}

-(void)stopActivityIndicator
{
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
}



@end
