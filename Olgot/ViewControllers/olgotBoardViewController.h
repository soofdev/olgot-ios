//
//  olgotBoardViewController.h
//  Olgot
//
//  Created by Raed Hamam on 5/11/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSToolkit.h>
#import <RestKit/RestKit.h>
#import "SSPullToRefresh.h"
#import <CoreLocation/CoreLocation.h>

@interface olgotBoardViewController : SSCollectionViewController<RKObjectLoaderDelegate, SSPullToRefreshViewDelegate,CLLocationManagerDelegate>{
    NSMutableArray* _items;
    NSIndexPath* _selectedRowIndexPath;
    
    CLLocationManager* locationManager;
    
    int _pageSize;
    int _currentPage;
    BOOL loadingNew;
    
    UIActivityIndicatorView* loadingMoreView;
}

@property (strong, nonatomic) NSNumber *categoryID;
@property (strong, nonatomic) NSString *boardName;
@property (nonatomic, strong) IBOutlet SSCollectionViewItem *itemCell;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

@end
