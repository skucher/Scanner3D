


/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH.
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import <QuartzCore/QuartzCore.h>
#import "EAGLViewQCAR.h"
#import <QCAR/QCAR.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/Tracker.h>
#import "Texture.h"
#import "Teapot.h"
#import <QCAR/VideoBackgroundConfig.h>
#import <QCAR/Renderer.h>
#import <QCAR/Tool.h>
#import <QCAR/Trackable.h>
#import <QCAR/Image.h>
#import "Vertex3D.h"
//NEW
#import <QCAR/UpdateCallback.h>
//#import "QCARButtonOverlay.h"
#import "ScannerCommon.h"
//


namespace {
    // Model scale factor
    const float kObjectScale = 3.0f;
    
    // Teapot texture filenames
    const char* textureFilenames[] = {
        "TextureTeapotBrass.png",
        "TextureTeapotBlue.png"
    };
    /*
    //NEW
    class VirtualButton_UpdateCallback : public QCAR::UpdateCallback {
        virtual void QCAR_onUpdate(QCAR::State& state);
    } qcarUpdate;
    
    
    // Menu entries
    static const char* menuEntries[] = {
        "Camera torch on",
        "Camera torch off",
        "Autofocus on",
        "Autofocus off"
    };
     */
    //
}


@interface EAGLViewQCAR (PrivateMethods)
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (int)loadTextures;
- (void)updateApplicationStatus:(status)newStatus;
- (void)bumpAppStatus;
- (void)initApplication;
- (void)initQCAR;
- (void)initApplicationAR;
- (void)loadTracker;
- (void)startCamera;
- (void)stopCamera;
- (void)configureVideoBackground;
- (void)initRendering;

- (void)drawOutline;
- (void) drawTeapot:(QCAR::State*)state;
- (void) drawCurrentMesh:(QCAR::State*)state;
@end


@implementation EAGLViewQCAR
@synthesize xTranslateConstant;
@synthesize yTranslateConstant;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self) {
        toDraw = YES;
        //self.cubeLocationShape = _cubeLocationShape;
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        ARData.QCARFlags = QCAR::GL_11;

        NSLog(@"QCAR OpenGL flag: %d", ARData.QCARFlags);
        
        if (!context) {
            NSLog(@"Failed to create ES context");
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self deleteFramebuffer];
    
    // Tear down context    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    //NEW
    //[buttonOverlay release];
    //
    [context release];
    [super dealloc];
}

- (void)createFramebuffer
{
    if (context && !defaultFramebuffer) {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
        glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &framebufferWidth);
        glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    }
}

- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffersOES(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffersOES(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffersOES(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer) {
            // Perform on the main thread to ensure safe memory allocation for
            // the shared buffer.  Block until the operation is complete to
            // prevent simultaneous access to the OpenGL context
            [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
        }
        
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next
    // setFramebuffer method call.
    [self deleteFramebuffer];
}


////////////////////////////////////////////////////////////////////////////////
- (void)onCreate
{
    //NEW
    //[self createButtonOverlay];
    //
    
    NSLog(@"EAGLViewQCAR onCreate()");
    ARData.appStatus = APPSTATUS_UNINITED;
    
    // Load textures
    int nErr = [self loadTextures];
    
    if (noErr == nErr) {
        [self updateApplicationStatus:APPSTATUS_INIT_APP];
    }
}


////////////////////////////////////////////////////////////////////////////////
- (void)onDestroy
{
    NSLog(@"EAGLViewQCAR onDestroy()");
    // Release the textures array
    [ARData.textures release];
    
    // Deinitialise QCAR SDK
    QCAR::deinit();
}


////////////////////////////////////////////////////////////////////////////////
- (void)onResume
{
    NSLog(@"EAGLViewQCAR onResume()");
    
    // If the app status is APPSTATUS_CAMERA_STOPPED, QCAR must have been fully
    // initialised
    if (APPSTATUS_CAMERA_STOPPED == ARData.appStatus) {
        // QCAR-specific resume operation
        QCAR::onResume();
        
        [self updateApplicationStatus:APPSTATUS_CAMERA_RUNNING];
    }
}


////////////////////////////////////////////////////////////////////////////////
- (void)onPause
{
    NSLog(@"EAGLViewQCAR onPause()");
    
    // If the app status is APPSTATUS_CAMERA_RUNNING, QCAR must have been fully
    // initialised
    if (APPSTATUS_CAMERA_RUNNING == ARData.appStatus) {
        [self updateApplicationStatus:APPSTATUS_CAMERA_STOPPED];
        
        // QCAR-specific pause operation
        QCAR::onPause();
    }
}

////////////////////////////////////////////////////////////////////////////////
// Load the textures for use by OpenGL
- (int)loadTextures
{
    int nErr = noErr;
    int nTextures = sizeof(textureFilenames) / sizeof(textureFilenames[0]);
    ARData.textures = [[NSMutableArray array] retain];
    
    @try {
        for (int i = 0; i < nTextures; ++i) {
            Texture* tex = [[[Texture alloc] init] autorelease];
            NSString* file = [NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding];
            
            nErr = [tex loadImage:file] == YES ? noErr : 1;
            [ARData.textures addObject:tex];
            
            if (noErr != nErr) {
                break;
            }
        }
    }
    @catch (NSException* e) {
        NSLog(@"NSMutableArray addObject exception");
    }
    
    assert([ARData.textures count] == nTextures);
    if ([ARData.textures count] != nTextures) {
        nErr = 1;
    }
    
    return nErr;
}

////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    exit(0);
}

////////////////////////////////////////////////////////////////////////////////
- (void)updateApplicationStatus:(status)newStatus
{
    if (newStatus != ARData.appStatus && APPSTATUS_ERROR != ARData.appStatus) {
        ARData.appStatus = newStatus;
        
        switch (ARData.appStatus) {
            case APPSTATUS_INIT_APP:
                // Initialise the application
                [self initApplication];
                [self updateApplicationStatus:APPSTATUS_INIT_QCAR];
                break;
                
            case APPSTATUS_INIT_QCAR:
                // Initialise QCAR
                [self performSelectorInBackground:@selector(initQCAR) withObject:nil];
                break;
                
            case APPSTATUS_INIT_APP_AR:
                // AR-specific initialisation
                [self initApplicationAR];
                [self updateApplicationStatus:APPSTATUS_INIT_TRACKER];
                break;
                
            case APPSTATUS_INIT_TRACKER:
                // Load tracker data
                [self performSelectorInBackground:@selector(loadTracker) withObject:nil];
                break;
                
            case APPSTATUS_INITED:
                // These two calls to setHint tell QCAR to split work over
                // multiple frames.  Depending on your requirements you can opt
                // to omit these.
                QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MULTI_FRAME_ENABLED, 1);
                QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MILLISECONDS_PER_MULTI_FRAME, 25);
                
                // Here we could also make a QCAR::setHint call to set the
                // maximum number of simultaneous targets                
                // QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 2);
                
                // Initialisation is complete, start QCAR
                QCAR::onResume();
                
                [self updateApplicationStatus:APPSTATUS_CAMERA_RUNNING];
                break;
                
            case APPSTATUS_CAMERA_RUNNING:
                [self startCamera];
                break;
                
            case APPSTATUS_CAMERA_STOPPED:
                [self stopCamera];
                break;
                
            default:
                NSLog(@"updateApplicationStatus: invalid app status");
                break;
        }
    }
    
    if (APPSTATUS_ERROR == ARData.appStatus) {
        // Application initialisation failed, display an alert view
        UIAlertView* alert;
        const char *msgNetwork = "Network connection required to initialize camera "
        "settings. Please check your connection and restart the application.";
        const char *msgDevice = "Failed to initialize QCAR because this device is not supported.";
        const char *msgDefault = "Application initialisation failed.";
        const char *msg = msgDefault;
        
        switch (ARData.errorCode) {
            case QCAR::INIT_CANNOT_DOWNLOAD_DEVICE_SETTINGS:
                msg = msgNetwork;
                break;
            case QCAR::INIT_DEVICE_NOT_SUPPORTED:
                msg = msgDevice;
                break;
            case QCAR::INIT_ERROR:
            default:
                break;
        }
        
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithUTF8String:msg] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


////////////////////////////////////////////////////////////////////////////////
// Bump the application status on one step
- (void)bumpAppStatus
{
    [self updateApplicationStatus:(status)(ARData.appStatus + 1)];
}


////////////////////////////////////////////////////////////////////////////////
// Initialise the application
- (void)initApplication
{
    // Get the device screen dimensions
    ARData.screenRect = [[UIScreen mainScreen] bounds];
    
    // Inform QCAR that the drawing surface has been created
    QCAR::onSurfaceCreated();
    
    // Inform QCAR that the drawing surface size has changed
    QCAR::onSurfaceChanged(ARData.screenRect.size.height, ARData.screenRect.size.width);
}


////////////////////////////////////////////////////////////////////////////////
// Initialise QCAR [performed on a background thread]
- (void)initQCAR
{
    // Background thread must have its own autorelease pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    QCAR::setInitParameters(ARData.QCARFlags);
    
    int nPercentComplete = 0;
    
    do {
        nPercentComplete = QCAR::init();
    } while (0 <= nPercentComplete && 100 > nPercentComplete);
    
    NSLog(@"QCAR::init percent: %d", nPercentComplete);
    
    if (0 > nPercentComplete) {
        ARData.appStatus = APPSTATUS_ERROR;
        ARData.errorCode = nPercentComplete;
    }    
    
    // Continue execution on the main thread
    [self performSelectorOnMainThread:@selector(bumpAppStatus) withObject:nil waitUntilDone:NO];
    
    [pool release];    
} 


////////////////////////////////////////////////////////////////////////////////
// Initialise the AR parts of the application
- (void)initApplicationAR
{
    // Initialise rendering
    [self initRendering];
}


////////////////////////////////////////////////////////////////////////////////
// Load the tracker data [performed on a background thread]
- (void)loadTracker
{
    int nPercentComplete = 0;

    // Background thread must have its own autorelease pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // Load the tracker data
    do {
        nPercentComplete = QCAR::Tracker::getInstance().load();
    } while (0 <= nPercentComplete && 100 > nPercentComplete);

    if (0 > nPercentComplete) {
        ARData.appStatus = APPSTATUS_ERROR;
        ARData.errorCode = nPercentComplete;
    }
    
    // Continue execution on the main thread
    [self performSelectorOnMainThread:@selector(bumpAppStatus) withObject:nil waitUntilDone:NO];
    
    [pool release];
}


////////////////////////////////////////////////////////////////////////////////
// Start capturing images from the camera
- (void)startCamera
{
    // Initialise the camera
    if (QCAR::CameraDevice::getInstance().init()) {
        // Configure video background
        [self configureVideoBackground];
        
        // Select the default mode
        if (QCAR::CameraDevice::getInstance().selectVideoMode(QCAR::CameraDevice::MODE_DEFAULT)) {
            // Start camera capturing
            if (QCAR::CameraDevice::getInstance().start()) {
                // Start the tracker
                QCAR::Tracker::getInstance().start();
                
                // Cache the projection matrix
                const QCAR::CameraCalibration& cameraCalibration = QCAR::Tracker::getInstance().getCameraCalibration();
                projectionMatrix = QCAR::Tool::getProjectionGL(cameraCalibration, 2.0f, 2000.0f);
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
// Stop capturing images from the camera
- (void)stopCamera
{
    QCAR::Tracker::getInstance().stop();
    QCAR::CameraDevice::getInstance().stop();
    QCAR::CameraDevice::getInstance().deinit();
}


////////////////////////////////////////////////////////////////////////////////
// Configure the video background
- (void)configureVideoBackground
{
    // Get the default video mode
    QCAR::CameraDevice& cameraDevice = QCAR::CameraDevice::getInstance();
    QCAR::VideoMode videoMode = cameraDevice.getVideoMode(QCAR::CameraDevice::MODE_DEFAULT);
    
    // Configure the video background
    QCAR::VideoBackgroundConfig config;
    config.mEnabled = true;
    config.mSynchronous = true;
    config.mPosition.data[0] = 0.0f;
    config.mPosition.data[1] = 0.0f;
    
    // Compare aspect ratios of video and screen.  If they are different
    // we use the full screen size while maintaining the video's aspect
    // ratio, which naturally entails some cropping of the video.
    // Note - screenRect is portrait but videoMode is always landscape,
    // which is why "width" and "height" appear to be reversed.
    float arVideo = (float)videoMode.mWidth / (float)videoMode.mHeight;
    float arScreen = ARData.screenRect.size.height / ARData.screenRect.size.width;
    
    if (arVideo > arScreen)
    {
        // Video mode is wider than the screen.  We'll crop the left and right edges of the video
        config.mSize.data[0] = (int)ARData.screenRect.size.width * arVideo;
        config.mSize.data[1] = (int)ARData.screenRect.size.width;
    }
    else
    {
        // Video mode is taller than the screen.  We'll crop the top and bottom edges of the video.
        // Also used when aspect ratios match (no cropping).
        config.mSize.data[0] = (int)ARData.screenRect.size.height;
        config.mSize.data[1] = (int)ARData.screenRect.size.height / arVideo;
    }
    
    // Set the config
    QCAR::Renderer::getInstance().setVideoBackgroundConfig(config);
}


////////////////////////////////////////////////////////////////////////////////
// Initialise OpenGL rendering
- (void)initRendering
{
    // Define the clear colour
    glClearColor(0.0f, 0.0f, 0.0f, QCAR::requiresAlpha() ? 0.0f : 1.0f);
    
    // Generate the OpenGL texture objects
    for (int i = 0; i < [ARData.textures count]; ++i) {
        GLuint nID;
        Texture* texture = [ARData.textures objectAtIndex:i];
        glGenTextures(1, &nID);
        [texture setTextureID: nID];
        glBindTexture(GL_TEXTURE_2D, nID);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [texture width], [texture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[texture pngData]);
    }
}

/*
////////////////////////////////////////////////////////////////////////////////
// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method on a single background thread ***
- (void)renderFrameQCAR
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    //NSLog(@"active trackables: %d", state.getNumActiveTrackables());
    
    if (QCAR::GL_11 & ARData.QCARFlags) {
        glEnable(GL_TEXTURE_2D);
        glDisable(GL_LIGHTING);
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    for (int i = 0; i < state.getNumActiveTrackables(); ++i) {
        // Get the trackable
        const QCAR::Trackable* trackable = state.getActiveTrackable(i);
        QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
        
        // Choose the texture based on the target name
        int textureIndex = (!strcmp(trackable->getName(), "stones")) ? 0 : 1;
        const Texture* const thisTexture = [ARData.textures objectAtIndex:textureIndex];
        
        // Render using the appropriate version of OpenGL
        if (QCAR::GL_11 & ARData.QCARFlags) {
            // Load the projection matrix
            glMatrixMode(GL_PROJECTION);
            glLoadMatrixf(projectionMatrix.data);
            
            // Load the model-view matrix
            glMatrixMode(GL_MODELVIEW);
            glLoadMatrixf(modelViewMatrix.data);
            glTranslatef(0.0f, 0.0f, -kObjectScale);
            glScalef(kObjectScale, kObjectScale, kObjectScale);
            
            // Draw object
            glBindTexture(GL_TEXTURE_2D, [thisTexture textureID]);
            glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid*)&teapotTexCoords[0]);
            glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*) &teapotVertices[0]);
            glNormalPointer(GL_FLOAT, 0, (const GLvoid*)&teapotNormals[0]);
            glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)&teapotIndices[0]);
        }
    }
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    if (QCAR::GL_11 & ARData.QCARFlags) {
        glDisable(GL_TEXTURE_2D);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    QCAR::Renderer::getInstance().end();
    [self presentFramebuffer];
}*/

- (void)renderFrameQCAR
{
    [self setFramebuffer];
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    //NSLog(@"active trackables: %d", state.getNumActiveTrackables());
    
    /*if(toDraw){
        if(Shape::getInstance().Initialized())
        {
            //[self drawCurrentMesh:&state];
        }
        else
        {
            NSLog(@"*****renderFrameQCAR - currentMesh is not Initialized********");
        }
    }*/
    [self drawTeapot:&state];
    //[self drawOutline];
    //[self drawMyCubeNoVBOs:&state];
    //[self drawAxes];
    
    QCAR::Renderer::getInstance().end();
    
    [self presentFramebuffer];
}

-(void)drawOutline
{
    Shape& shapeToDisplay = Shape::getInstance();
    glEnableClientState(GL_VERTEX_ARRAY);
    for (int outlineIndex = 0; outlineIndex < shapeToDisplay.outlineSize; outlineIndex++) {
        glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // opaque red
        glVertexPointer(3, GL_FLOAT, 0, &shapeToDisplay.outline[outlineIndex]);
        glDrawArrays(GL_LINES, 0, 2);
    }
    glDisableClientState(GL_VERTEX_ARRAY);
    
}

- (void)drawTeapot:(QCAR::State*)state
{
    if (QCAR::GL_11 & ARData.QCARFlags) {
        glEnable(GL_TEXTURE_2D);
        glDisable(GL_LIGHTING);
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    
    for (int i = 0; i < state->getNumActiveTrackables(); ++i) {
        // Get the trackable
        const QCAR::Trackable* trackable = state->getActiveTrackable(i);
        QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
        
        // Choose the texture based on the target name
        int textureIndex = (!strcmp(trackable->getName(), "stones")) ? 0 : 1;
        const Texture* const thisTexture = [ARData.textures objectAtIndex:textureIndex];
        
        // Render using the appropriate version of OpenGL
        if (QCAR::GL_11 & ARData.QCARFlags) {
            
            // Load the projection matrix
            glMatrixMode(GL_PROJECTION);
            glLoadMatrixf(projectionMatrix.data);
            
            // Load the model-view matrix
            glMatrixMode(GL_MODELVIEW);
            glLoadMatrixf(modelViewMatrix.data);
            
            //glTranslatef(0.0f, 0.0f, -kObjectScale);
            glTranslatef(self.xTranslateConstant, self.yTranslateConstant, -kObjectScale);
            
            glBindTexture(GL_TEXTURE_2D, [thisTexture textureID]);
            
            //glVertexPointer(3, GL_FLOAT, sizeof(Vertex3D), &self.cubeLocationShape->vertices[0]._position);
            //glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Vertex3D), &self.cubeLocationShape->vertices[0]._color);
            //glNormalPointer(GL_FLOAT, sizeof(Vertex3D), &mesh->vertices[0]._normal);
            
            //glDrawElements(GL_TRIANGLES, self.cubeLocationShape->numIndices, GL_UNSIGNED_SHORT, self.cubeLocationShape->indices);
            Shape& shapeToDisplay = Shape::getInstance();
            for (int outlineIndex = 0; outlineIndex < shapeToDisplay.outlineSize; outlineIndex++) {
                glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // opaque red
                glVertexPointer(3, GL_FLOAT, 0, &shapeToDisplay.outline[outlineIndex]);
                glDrawArrays(GL_LINES, 0, 2);
            }
            glScalef(kObjectScale, kObjectScale, kObjectScale);
            
            // Draw object
            
            glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid*)&teapotTexCoords[0]);
            glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*) &teapotVertices[0]);
            glNormalPointer(GL_FLOAT, 0, (const GLvoid*)&teapotNormals[0]);
            
            glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)&teapotIndices[0]);
            
        }
        
    }
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    if (QCAR::GL_11 & ARData.QCARFlags) {
        glDisable(GL_TEXTURE_2D);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
}

- (void)drawCurrentMesh:(QCAR::State*)state
{
    
    if (QCAR::GL_11 & ARData.QCARFlags) {
        glDisable(GL_LIGHTING);
        glEnableClientState(GL_VERTEX_ARRAY);
        //glEnableClientState(GL_COLOR_ARRAY);
        //glEnableClientState(GL_NORMAL_ARRAY);
        glEnable(GL_COLOR_MATERIAL);
    }
    
    //glEnable(GL_DEPTH_TEST);
    //glEnable(GL_CULL_FACE);
    
    for (int i = 0; i < state->getNumActiveTrackables(); ++i) {
        // Get the trackable
        const QCAR::Trackable* trackable = state->getActiveTrackable(i);
        QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
        
        // Render using the appropriate version of OpenGL
        if (QCAR::GL_11 & ARData.QCARFlags) {
            // Load the projection matrix
            glMatrixMode(GL_PROJECTION);
            glLoadMatrixf(projectionMatrix.data);
            glMatrixMode(GL_MODELVIEW);
            glLoadMatrixf(modelViewMatrix.data);
            
            glTranslatef(self.xTranslateConstant, self.yTranslateConstant, -kObjectScale);
            //glScalef(kObjectScale, kObjectScale, kObjectScale);
        }
        
    }
    
    //glDisable(GL_DEPTH_TEST);
    //glDisable(GL_CULL_FACE);
    
    if (QCAR::GL_11 & ARData.QCARFlags) {
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisable(GL_COLOR_MATERIAL);
        //glDisableClientState(GL_COLOR_ARRAY);
        //glDisableClientState(GL_NORMAL_ARRAY);
    }    
}

- (UIImage*)GetCurrentImage
{
    QCAR::setFrameFormat(QCAR::RGB888,true);
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    QCAR::Frame frame = state.getFrame();
    for (int i = 0; i < frame.getNumImages(); i++)
    {
        const QCAR::Image *qcarImage = frame.getImage(i);
        if (qcarImage->getFormat() == QCAR::RGB888)
        {
            return [ScannerCommon QcarImageToUIImage: qcarImage ];
        }
    }
    return nil;
}

- (bool)GetCurrentQCARData:(UIImage**)image:(QCAR::Matrix34F*)modelViewMatrix
{    
    QCAR::setFrameFormat(QCAR::RGB888,true);
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    
    const QCAR::Trackable* trackable = state.getActiveTrackable(0);
    if(trackable == nil)
    {
        return false;
    }
    
    QCAR::Frame frame = state.getFrame();
    for (int i = 0; i < frame.getNumImages(); i++)
    {
        const QCAR::Image *qcarImage = frame.getImage(i);
        if (qcarImage->getFormat() == QCAR::RGB888)
        {
            *image = [ScannerCommon QcarImageToUIImage: qcarImage ];
            
            CGImageRef myCGImage = (*image).CGImage;
            size_t width  = CGImageGetWidth(myCGImage);
            size_t height = CGImageGetHeight(myCGImage);
            *modelViewMatrix = trackable->getPose();
            
            [ScannerCommon PerformCalibration : modelViewMatrix->data :width :height];
            
            return true;
        }
    }
    return false;
}

@end
