//
//  RootViewController.m

#import "DropShadows.h"
#import "RootViewController.h"
#import "OpenGLViewController.h"
#import "MeshLibraryViewController.h"
#import "QCARViewController.h"
#import "Credits.h"
#import "DinosaurPMatrixes.h"
#import "BackgroundWorker.h"
#import "Event.h"
#import "SculpImage.h"

@interface RootViewController ()

/**performs sculpting algorithm on dinosaur images*/
-(void)toSculp;
/**performs sculpting algorithm on dinosaur silhouettes*/
-(void)toSculpOrig;

/**UI methods*/
-(void)goToOpenGL;
-(void)updateDinoImageWith:(UIImage*)newimage;
-(void)updateMasageWith:(NSString*)text;
-(void)hideMessage;
-(void)showMessage;
-(void)enableButtons;
-(void)disableButtons;

/**support method*/
-(SculpImage*)SculptDataToUIImage:(SculptData)data :(DropShadows*)shadows;

@end

@implementation RootViewController

@synthesize dinoImage;
@synthesize message;
@synthesize meshLibButtonCurr, createNewMeshButtonCurr, dinosaurButtonCurr, creditsButtonCurr;
@synthesize openGLViewController, qcarViewController, meshLibraryViewController, credits;

#pragma mark -
#pragma mark - Controller Methods

-(void)dealloc
{
    if (displayMyNSLog) NSLog(@"RootViewController.mm - dealloc");

    [createNewMeshButtonCurr release];
    [meshLibButtonCurr release];
    [creditsButtonCurr release];
    [dinosaurButtonCurr release];

    [image release];
    [message release];
    [dinoImage release];
    
    delete dinosaurSculptor;
    
    [self.qcarViewController release];
    [self.meshLibraryViewController release];
    [self.credits release];
    [self.openGLViewController release];
    
    if(backgroundWorker != nil)
        [backgroundWorker release];
    

    [super dealloc];
}

-(void)viewDidLoad
{
    if (displayMyNSLog) NSLog(@"RootViewController.mm - viewDidLoad");

    dinosaurSculptor = new Sculptor<kResolution>(DINO_MESH_SCALE_FACTOR,DINO_MESH_POSITION);
    backgroundWorker = [[BackgroundWorker alloc] init];
    buttonsDisabled = NO;
    
    self.qcarViewController = [[QCARViewController alloc] init];
    self.meshLibraryViewController = [[MeshLibraryViewController alloc] init];
    self.openGLViewController = [[OpenGLViewController alloc] initWithNibName:@"OpenGLViewController" bundle:[NSBundle mainBundle]];
    self.credits = [[Credits alloc] initWithNibName:@"Credits" bundle:[NSBundle mainBundle]];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

 -(void)viewDidUnload
{
    /* If the view controller releases its view, it calls its viewDidUnload method. You can override this method to perform any additional 
     cleanup required for your views and view hierarchy.
     Release any retained subviews of the main view.
     e.g. self.myOutlet = nil;
     */

    if (displayMyNSLog) NSLog(@"RootViewController.mm - viewDidUnload");

    [self setCreateNewMeshButtonCurr:nil];
    [self setMeshLibButtonCurr:nil];
    [self setCreditsButtonCurr:nil];
    [self setDinosaurButtonCurr:nil];
    
    image = nil;
    
    [self setOpenGLViewController:nil];
    [self setQcarViewController:nil];
    [self setMeshLibraryViewController:nil];
    [self setCredits:nil];


    [self setMessage:nil];
    [self setDinoImage:nil];
    [super viewDidUnload];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (displayMyNSLog) NSLog(@"RootViewController.mm - shouldAutorotateToInterfaceOrientation");

    return UIInterfaceOrientationLandscapeRight == interfaceOrientation;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (displayMyNSLog) NSLog(@"RootViewController.mm - viewWillAppear");
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark - UI Methods

-(IBAction)buttonPushed:(id)sender 
{
    if (buttonsDisabled) return;
    
    UIButton* button = (UIButton*)sender;
    
    if (button == createNewMeshButtonCurr)
    {
        [self.navigationController pushViewController:self.qcarViewController animated:YES];   
        
    } else if (button == meshLibButtonCurr)
    {        
        [self.navigationController pushViewController:self.meshLibraryViewController animated:YES];
        
    } else if (button == creditsButtonCurr)
    {        
        [self.navigationController pushViewController:self.credits animated:YES];
        
    }  else if (button == dinosaurButtonCurr)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Create dinosaur from?"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:@"Silhouettes" 
                                                  otherButtonTitles:@"Original images", @"Cancel",nil]; 
        [sheet showInView:self.view];
        [sheet release];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 2) return;
    
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
        
        if (buttonIndex == 0)
        {
            [backgroundWorker.onDoWork signMethod:self :@selector(toSculpOrig)];
        }
        else
        {
            [backgroundWorker.onDoWork signMethod:self :@selector(toSculp)];
        }
            
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(goToOpenGL)];
        
        [backgroundWorker runWorkerAsync];
    }  

}

-(void)disableButtons
{
    buttonsDisabled = YES;
}

-(void)enableButtons
{
    buttonsDisabled = NO;
}

-(void)hideMessage
{
    message.hidden = YES;
}

-(void)showMessage
{
    message.hidden = NO;
}

-(void)updateMasageWith:(NSString*)text
{
    message.text = text;
}

-(void)goToOpenGL
{    
    [self.navigationController pushViewController:openGLViewController animated:YES];
}

-(void)updateDinoImageWith:(UIImage*)newimage
{
    dinoImage.image = newimage;
}

#pragma mark -
#pragma mark - Additional Methodes

-(void)toSculpOrig
{    
    dinosaurSculptor->Reset();
    [self performSelectorOnMainThread:@selector(showMessage) 
                           withObject:nil 
                        waitUntilDone:YES];

    float totalSculpTime = 0;
    //Sculpting operations
    for (int pMatrix=0; pMatrix < 36; pMatrix++)
    {
        
        [self performSelectorOnMainThread:@selector(updateMasageWith:) 
                               withObject:[NSString stringWithFormat:@"Performing sculpting algorithm for silhouette: %d from 36", pMatrix+1] 
                            waitUntilDone:YES];
        
        NSString *imageName = [NSString stringWithFormat:@"/sil_%d.png", pMatrix + 1];
        UIImage* myImage = [UIImage imageNamed:imageName];
        
        [self performSelectorOnMainThread:@selector(updateDinoImageWith:) 
                               withObject:myImage 
                            waitUntilDone:YES];
        
        
        CGImageRef myCGImage = myImage.CGImage;
        size_t width  = CGImageGetWidth(myCGImage);
        size_t height = CGImageGetHeight(myCGImage);
        CGContextRef cgctx = [ScannerCommon CreateRGBBitmapContext: width :height:NULL];
        if (cgctx == NULL) 
        { 
            // error creating context
            return;
        }
        
        CGRect rect = {{0,0},{width,height}}; 
        
        // Draw the image to the bitmap context. Once we draw, the memory 
        // allocated for the context for rendering will then contain the 
        // raw image data in the specified color space.
        CGContextDrawImage(cgctx, rect, myCGImage); 
        
        byte* myImageDataRgbx = (byte*)CGBitmapContextGetData (cgctx);
        byte* sculptorMap = [ScannerCommon CreateBitmapFromRgbx:myImageDataRgbx :
                             width*height*4];
        
        SculptData sculpData;
        for (int index = 0; index < 12; index++){
            sculpData.projection[index] = projectionMatrix[pMatrix][index];
        }
        
        sculpData.map = sculptorMap;
        sculpData.sizeXmap = width;
        sculpData.sizeYmap = height;
        
        double before = [[NSDate date] timeIntervalSince1970];
        dinosaurSculptor->Sculp(&sculpData,FAST);
        double after = [[NSDate date] timeIntervalSince1970];
        
        delete[] myImageDataRgbx;
        delete[] sculptorMap;
        
        totalSculpTime += (after - before);
        NSLog(@"Sculp Time of image number: %d is : %lf",pMatrix+1,after - before);
        
    }
    
    NSLog(@"Total Sculp Time is: %lf",totalSculpTime);
    
    [self performSelectorOnMainThread:@selector(updateMasageWith:) 
                           withObject:@"Performing Marching Cube algorithm" 
                        waitUntilDone:YES];
    

    [self performSelectorOnMainThread:@selector(updateDinoImageWith:) 
                           withObject:nil
                        waitUntilDone:YES];
    
    double before = [[NSDate date] timeIntervalSince1970];
    dinosaurSculptor->ToShape(ACCURATE,MESH_SCALE_FACTOR/DINO_MESH_SCALE_FACTOR);
    double after = [[NSDate date] timeIntervalSince1970];
    NSLog(@"To shape time : %lf",after - before);
    NSLog(@"Number of triangles : %d",Shape::getInstance().numIndices/3);
    
    [self performSelectorOnMainThread:@selector(hideMessage) 
                           withObject:nil 
                        waitUntilDone:YES];
    
}

-(void)toSculp
{    
    dinosaurSculptor->Reset();
    DropShadows shadows;
    PixelVector bgColor;
    [self performSelectorOnMainThread:@selector(showMessage) 
                           withObject:nil 
                        waitUntilDone:YES];
    
    for (int pMatrix=0; pMatrix < 36; pMatrix++)
    {
        
        [self performSelectorOnMainThread:@selector(updateMasageWith:) 
                               withObject:[NSString stringWithFormat:@"Performing sculpting algorithm for image: %d from 36", pMatrix+1] 
                            waitUntilDone:YES];
        
        double beforeSculpIteration = [[NSDate date] timeIntervalSince1970];
        double before = [[NSDate date] timeIntervalSince1970];
        NSString *imageName = [NSString stringWithFormat:@"/viff.%d.png", pMatrix + 1];
        
        UIImage* myImage = [UIImage imageNamed:imageName];
        
        [self performSelectorOnMainThread:@selector(updateDinoImageWith:) 
                               withObject:myImage 
                            waitUntilDone:YES];

        
        CGImageRef myCGImage = myImage.CGImage;
        size_t width  = CGImageGetWidth(myCGImage);
        size_t height = CGImageGetHeight(myCGImage);
        CGContextRef cgctx = [ScannerCommon CreateRGBBitmapContext: width :height:NULL];
        if (cgctx == NULL) 
        { 
            // error creating context
            return;
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
        NSLog(@"ImageProcessing Time of image number: %d is : %lf",pMatrix+1,after - before);
        
        byte *bwFlatImg = new byte[width * height >> 3];
        byte *bwFlatImgTemp = new byte[width * height >> 3];
        
        before = [[NSDate date] timeIntervalSince1970];
        byte* sculptorMap = new byte[width * height];
        
        bgColor = shadows.getCommonColor(myImageDataRgbx, width * height * 4);
        
        shadows.doSmartDropShadows(myImageDataRgbx, bwFlatImg , width, height,bgColor);
        shadows.doErosionShapeWithMask(bwFlatImg, bwFlatImgTemp, width, height, 2);
        shadows.doDelutionShapeWithMask(bwFlatImgTemp, bwFlatImg, width, height, 2);
        shadows.toImage(sculptorMap, bwFlatImg, width*height);
        
        //after drop shadows
        after = [[NSDate date] timeIntervalSince1970];
        NSLog(@"Drop Shadows Time of image number: %d is : %lf",pMatrix+1,after - before);
        
        SculptData sculpData;
        for (int index = 0; index < 12; index++){
            sculpData.projection[index] = projectionMatrix[pMatrix][index];
        }
        
        sculpData.map = sculptorMap;
        sculpData.sizeXmap = width;
        sculpData.sizeYmap = height;
        
        before = [[NSDate date] timeIntervalSince1970];
        dinosaurSculptor->Sculp(&sculpData,FAST);

        after = [[NSDate date] timeIntervalSince1970];
        
        UIImage* displayImage = [self SculptDataToUIImage:sculpData :&shadows];
        
        [self performSelectorOnMainThread:@selector(updateDinoImageWith:) 
                               withObject:displayImage 
                            waitUntilDone:YES];
        sleep(1);

        [displayImage release];
        
        NSLog(@"Sculp Time of image number: %d is : %lf",pMatrix+1,after - before);
        
        delete [] myImageDataRgbx;
        delete [] bwFlatImgTemp;
        delete [] bwFlatImg;
        
        double afterSculpIteration = [[NSDate date] timeIntervalSince1970];
        NSLog(@"Sculp interation Time of image number: %d is : %lf",pMatrix+1, afterSculpIteration - beforeSculpIteration);
         
    }
  
    [self performSelectorOnMainThread:@selector(updateMasageWith:) 
                           withObject:@"Performing Marching Cube algorithm" 
                        waitUntilDone:YES];
    
    [self performSelectorOnMainThread:@selector(updateDinoImageWith:) 
                           withObject:nil
                        waitUntilDone:YES];
    
    double before = [[NSDate date] timeIntervalSince1970];
    dinosaurSculptor->ToShape(ACCURATE,MESH_SCALE_FACTOR/DINO_MESH_SCALE_FACTOR);
    double after = [[NSDate date] timeIntervalSince1970];
    NSLog(@"To shape time : %lf",after - before);
        
    [self performSelectorOnMainThread:@selector(hideMessage) 
                           withObject:nil 
                        waitUntilDone:YES];
}

-(SculpImage*)SculptDataToUIImage:(SculptData)data :(DropShadows*)shadows
{
    int bytes = data.sizeXmap*data.sizeYmap;
    byte* map = new byte[bytes*4];
    shadows->toRgbx(map, data.map, bytes);
    CGContextRef context = [ScannerCommon CreateRGBBitmapContext:data.sizeXmap :data.sizeYmap:map];
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    SculpImage* sImage = [[SculpImage alloc] initWithCGImage:cgImage:data];
    return sImage;
}

@end
