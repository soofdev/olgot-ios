//
//  olgotShareViewController.m
//  Olgot
//
//  Created by Raed Hamam on 5/11/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import "olgotShareViewController.h"
#import "olgotAddItemNearbyPlacesViewController.h"

@interface olgotShareViewController ()

@end

@implementation olgotShareViewController

@synthesize imgPicker;

@synthesize imageView, mOverlayViewController, capturedImages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
//    self.imgPicker = [[UIImagePickerController alloc] init];
//    self.imgPicker.allowsEditing = NO;
//    self.imgPicker.delegate = self;
//    self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [self presentModalViewController:self.imgPicker animated:NO];  
    if (showCam) {
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    showCam = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"set show cam to yes");
    showCam = YES;
    
    self.mOverlayViewController =
    [[olgotCameraOverlayViewController alloc] initWithNibName:@"olgotCameraOverlayViewController" bundle:nil];
    
    // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
    self.mOverlayViewController.delegate = self;
    
    self.capturedImages = [NSMutableArray array];
    
//	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
        // camera is not on this device, don't show the camera button
//        NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:self.myToolbar.items.count];
//        [toolbarItems addObjectsFromArray:self.myToolbar.items];
//        [toolbarItems removeObjectAtIndex:2];
//        [self.myToolbar setItems:toolbarItems animated:NO];
//    }
}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.mOverlayViewController = nil;
    self.capturedImages = nil;
}

#pragma mark -
#pragma mark Toolbar Actions

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if (self.capturedImages.count > 0)
        [self.capturedImages removeAllObjects];
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.mOverlayViewController setupImagePicker:sourceType];
        [self presentModalViewController:self.mOverlayViewController.imagePickerController animated:NO];
    }
}

- (IBAction)cameraAction:(id)sender
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark -
#pragma mark OverlayViewControllerDelegate

// as a delegate we are being told a picture was taken
- (void)didTakePicture:(UIImage *)picture
{
    [self.capturedImages addObject:picture];
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera
{
    showCam = NO;
    
    NSLog(@"%d images in array", [self.capturedImages count]);
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // we took a single shot
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            if ([[defaults objectForKey:@"autoSavePhotos"] isEqual:@"yes"]) {
                UIImageWriteToSavedPhotosAlbum([self.capturedImages objectAtIndex:0], nil, nil, nil);
            }
            
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
            [self dismissViewControllerAnimated:NO completion:^(void){
                        [self performSegueWithIdentifier:@"ShowNearbyPlaces" sender:self];
            }];
            
        }
        else
        {
            NSLog(@"warning! %d images in array", [self.capturedImages count]);
        }
    }else {
        [self dismissViewControllerAnimated:NO completion:^(void){
            self.tabBarController.selectedIndex = 0;
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowNearbyPlaces"]) {
        olgotAddItemNearbyPlacesViewController* nearbyController = [segue destinationViewController];
        
        nearbyController.capturedImage = [self.capturedImages objectAtIndex:0];
        [self.capturedImages removeAllObjects];
        
    }
}

//- (void) useCamera
//{
//    if ([UIImagePickerController isSourceTypeAvailable:
//         UIImagePickerControllerSourceTypeCamera])
//    {
//        UIImagePickerController *imagePicker =
//        [[UIImagePickerController alloc] init];
//        imagePicker.delegate = self;
//        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        imagePicker.showsCameraControls = NO;
//        imagePicker.cameraOverlayView = self.mOverlayViewController.view;
//        //        imagePicker.mediaTypes = [NSArray arrayWithObjects:
//        //                                  (NSString *) kUTTypeImage,
//        //                                  nil];
//        imagePicker.allowsEditing = NO;
//        [self presentModalViewController:imagePicker animated:NO];
//        newMedia = YES;
//    }
//}

//-(void)imagePickerController:(UIImagePickerController *)picker
//didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    
//    [self dismissModalViewControllerAnimated:NO];
//    
//    
//    UIImage *image = [info 
//                      objectForKey:UIImagePickerControllerOriginalImage];
//    
//    if (newMedia)
//        UIImageWriteToSavedPhotosAlbum(image, 
//                                       self,
//                                       @selector(image:finishedSavingWithError:contextInfo:),
//                                       nil);
//    
//    [self performSegueWithIdentifier:@"ShowNearbyPlaces" sender:self];
//    
//}

//-(void)image:(UIImage *)image
//finishedSavingWithError:(NSError *)error 
// contextInfo:(void *)contextInfo
//{
//    if (error) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle: @"Save failed"
//                              message: @"Failed to save image"
//                              delegate: nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
//    }
//}

//-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [self dismissModalViewControllerAnimated:NO];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
