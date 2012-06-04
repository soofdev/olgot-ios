//
//  olgotProfileViewController.m
//  Olgot
//
//  Created by Raed Hamam on 5/11/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import "olgotProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "olgotItem.h"
#import "olgotUser.h"
#import "olgotItemViewController.h"


@interface olgotProfileViewController ()

@end

@implementation olgotProfileViewController

@synthesize profileCardTile = _profileCardTile, profileItemTile = _profileItemTile;

@synthesize userID = _userID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setUserID:(NSNumber *)userID
{
    if (_userID != userID) {
        _userID = userID;
        [self loadItems];
        [self loadUser];
    }
}

-(void)loadUser
{
    defaults = [NSUserDefaults standardUserDefaults];
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    NSDictionary* myParams = [NSDictionary dictionaryWithObjectsAndKeys: _userID, @"user", [defaults objectForKey:@"userid"], @"id", nil];
    NSString* resourcePath = [@"/user/" appendQueryParams:myParams];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self];
}

- (void)loadItems {
    // Load the object model via RestKit
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    NSDictionary* myParams = [NSDictionary dictionaryWithObjectsAndKeys: _userID, @"user", nil];
    NSString* resourcePath = [@"/useritems/" appendQueryParams:myParams];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    if ([[objects objectAtIndex:0] class] == [olgotUser class]) {
        _user = [objects objectAtIndex:0];
        [self.collectionView reloadData];
    } else {
        _items = objects;
        [self.collectionView reloadData];
    }
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Hit error: %@", error);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // background
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [tempImageView setFrame:self.collectionView.frame]; 
    
    self.collectionView.backgroundView = tempImageView;
    self.collectionView.rowSpacing = 10.0f;
    self.collectionView.scrollView.contentInset = UIEdgeInsetsMake(10.0,0.0,0.0,0.0);
    
    self.collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    
    defaults = [NSUserDefaults standardUserDefaults];
    if(_userID == nil){
        _userID = [defaults objectForKey:@"userid"];
        [self loadItems];
        [self loadUser];
    }
    
    
    
}

- (void)viewDidUnload
{
    self.userID = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
    if (_user != NULL) {
        return 2;
    }else {
        return 0;
    }
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return [_items count];
    }
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
	static NSString *myProfileItemTileIdentifier = @"ProfileItemTileID";
    static NSString *myProfileCardIdentifier = @"ProfileCardID";
    
    if (indexPath.section == 0) {
        SSCollectionViewItem *cell1 = [aCollectionView dequeueReusableItemWithIdentifier:myProfileCardIdentifier];
        
        if (cell1 == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"profileViewPersonCard" owner:self options:nil];
            cell1 = _profileCardTile;
            self.profileCardTile = nil;
        }
        
        UIButton* followButton;
        followButton = (UIButton*)[cell1 viewWithTag:7];
        [followButton setTitle:[NSString stringWithFormat:@"Follow %@",[_user firstName]] forState:UIControlStateNormal];
        
        // configure custom data
        if ([_userID isEqualToNumber:[defaults objectForKey:@"userid"]]) {
            [followButton setHidden:YES];
        }else {
            [followButton setHidden:NO];
        }
        
        UIImageView* userImage;
        UILabel* userLabel;
        
        userImage = (UIImageView*)[cell1 viewWithTag:1];
        [userImage setImageWithURL:[NSURL URLWithString:[_user userProfileImageUrl]]];
        
        userLabel = (UILabel*)[cell1 viewWithTag:2];    //Name
        userLabel.text = [NSString stringWithFormat:@"%@ %@",[_user firstName],[_user lastName]];
        
        userLabel = (UILabel*)[cell1 viewWithTag:3];    //username
        userLabel.text = [_user username];
        
        userLabel = (UILabel*)[cell1 viewWithTag:4];    //items
        userLabel.text = [[_user items] stringValue];
        
        userLabel = (UILabel*)[cell1 viewWithTag:5];    //followers
        userLabel.text = [[_user followers] stringValue];
        
        userLabel = (UILabel*)[cell1 viewWithTag:6];    //following
        userLabel.text = [[_user following] stringValue];
        
//        cell1.layer.shadowOpacity = 0.5;
//        cell1.layer.shadowColor = [[UIColor blackColor] CGColor];
//        cell1.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        
        return cell1;
    }
    else {
        SSCollectionViewItem *cell2 = [aCollectionView dequeueReusableItemWithIdentifier:myProfileItemTileIdentifier];
        
        if (cell2 == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"profileViewItemTile" owner:self options:nil];
            cell2 = _profileItemTile;
            self.profileItemTile = nil;
        }
        
        UIImageView *itemImage;
        UILabel *itemLabel;
        
        itemImage = (UIImageView *)[cell2 viewWithTag:1];
        [itemImage setImageWithURL:[NSURL URLWithString:[[_items objectAtIndex:indexPath.row] itemPhotoUrl]]];
        
        itemLabel = (UILabel *)[cell2 viewWithTag:2]; //description
        [itemLabel setText:[[_items objectAtIndex:indexPath.row] itemDescription]];
        
        itemLabel = (UILabel *)[cell2 viewWithTag:3]; //venue
        [itemLabel setText:[[_items objectAtIndex:indexPath.row] venueName_En]];
        
        itemLabel = (UILabel *)[cell2 viewWithTag:4]; //price
        [itemLabel setText:[NSString stringWithFormat:@"%d %@",
                            [[[_items objectAtIndex:indexPath.row] itemPrice] integerValue],
                            [[_items objectAtIndex:indexPath.row] countryCurrencyShortName]                  
                            ]];
        
//        cell2.layer.shadowOpacity = 0.5;
//        cell2.layer.shadowColor = [[UIColor blackColor] CGColor];
//        cell2.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        
        return cell2;
    }
    
}


- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
	SSLabel *header = [[SSLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.0f)];
	header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //	header.text = [NSString stringWithFormat:@"Section %i", section + 1];
	header.textEdgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
	header.shadowColor = [UIColor whiteColor];
	header.shadowOffset = CGSizeMake(0.0f, 1.0f);
	header.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
	return header;
}


#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
    if (section == 0) {
        if ([_userID isEqualToNumber:[defaults objectForKey:@"userid"]]) {
            return CGSizeMake(300.0f, 95.0f);
        }else {
            return CGSizeMake(300.0f, 138.0f);
        }
        
    }else{
        return CGSizeMake(145.0f, 184.0f);
    }
	
}

- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1){
        _selectedRowIndexPath = indexPath;
        [self performSegueWithIdentifier:@"ShowItemView" sender:self];
    }
    
}


- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
    if (section == 0) {
        return 0.0f;
    }else{
        return 0.0f;
    }
	
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"ShowItemView"]){
        olgotItemViewController *itemViewController = [segue destinationViewController];
        
        itemViewController.itemID = [[_items objectAtIndex:_selectedRowIndexPath.row] itemID];
        itemViewController.itemKey = [[_items objectAtIndex:_selectedRowIndexPath.row] itemKey];
    }
}


@end
