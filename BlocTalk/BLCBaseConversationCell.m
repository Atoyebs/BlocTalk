//
//  BLCBaseConversationCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 27/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCBaseConversationCell.h"
#import "BLCConversationCell.h"
#import "BLCDataSource.h"
#import "BLCMultiPeerManager.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCConversation.h"
#import "BLCUser.h"
#import "BLCAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <PureLayout/PureLayout.h>
#import <JSQMessage.h>

@interface BLCBaseConversationCell()

@property (nonatomic, strong) BLCAppDelegate *appDelegate;

@property (nonatomic, strong) BLCDataSource *dataSource;

@property (nonatomic, strong) UIFont *usernameFont;

@property (nonatomic, strong) UIFont *messagePreviewFont;

@property (nonatomic, assign) BOOL constraintsAreSetup;


@end


@implementation BLCBaseConversationCell

@synthesize dataSource = _dataSource;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.constraintsAreSetup = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
        self.dataSource = [BLCDataSource sharedInstance];
        
        self.usernameFont = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16.5];
        self.messagePreviewFont = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12.5];
        
        [self.textLabel removeFromSuperview];
        [self.detailTextLabel removeFromSuperview];
        [self.imageView removeFromSuperview];
        
        self.userProfilePicture = [UIImageView new];
        
        self.usernameLabel = [UILabel new];
        self.messagePreviewTextView = [UITextView new];
        
        self.messagePreviewTextView.scrollEnabled = NO;
        self.messagePreviewTextView.editable = NO;
        self.messagePreviewTextView.selectable = NO;
        self.messagePreviewTextView.userInteractionEnabled = NO;
        
        self.messagePreviewTextView.textAlignment = NSTextAlignmentLeft;
        
        self.usernameLabel.font = self.usernameFont;
        self.messagePreviewTextView.font = self.messagePreviewFont;
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.userProfilePicture.translatesAutoresizingMaskIntoConstraints = NO;
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.messagePreviewTextView.translatesAutoresizingMaskIntoConstraints = NO;

        
        [self.contentView addSubview:self.userProfilePicture];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.messagePreviewTextView];
        
        [self layoutSubviews];

        
    }
    
    return self;
}


-(void)setupCell {
    
    BLCJSQMessageWrapper *mostRecentMessage = [self.conversation.messages lastObject];
    
    self.messagePreviewTextView.text = mostRecentMessage.text;
    
    self.userProfilePicture.image = mostRecentMessage.image;
    
    if (!mostRecentMessage.image) {
        self.userProfilePicture.image = self.appDelegate.profilePicturePlaceholderImage;
        
    }
    
    self.usernameLabel.text = self.conversation.conversationTitle;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
}


-(void)updateConversationCellWithProfilePictureFromUser:(BLCUser *)user {
    
    BLCJSQMessageWrapper *mostRecentMessage = [self.conversation.messages lastObject];
    
    if (user) {
        self.userProfilePicture.image = user.profilePicture;
    }
    else {
        self.userProfilePicture.image = self.appDelegate.profilePicturePlaceholderImage;
    }
    
    self.messagePreviewTextView.text = mostRecentMessage.text;
    
}


-(void)updateConversationCell {
    
    BLCJSQMessageWrapper *mostRecentMessage = [self.conversation.messages lastObject];
    self.messagePreviewTextView.text = mostRecentMessage.text;
    
    
    if (!self.conversation.isGroupConversation) {
        
        MCPeerID *peerID = (MCPeerID *)self.conversation.recipients.firstObject;
        
        UIImage *imageToUse = [self.dataSource findImageForPeerDisplayName:peerID.displayName];
        
        self.userProfilePicture.image = self.appDelegate.profilePicturePlaceholderImage;
        
        if (imageToUse) {
            self.userProfilePicture.image = imageToUse;
        }
        
    }
        
}



-(void)layoutCell {
    
    
    CGSize cellSize = self.frame.size;
    
    
    if (!self.constraintsAreSetup) {
        
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
        
        
        NSLayoutConstraint *usernameLabelTopBorder, *usernameLabelLefBorder, *usernameLabelHeight;
        
        usernameLabelTopBorder = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userProfilePicture attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        usernameLabelLefBorder = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userProfilePicture attribute:NSLayoutAttributeRight multiplier:1 constant:12];
        
        usernameLabelHeight = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.25 constant:0];
        
        
        
        NSLayoutConstraint *messagePreviewTextViewTopBorder, *messagePreviewTextViewLeftBorder, *messagePreviewTextViewBottomBorder, *messagePreviewTextViewRightBorder;
        
        messagePreviewTextViewTopBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        messagePreviewTextViewLeftBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:-3];
        
        messagePreviewTextViewBottomBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-5];
        
        messagePreviewTextViewRightBorder = [NSLayoutConstraint constraintWithItem:self.messagePreviewTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-(cellSize.width * 0.1)];
        
        
        
        [self addConstraints:@[contentViewTopBorder, contentViewBottomBorder, contentViewLeftBorder, contentViewRightBorder]];
     
        [self.contentView addConstraints:@[profilePictureTopBorder, profilePictureBottomBorder, profilePictureLeftBorder, profilePictureWidth]];
        
        [self.contentView addConstraints:@[usernameLabelTopBorder, usernameLabelLefBorder, usernameLabelHeight]];
        
        [self.contentView addConstraints:@[messagePreviewTextViewTopBorder, messagePreviewTextViewBottomBorder, messagePreviewTextViewLeftBorder, messagePreviewTextViewRightBorder]];
        
        self.constraintsAreSetup = YES;
        
    }
    
}


-(void)layoutSubviews {
    
        [super layoutSubviews];
        
        self.userProfilePicture.clipsToBounds = YES;
        self.userProfilePicture.layer.masksToBounds = YES;
        self.userProfilePicture.layer.cornerRadius = self.userProfilePicture.layer.frame.size.width/2;
        
        [self layoutCell];
    
}




@end
