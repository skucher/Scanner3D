#import "TapDetectingImageView.h"

@implementation TapDetectingImageView
@synthesize delegate;

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        
        [doubleTap setNumberOfTapsRequired:2];
        [twoFingerTap setNumberOfTouchesRequired:2];
        
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
        [self addGestureRecognizer:twoFingerTap];
        
        [singleTap release];
        [doubleTap release];
        [twoFingerTap release];
    }
    return self;
}

#pragma mark Private

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([delegate respondsToSelector:@selector(tapDetectingImageView:gotSingleTapAtPoint:)])
        [delegate tapDetectingImageView:self gotSingleTapAtPoint:[gestureRecognizer locationInView:self]];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([delegate respondsToSelector:@selector(tapDetectingImageView:gotDoubleTapAtPoint:)])
        [delegate tapDetectingImageView:self gotDoubleTapAtPoint:[gestureRecognizer locationInView:self]];
}
    
- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([delegate respondsToSelector:@selector(tapDetectingImageView:gotTwoFingerTapAtPoint:)])
        [delegate tapDetectingImageView:self gotTwoFingerTapAtPoint:[gestureRecognizer locationInView:self]];
}
    
@end
                    
