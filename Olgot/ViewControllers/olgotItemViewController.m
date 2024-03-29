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
#import "DejalActivityView.h"
#import "olgotProtocols.h"
#import "PreviewItemImageViewController.h"
#import "olgotEditItemViewController.h"
#import <FacebookSDK/FBRequest.h>



@interface olgotItemViewController ()

@end

@implementation olgotItemViewController
@synthesize wantButton = _wantButton;
@synthesize likeButton = _likeButton;
//@synthesize gotButton = _gotButton;
@synthesize mySmallImage = _mySmallImage;
//@synthesize myCommentTF = _myCommentTF;
@synthesize myCommentTA = _myCommentTA;
@synthesize postButton = _postButton;
@synthesize footerView = _footerView;

@synthesize delegate;
//@synthesize editDelegate;

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

-(void)finishedEditItem
{
    NSLog(@"OlgotItemViewController ->  finishedEditItem");
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissModalViewControllerAnimated:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self loadItemData];
}
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
//-(void)viewWillAppear:(BOOL)animated
//{
//    [self loadItemData];
//    [super viewWillAppear:animated];
//}

-(void)gestureTapped
{
//    NSLog(@"self.myCommentTA.text.length = %f", self.myCommentTA.text.length);
//    if(self.myCommentTA.text && ![self.myCommentTA.text isEqualToString:@"comment..."] && self.myCommentTA.text.length > 0.0)
//    {
//        [self postPressed:nil];
//    }
//    else
        [self dismissKeyboard];
}
-(void)dismissKeyboard {
    //    [self.myCommentTF resignFirstResponder];
    [self.myCommentTA setText:@"comment..."];
    [self.myCommentTA setTextColor:[UIColor lightGrayColor]];
    [self.postButton setEnabled:NO];
    
    [self.myCommentTA resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    //    myCommentView.frame = CGRectMake(0, 378, 320, 40);
    myCommentView.frame = CGRectMake(0, self.view.frame.size.height-50, 320, 50);
    self.myCommentTA.frame = CGRectMake(self.myCommentTA.frame.origin.x, 8.0f, self.myCommentTA.frame.size.width, 34.0f);

    [UIView commitAnimations];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [tempImageView setFrame:self.collectionView.frame];
    
    self.collectionView.backgroundView = tempImageView;
    self.collectionView.rowSpacing = 0.0f;
    
    self.collectionView.scrollView.contentInset = UIEdgeInsetsMake(10.0,0.0,50.0,0.0);
    
    self.collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    
    //    Share button
    UIImage *shareImage30 = [UIImage imageNamed:@"btn-share"];
    
    UIButton *shareBtn = [[UIButton alloc] init];
    shareBtn.frame=CGRectMake(0,0,35,30);
    [shareBtn setBackgroundImage:shareImage30 forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(displayShareActionSheet) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    myCommentView = [[[NSBundle mainBundle] loadNibNamed:@"itemViewWriteCommentView" owner:self options:nil] objectAtIndex:0];
    
    myCommentView.frame = CGRectMake(0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-50, self.view.frame.size.width, 50);
    

    self.myCommentTA.clipsToBounds = YES;
    self.myCommentTA.layer.cornerRadius = 5.0f;
    [self.myCommentTA.layer setBorderColor:[[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.myCommentTA.layer setBorderWidth:1.0];
    
    self.postButton.clipsToBounds = YES;
    self.postButton.layer.cornerRadius = 10.0f;
//    [self.postButton.layer setBorderColor:[[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor]];
//    [self.postButton.layer setBorderWidth:1.0];

    
    
    [self.mySmallImage setImageWithURL:[NSURL URLWithString:[defaults objectForKey:@"userProfileImageUrl"]]];
    [self.view addSubview:myCommentView];
    
    [self.postButton addTarget:self action:@selector(postPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.postButton setEnabled:NO];
    
    UITapGestureRecognizer *postButtonGestures = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(postPressed:)];
    
    [postButtonGestures setCancelsTouchesInView:NO];
    [self.postButton addGestureRecognizer:postButtonGestures];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(gestureTapped)];
    
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    
    
    
    [self loadItemData];
}

-(IBAction)postPressed:(id)sender
{
    [self finishedComment:nil];
}

-(void)addEditItemButton
{
    if(!self.footerView)
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 108.0f)];
    
    UIButton* editButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 44.0f)];
    
    [editButton setTitle:@"Edit item" forState:UIControlStateNormal];
    
    [editButton setBackgroundImage:[UIImage imageNamed:@"btn-select-username"] forState:UIControlStateNormal];
    
    [editButton addTarget:self action:@selector(editItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.footerView addSubview:editButton];
    
    [self.collectionView setCollectionFooterView:self.footerView];
}

-(void)addDeleteItemButton
{
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 54.0f)];
    
    UIButton* deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 62.0f, 300.0f, 44.0f)];
    
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"btn-select-username"] forState:UIControlStateNormal];
    
    [deleteButton addTarget:self action:@selector(confirmDeleteItem) forControlEvents:UIControlEventTouchUpInside];
    
    [self.footerView addSubview:deleteButton];
    
    [self.collectionView setCollectionFooterView:self.footerView];
}

-(void)tweetItem
{
    // Initialize Tweet Compose View Controller
    TWTweetComposeViewController *vc = [[TWTweetComposeViewController alloc] init];
    // Settin The Initial Text
    //    [vc setInitialText:[NSString stringWithFormat:@"I just found this item at %@ using Olgot %@ %@", [_item venueName_En], [_item userTwitterName], [_item venueTwitterName]]];
    
    [vc setInitialText:[NSString stringWithFormat:@"Love this at %@ %@. Posted on #Olgot by %@", [_item venueName_En], [_item venueTwitterName], [_item userTwitterName] ]];
    
    // Adding an Image
    //    UIImage *image = [(UIImageView*)[self.itemCell viewWithTag:1] image];
    NSURL *imageURL = [NSURL URLWithString:[_item itemPhotoUrl]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    [vc addImage:image];
    
    // Adding a URL
    NSURL *url = [NSURL URLWithString:[_item itemUrl]];
    [vc addURL:url];
    
    // Setting a Completing Handler
    [vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        [self dismissModalViewControllerAnimated:YES];
    }];
    // Display Tweet Compose View Controller Modally
    [self presentViewController:vc animated:YES completion:nil];
}

//-(void)dismissKeyboard {
//    [self.myCommentTF resignFirstResponder];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
////    myCommentView.frame = CGRectMake(0, 378, 320, 40);
//     myCommentView.frame = CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50);
//    [UIView commitAnimations];
//}

- (void)viewDidUnload
{
    [self setLikeButton:nil];
    [self setWantButton:nil];
    //    [self setGotButton:nil];
    [self setMySmallImage:nil];
//    [self setMyCommentTF:nil];
    [self setMyCommentTA:nil];
    [self setPostButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[[RKObjectManager sharedManager] requestQueue] cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"resource path: %@",[request resourcePath]);
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
    
    id userData = [request userData];
    
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
                else if ([[request resourcePath] isEqual:@"/comment/"]) {
                    NSLog(@"succesful got");
                    [self loadItemData];
                }
                NSLog(@"Got a JSON response back from our POST! %@", [response bodyAsString]);
                
                [self.collectionView reloadData];
            }else {
                
            }
        }
        
    }else if ([request isDELETE]) {
        if ([response isJSON]) {
            
            if([response isOK]){
                
                
                if ([userData isEqual:@"unlike"]) {
                    NSLog(@"succesful unlike");
                    [_item setILike:[NSNumber numberWithInt:0]];
                }else if ([userData isEqual:@"unwant"]) {
                    NSLog(@"succesful unwant");
                    [_item setIWant:[NSNumber numberWithInt:0]];
                }else if ([userData isEqual:@"ungot"]) {
                    NSLog(@"succesful ungot");
                    [_item setIGot:[NSNumber numberWithInt:0]];
                }else if ([userData isEqual:@"deleteitem"]){
                    if (self.delegate) {
                        [self.delegate deletedItem];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                NSLog(@"Got a JSON response back from our DELETE! %@", [response bodyAsString]);
                
                [self.collectionView reloadData];
            }else {
                if ([userData isEqual:@"deleteitem"]){
                    [self showAlertWithErrorTitle:@"Oops!" message:@"Failed to delete Item"];
                }
            }
        }else{
            if ([userData isEqual:@"deleteitem"]){
                [self showAlertWithErrorTitle:@"Oops!" message:@"Failed to delete Item"];
            }
        }
    }
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"loaded item %@", objects);
    _item = [objects objectAtIndex:0];
    //    _item.itemName = @"belalal";
    _comments = [_item comments];
    _likes = [_item likes];
    //    _wants = [_item wants];
    //    _gots = [_item gots];
    NSLog(@"user actions: %@",[_item iLike]);//,[_item iWant],[_item iGot]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[_item userID] isEqual:[defaults objectForKey:@"userid"]]) {
        NSLog(@"Item Owner");
        [self addEditItemButton];
        [self addDeleteItemButton];
        
    } else {
        NSLog(@"Item Visitor");
    }
    
    self.navigationItem.title = [_item itemName];
    [self.collectionView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    //    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    
    NSLog(@"Hit error: %@", error);
}

#pragma mark -

-(void)showAlertWithErrorTitle:(NSString*)title message:(NSString*)message{
    UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok.." otherButtonTitles:nil, nil];
    
    [errAlert show];
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
        //        if ([[_item itemStatsWants] intValue] > 0) {
        //            return 1;
        //        }else {
        return 0;
        //        }
    }
    else if (section == 4) {    //gots
        //        if ([[_item itemStatsGots] intValue] > 0) {
        //            return 1;
        //        }else {
        return 0;
        //        }
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
            return [_comments count];
        } else {
            return 0;
        }
    }
    else {  //comments footer
        if ([[_item itemStatsComments] intValue] > 3) {
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
//    NSInteger ii = indexPath.section;
//    NSLog(@"dasdas %d",ii);
    if (indexPath.section == 1) {
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
        //
        //        if ([[_item iGot] isEqual:[NSNumber numberWithInt:1]]) {
        //            NSLog(@"user got this");
        //            [self.gotButton setImage:[UIImage imageNamed:@"icon-item-action-got-active"] forState:UIControlStateNormal];
        //        }else {
        //            [self.gotButton setImage:[UIImage imageNamed:@"icon-item-action-got"] forState:UIControlStateNormal];
        //        }
        

        
//        UILabel* itemDateLabel;
        UILabel* itemDescription;
        UILabel* itemPriceLabel;
        UIView *priceView;
        UIImageView *priceTagImage;
        
        itemImageView = (UIImageView*)[cell viewWithTag:1];
        itemDescription = (UILabel*)[cell viewWithTag:2];
//        itemDateLabel = (UILabel*)[cell viewWithTag:5];
        priceView = (UIView*)[cell viewWithTag:77];
        priceTagImage = (UIImageView*)[priceView viewWithTag:66];
        
        [itemImageView setImageWithURL:[NSURL URLWithString:[_item itemPhotoUrl]]];
        [itemDescription setText:[_item itemDescription]];
    
        
        itemPriceLabel = (UILabel*)[priceView viewWithTag:33]; //price
        NSString *priceStr = [_item itemPrice];//[[_item itemPrice] stringByAppendingString:@"hi man how are you babykjkn are you good or not"];
        //        if ([[_item itemPrice] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        if (!priceStr || [priceStr isEqualToString:@""]) {
            [priceView setHidden:YES];
            //            priceStr = @" Make me an offer! ";
        }
        else{
            priceStr = [NSString stringWithFormat:@"  %@  ",priceStr];//,[_item countryCurrencyShortName]];
            [priceView setHidden:NO];
            [itemPriceLabel setText:priceStr ];
        }
        
        CGRect priceLabelFrame = itemPriceLabel.frame;
        CGRect priceViewFrame = priceView.frame;
       
        CGSize textSize = [[itemPriceLabel text] sizeWithFont:[itemPriceLabel font]];
        CGFloat newWidth = textSize.width;
        
        priceViewFrame.size.width = newWidth + 6 + priceTagImage.frame.size.width;
        priceViewFrame.origin.x = itemImageView.frame.origin.x+itemImageView.frame.size.width - 10 - priceViewFrame.size.width;
        [priceView setFrame:priceViewFrame];
        
        priceLabelFrame.size.width = newWidth;
        [itemPriceLabel setFrame:priceLabelFrame];
        
if(priceViewFrame.size.width > itemImageView.frame.size.width-20)
{
    priceViewFrame.size.width = itemImageView.frame.size.width - 20;
    priceViewFrame.origin.x = itemImageView.frame.origin.x + 10;
    [priceView setFrame:priceViewFrame];
    
   
    priceLabelFrame.size.width = priceViewFrame.size.width - priceTagImage.frame.size.width - 6;
    [itemPriceLabel setFrame:priceLabelFrame];
     [itemPriceLabel sizeToFit];
    
    priceLabelFrame = itemPriceLabel.frame;
    if(priceViewFrame.size.height > priceViewFrame.size.height-10)
    {
        priceViewFrame.size.height = priceLabelFrame.size.height + 10;
        priceViewFrame.origin.y = (itemImageView.frame.origin.y+itemImageView.frame.size.height)- 10 - priceViewFrame.size.height;
        [priceView setFrame:priceViewFrame];
        
        //re-centering the price tag image vertically
        priceTagImage.frame = CGRectMake(3, (priceViewFrame.size.height-priceTagImage.frame.size.height)/2, priceTagImage.frame.size.width, priceTagImage.frame.size.height);
        
        
        //recalculating the priceview width;
        priceViewFrame = priceView.frame;
        priceViewFrame.size.width = itemImageView.frame.size.width-20;//priceLabelFrame.size.width + priceTagImage.frame.size.width + 6;
        priceViewFrame.origin.x = 20;//itemImageView.frame.origin.x+itemImageView.frame.size.width - 10 - priceViewFrame.size.width;
        [priceView setFrame:priceViewFrame];
        
    }
    
   
    
}
    
        
//        [itemDateLabel setText:[_item itemDateNatural]];
        
        return cell;
    }
    else if (indexPath.section == 0) {
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myFinderTileIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"itemViewFinderTile" owner:self options:nil];
            cell = _finderCell;
            self.finderCell = nil;
        }
        
        UIImageView* finderImage;
        UILabel *finderPublishDateLabel;
        UIButton* finderButton;
        
        finderImage = (UIImageView*)[cell viewWithTag:1];
        [finderImage setImageWithURL:[NSURL URLWithString:[_item userProfileImgUrl]]];
        
        finderButton = (UIButton*)[cell viewWithTag:2]; //finder name
        [finderButton setTitle:[NSString stringWithFormat:@"%@ %@",[_item userFirstName],[_item userLastName]] forState:UIControlStateNormal ];
        
        finderButton = (UIButton*)[cell viewWithTag:3]; //venue name
        [finderButton setTitle:[_item venueName_En] forState:UIControlStateNormal];
        
        finderImage.layer.cornerRadius = 4;
        finderImage.clipsToBounds = YES;
        
        finderPublishDateLabel = (UILabel*)[cell viewWithTag:5];
        [finderPublishDateLabel setText:[_item itemDateNatural]];
        
        //        finderLabel = (UILabel*)[cell viewWithTag:4]; //price
        //        [finderLabel setText:[NSString stringWithFormat:@"%@ %g",[_item countryCurrencyShortName],[[_item itemPrice] floatValue]]];
        
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
    //    else if (indexPath.section == 3) {  //wants
    //        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myPeopleTileIdentifier];
    //
    //        if (cell == nil) {
    //            [[NSBundle mainBundle] loadNibNamed:@"itemViewPeopleRow" owner:self options:nil];
    //            cell = _peopleRowCell;
    //            self.peopleRowCell = nil;
    //        }
    //
    //        UILabel* peopleLabel;
    //
    //        peopleLabel = (UILabel*)[cell viewWithTag:1];
    //        [peopleLabel setText:@"Want it"];
    //
    //        peopleLabel = (UILabel*)[cell viewWithTag:2];
    //        [peopleLabel setText:[NSString stringWithFormat:@"%@ people want this",[_item itemStatsWants]]];
    //
    //        int x = 10;
    //        for (olgotActionUser *actioner in _wants) {
    //            UIImageView* actionerIV = [[UIImageView alloc] initWithFrame:CGRectMake(x, 25, 35, 35)];
    //            [actionerIV setImageWithURL:[NSURL URLWithString:[actioner userProfileImgUrl]]];
    //            [cell addSubview:actionerIV];
    //            x = x + 35 + 5;
    //        }
    //
    //        return cell;
    //    }
    //    else if (indexPath.section == 4) {  //gots
    //        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myPeopleTileIdentifier];
    //
    //        if (cell == nil) {
    //            [[NSBundle mainBundle] loadNibNamed:@"itemViewPeopleRow" owner:self options:nil];
    //            cell = _peopleRowCell;
    //            self.peopleRowCell = nil;
    //        }
    //
    //        UILabel* peopleLabel;
    //
    //        peopleLabel = (UILabel*)[cell viewWithTag:1];
    //        [peopleLabel setText:@"Got it"];
    //
    //        peopleLabel = (UILabel*)[cell viewWithTag:2];
    //        [peopleLabel setText:[NSString stringWithFormat:@"%@ people got this",[_item itemStatsGots]]];
    //
    //        int x = 10;
    //        for (olgotActionUser *actioner in _gots) {
    //            UIImageView* actionerIV = [[UIImageView alloc] initWithFrame:CGRectMake(x, 25, 35, 35)];
    //            [actionerIV setImageWithURL:[NSURL URLWithString:[actioner userProfileImgUrl]]];
    //            [cell addSubview:actionerIV];
    //            x = x + 35 + 5;
    //        }
    //
    //        return cell;
    //    }
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
        
        UIImageView* commentImage;
        UILabel* commentLabel;
        
        commentImage = (UIImageView*)[cell viewWithTag:1];
        [commentImage setImageWithURL:
         [NSURL URLWithString:
          [[_comments objectAtIndex:indexPath.row] userProfileImgUrl]]];
        
        commentLabel = (UILabel*)[cell viewWithTag:2];  //person name
        commentLabel.text = [NSString stringWithFormat:
                             @"%@ %@",
                             [[_comments objectAtIndex:indexPath.row] userFirstName],
                             [[_comments objectAtIndex:indexPath.row] userLastName]];
        
        commentLabel = (UILabel*)[cell viewWithTag:3];  //comment time
        commentLabel.text = [[_comments objectAtIndex:indexPath.row] commentDate];
        
        commentLabel = (UILabel*)[cell viewWithTag:4];  //comment body
        commentLabel.text = [[_comments objectAtIndex:indexPath.row] body];
        
        return cell;
        
    }
    else if (indexPath.section == 7) { //comments footer
        NSLog(@"index path %d",indexPath.section);
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
    else if (indexPath.section == 8){
        
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
    if(section == 1){
        CGSize labelSize = [[_item itemDescription] sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(280.0, 9000.0) lineBreakMode:UILineBreakModeWordWrap];
        
        CGSize itemSize = CGSizeMake(300.0, labelSize.height + 370.0);
        
        return itemSize;
        
        //        return CGSizeMake(300.0f, 370.0f);
    }
    else if (section == 0) {
        return CGSizeMake(300.0f, 55.0f);
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
        //        CGSize commentSize = [[_comments objectAtIndex:indexPath.row] body]
        
        return CGSizeMake(300.0f, 70.0f);
    }
    else {
        return CGSizeMake(300.0f, 44.0f);
    }
    
	
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"showLikes" sender:self];
    }
    //    else if (indexPath.section == 3) {
    //        [self performSegueWithIdentifier:@"showWants" sender:self];
    //    }
    //    else if (indexPath.section == 4) {
    //        [self performSegueWithIdentifier:@"showGots" sender:self];
    //    }
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
            [_item setILike:[NSNumber numberWithInt:0]];
            [[[RKClient sharedClient] delete:[@"/likeitem/" stringByAppendingQueryParameters:params] delegate:nil] setUserData:@"unlike"];
        }else {
            [_item setILike:[NSNumber numberWithInt:1]];
            [[RKClient sharedClient] post:@"/likeitem/" params:params delegate:nil];
        }
        [self.collectionView reloadData];
    }
    else if([sender isEqualToString:@"want"]){
        if ([[_item iWant] isEqual:[NSNumber numberWithInt:1]]) {
            [_item setIWant:[NSNumber numberWithInt:0]];
            [[[RKClient sharedClient] delete:[@"/wantitem/" stringByAppendingQueryParameters:params] delegate:nil]  setUserData:@"unwant"];
        }else {
            [_item setIWant:[NSNumber numberWithInt:1]];
            [[RKClient sharedClient] post:@"/wantitem/" params:params delegate:nil];
        }
        [self.collectionView reloadData];
    }
    //    else if([sender isEqualToString:@"got"]){
    //        if ([[_item iGot] isEqual:[NSNumber numberWithInt:1]]) {
    //            [_item setIGot:[NSNumber numberWithInt:0]];
    //            [[[RKClient sharedClient] delete:[@"/gotitem/" stringByAppendingQueryParameters:params] delegate:nil]  setUserData:@"ungot"];
    //        }else {
    //            [_item setIGot:[NSNumber numberWithInt:1]];
    //            [[RKClient sharedClient] post:@"/gotitem/" params:params delegate:nil];
    //        }
    //        [self.collectionView reloadData];
    //    }
    else {
        return;
    }
    
}

- (IBAction)showVenue:(id)sender {
    [self performSegueWithIdentifier:@"showVenue" sender:self];
    
}

- (IBAction)likeAction:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"userid"] == nil) {
        olgotAppDelegate* appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate showSignup];
    }else{
        [self performSelector:@selector(showPopup:) withObject:@"like"];
        [self performSelector:@selector(sendItemAction:) withObject:@"like"];
    }
    
}

- (IBAction)wantAction:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"userid"] == nil) {
        olgotAppDelegate* appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate showSignup];
    }else{
        [self performSelector:@selector(showPopup:) withObject:@"want"];
        [self performSelector:@selector(sendItemAction:) withObject:@"want"];
    }
    
}
//
//- (IBAction)gotAction:(id)sender {
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:@"userid"] == nil) {
//        olgotAppDelegate* appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
//        [appDelegate showSignup];
//    }else{
//        [self performSelector:@selector(showPopup:) withObject:@"got"];
//        [self performSelector:@selector(sendItemAction:) withObject:@"got"];
//    }
//}


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.myCommentTA.text = @"";
    self.myCommentTA.textColor = [UIColor blackColor];

    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"userid"] == nil) {
        [self.myCommentTA resignFirstResponder];
        olgotAppDelegate* appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate showSignup];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        //        myCommentView.frame = CGRectMake(0, 160, 320, 40);
        myCommentView.frame = CGRectMake(0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-50-172, self.view.frame.size.width, 50);
        [UIView commitAnimations];
    }

    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if((textView.text.length == 0 || textView.text.length == 1) && [text isEqualToString:@""])
    {
        [self.postButton setEnabled:NO];
        
        CGRect myCommentViewFrame = myCommentView.frame;
        CGRect textViewFrame = textView.frame;

        myCommentViewFrame.size.height = 50;
        myCommentViewFrame.origin.y = self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-myCommentViewFrame.size.height-172;
        [myCommentView setFrame:myCommentViewFrame];
        
        textViewFrame.origin.y = 8.0f;
        textViewFrame.size.height = 34;
        textView.frame = textViewFrame;

    }
    else
    {
        [self.postButton setEnabled:YES];
        
        
        CGRect myCommentViewFrame = myCommentView.frame;
        CGRect textViewFrame = textView.frame;
        NSInteger oldH = textViewFrame.size.height;
        NSInteger newH = [textView contentSize].height;
        
        if(newH != oldH && newH <=142)//this equal to the height of 7 lines 
        {
            textViewFrame.size.height = newH;
        textView.frame = textViewFrame;

//       //reset to default size
            

            myCommentViewFrame.size.height = textView.frame.size.height + 16;
            myCommentViewFrame.origin.y = self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-myCommentViewFrame.size.height-172;
            [myCommentView setFrame:myCommentViewFrame];
            
            textViewFrame.origin.y = 8.0f;
            textView.frame = textViewFrame;
 
        }
        
           
    }
    return YES;
}

//- (IBAction)touchedWriteComment:(id)sender {
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:@"userid"] == nil) {
//        [self.myCommentTF resignFirstResponder];
//        olgotAppDelegate* appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
//        [appDelegate showSignup];
//    }else{
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
////        myCommentView.frame = CGRectMake(0, 160, 320, 40);
//         myCommentView.frame = CGRectMake(0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-50-172, self.view.frame.size.width, 50);
//        [UIView commitAnimations];
//    }
//    
//}

- (IBAction)finishedComment:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"userid"] == nil) {
        olgotAppDelegate* appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate showSignup];
        return;
    }
    NSString *commentText = self.myCommentTA.text;
    [self performSelector:@selector(dismissKeyboard)];
    NSLog(@"user finished commenting: %@", commentText);
    
//    NSString* commentBody = self.myCommentTF.text;
    NSString* commentBody = commentText;
    NSString *trimmedBody = [commentBody stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![trimmedBody isEqualToString:@""]) {
        NSLog(@"sending comment");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [_item itemID], @"item",
                                [defaults objectForKey:@"userid"], @"id",
                                commentBody, @"body",
                                nil];
        
        [[RKClient sharedClient] setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [[RKClient sharedClient] post:@"/comment/" params:params delegate:self];
    }else {
        NSLog(@"empty comment, not sending");
    }
    
//    self.myCommentTF.text = nil;
//    self.myCommentTA.text = nil;
    [self.postButton setEnabled:NO];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showEditItem"]) {
        olgotEditItemViewController *editItemViewController = [segue destinationViewController];
        
                editItemViewController.navigationItem.title = @"Edit Item";
        editItemViewController.itemToView = _item;
        editItemViewController.editDelegate = self;
    }
    if ([[segue identifier] isEqualToString:@"showAllComments"]) {
        olgotCommentsListViewController *commentsViewController = [segue destinationViewController];
        
        commentsViewController.commentsNumber = [_item itemStatsComments];
        commentsViewController.itemID = [_item itemID];
        commentsViewController.itemName = [_item itemName];
        
    }else if ([[segue identifier] isEqualToString:@"showLikes"]) {
        olgotPeopleListViewController *peopleViewController = [segue destinationViewController];
        
        peopleViewController.actionStats = [_item itemStatsLikes];
        peopleViewController.actionName = @"Likes";
        peopleViewController.itemID = [_item itemID];
        peopleViewController.itemName = [_item itemName];
    }
    //    else if ([[segue identifier] isEqualToString:@"showWants"]) {
    //       olgotPeopleListViewController *peopleViewController = [segue destinationViewController];
    //
    //        peopleViewController.actionStats = [_item itemStatsWants];
    //        peopleViewController.actionName = @"Wants";
    //        peopleViewController.itemID = [_item itemID];
    //
    //    }
    //    else if ([[segue identifier] isEqualToString:@"showGots"]) {
    //        olgotPeopleListViewController *peopleViewController = [segue destinationViewController];
    //
    //        peopleViewController.actionStats = [_item itemStatsGots];
    //        peopleViewController.actionName = @"Gots";
    //        peopleViewController.itemID = [_item itemID];
    //    }
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

-(IBAction)previewItemImagePressed:(id)sender
{
    PreviewItemImageViewController *previewScreen = [[PreviewItemImageViewController alloc] initWithNibName:@"PreviewItemImageViewController" bundle:nil];
    
    [previewScreen setItemImage:itemImageView.image];
    [previewScreen setItemTitle:[_item itemName]];
    
    [self.navigationController pushViewController:previewScreen animated:YES];
    
}

- (IBAction)showProfile:(id)sender {
    [self performSegueWithIdentifier:@"showProfile" sender:self];
}

-(void)displayShareActionSheet{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"userid"] == nil) {
        olgotAppDelegate* appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate showSignup];
    }else{
        UIActionSheet *shareAS = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter",@"Email", nil];
        
        shareAS.actionSheetStyle = UIActionSheetStyleDefault;
        [shareAS showInView:self.view];
    }
    
}

-(void)shareOnFacebook{
    //    id<olgotOgItem> itemObject = [self itemObjectForItem];
    id<olgotOgItem> itemObject = [self itemObjectForItem:@"dummy"];
    
    id<olgotOgFindItem> action = (id<olgotOgFindItem>)[FBGraphObject graphObject];
    
    action.item = itemObject;
    
    [FBSettings setLoggingBehavior:[NSSet
                                    setWithObjects:FBLoggingBehaviorFBRequests,
                                    FBLoggingBehaviorFBURLConnections,
                                    nil]];
    
    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/olgotapp:find"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
                                     [self.view setUserInteractionEnabled:YES];
                                     
                                     NSString *alertText;
                                     if (!error) {
                                         alertText = [NSString stringWithFormat:@"Posted Open Graph action, id: %@",
                                                      [result objectForKey:@"id"]];
                                         
                                         
                                     } else {
                                         alertText = [NSString stringWithFormat:@"error: domain = %@, code = %d",
                                                      error.domain, error.code];
                                     }
                                     
                                     NSLog(@"Facebook: %@",alertText);
                                     //                                     [[[UIAlertView alloc] initWithTitle:@"Result"
                                     //                                                                 message:alertText
                                     //                                                                delegate:nil
                                     //                                                       cancelButtonTitle:@"Thanks!"
                                     //                                                       otherButtonTitles:nil]
                                     //                                      show];
                                 }];
}

- (id<olgotOgItem>)itemObjectForItem:(NSString*)mItem
{
    id<olgotOgItem> result = (id<olgotOgItem>)[FBGraphObject graphObject];
    
    result.url = self.item.itemUrl;
    //    result.url = @"http://naf-lab.com/olgottesting/dummyitem.php";
    
    return result;
    
    //    // This URL is specific to this sample, and can be used to
    //    // create arbitrary OG objects for this app; your OG objects
    //    // will have URLs hosted by your server.
    //    NSString *format =
    //    @"http://naf-lab.com/olgottesting/repeater.php?"
    //    @"fb:app_id=474720479212670&og:type=%@&"
    //    @"og:title=%@&og:description=%%22%@%%22&"
    //    @"og:image=https://s-static.ak.fbcdn.net/images/devsite/attachment_blank.png&"
    //    @"body=%@";
    //
    //    // We create an FBGraphObject object, but we can treat it as
    //    // an SCOGMeal with typed properties, etc. See <FacebookSDK/FBGraphObject.h>
    //    // for more details.
    //    id<olgotOgItem> result = (id<olgotOgItem>)[FBGraphObject graphObject];
    //
    //    // Give it a URL that will echo back the name of the meal as its title,
    //    // description, and body.
    //    result.url = [NSString stringWithFormat:format,
    //                  @"olgotapp:item", mItem, mItem, mItem];
    
    //    return result;
}

-(void)showMailComposer
{
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    
    mailer.mailComposeDelegate = self;
    
    [mailer setSubject:@"Olgot"];
    
    NSString *emailBody = [NSString stringWithFormat:@"I just found this item on Olgot! %@", self.item.itemUrl];
    [mailer setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:mailer animated:YES];
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        //facebook
        if (FBSession.activeSession.state == FBSessionStateOpen) {
            // Yes, so just open the session (this won't display any UX).
            [self shareOnFacebook];
        }else{
            olgotAppDelegate* appDelegate =  (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.facebookDelegate = self;
            [appDelegate openFBSession];
        }
        
        
	} else if (buttonIndex == 1) {
        //twitter
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber* twitterAccountIndex = [defaults objectForKey:@"twitterAccountIndex"];
        
        if([TWTweetComposeViewController canSendTweet]  && twitterAccountIndex != nil){
            [self tweetItem];
        }else{
            //connect with twitter
            olgotAppDelegate *appDelegate = (olgotAppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.twitterDelegate = self;
            [appDelegate twitterConnect];
        }
        
	} else if (buttonIndex == 2) {
        //email
        if ([MFMailComposeViewController canSendMail])
        {
            [self showMailComposer];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"Your device doesn't support the composer sheet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
	} else if (buttonIndex == 3) {
        //cancel
    }
    
}

#pragma mark - MFMailComposer Delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -

-(void)confirmDeleteItem
{
    NSLog(@"delete item with id %@ key %@", [_item itemID], [_item itemKey]);
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Item"
                                                      message:@"Your are about to delete this item, this action cannot be undone."
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Delete", nil];
    [message show];
}


-(IBAction)editItemPressed:(id)sender
{
  [self performSegueWithIdentifier:@"showEditItem" sender:self];
}


-(void)deleteItem
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [_item itemID], @"item",
                            [_item itemKey], @"key",
                            [defaults objectForKey:@"userid"], @"id",
                            nil];
    
    [[RKClient sharedClient] setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [[[RKClient sharedClient] delete:[@"/item/" stringByAppendingQueryParameters:params] delegate:self] setUserData:@"deleteitem"];
    
    
}

#pragma mark uialertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
        NSLog(@"cancel");
    } else {
        NSLog(@"delete");
        [self deleteItem];
    }
}

#pragma mark olgotTwitterDelegate;

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
    [self tweetItem];
}

-(void)cancelledTwitter
{
    [DejalBezelActivityView removeView];
}


#pragma mark olgotFacebookDelegate

-(void)facebookSuccess
{
    [self shareOnFacebook];
}

-(void)facebookFailed
{
    
}

-(void)facebookCancelled{
    
}

@end
