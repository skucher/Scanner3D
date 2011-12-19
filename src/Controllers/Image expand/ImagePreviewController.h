
#import "TapDetectingImageView.h"
#import "HSImageSidebarView.h"
#import "DropShadows.h"
#import "SculpImage.h"

/**ImagePreviewController controller responsible for displaying images from QCARViewController. The implementation code is taken from WWDC2010 release:TapToZoom example
 *@see: QCARViewController, wwdc2010 release:TapToZoom Example
 */
@interface ImagePreviewController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate, UIGestureRecognizerDelegate, HSImageSidebarViewDelegate, UIPopoverControllerDelegate> 
{
    SculpImage* _image;
    SculpImage* _imageBackup;
    SculpImage** _outputImageLocation;
    
    UIScrollView *_imageScrollView;
    UIImageView *imageView;
    BOOL buttonsDisabled;
    BOOL delusionErosionAllowed;
    DropShadows dropShadows;
    
    HSImageSidebarView *_sidebarButtons;
    UITextField *erosionTestField;
    UITextField *delusionTextFiled;
    NSMutableArray* buttons;//for _sidebarButtons
    UILabel *messageLable;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(SculpImage**)image;


/**UI Components*/
@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, retain) IBOutlet HSImageSidebarView *sidebarButtons;
@property (nonatomic, retain) IBOutlet UITextField *erosionTextField;
@property (nonatomic, retain) IBOutlet UITextField *delusionTextFiled;
@property (nonatomic, retain) IBOutlet UILabel *messageLable;

/**executed when the user pressed 'done' button on iPhone\iPad keyboard
 */
- (IBAction)textFieldDoneEditing:(id)sender;
/**executed when the user pressed on background, the method resigns UITextFields from being active
 */
- (IBAction)backgroundTap:(id)sender;
@end

