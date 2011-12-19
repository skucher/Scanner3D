
#import <UIKit/UIKit.h>

/**EditableDetailCell table view cell in MeshLibraryViewController table view
 *@see MeshLibraryViewController
 */
@interface EditableDetailCell : UITableViewCell
{
    UITextField *_textField;
}

@property (nonatomic, retain) UITextField *textField;

@end
