//
//  RootViewController.h

#import "ScannerCommon.h"
#import "Sculptor.h"

#import <UIKit/UIKit.h>

@class OpenGLViewController;
@class QCARViewController;
@class MeshLibraryViewController;
@class Credits;
@class BackgroundWorker;

/**RootViewController: root controller of the application which coardinates all the other controllers
 *@see OpenGLViewController, QCARViewController, MeshLibraryViewController, Credits, BackgroundWorker
 */
@interface RootViewController : UIViewController <UIActionSheetDelegate> 
{
    @private
    
    Sculptor<kResolution>* dinosaurSculptor;
    UIImage *image;
        
    BackgroundWorker* backgroundWorker;
    
    BOOL buttonsDisabled;

    UIImageView *dinoImage;
}

/**UIView Controllers - each one on the following controllers is created once when rootViewCotroller loads it's view. */
@property(nonatomic,retain) OpenGLViewController *openGLViewController;
@property(nonatomic,retain) MeshLibraryViewController *meshLibraryViewController;
@property(nonatomic,retain) QCARViewController *qcarViewController;
@property(nonatomic,retain) Credits *credits;

/**UI Componnents*/
@property (nonatomic, retain) IBOutlet UIButton *createNewMeshButtonCurr;
@property (nonatomic, retain) IBOutlet UIButton *meshLibButtonCurr;
@property (nonatomic, retain) IBOutlet UIButton *creditsButtonCurr;
@property (nonatomic, retain) IBOutlet UIButton *dinosaurButtonCurr;

@property (nonatomic, retain) IBOutlet UIImageView *dinoImage;
@property (nonatomic, retain) IBOutlet UILabel *message;

/**buttonPushed: IBAction wich occures when one of the buttons is pushed
 */
- (IBAction)buttonPushed:(id)sender;


@end
