#import <QuartzCore/QuartzCore.h>

#import "MeshLibraryViewController.h"
#import "MeshForLibrary.h"
#import "RootViewController.h"
#import "OpenGLViewController.h"
#import "BackgroundWorker.h"
#import "Event.h"
#import "Shape.h"

@interface MeshLibraryViewController ()

-(void)addObject:(id)anObject;

-(void)disableButtons;
-(void)enableButtons;

-(void)goToOpenGL;
-(void)updateMessageWith:(NSString*)text;

@property (nonatomic, retain) NSMutableArray *displayedObjects;
@property (copy) void (^actionSheetBlock)(NSUInteger);

@end

@implementation MeshLibraryViewController

@synthesize displayedObjects = _displayedObjects;
@synthesize actionSheetBlock, logMesageLabel;

#pragma mark -
#pragma mark - Controller Methods

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{  
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {       
        backgroundWorker = [[BackgroundWorker alloc] init];
        buttonsDisabled = NO;
    }
    return self;
}

-(void)dealloc
{
    [_displayedObjects release];
    [logMesageLabel release];
    
    if(backgroundWorker != nil)
        [backgroundWorker release];

    
    [super dealloc];
}

//  Lazily initializes array of displayed objects
//

-(void)reloadDisplayedObjects
{
    if (_displayedObjects == nil)
    {
       _displayedObjects = [[NSMutableArray alloc] init]; 
    }
    else
    {
        [_displayedObjects removeAllObjects];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:const_MeshFolderPath];       
    
    NSArray *tempDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    for (NSString* elem in tempDirContents)
    {
        [_displayedObjects addObject:[MeshForLibrary meshWithName:elem]];
    }
}

-(NSMutableArray *)displayedObjects
{
    return _displayedObjects;
}

-(void)addObject:(id)anObject
{
    if (anObject != nil)
    {
        [[self displayedObjects] addObject:anObject];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadDisplayedObjects];
    [[self tableView] reloadData];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //  The controller's title (if set) will be displayed in the
    //  navigation controller's navigation bar at the top of the screen.
    //
    [self setTitle:@"My Meshes"];
    
    [[self tableView] setRowHeight:54.0];
    
    //  Configure the Edit button
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
    //  Configure the Back button
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:@"Back" 
                                           style:UIBarButtonItemStylePlain 
                                          target:self 
                                          action:@selector(goBack)];
    
    [[self navigationItem] setLeftBarButtonItem:backButton];
    [backButton release];
    

    CGRect labelRect;
    CGRect labelRectIphone = {{240.0,38.0}, {380.0,37.0}};
    CGRect labelRectIpad   = {{37.0,74.0}, {950.0,50.0}};
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPad"])
    {
        labelRect = labelRectIpad;
    }
    else
    {
        labelRect = labelRectIphone;
    };
    
    logMesageLabel = [[UILabel alloc] initWithFrame:labelRect];
    logMesageLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    logMesageLabel.font = [UIFont boldSystemFontOfSize:17];
    logMesageLabel.backgroundColor = [UIColor lightGrayColor];
    logMesageLabel.textColor = [UIColor whiteColor];
    logMesageLabel.adjustsFontSizeToFitWidth = YES;
    logMesageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    logMesageLabel.textAlignment = UITextAlignmentCenter;
    logMesageLabel.hidden = YES;
    [self.view addSubview:logMesageLabel];
}

-(void)viewDidUnload
{
    self.logMesageLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (displayMyNSLog) NSLog(@"MeshLibraryViewController.mm - shouldAutorotateToInterfaceOrientation");
    
    // Return YES for supported orientations
    return UIInterfaceOrientationLandscapeRight == interfaceOrientation;
}

- (void)setEditing:(BOOL)editing
          animated:(BOOL)animated
{
    [super setEditing:editing
             animated:animated];
    
    UIBarButtonItem *editButton = [[self navigationItem] leftBarButtonItem];
    [editButton setEnabled:!editing];
}

#pragma mark -
#pragma mark UITableViewDelegate Protocol
//
//  The table view's delegate is notified of runtime events, such as when
//  the user taps on a given row, or attempts to add, remove or reorder rows.

//  Notifies the delegate when the user selects a row.
//
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (buttonsDisabled == YES)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:@"To Display" 
                                              otherButtonTitles:@"Cancel",nil];        
    
    self.actionSheetBlock = ^(NSUInteger userChoice) 
    { 
        if (userChoice == 0)
        {
            MeshForLibrary* mesh = [[self displayedObjects] objectAtIndex:[indexPath row]];
            
            //SettingUp full Mesh file name
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:const_MeshFolderPath];
            documentsDirectory = [documentsDirectory stringByAppendingPathComponent:mesh.name];
            meshNameChoosenByUser = [[NSString alloc] initWithString:documentsDirectory];
            
            NSString* messageText = [NSString stringWithFormat:@"Reading File Data of: %@",mesh.name];
            
            
            [self performSelectorOnMainThread:@selector(updateMessageWith:) 
                                   withObject:messageText 
                                waitUntilDone:YES];
            
            if([backgroundWorker isFinished])
            {
                [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
                [backgroundWorker.onDoWork signMethod:self :@selector(readMeshDataFromFile)];
                [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
                [backgroundWorker.onRunWorkerCompleted signMethod:meshNameChoosenByUser :@selector(release)];

                [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(goToOpenGL)];
                [backgroundWorker runWorkerAsync];
            }
            
        }
        else 
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    };
    
   
    [sheet showInView:self.view];
    [sheet release];
                            
   
}

#pragma mark -
#pragma mark UITableViewDataSource Protocol
//
//  By default, UITableViewController makes itself the delegate of its own
//  UITableView instance, so we can implement data source protocol methods here.
//  You can move these methods to another class if you prefer -- just be sure 
//  to send a -setDelegate: message to the table view if you do.


//  Returns the number of rows in the current section.
//
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self displayedObjects] count];
}

//  Return YES to allow the user to reorder table view rows
//
- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//  Invoked when the user drags one of the table view's cells. Mirror the
//  change in the user interface by updating the array of displayed objects.
//
- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toIndexPath:(NSIndexPath *)targetIndexPath
{
    NSUInteger sourceIndex = [sourceIndexPath row];
    NSUInteger targetIndex = [targetIndexPath row];
    
    if (sourceIndex != targetIndex)
    {
        [[self displayedObjects] exchangeObjectAtIndex:sourceIndex
                                     withObjectAtIndex:targetIndex];
    }
}

//  Update array of displayed objects by inserting/removing objects as necessary.
//
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Remove the filename
        MeshForLibrary* mesh = [[self displayedObjects] objectAtIndex:[indexPath row]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [[[paths objectAtIndex:0] stringByAppendingPathComponent:const_MeshFolderPath]    
                                        stringByAppendingPathComponent:mesh.name];       
        
        [[NSFileManager defaultManager] removeItemAtPath:documentsDirectory error:nil];
        
        //remove the object
        [[self displayedObjects] removeObjectAtIndex:[indexPath row]];
        
        //  Animate deletion
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [[self tableView] deleteRowsAtIndexPaths:indexPaths
                                withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}

// Return a cell containing the text to display at the provided row index.
//
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"MyCell"];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        UIFont *titleFont = [UIFont fontWithName:@"Georgia-BoldItalic" size:18.0];
        [[cell textLabel] setFont:titleFont];
        
        UIFont *detailFont = [UIFont fontWithName:@"Georgia" size:16.0];
        [[cell detailTextLabel] setFont:detailFont];
        
        [cell autorelease];
    }
    
    NSUInteger index = [indexPath row];
    id mesh = [[self displayedObjects] objectAtIndex:index];
    
    NSString *name = [mesh name];
    [[cell textLabel] setText:(name == nil || [name length] < 1 ? @"?" : name)];
    

    return cell;
}


#pragma Mark
#pragma Mark - UI Methods

-(void)disableButtons
{
    buttonsDisabled = YES;
}

-(void)enableButtons
{
    buttonsDisabled = NO;
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    actionSheetBlock(buttonIndex);
}

-(void)updateMessageWith:(NSString*)text
{
    if (text == @"") 
    {
        logMesageLabel.hidden = YES;
    }
    else
    {
        logMesageLabel.hidden = NO;
    }
    logMesageLabel.text = text;
}

#pragma mark -
#pragma mark Navigation Controller Methods

- (void)goBack
{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)goToOpenGL
{
    [self performSelectorOnMainThread:@selector(updateMessageWith:) 
                           withObject:@"" 
                        waitUntilDone:YES];
    
    RootViewController* rootController = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController pushViewController:rootController.openGLViewController animated:YES];
}

#pragma mark -
#pragma mark Support Methods

-(void)readMeshDataFromFile
{
    Shape::getInstance().ReadDataFromFile([meshNameChoosenByUser UTF8String]);
}


@end
