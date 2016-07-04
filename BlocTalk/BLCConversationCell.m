//
//  BLCMessageTableViewCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationCell.h"
#import "BLCConversation.h"
#import "BLCUser.h"
#import "BLCAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <PureLayout/PureLayout.h>
#import <JSQMessage.h>


@interface BLCConversationCell()

@property (nonatomic, strong) BLCAppDelegate *appDelegate;

@property (nonatomic, strong) UIImageView *userProfilePicture;

@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) UILabel *messagePreviewLabel;

@property (nonatomic, assign) BOOL hasSetupConstraints;

@property (nonatomic, strong) UIFont *usernameFont;

@property (nonatomic, strong) UIFont *messagePreviewFont;

@end


@implementation BLCConversationCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
//    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.usernameFont = [UIFont fontWithName:@"AppleSDGothicNeo-UltraLight" size:16.5];
        self.messagePreviewFont = [UIFont fontWithName:@"AppleSDGothicNeo-UltraLight" size:12.5];
        
        [self.textLabel removeFromSuperview];
        [self.detailTextLabel removeFromSuperview];
        [self.imageView removeFromSuperview];
     
        self.userProfilePicture = [UIImageView new];
        
        self.usernameLabel = [UILabel new];
        self.messagePreviewLabel = [UILabel new];
        
        self.usernameLabel.font = self.usernameFont;
        self.messagePreviewLabel.font = self.messagePreviewFont;
        
        [self.contentView addSubview:self.userProfilePicture];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.messagePreviewLabel];
        
        //autoLayout
        CGSize cellSize = self.frame.size;
        
        [self.contentView autoSetDimension:ALDimensionWidth toSize:0.90 * cellSize.width];
        [self.contentView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
        [self.contentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
        [self.contentView autoCenterInSuperview];
        
        
        [self.userProfilePicture autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        
        [self.userProfilePicture autoSetDimension:ALDimensionWidth toSize:cellSize.width * 0.23];
        
        [self.userProfilePicture autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [self.userProfilePicture autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
        
        
        [self.usernameLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.userProfilePicture];
        [self.usernameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.userProfilePicture withOffset:10];
        
        [self.messagePreviewLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.usernameLabel withOffset:5];
        [self.messagePreviewLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.userProfilePicture withOffset:12];
        [self.messagePreviewLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
        [self.messagePreviewLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
        
        [self.messagePreviewLabel sizeToFit];
        self.messagePreviewLabel.numberOfLines = 3;
        
    }
    
    return self;
}

-(void)setupCell {
    
    if (!self.conversation.user.profilePicture) {
        self.conversation.user.profilePicture = [UIImage imageNamed:@"Landscape-Placeholder.png"];
    }
    
    self.userProfilePicture.image = self.conversation.user.profilePicture;
    
    self.usernameLabel.text = self.conversation.user.username;
    JSQMessage *mostRecentMessage = [self.conversation.messages lastObject];
    self.messagePreviewLabel.text = mostRecentMessage.text;
    
    self.contentView.backgroundColor = [UIColor whiteColor];

}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.userProfilePicture.layer.masksToBounds = YES;
    self.userProfilePicture.layer.cornerRadius = self.userProfilePicture.layer.frame.size.width/2;
}



@end
