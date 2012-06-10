//
//  olgotAddItemNearbyPlacesViewController.m
//  Olgot
//
//  Created by Raed Hamam on 5/15/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import "olgotAddItemNearbyPlacesViewController.h"
#import "UIImageView+AFNetworking.h"
#import "olgotAddItemDetailsViewController.h"
#import "olgotVenue.h"

@interface olgotAddItemNearbyPlacesViewController ()

@end

@implementation olgotAddItemNearbyPlacesViewController

@synthesize capturedImage = _capturedImage, placeCell = _placeCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadVenues {
    // Load the object model via RestKit
    RKObjectManager* objectManager = [RKObjectManager sharedManager];

        NSDictionary* myParams = [NSDictionary dictionaryWithObjectsAndKeys: @"0.0", @"lat",@"0.0",@"long", nil];
        NSString* resourcePath = [@"/nearbyvenues/" appendQueryParams:myParams];
        [objectManager loadObjectsAtResourcePath:resourcePath delegate:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [tempImageView setFrame:self.collectionView.frame]; 
    
    self.collectionView.backgroundView = tempImageView;
    self.collectionView.rowSpacing = 0.0f;
    
    self.collectionView.scrollView.contentInset = UIEdgeInsetsMake(10.0,0.0,0.0,0.0);
    
    self.collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    
    [self loadVenues];
}

-(void)viewDidAppear:(BOOL)animated
{
//    [self performSegueWithIdentifier:@"ShowAddItemDetails" sender:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"Loaded actions: %@", objects);
    if([objectLoader.response isOK]){
        _places = objects;
        [self.collectionView reloadData];
    }
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Hit error: %@", error);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowAddItemDetails"]) {
        olgotAddItemDetailsViewController* itemDetailsController = [segue destinationViewController];
        
        itemDetailsController.venue = [_places objectAtIndex:_selectedRowIndexPath.row];
        itemDetailsController.itemImage = _capturedImage;
    }
}

#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
	return 1;
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
    return [_places count];
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myVenueRowIdentifier = @"venueRowCell"; 
    
        SSCollectionViewItem *cell = [aCollectionView dequeueReusableItemWithIdentifier:myVenueRowIdentifier];
        
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"nearbyViewPlaceRow" owner:self options:nil];
            cell = _placeCell;
            self.placeCell = nil;
        }
    
    UIImageView* placeImage;
    UILabel* placeLabel;
    
    placeImage = (UIImageView*)[cell viewWithTag:1];
    [placeImage setImageWithURL:[NSURL URLWithString:[[_places objectAtIndex:indexPath.row] venueIcon]]];
    
    placeLabel = (UILabel*)[cell viewWithTag:2];    //place name
    placeLabel.text = [[_places objectAtIndex:indexPath.row] name_En];
    
    placeLabel = (UILabel*)[cell viewWithTag:3];    //place name
    placeLabel.text = [[_places objectAtIndex:indexPath.row] name_En];
        
    return cell;
}


- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
	SSLabel *header = [[SSLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
	header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    header.text = [NSString stringWithFormat:@"Section %i", section + 1];
	header.textEdgeInsets = UIEdgeInsetsMake(0.0f, 19.0f, 0.0f, 19.0f);
	header.shadowColor = [UIColor whiteColor];
	header.shadowOffset = CGSizeMake(0.0f, 1.0f);
	header.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
	return header;
}


#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
    
    return CGSizeMake(300.0f, 80.0f);
    
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        _selectedRowIndexPath = indexPath;
        [self performSegueWithIdentifier:@"ShowAddItemDetails" sender:self];
    }
    
}


- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
	return 0.0f;
}



@end
