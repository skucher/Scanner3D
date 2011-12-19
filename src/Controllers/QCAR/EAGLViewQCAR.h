/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH.
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QCAR/Tool.h>
#import <QCAR/UIGLViewProtocol.h>
#import "Shape.h"

/**Application status*/
typedef enum _status {
    APPSTATUS_UNINITED,
    APPSTATUS_INIT_APP,
    APPSTATUS_INIT_QCAR,
    APPSTATUS_INIT_APP_AR,
    APPSTATUS_INIT_TRACKER,
    APPSTATUS_INITED,
    APPSTATUS_CAMERA_STOPPED,
    APPSTATUS_CAMERA_RUNNING,
    APPSTATUS_ERROR
} status;


/**EAGLViewQCAR: this class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass. The view content is basically an EAGL surface you render your OpenGL scene into. Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */ 
@interface EAGLViewQCAR : UIView <UIGLViewProtocol>
{
@private
    EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view.
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    // OpenGL projection matrix
    QCAR::Matrix44F projectionMatrix;    
    
    struct tagARData {
        CGRect screenRect;
        NSMutableArray* textures;   // Teapot textures
        int QCARFlags;              // QCAR initialisation flags
        status appStatus;           // Current app status
        int errorCode;              // if appStatus == APPSTATUS_ERROR
    } ARData;
    
    
@public
    BOOL toDraw;
}

- (id)initWithFrame:(CGRect)frame;

- (void)renderFrameQCAR;    // Render frame method called by QCAR
/**QCAR library method*/
- (void)onCreate;
/**QCAR library method*/
- (void)onDestroy;
/**QCAR library method*/
- (void)onResume;
/**QCAR library method*/
- (void)onPause;

/**retrives into image the last image that was taken by the camera and into modelViewMatrix the  model view matrix from QCAR library that coresponds to the image
 @param image: Last (current) image taken by the camera is converted to UIImage*, image points to it after the end of the method
 @param modelViewMatrix: model view matrix from QCAR library that coresponds to the image, modelViewMatrix points to it after the end of the method*/
- (bool)GetCurrentQCARData:(UIImage**)image:(QCAR::Matrix34F*)modelViewMatrix;

/**returns the last (current) image (as UIImage) that was capture by the cammera*/
- (UIImage*)GetCurrentImage;

@property float xTranslateConstant;
@property float yTranslateConstant;

@end
