//
//  MeshLibraryViewController.h

#import <UIKit/UIKit.h>

@class BackgroundWorker;

/**MeshLibraryViewController controller responsible for displaying the list of all the saved meshes. It allows to display one of the meshes by clicking on the row of the desired mesh, deleting meshes from memory and swiching the display order of meshes in the list
 *@see EditableDetailCell, MeshForLibrary, BackgroundWorker
 */
@interface MeshLibraryViewController : UITableViewController <UIActionSheetDelegate>
{
    @private
    
    NSMutableArray *_displayedObjects;
    NSString* meshNameChoosenByUser;
    
    BackgroundWorker* backgroundWorker;
    BOOL buttonsDisabled;
}

/**label for displaying messages*/
@property (nonatomic, retain) IBOutlet UILabel *logMesageLabel;

@end
