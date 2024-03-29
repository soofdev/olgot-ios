//
//  olgotMoreViewController.m
//  Olgot
//
//  Created by Raed Hamam on 5/11/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import "olgotMoreViewController.h"

@interface olgotMoreViewController ()

@end

@implementation olgotMoreViewController
@synthesize savePhotosSwitch;
@synthesize autoTweetSwitch;
@synthesize facebookConnectSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
	UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [tempImageView setFrame:self.tableView.frame]; 
    
    self.tableView.backgroundView = tempImageView;
    self.tableView.contentInset = UIEdgeInsetsMake(10.0,0.0,0.0,0.0);
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"autoSavePhotos"] isEqual:@"yes"]) {
        [self.savePhotosSwitch setOn:YES];
    }else {
        [self.savePhotosSwitch setOn:NO];
    }
    
    if ([[defaults objectForKey:@"autoTweetItems"] isEqual:@"yes"]) {
        [self.autoTweetSwitch setOn:YES];
    }else {
        [self.autoTweetSwitch setOn:NO];
    }
    
    //    check for facebook session
    if (FBSession.activeSession.state == FBSessionStateOpen) {
        // Yes, so just open the session (this won't display any UX).
        [self.facebookConnectSwitch setOn:YES];
    }else{
        [self.facebookConnectSwitch setOn:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([defaults objectForKey:@"userid"] != nil) {
        [self.sessionStatusLbl setText:@"Logout"];
    } else {
        [self.sessionStatusLbl setText:@"Login"];
    }
}

- (void)viewDidUnload
{
    [self setSavePhotosSwitch:nil];
    [self setAutoTweetSwitch:nil];
    [self setFacebookConnectSwitch:nil];
    [self setSessionStatusLbl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        NSLog(@"logout");
        // Delete data
        
//        [defaults setObject:nil forKey:@"firstRun"];
//        [defaults setObject:nil forKey:@"userid"];
//        [defaults setObject:nil forKey:@"username"];
//        [defaults setObject:nil forKey:@"email"];
//        [defaults setObject:nil forKey:@"fullname"];
//        [defaults setObject:nil forKey:@"twitterid"];
//        [defaults setObject:nil forKey:@"twittername"];
//        
//        [defaults synchronize];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        [FBSession.activeSession closeAndClearTokenInformation];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:@"You have been logged out."
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
        
        [self.tabBarController setSelectedIndex:0];
//        [alert show];
    }
}

- (IBAction)changeSavePhotos:(id)sender {
    NSLog(@"user changing auto save photos");
    
    
    
    UISwitch* photosSwitch = (UISwitch*)sender;
    if (photosSwitch.isOn) {
        NSLog(@"switched on");
        [defaults setObject:@"yes" forKey:@"autoSavePhotos"];
    }else {
        NSLog(@"switched off");
        [defaults setObject:@"no" forKey:@"autoSavePhotos"];
    }
    
    [defaults synchronize];
}

- (IBAction)changeAutoTweet:(id)sender {
    NSLog(@"user changing auto tweet items");
    
    
    
    UISwitch* tweetSwitch = (UISwitch*)sender;
    if (tweetSwitch.isOn) {
        NSLog(@"switched on");
        NSNumber* twitterAccountIndex = [defaults objectForKey:@"twitterAccountIndex"];
        if([TWTweetComposeViewController canSendTweet] && twitterAccountIndex != nil){
            //user can tweet, seebo b7alo
            NSLog(@"can tweet");
            [defaults setObject:@"yes" forKey:@"autoTweetItems"];
        }else{
            //user can't tweet
            olgotAppDelegate *appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.twitterDelegate = self;
            [appDelegate twitterConnect];
        }
        
    }else {
        NSLog(@"switched off");
        [defaults setObject:@"no" forKey:@"autoTweetItems"];
    }
    
    [defaults synchronize];
}

- (IBAction)changeFacebookConnect:(id)sender {
    NSLog(@"changing facebook connect status");
    
    if (facebookConnectSwitch.isOn) {
//        user wants to connect with facebook
        olgotAppDelegate* appDelegate =  (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.facebookDelegate = self;
        [appDelegate openFBSession];
        
    } else {
//        user wants to disconnect facebook
        [FBSession.activeSession closeAndClearTokenInformation];
        
    }
}

-(void)loadingAccounts
{
    [DejalBezelActivityView activityViewForView:self.view];
}

-(void)loadedAccounts
{
    [DejalBezelActivityView removeView];
}

-(void)didChooseAccount
{
    [defaults setObject:@"yes" forKey:@"autoTweetItems"];
    [defaults synchronize];
}

-(void)cancelledTwitter
{
    [DejalBezelActivityView removeView];
    [defaults setObject:@"yes" forKey:@"autoTweetItems"];
    [defaults synchronize];
    [autoTweetSwitch setOn:NO animated:YES];
}

#pragma mark - olgotFacebookDelegate

-(void)facebookSuccess
{
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *user,
       NSError *error) {
         if (!error) {
             NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [defaults objectForKey:@"userid"], @"id",
                                     user.id, @"facebookid",
                                     nil];
             
             [[RKClient sharedClient] setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
             
             [[RKClient sharedClient] post:@"/fbconnect/" params:params delegate:nil];
         }
     }];
    
}


@end
