/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH.
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/

#import "RootViewController.h"
#import "OpenGLViewController.h"
#import "QCARViewController.h"
#import "EAGLViewQCAR.h"
#import "QCARButtonOverlay.h"
#import "ImagePreviewController.h"
#import "SculpImage.h"

@interface QCARViewController() <UIActionSheetDelegate>

-(void)processImage:(CGImageRef&)myCGImage:(SculptData&)sculptData:(QCAR::Matrix34F&)matrix;
-(void)buttonOverlayInit;
-(EAGLViewQCAR *)getQCARView;
-(void)performSculpt:(SculpImage*)sculptImage;

@property (copy) void (^actionSheetBlock)(NSUInteger);

@end

@implementation QCARViewController
@synthesize buttonOverlay;
@synthesize actionSheetBlock;

#pragma mark
#pragma mark Controller methods

-(id)init
{
    self = [super init];
    if (self) 
    {
        sculptor = new Sculptor<kResolution>(MESH_SCALE_FACTOR,MESH_POSITION);
        sculptor->CreateOutline();
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.view = [[EAGLViewQCAR alloc] initWithFrame: screenBounds];
        imageptr = nil;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad]; 
}

-(void)dealloc
{
    [buttonOverlay release];
    [(EAGLViewQCAR*)self.view onDestroy];
    
    [self.view release];
    
    delete sculptor;
    
    [super dealloc];
}

-(void)buttonOverlayInit
{
    buttonOverlay = [[QCARButtonOverlay alloc] initWithNibName:@"QCARButtonOverlay" bundle:nil];
    buttonOverlay.father = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    static BOOL firstTime = YES;
    if (firstTime) 
    {
        // Create an overlay view and its view controller (used for
        // displaying UI objects, such as the camera control menu)
        [self buttonOverlayInit];
        [super.view addSubview:buttonOverlay.view];
        [[self getQCARView] onCreate];
        [[self getQCARView] onResume];
                
        firstTime=NO;
        return;
    }
     
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(imageptr!=nil)
    {
        NSInteger selectedIndex = buttonOverlay.sidebarImages.selectedIndex;
        [buttonOverlay sideBarDeleteRowAtIndex:selectedIndex];
        [buttonOverlay sideBarInsertRow:*imageptr atIndex:selectedIndex];
        imageptr = nil;
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationLandscapeRight == interfaceOrientation;
}

-(EAGLViewQCAR *)getQCARView
{
    return (EAGLViewQCAR *)self.view;
}


#pragma mark
#pragma mark Sculptor Methods

-(void)PrintCurrentMesh
{
    Shape& currentMesh = Shape::getInstance();
    NSLog(@"Number of vertices - %d",currentMesh.numVertices);
    NSLog(@"Number of indices - %d",currentMesh.numIndices);
    NSLog(@"Number of triangles - %d",currentMesh.numIndices/3);
}

-(void)processImage:(CGImageRef&)myCGImage:(SculptData&)sculptData:(QCAR::Matrix34F&) modelViewMatrix
{
    double before = [[NSDate date] timeIntervalSince1970];
    //CGImageRef myCGImage = _image.CGImage;
    
    size_t width  = CGImageGetWidth(myCGImage);
    size_t height = CGImageGetHeight(myCGImage);
    CGContextRef cgctx = [ScannerCommon CreateRGBBitmapContext:width:height:NULL];
    if (cgctx == NULL) 
    { 
        // error creating context
        return ;
    }
    
    CGRect rect = {{0,0},{width,height}}; 
    
    // Draw the image to the bitmap context. Once we draw, the memory 
    // allocated for the context for rendering will then contain the 
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, myCGImage); 
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    byte* myImageDataRgbx = (byte*)CGBitmapContextGetData (cgctx);
    
    double after = [[NSDate date] timeIntervalSince1970];
    NSLog(@"ImageProcessing Time is : %lf",after - before);
    
    bgColor = dropShadows.getCommonColor(myImageDataRgbx, width * height * 4);
    
    byte *bwFlatImg = new byte[width * height >> 3];
    byte *bwFlatImgTemp = new byte[width * height >> 3];
    
    before = [[NSDate date] timeIntervalSince1970];
    byte* sculptorMap = new byte[width * height];
    
    dropShadows.doSmartDropShadows(myImageDataRgbx, bwFlatImg , width, height,bgColor);//BACKGROUND_COLOR);                      
    dropShadows.doErosionShapeWithMask(bwFlatImg, bwFlatImgTemp, width, height, 2);
    dropShadows.doDelutionShapeWithMask(bwFlatImgTemp, bwFlatImg, width, height, 2);
    
    dropShadows.toImage(sculptorMap, bwFlatImg, width*height);
    
    after = [[NSDate date] timeIntervalSince1970];
    NSLog(@"Drop Shadows Time is : %lf",after - before);
    
    for (int index = 0; index < 12; index++){
        sculptData.projection[index] = modelViewMatrix.data[index];
    }
    
    sculptData.map = sculptorMap;
    sculptData.sizeXmap = width;
    sculptData.sizeYmap = height;
    delete [] myImageDataRgbx;
    delete [] bwFlatImg;
    delete [] bwFlatImgTemp;
}

#pragma mark
#pragma mark Event handlers

-(void)takePictureButtonPushed
{
    [buttonOverlay startActivityIndicator];
    UIImage* _image;
    QCAR::Matrix34F modelViewMatrix; 
    if([[self getQCARView] GetCurrentQCARData: &_image: &modelViewMatrix] == false)
    {
        return;
    }
    
    SculptData sculpData;
    CGImageRef imageRef = _image.CGImage;
    [self processImage:imageRef : sculpData: modelViewMatrix];
    _image = [ScannerCommon SculptDataToUIImage:sculpData];
    
    [self.buttonOverlay sideBarInsertRow:_image atIndex:buttonOverlay.sidebarImages.selectedIndex +1];
    [buttonOverlay stopActivityIndicator];

}

-(void)displayMeshButtonPushedWithSculp
{
    [self displayMeshButtonPushed:YES];
}

-(void)displayMeshButtonPushedNoSculp
{
    [self displayMeshButtonPushed:NO];
}

-(void)displayMeshButtonPushed:(BOOL)toSculp
{
    if(toSculp)
    {
        for (int imageIndex = 0; imageIndex < buttonOverlay.sidebarImages.imageCount; imageIndex++) 
        {
            NSLog(@"Getting image at index %d",imageIndex);
            SculpImage* currentImage = [buttonOverlay.images objectAtIndex:imageIndex]; 
            if(currentImage.sculpted == NO)
            {
                NSLog(@"Perform sculp image at index %d",imageIndex);
                [self sculptImage:currentImage index:imageIndex];
            }
        }
    }
    double before = [[NSDate date] timeIntervalSince1970];
    NSLog(@"Performing to shape operation");

    sculptor->ToShape(ACCURATE,1);
    double after = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"Shape operation time : %lf",after - before);
    [self PrintCurrentMesh];
}

-(void)sculptImage:(SculpImage*)image index:(NSInteger)imageIndex
{
    [self performSculpt:image];
    [buttonOverlay sideBarDeleteRowAtIndex:imageIndex];
    SculpImage* paintedSculpImage = [ScannerCommon SculptDataToUIImage:image->sculptData];
    paintedSculpImage.sculpted = YES;
    [image release];
    [buttonOverlay sideBarInsertRow:paintedSculpImage atIndex:imageIndex];
}

-(void)gotoOpenGLView
{
    RootViewController* rootConroller = [[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController pushViewController:rootConroller.openGLViewController animated:YES];
}

-(void)performSculpt:(SculpImage*)sculptImage
{
    if(sculptImage->sculptData.Initialized())
    {
        double before = [[NSDate date] timeIntervalSince1970];
        NSLog(@"Performing to shape operation");
        
        sculptor->Sculp(&(sculptImage->sculptData),FAST);
        
        double after = [[NSDate date] timeIntervalSince1970];
        NSLog(@"To sculp operation time : %lf",after - before);
        
    }
}

-(void)resetPushed
{
    [self getQCARView]->toDraw = NO;
    sculptor->Reset();
    Shape::getInstance().Clear();
}

-(void)backPushed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)expandImageButtonPushed
{
    NSInteger selectedIndex = buttonOverlay.sidebarImages.selectedIndex;
	if (selectedIndex != -1) 
    {
		UIImage* _image = [buttonOverlay.images objectAtIndex:selectedIndex];
        imageptr = (SculpImage**)&_image;
        
        ImagePreviewController* ipController = [[ImagePreviewController alloc] 
                                                initWithNibName:@"ImagePreviewController"
                                                         bundle:[NSBundle mainBundle] 
                                                          image:imageptr];
        
        [self.navigationController pushViewController:ipController animated:YES];
        [ipController release];
	}
}

@end