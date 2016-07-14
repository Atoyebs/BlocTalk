//
//  BLCMessageTableViewCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationCell.h"
#import "BLCMessageData.h"
#import "BLCConversation.h"
#import "BLCUser.h"
#import "BLCAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <PureLayout/PureLayout.h>
#import <JSQMessage.h>


@interface BLCConversationCell()

@property (nonatomic, strong) BLCAppDelegate *appDelegate;

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
        
        self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
        
        self.usernameFont = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16.5];
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
        
        [self layoutCell];
        
        [self setNeedsLayout];
        
    }
    
    return self;
}



-(void)setupCell {
    
    BLCMessageData *mostRecentMessage = [self.conversation.messages lastObject];
    
    self.messagePreviewLabel.text = mostRecentMessage.text;
    
    self.userProfilePicture.image = mostRecentMessage.image;
    
    if (!mostRecentMessage.image) {
        self.userProfilePicture.image = [UIImage imageNamed:@"profile-placeholder.jpg"];

    }
    
    self.usernameLabel.text = self.conversation.conversationTitle;
    
    self.contentView.backgroundColor = [UIColor whiteColor];

}


-(void)updateConversationCell {

    BLCMessageData *mostRecentMessage = [self.conversation.messages lastObject];
    self.messagePreviewLabel.text = mostRecentMessage.text;
    
    if (![mostRecentMessage.senderId isEqualToString:[[UIDevice currentDevice]identifierForVendor].UUIDString]) {
        self.userProfilePicture.image = mostRecentMessage.image;
    }
    
}


-(void)updateConversationCellWithProfilePictureFromUser:(BLCUser *)user {
    
    if (user) {
        self.userProfilePicture.image = user.profilePicture;
    }
    else {
        self.userProfilePicture.image = [UIImage imageNamed:@"profile-placeholder.jpg"];
    }
    
}


-(void)layoutSubviews {
    
    [super layoutSubviews];

    self.userProfilePicture.clipsToBounds = YES;
    self.userProfilePicture.layer.masksToBounds = YES;
    self.userProfilePicture.layer.cornerRadius = self.userProfilePicture.layer.frame.size.width/2;
    
}


-(void)layoutCell {
    
       
    CGSize cellSize = self.frame.size;


    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userProfilePicture.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.messagePreviewLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *contentViewLeftBorder, *contentViewRightBorder, *contentViewTopBorder, *contentViewBottomBorder;
    
    contentViewLeftBorder = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:(cellSize.width * 0.04)];
    
    contentViewRightBorder = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-(cellSize.width * 0.04)];
    
    contentViewTopBorder = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    contentViewBottomBorder = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    
    NSLayoutConstraint *profilePictureLeftBorder, *profilePictureTopBorder, *profilePictureBottomBorder, *profilePictureWidth;
    
    profilePictureLeftBorder = [NSLayoutConstraint constraintWithItem:self.userProfilePicture attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
    
    profilePictureWidth = [NSLayoutConstraint constraintWithItem:self.userProfilePicture attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:cellSize.width * 0.23];
    
    profilePictureTopBorder = [NSLayoutConstraint constraintWithItem:self.userProfilePicture attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:10];
    
    profilePictureBottomBorder = [NSLayoutConstraint constraintWithItem:self.userProfilePicture attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
    
    
    NSLayoutConstraint *usernameLabelTopBorder, *usernameLabelLefBorder;
    
    usernameLabelTopBorder = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userProfilePicture attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    usernameLabelLefBorder = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userProfilePicture attribute:NSLayoutAttributeRight multiplier:1 constant:10];
    
    
    NSLayoutConstraint *messagePreviewLabelTopBorder, *messagePreviewLabelLeftBorder, *messagePreviewLabelBottomBorder, *messagePreviewLabelRightBorder;
    
    
    messagePreviewLabelTopBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:5];
    
    messagePreviewLabelLeftBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userProfilePicture attribute:NSLayoutAttributeRight multiplier:1 constant:12];
    
    messagePreviewLabelBottomBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-5];
    
    messagePreviewLabelRightBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-(cellSize.width * 0.1)];
    
    
    [self.messagePreviewLabel sizeToFit];
    self.messagePreviewLabel.numberOfLines = 0;
    
    
    [self addConstraints:@[contentViewTopBorder, contentViewBottomBorder, contentViewLeftBorder, contentViewRightBorder]];
    
    [self addConstraints:@[profilePictureTopBorder, profilePictureBottomBorder, profilePictureLeftBorder, profilePictureWidth]];
    
    [self addConstraints:@[usernameLabelTopBorder, usernameLabelLefBorder]];
    
    [self addConstraints:@[messagePreviewLabelTopBorder, messagePreviewLabelBottomBorder, messagePreviewLabelLeftBorder, messagePreviewLabelRightBorder]];

}


/*
 [self.contentView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:cellSize.width * 0.04];
 [self.contentView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:cellSize.width * 0.04];
 
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
 [self.messagePreviewLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:(cellSize.width * 0.1)];
 
 */



@end
