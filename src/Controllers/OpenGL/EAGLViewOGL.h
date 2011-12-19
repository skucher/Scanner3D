//
//  EAGLViewOGL.h
//  Scanner

#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>



@class EAGLContext;

/**EAGLViewOGL: this class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass. The view content is basically an EAGL surface you render your OpenGL scene into. Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */ 
@interface EAGLViewOGL : UIView {
@private
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer, depthRenderbuffer;
}

@property (nonatomic, retain) EAGLContext *context;

/**creates defaultFramebuffer, colorRenderbuffer, depthRenderbuffer
 */
- (void)createFramebuffer;
- (void)setFramebuffer;
- (void)deleteFramebuffer;
- (BOOL)presentFramebuffer;

@end
