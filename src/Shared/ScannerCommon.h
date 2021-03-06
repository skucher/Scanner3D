//
//  ScannerCommon.h
//  Scanner
//
//  Created by אדמין on 1/20/72.
//  Copyright 5772 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector3D.h"
#import "PixelVector.h"
#import "SculpImage.h"
#import "SculptData.h"

#import <QCAR/Image.h>

#define kResolution 96

typedef enum 
{
    EMPTY_BUTTON,
    BACK_BUTTON,
    TAKE_PICTURE_BUTTON,
    DISPLAY_BUTTON,
    RESET_BUTTON,
    SAVE_BUTTON,
    EROSION_BUTTON,
    DELUSION_BUTTON
    
} ButtonName;


extern BOOL const displayMyNSLog;
extern NSString* const const_MeshFolderPath;
extern float const MESH_SCALE_FACTOR;
extern Vector3D const MESH_POSITION;
extern float const DINO_MESH_SCALE_FACTOR;
extern Vector3D const DINO_MESH_POSITION;
extern PixelVector const BACKGROUND_COLOR;

/**Common methods and fields class*/
@interface ScannerCommon : NSObject 
{

}
/**Degrees To Radians*/
+(float) DegreesToRadians:(float) degree;
/**Copy Image Pixels*/
+(CFDataRef) CopyImagePixels:(CGImageRef) inImage;
/**Create RGB Bitmap Context*/
+(CGContextRef)CreateRGBBitmapContext :(size_t) pixelsWide :(size_t) pixelsHigh : (void*) data;
/**Qcar Image To UIImage*/
+(UIImage*)QcarImageToUIImage:(const QCAR::Image *) qcarImage;
/**Perform Calibration*/
+(void)PerformCalibration: (float[3*4]) postionMatrix:(size_t) pixelsWide :(size_t) pixelsHigh;
/**Get Image Data Rgbx*/
+(byte*)GetImageDataRgbx:(UIImage*) _image;
/**Create Bitmap From Rgbx*/
+ (byte*)CreateBitmapFromRgbx:(byte*) rgbxArray : (int) size ;
+ (SculpImage*)SculptDataToUIImage:(SculptData)data;
@end
