//
//  olgotTabBarViewController.h
//  Olgot
//
//  Created by Raed Hamam on 8/28/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "olgotAddItemNearbyPlacesViewController.h"
#import "olgotAddItemConfirmationViewController.h"
#import "olgotCameraOverlayViewController.h"
#import "ImageCropper.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+WBImage.h"
#import "olgotAppDelegate.h"

@interface olgotTabBarViewController : UITabBarController<olgotCameraOverlayViewControllerDelegate ,addItemNearbyProtocol, ImageCropperDelegate>
{

}
// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage;

@property (nonatomic,retain) olgotCameraOverlayViewController *cameraOverlayViewController;



@end
