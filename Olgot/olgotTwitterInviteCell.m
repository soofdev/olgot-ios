//
//  olgotTwitterInviteCell.m
//  Olgot
//
//  Created by Raed Hamam on 9/23/12.
//  Copyright (c) 2012 Not Another Fruit. All rights reserved.
//

#import "olgotTwitterInviteCell.h"

@implementation olgotTwitterInviteCell
@synthesize userImage;
@synthesize userFullName;
@synthesize userScreenName;
@synthesize inviteUserBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
