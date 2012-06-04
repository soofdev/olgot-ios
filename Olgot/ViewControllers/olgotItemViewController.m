//
//  olgotItemViewController.m
//  Olgot
//
//  Created by Raed Hamam on 5/14/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import "olgotItemViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "olgotCommentsListViewController.h"
#import "olgotPeopleListViewController.h"
#import "olgotProfileViewController.h"
#import "olgotVenueViewController.h"
#import "olgotItem.h"
#import "olgotActionUser.h"
#import "olgotComment.h"


@interface olgotItemViewController ()

@end

@implementation olgotItemViewController
@synthesize wantButton = _wantButton;
@synthesize likeButton = _likeButton;
@synthesize gotButton = _gotButton;
@synthesize commentButton = _commentButton;

@synthesize itemCell = _itemCell, finderCell = _finderCell, peopleRowCell = _peopleRowCell,  commentsHeader, commentCell = _commentCell, commentsFooter = _commentsFooter;

@synthesize item = _item;

@synthesize itemID = _itemID, itemKey = _itemKey;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)setItem:(olgotItem *)item
//{
//    if(_item != item){
//        _item = item;
//        self.navigationItem.title = [_item itemDescription];
//        NSLog(@"item ID = %d", [[_item itemID] intValue]);
//        
//        [self loadItemData];
//    }
//}

-(void)loadItemData
{
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
//    NSDictionary* myParams = [NSDictionary dictionaryWithObjectsAndKeys: [_item itemID], @"item", [_item itemKey], @"key", nil];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* myParams = [NSDictionary dictionaryWithObjectsAndKeys: _itemID, @"item", _itemKey, @"key", [defaults objectForKey:@"userid"], @"id", nil];

    //likes
    NSString* resourcePath = @"/item/";
    [objectManager loadObjectsAtResourcePath:[resourcePath stringByAppendingQueryParameters:myParams] delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [tempImageView setFrame:self.collectionView.frame]; 
    
    self.collectionView.backgroundView = tempImageView;
    self.collectionView.rowSpacing = 0.0f;
    
    self.collectionView.scrollView.contentInset = UIEdgeInsetsMake(10.0,0.0,40.0,0.0);
    
    self.collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    
    [self loadItemData];
}


- (void)viewDidUnload
{
    [self setLikeButton:nil];
    [self setWantButton:nil];
    [self setGotButton:nil];
    [self setCommentButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"resource path: %@",[request resourcePath]);
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
    if ([request isPOST]) {  
        
        if ([response isJSON]) {
            
            if([response isOK]){
                if ([[request resourcePath] isEqual:@"/likeitem/"]) {
                    NSLog(@"succesful like");
                    [_item setILike:[NSNumber numberWithInt:1]];
                }else if ([[request resourcePath] isEqual:@"/wantitem/"]) {
                    NSLog(@"succesful want");
                    [_item setIWant:[NSNumber numberWithInt:1]];
                }else if ([[request resourcePath] isEqual:@"/gotitem/"]) {
                    NSLog(@"succesful got");
                    [_item setIGot:[NSNumber numberWithInt:1]];
                }
                NSLog(@"Got a JSON response back from our POST! %@", [response bodyAsString]);
                
                [self.collectionView reloadData];
            }else {
                
            }
        }  
        
    }else if ([request isDELETE]) {
        if ([response isJSON]) {
            
            if([response isOK]){
                id userData = [request userData];
                
                if ([userData isEqual:@"unlike"]) {
                    NSLog(@"succesful unlike");
                    [_item setILike:[NSNumber numberWithInt:0]];
                }else if ([userData isEqual:@"unwant"]) {
                    NSLog(@"succesful unwant");
                    [_item setIWant:[NSNumber numberWithInt:0]];
                }else if ([userData isEqual:@"ungot"]) {
                    NSLog(@"succesful ungot");
                    [_item setIGot:[NSNumber numberWithInt:0]];
                }
                NSLog(@"Got a JSON response back from our DELETE! %@", [response bodyAsString]);
                
                [self.collectionView reloadData];
            }else {
                
            }
        }
    }

}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"loaded item %@", objects);
    _item = [objects objectAtIndex:0];
    _comments = [_item comments];
    _likes = [_item likes];
    _wants = [_item wants];
    _gots = [_item gots];
    NSLog(@"user actions: %@ %@ %@",[_item iLike],[_item iWant],[_item iGot]);
    
    [self.collectionView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Hit error: %@", error);
}


#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
    if (_item != NULL) {
        return 8;
    }
    else {
        return 0;
    }
	
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
    if(section == 0){   //item header
        return 1;
    }
    else if (section == 1) {    //finder
        return 1;
    }
    else if (section == 2) {    //likes
        if ([[_item itemStatsLikes] intValue] > 0) {
            return 1;
        }else {
            return 0;
        }
    }
    else if (section == 3) {    //wants
        if ([[_item itemStatsWants] intValue] > 0) {
            return 1;
        }else {
            return 0;
        }
    }
    else if (section == 4) {    //gots
        if ([[_item itemStatsGots] intValue] > 0) {
            return 1;
        }else {
            return 0;
        }
    }
    else if (section == 5) {    //comments header
        if ([[_item itemStatsComments] intValue] > 0) {
            return 1;
        } else {
            return 0;
        }
    }
    else if (section == 6){ //comments
        if ([[_item itemStatsComments] intValue] > 0) {
            return 2;
        } else {
            return 0;
        }
    }
    else {  //comments footer
        if ([[_item itemStatsComments] intValue] > 0) {
            return 1;
        } else {
            return 0;
        }
    }
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *myItemTileIdentifier = @"itemViewHeaderID";
    static NSString *myFinderTileIdentifier = @"itemViewFinderID";
    static NSString *myPeopleTileIdentifier = @"itemViewPeopleRowID";
    static NSString *myCommentTileIdentifier = @"itemViewCommentRowID";
    static NSString *myCommentsFooterIdentifier = @"commentsFooter";
    
    if (indexPath.section == 0) {
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myItemTileIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewHeaderTile" owner:self options:nil];
            cell = _itemCell;
            self.itemCell = nil;
        }
        
        if ([[_item iLike] isEqual:[NSNumber numberWithInt:1]]) {
            NSLog(@"user likes this");
            [self.likeButton setImage:[UIImage imageNamed:@"icon-item-action-like-active"] forState:UIControlStateNormal];
        }else {
            [self.likeButton setImage:[UIImage imageNamed:@"icon-item-action-like"] forState:UIControlStateNormal];
        }
        
        if ([[_item iWant] isEqual:[NSNumber numberWithInt:1]]) {
            NSLog(@"user wants this");
            [self.wantButton setImage:[UIImage imageNamed:@"icon-item-action-want-active"] forState:UIControlStateNormal];
        }else {
            [self.wantButton setImage:[UIImage imageNamed:@"icon-item-action-want"] forState:UIControlStateNormal];
        }
        
        if ([[_item iGot] isEqual:[NSNumber numberWithInt:1]]) {
            NSLog(@"user got this");
            [self.gotButton setImage:[UIImage imageNamed:@"icon-item-action-got-active"] forState:UIControlStateNormal];
        }else {
            [self.gotButton setImage:[UIImage imageNamed:@"icon-item-action-got"] forState:UIControlStateNormal];
        }
        
        UIImageView* itemImage;
        UILabel* itemDescription;
        
        itemImage = (UIImageView*)[cell viewWithTag:1];
        itemDescription = (UILabel*)[cell viewWithTag:2];
        
        [itemImage setImageWithURL:[NSURL URLWithString:[_item itemPhotoUrl]]];
        [itemDescription setText:[_item itemDescription]];
        
        
        
        return cell;
    }
    else if (indexPath.section == 1) {
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myFinderTileIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewFinderTile" owner:self options:nil];
            cell = _finderCell;
            self.finderCell = nil;
        }
        
        UIImageView* finderImage;
        UILabel* finderLabel;
        UIButton* finderButton;
        
        finderImage = (UIImageView*)[cell viewWithTag:1];
        [finderImage setImageWithURL:[NSURL URLWithString:[_item userProfileImgUrl]]];
        
        finderButton = (UIButton*)[cell viewWithTag:2]; //finder name
        [finderButton setTitle:[NSString stringWithFormat:@"%@ %@",[_item userFirstName],[_item userLastName]] forState:UIControlStateNormal ];
        
        finderButton = (UIButton*)[cell viewWithTag:3]; //venue name
        [finderButton setTitle:[_item venueName_En] forState:UIControlStateNormal];
        
        finderLabel = (UILabel*)[cell viewWithTag:4]; //price
        [finderLabel setText:[NSString stringWithFormat:@"%@ %d",[_item countryCurrencyShortName],[[_item itemPrice] intValue]]];
        
        return cell;
    }
    else if (indexPath.section == 2) {  //likes
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myPeopleTileIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewPeopleRow" owner:self options:nil];
            cell = _peopleRowCell;
            self.peopleRowCell = nil;
        }
        
        UILabel* peopleLabel;
        
        peopleLabel = (UILabel*)[cell viewWithTag:1];
        [peopleLabel setText:@"Like it"];
        
        peopleLabel = (UILabel*)[cell viewWithTag:2];
        [peopleLabel setText:[NSString stringWithFormat:@"%@ people likes this",[_item itemStatsLikes]]];
        
        int x = 10;
        for (olgotActionUser *actioner in _likes) {
            UIImageView* actionerIV = [[UIImageView alloc] initWithFrame:CGRectMake(x, 25, 35, 35)];
            [actionerIV setImageWithURL:[NSURL URLWithString:[actioner userProfileImgUrl]]];
            [cell addSubview:actionerIV];
            x = x + 35 + 5;
        }
        
        return cell;
    }
    else if (indexPath.section == 3) {  //wants
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myPeopleTileIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewPeopleRow" owner:self options:nil];
            cell = _peopleRowCell;
            self.peopleRowCell = nil;
        }
        
        UILabel* peopleLabel;
        
        peopleLabel = (UILabel*)[cell viewWithTag:1];
        [peopleLabel setText:@"Want it"];
        
        peopleLabel = (UILabel*)[cell viewWithTag:2];
        [peopleLabel setText:[NSString stringWithFormat:@"%@ people want this",[_item itemStatsWants]]];
        
        int x = 10;
        for (olgotActionUser *actioner in _wants) {
            UIImageView* actionerIV = [[UIImageView alloc] initWithFrame:CGRectMake(x, 25, 35, 35)];
            [actionerIV setImageWithURL:[NSURL URLWithString:[actioner userProfileImgUrl]]];
            [cell addSubview:actionerIV];
            x = x + 35 + 5;
        }
        
        return cell;
    }
    else if (indexPath.section == 4) {  //gots
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myPeopleTileIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewPeopleRow" owner:self options:nil];
            cell = _peopleRowCell;
            self.peopleRowCell = nil;
        }
        
        UILabel* peopleLabel;
        
        peopleLabel = (UILabel*)[cell viewWithTag:1];
        [peopleLabel setText:@"Got it"];
        
        peopleLabel = (UILabel*)[cell viewWithTag:2];
        [peopleLabel setText:[NSString stringWithFormat:@"%@ people got this",[_item itemStatsGots]]];
        
        int x = 10;
        for (olgotActionUser *actioner in _gots) {
            UIImageView* actionerIV = [[UIImageView alloc] initWithFrame:CGRectMake(x, 25, 35, 35)];
            [actionerIV setImageWithURL:[NSURL URLWithString:[actioner userProfileImgUrl]]];
            [cell addSubview:actionerIV];
            x = x + 35 + 5;
        }
        
        return cell;
    }
    else if (indexPath.section == 5) {

        [[NSBundle mainBundle] loadNibNamed:@"itemViewCommentsHeader" owner:self options:nil];
        
        return commentsHeader;
    }
    else if (indexPath.section == 6) {  //comments
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myCommentTileIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewCommentRow" owner:self options:nil];
            cell = _commentCell;
            self.commentCell = nil;
        }
        
        return cell;
 
    }
    else {
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myCommentsFooterIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewCommentsFooter" owner:self options:nil];
            cell = _commentsFooter;
            self.commentsFooter = nil;
        }
        
        UILabel* footerLabel;
        
        footerLabel = (UILabel*)[cell viewWithTag:1];
        [footerLabel setText:[NSString stringWithFormat:@"See all (%d) comments",[[_item itemStatsComments] intValue]]];
        
        return cell;
    }
	
}


- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
    
    SSLabel *header = [[SSLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 30.0f)];
	header.autoresizingMask = UIViewAutoresizingNone;
    header.textEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
	header.shadowColor = [UIColor whiteColor];
	header.shadowOffset = CGSizeMake(0.0f, 0.0f);
	header.backgroundColor = [UIColor whiteColor];
    
    if (section == 5) {
        header.text = @"Comments";
    }
	
	return header;
}


#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
    if(section == 0){
        return CGSizeMake(300.0f, 370.0f);
    }
    else if (section == 1) {
        return CGSizeMake(300.0f, 44.0f);
    }
    else if (section == 2) {
        return CGSizeMake(300.0f, 85.0f);
    }
    else if (section == 3) {
        return CGSizeMake(300.0f, 85.0f);
    }
    else if (section == 4) {
        return CGSizeMake(300.0f, 85.0f);
    }
    else if (section == 5) {
        return CGSizeMake(300.0f, 30.0f);
    }
    else if (section == 6){
        return CGSizeMake(300.0f, 86.0f);
    }
    else {
        return CGSizeMake(300.0f, 44.0f);
    }
    
	
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"showLikes" sender:self];
    }
    else if (indexPath.section == 3) {
        [self performSegueWithIdentifier:@"showWants" sender:self];
    }
    else if (indexPath.section == 4) {
        [self performSegueWithIdentifier:@"showGots" sender:self];
    }
    else if (indexPath.section == 7) {
        [self performSegueWithIdentifier:@"showAllComments" sender:self];
    }
}


- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
    
    if (section == 3) {
        return 0.0f;
    }
    else{
        return 0.0f;
    }
	
}

-(void)showPopup:(NSString*)sender
{
    NSLog(@"show action popup");
    UIImageView* actionPopup;
    if ([sender isEqualToString:@"like"]) {
        if ([[_item iLike] isEqual:[NSNumber numberWithInt:1]]) {
            return;
        }
        actionPopup = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg-action-like"]];
    } else if([sender isEqualToString:@"want"]){
        if ([[_item iWant] isEqual:[NSNumber numberWithInt:1]]) {
            return;
        }
        actionPopup = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg-action-want"]];       
    } else if([sender isEqualToString:@"got"]){
        if ([[_item iGot] isEqual:[NSNumber numberWithInt:1]]) {
            return;
        }
        actionPopup = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg-action-got"]];
    }else {
        return;
    }
    
    CGRect b = self.view.bounds;
    
    actionPopup.frame = CGRectMake((b.size.width - 0) / 2, (b.size.height - 0) / 2, 0, 0);
    [self.view addSubview: actionPopup];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    actionPopup.frame = CGRectMake((b.size.width - 113) / 2, (b.size.height - 113) / 2, 113, 113);
    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.5 delay:2.0 options:UIViewAnimationCurveEaseOut animations:^{
        actionPopup.alpha = 0.0;} completion:^(BOOL finished){[actionPopup removeFromSuperview];}];
    
}

-(void)sendItemAction:(NSString*)sender
{
    NSLog(@"%@ item with id %@", sender, [_item itemID]);
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [_item itemID], @"item",
                            [defaults objectForKey:@"userid"], @"id",
                            nil];
    
    [[RKClient sharedClient] setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    if ([sender isEqualToString:@"like"]) {
        if ([[_item iLike] isEqual:[NSNumber numberWithInt:1]]) {
            [[[RKClient sharedClient] delete:[@"/likeitem/" stringByAppendingQueryParameters:params] delegate:self] setUserData:@"unlike"];
        }else {
            [[RKClient sharedClient] post:@"/likeitem/" params:params delegate:self];
        }
        
    } else if([sender isEqualToString:@"want"]){
        if ([[_item iWant] isEqual:[NSNumber numberWithInt:1]]) {
            [[[RKClient sharedClient] delete:[@"/wantitem/" stringByAppendingQueryParameters:params] delegate:self]  setUserData:@"unwant"];
        }else {
            [[RKClient sharedClient] post:@"/wantitem/" params:params delegate:self];
        }
    } else if([sender isEqualToString:@"got"]){
        if ([[_item iGot] isEqual:[NSNumber numberWithInt:1]]) {
            [[[RKClient sharedClient] delete:[@"/gotitem/" stringByAppendingQueryParameters:params] delegate:self]  setUserData:@"ungot"];
        }else {
            [[RKClient sharedClient] post:@"/gotitem/" params:params delegate:self];
        }
    }else {
        return;
    }
    
}

- (IBAction)showVenue:(id)sender {
    [self performSegueWithIdentifier:@"showVenue" sender:self];
    
}

- (IBAction)likeAction:(id)sender {
    [self performSelector:@selector(showPopup:) withObject:@"like"];
    [self performSelector:@selector(sendItemAction:) withObject:@"like"];
}

- (IBAction)wantAction:(id)sender {
    [self performSelector:@selector(showPopup:) withObject:@"want"];
    [self performSelector:@selector(sendItemAction:) withObject:@"want"];
}

- (IBAction)gotAction:(id)sender {
    [self performSelector:@selector(showPopup:) withObject:@"got"];
    [self performSelector:@selector(sendItemAction:) withObject:@"got"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAllComments"]) {
        olgotCommentsListViewController *commentsViewController = [segue destinationViewController];
        
        commentsViewController.commentsNumber = [_item itemStatsComments];
        commentsViewController.itemID = [_item itemID];        
        
    }else if ([[segue identifier] isEqualToString:@"showLikes"]) {
        olgotPeopleListViewController *peopleViewController = [segue destinationViewController];
        
        peopleViewController.actionStats = [_item itemStatsLikes];
        peopleViewController.actionName = @"Likes";
        peopleViewController.itemID = [_item itemID];
    }
    else if ([[segue identifier] isEqualToString:@"showWants"]) {
       olgotPeopleListViewController *peopleViewController = [segue destinationViewController];
        
        peopleViewController.actionStats = [_item itemStatsWants];
        peopleViewController.actionName = @"Wants";
        peopleViewController.itemID = [_item itemID];
        
    }
    else if ([[segue identifier] isEqualToString:@"showGots"]) {
        olgotPeopleListViewController *peopleViewController = [segue destinationViewController];
        
        peopleViewController.actionStats = [_item itemStatsGots];
        peopleViewController.actionName = @"Gots";
        peopleViewController.itemID = [_item itemID];
    }
    else if ([[segue identifier] isEqualToString:@"showProfile"]) {
        olgotProfileViewController *profileViewController = [segue destinationViewController];
        
        profileViewController.userID = [_item userID];
    }
    else if ([[segue identifier] isEqualToString:@"showVenue"]) {
        olgotVenueViewController *venueViewController = [segue destinationViewController];
        
        venueViewController.venueId = [_item venueId];
        venueViewController.navigationItem.title = [_item venueName_En];
    }
}

- (IBAction)showProfile:(id)sender {
    [self performSegueWithIdentifier:@"showProfile" sender:self];
}
@end
