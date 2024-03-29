//
//  olgotItemViewController.h
//  Olgot
//
//  Created by Raed Hamam on 5/14/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSToolkit.h>
#import <RestKit/RestKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "olgotAppDelegate.h"

@class olgotItem;

@protocol olgotDeleteItemProtocol;
@protocol olgotEditItemProtocol;

@interface olgotItemViewController : SSCollectionViewController<RKObjectLoaderDelegate, UITextFieldDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, olgotTwitterDelegate,olgotFacebookDelegate, olgotEditItemProtocol>{
    SSCollectionViewItem *commentsHeader;
    NSArray* _likes;
//    NSArray* _wants;
//    NSArray* _gots;
    NSArray* _comments;
    NSIndexPath* _selectedRowIndexPath;
    
    UIView* myCommentView;
    
    NSArray* accountsArray;
    
//    UIScrollView *slideShowImageViewScrollView;
    UIImageView *itemImageView;
    
    id <olgotDeleteItemProtocol> delegate;
//     id <olgotEditItemProtocol> editDelegate;
}
- (IBAction)showProfile:(id)sender;

@property (nonatomic, strong)UIView *footerView;
@property (nonatomic, retain) id <olgotDeleteItemProtocol> delegate;
//@property (nonatomic, retain) id <olgotEditItemProtocol> editDelegate;
@property (strong, nonatomic) NSNumber *itemID;
@property (strong, nonatomic) NSNumber *itemKey;
@property (nonatomic, strong) olgotItem *item;
@property (nonatomic, strong) IBOutlet SSCollectionViewItem *itemCell;
@property (nonatomic, strong) IBOutlet SSCollectionViewItem *finderCell;
@property (nonatomic, strong) IBOutlet SSCollectionViewItem *peopleRowCell;
@property (nonatomic, strong) IBOutlet SSCollectionViewItem *commentsHeader;
@property (nonatomic, strong) IBOutlet SSCollectionViewItem *commentCell;
@property (nonatomic, strong) IBOutlet SSCollectionViewItem *commentsFooter;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *wantButton;
//@property (strong, nonatomic) IBOutlet UIButton *gotButton;

@property (strong, nonatomic) IBOutlet UIImageView *mySmallImage;
//@property (strong, nonatomic) IBOutlet UITextField *myCommentTF;
@property (strong, nonatomic) IBOutlet UITextView *myCommentTA;
@property (strong, nonatomic) IBOutlet UIButton *postButton;


-(IBAction)previewItemImagePressed:(id)sender;
- (IBAction)showVenue:(id)sender;
- (IBAction)likeAction:(id)sender;
- (IBAction)wantAction:(id)sender;
//- (IBAction)gotAction:(id)sender;

- (IBAction)touchedWriteComment:(id)sender;
- (IBAction)finishedComment:(id)sender;


@end

//@protocol olgotEditItemProtocol
//
//-(void)finishedEditItem;
//
//@end

@protocol olgotDeleteItemProtocol

-(void)deletedItem;

@end
