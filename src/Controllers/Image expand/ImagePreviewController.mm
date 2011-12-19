
#import "ImagePreviewController.h"
#import "ScannerCommon.h"
#import "RootViewController.h"
#import "Messager.h"
#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5


@interface ImagePreviewController ()
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

//Sidebar
@property (retain) UIPopoverController *popover;
-(void)sideBarButtonsInsertButton:(NSNumber*)button atIndex:(NSInteger)index;
-(void)sidebarButtonsClearSelection;
-(void)sideBarDeleteRowAtIndex:(NSInteger)selectedIndex;

-(void)erosionDelusionButtonPushed :(BOOL)isErosion;
-(void)backButtonPushed;
-(void)resetButtonPushed;
@end


@implementation ImagePreviewController
@synthesize erosionTextField;
@synthesize delusionTextFiled;
@synthesize messageLable;
@synthesize imageScrollView = _imageScrollView, sidebarButtons = _sidebarButtons, popover;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(SculpImage **)image
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        buttonsDisabled = NO;
        //_image = [[SculpImage alloc] initWithCGImage:[image CGImage] :image->sculptData];
        _image = [ScannerCommon SculptDataToUIImage:(*image)->sculptData];
        _imageBackup = [ScannerCommon SculptDataToUIImage:(*image)->sculptData];
        _outputImageLocation = image;
        delusionErosionAllowed = !(*image).sculpted;
    }
    return self;
}

-(void)loadView 
{
    [super loadView];
    
    _sidebarButtons.delegate = self;
    buttons = [[NSMutableArray alloc] init];
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"])
    {
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:BACK_BUTTON]  atIndex:0];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON] atIndex:1];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EROSION_BUTTON] atIndex:2];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:DELUSION_BUTTON]  atIndex:3];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:RESET_BUTTON]  atIndex:4];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON]  atIndex:5];
        
    }
    else
    {
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:BACK_BUTTON]  atIndex:0];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EROSION_BUTTON]  atIndex:1];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:DELUSION_BUTTON]  atIndex:2];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:RESET_BUTTON]  atIndex:3];
    };
    
    
    _sidebarButtons.selectedIndex = -1;
    
    [_imageScrollView setDelegate:self];
    [_imageScrollView setBouncesZoom:YES];
    
    // add touch-sensitive image view to the scroll view
    
    imageView = [[UIImageView alloc] initWithImage:_image];
    //imageView.frame = self.view.frame;

    [imageView setTag:ZOOM_VIEW_TAG];
    [imageView setUserInteractionEnabled:YES];
    [_imageScrollView setContentSize:[imageView frame].size];
    [_imageScrollView addSubview:imageView];
    
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];
    [imageView addGestureRecognizer:twoFingerTap];
    
    [singleTap release];
    [doubleTap release];
    [twoFingerTap release];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [_imageScrollView frame].size.width  / [imageView frame].size.width;
    [_imageScrollView setMinimumZoomScale:minimumScale];
    [_imageScrollView setZoomScale:minimumScale];
}

-(void)viewDidUnload
{
    _sidebarButtons = nil;
    _imageScrollView = nil;
    [self setMessageLable:nil];
    [self setErosionTextField:nil];
    [self setDelusionTextFiled:nil];
    [super viewDidUnload];
}

-(void)dealloc 
{
    [_imageScrollView release];
    if (_image != nil) {
        _image->sculptData.Clear();
    }
    [_image release];
    if (_imageBackup != nil) {
        _imageBackup->sculptData.Clear();
    }
    [_imageBackup release];
    [popover release];
    [buttons removeAllObjects];
    [buttons release];
    [_sidebarButtons release];
    [imageView release];
    [messageLable release];
    [erosionTextField release];
    [delusionTextFiled release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [_imageScrollView viewWithTag:ZOOM_VIEW_TAG];
}

/************************************** NOTE **************************************/
/* The following delegate method works around a known bug in zoomToRect:animated: */
/* In the next release after 3.0 this workaround will no longer be necessary      */
/**********************************************************************************/
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    float newScale = [_imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [_imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [_imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [_imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [_imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [_imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}
#pragma mark
#pragma Sidebar Methods ------------------------------------------------------------

-(void)sideBarDeleteRowAtIndex:(NSInteger)selectedIndex
{
	if (selectedIndex != -1) {
		BOOL isLastRow = (selectedIndex == ([buttons count] - 1));
		[buttons removeObjectAtIndex:selectedIndex];
        //TODO check if removeObjectAtIndex calls release
		[_sidebarButtons deleteRowAtIndex:selectedIndex];
		
		if ([buttons count] != 0) {
			NSUInteger newSelection = selectedIndex;
			if (isLastRow) {
				newSelection = [buttons count] - 1;
			}
			_sidebarButtons.selectedIndex = newSelection;
			[_sidebarButtons scrollRowAtIndexToVisible:newSelection];
		}
	}
}

-(void)sideBarButtonsInsertButton:(NSNumber*)button atIndex:(NSInteger)index
{
	[buttons insertObject:button atIndex:index];
	[_sidebarButtons insertRowAtIndex:index];
	[_sidebarButtons scrollRowAtIndexToVisible:index];
	_sidebarButtons.selectedIndex = index;
}

-(UIImage*)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex 
{
    if (sidebar == _sidebarButtons)
    {
        int button = [[buttons objectAtIndex:anIndex] intValue];
        switch (button) 
        {
            case EMPTY_BUTTON:
                return [UIImage imageNamed:@"Empty Icon.png"];
                break;
                
            case BACK_BUTTON:
                return [UIImage imageNamed:@"GoBackButton.png"];
                break;     
                
            case EROSION_BUTTON:
                return [UIImage imageNamed:@"ErosionButton.png"];
                break;
                
            case DELUSION_BUTTON:
                return [UIImage imageNamed:@"DelusionButton.png"];
                break;
                
            case RESET_BUTTON:
                return [UIImage imageNamed:@"Reset Square.png"];
                break;
                
            default:
                return [UIImage imageNamed:@"Empty Icon.png"];
                break;  
        }
        
    }
    return nil;
}

-(void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex 
{
    if (buttonsDisabled == NO) 
    {
        
        int button = [[buttons objectAtIndex:anIndex] intValue];
        switch (button) 
        {
            case EMPTY_BUTTON:            
                break;
                
            case BACK_BUTTON:
                [self backButtonPushed];
                break;
                
            case EROSION_BUTTON:
                [self erosionDelusionButtonPushed:YES];
                break;
                
            case DELUSION_BUTTON:
                [self erosionDelusionButtonPushed:NO];
                break;
                
            case RESET_BUTTON:
                [self resetButtonPushed];
                break;
                
            default:
                break;  
        }
    }
    
    [self performSelectorOnMainThread:@selector(sidebarButtonsClearSelection) withObject:nil waitUntilDone:YES]; 
}


-(void)sidebar:(HSImageSidebarView *)sidebar didMoveImageAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex 
{  
    NSLog(@"Image at index %d moved to index %d", oldIndex, newIndex);
    
    NSNumber *button = [[buttons objectAtIndex:oldIndex] retain];
    [buttons removeObjectAtIndex:oldIndex];
    [buttons insertObject:button atIndex:newIndex];
    [button release];
    
    [self performSelectorOnMainThread:@selector(sidebarButtonsClearSelection) withObject:nil waitUntilDone:YES];
    
    return;
}

-(void)sidebar:(HSImageSidebarView *)sidebar didRemoveImageAtIndex:(NSUInteger)anIndex {
    
    return;
}


-(void)sidebarButtonsClearSelection
{
    _sidebarButtons.selectedIndex = 1;
}

-(NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar 
{
    return [buttons count];
}

-(void)backButtonPushed
{
    *_outputImageLocation = [ScannerCommon SculptDataToUIImage:_image->sculptData];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)erosionDelusionButtonPushed :(BOOL)isErosion
{
    buttonsDisabled = YES;
    if (delusionErosionAllowed == NO)
    {
        NSString* message;
        if (isErosion)
        {
            message = @"Erosion operation is not aloowed on Sculpted images";
        }
        else
        {
            message = @"Delusion operation is not aloowed on Sculpted images";
        }
        Messager* messager = [[Messager alloc] initWith:messageLable];
        [messager showMessage:message withFadeDuration:1.0 withShowDuration:1.0];
        [messager release];
        buttonsDisabled = NO;
        [self performSelectorOnMainThread:@selector(sidebarButtonsClearSelection) withObject:nil waitUntilDone:YES];
        return;
    }
    
    SculptData& sculpData = _image->sculptData;
    byte* map = sculpData.map;
    
    int height = sculpData.sizeYmap;
    int width = sculpData.sizeXmap;
    int mapSize = width * height;
    
    byte* flatMapBefore = new byte[mapSize >> 3];
    byte* flatMapAfter = new byte[mapSize >> 3];
    
    dropShadows.toFlat(map, flatMapBefore,mapSize);
    if(isErosion)
    {
        int val = [erosionTextField.text intValue];
        dropShadows.doErosionShapeWithMask(flatMapBefore, flatMapAfter, width, height, val);
    }
    else
    {
        int val = [delusionTextFiled.text intValue];
        dropShadows.doDelutionShapeWithMask(flatMapBefore, flatMapAfter, width, height, val);
    }
    dropShadows.toImage(sculpData.map, flatMapAfter, mapSize);
    
    [_image release];
    _image = [ScannerCommon SculptDataToUIImage:sculpData];
    
    imageView.image = _image;
    
    delete[] flatMapBefore;
    delete[] flatMapAfter;
    
    buttonsDisabled = NO;
    
    [self performSelectorOnMainThread:@selector(sidebarButtonsClearSelection) withObject:nil waitUntilDone:YES];
}

-(void)resetButtonPushed
{   
    buttonsDisabled = YES;
    if (delusionErosionAllowed == NO)
    {
        buttonsDisabled = NO;
        [self performSelectorOnMainThread:@selector(sidebarButtonsClearSelection) withObject:nil waitUntilDone:YES];
        return;
    }
    
    if(_image != nil)
    {
        _image->sculptData.Clear();
        [_image release];
    }
    _image = [ScannerCommon SculptDataToUIImage:(_imageBackup)->sculptData];
    
    imageView.image = _image;
    
    buttonsDisabled = NO;
    
    [self performSelectorOnMainThread:@selector(sidebarButtonsClearSelection) withObject:nil waitUntilDone:YES];
    
}

-(void)disableButtons
{
    buttonsDisabled = YES;
}

-(void)enableButtons
{
    buttonsDisabled = NO;
}


-(IBAction)textFieldDoneEditing:(id)sender 
{
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender 
{
    [erosionTextField resignFirstResponder];
    [delusionTextFiled resignFirstResponder];
}

@end
