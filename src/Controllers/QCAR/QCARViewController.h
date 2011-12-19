/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH.
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/

#import "ScannerCommon.h"
#import "Sculptor.h"
#import "DropShadows.h"
#import "Delegate.h"
#import <QCAR/Matrices.h>
#import <UIKit/UIKit.h>

@class QCARButtonOverlay;
@class EAGLViewQCAR;
@class SculpImage;

/**QCARViewController controller class responsible for QCAR library UI
 *@see QCARButtonOverlay, EAGLViewQCAR, SculpImage
 */
@interface QCARViewController : UIViewController
{
    @private
    Sculptor<kResolution>* sculptor;
    
    DropShadows dropShadows;
    PixelVector bgColor;
    SculpImage** imageptr;
}
/**Button overaly controller that overlays the qcar view. This controller responsible for UI layer of QCARViewController */
@property (nonatomic, retain) QCARButtonOverlay* buttonOverlay;

/**called by QCARButtonOveraly controller when take picture button is pushed */
-(void)takePictureButtonPushed;
/**called by QCARButtonOveraly controller when display Mesh button is pushed
 *@param toSculpt: when true, sculpting operation is performed on the selected image in the images sidebar (from QCARButtonOveraly)
 */
-(void)displayMeshButtonPushed:(BOOL)toSculp;
/**called by QCARButtonOveraly controller when expand image button is pushed */
-(void)expandImageButtonPushed;

/**Performs sculpting algorithm on the provided image. 
 *@param currentImage: pointer to the image meant for sculpting
 *@param imageIndex  : index the image in the images sidebar (QCARButtonOveraly controller)
 */
-(void)sculptImage:(SculpImage*)currentImage index:(NSInteger)imageIndex;

@end
