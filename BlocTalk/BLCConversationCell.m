//
//  BLCMessageTableViewCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationCell.h"
#import "BLCButtonSwipeView.h"
#import "BLCDataSource.h"
#import "BLCMultiPeerManager.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCConversation.h"
#import "BLCUser.h"
#import "BLCAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <PureLayout/PureLayout.h>
#import <JSQMessage.h>


@interface BLCConversationCell() <BLCMultiPeerSessionMonitorDelegate>

@property (nonatomic, strong) BLCAppDelegate *appDelegate;

@property (nonatomic, strong) BLCDataSource *dataSource;

@property (nonatomic, strong) UIFont *usernameFont;

@property (nonatomic, strong) UIFont *messagePreviewFont;

@property (nonatomic, strong) UIImageView *connectionIconImageView;

@property (nonatomic, strong) BLCButtonSwipeView *leftSwipeView;

@property (nonatomic, assign) CGPoint lastKnownTranslation;


@end


@implementation BLCConversationCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
        self.dataSource = [BLCDataSource sharedInstance];
        
        self.usernameFont = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16.5];
        self.messagePreviewFont = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12.5];
        
        self.connectionIconImageView = [[UIImageView alloc] init];
        self.connectionIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.connectionIconImageView.alpha = 0;
        
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
        
        [self.contentView addSubview:self.userProfilePicture];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.messagePreviewTextView];
        [self.contentView addSubview:self.connectionIconImageView];
        
        self.lastKnownTranslation = CGPointZero;
        self.appDelegate.mpManager.delegate = self;
        
        [self layoutCell];
        
        [self layoutSubviews];
        
    }
    
    return self;
}


-(void)setupSwipeViews {
    
    BLCButtonSwipeView *swipeViewLeft = [[BLCButtonSwipeView alloc] init];
    
    [self setSwipeEffect:YATableSwipeEffectUnmask];
    self.allowMultiple = YES;
    self.swipeContainerViewBackgroundColor = swipeViewLeft.swipeColor;
    self.leftSwipeSnapThreshold = self.bounds.size.width * 0.30;
    
    __weak BLCConversationCell *weakSelf = self;
    
    [self setSwipeBlock:^(UITableViewCell *cell, CGPoint translation){
        
        if (translation.x > 0) {
            [weakSelf.leftSwipeView didSwipeWithTranslation:translation];
        }
        
        weakSelf.lastKnownTranslation = translation;
    }];
    
    // Call the didTriggerLeftViewButtonWithIndex delegate when the left view button is triggered
    swipeViewLeft.buttonTappedActionBlock= ^(void) {
        if (weakSelf.delegate) {
            [weakSelf.delegate swipeableTableViewCell:weakSelf didTriggerLeftViewButtonWithIndex:0];
        }
    };
    
    [self setModeChangedBlock:^(UITableViewCell *cell, YATableSwipeMode mode){
        [swipeViewLeft didChangeMode:mode];
        
        if (weakSelf.lastKnownTranslation.x > self.bounds.size.width * 0.30) {
            
            if (weakSelf.delegate) {
                [weakSelf.delegate swipeableTableViewCell:weakSelf didCompleteSwipe:mode];
            }
            
        }
        
    }];


    self.leftSwipeView = swipeViewLeft;
    [self addLeftView:self.leftSwipeView];
    
}



-(void)setupCell {
    
    BLCJSQMessageWrapper *mostRecentMessage = [self.conversation.messages lastObject];
    
    self.messagePreviewTextView.text = mostRecentMessage.text;
    
    self.userProfilePicture.image = mostRecentMessage.image;
    
    if (!mostRecentMessage.image) {
        self.userProfilePicture.image = self.appDelegate.profilePicturePlaceholderImage;

    }
    
    self.usernameLabel.text = self.conversation.conversationTitle;
    
    [self setupSwipeViews];
    
    self.contentView.backgroundColor = [UIColor whiteColor];

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
    
    if (!self.conversation.isGroupConversation && [self.dataSource isPeerConnected:self.conversation.recipients.firstObject]) {
        [self animateConnectedToRecipientOfConversation];
    }
    else if (!self.conversation.isGroupConversation && ![self.dataSource isPeerConnected:self.conversation.recipients.firstObject]){
        [self animateDisconnectedFromRecipientOfConversation];
    }
    
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


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.userProfilePicture.clipsToBounds = YES;
        self.userProfilePicture.layer.masksToBounds = YES;
        self.userProfilePicture.layer.cornerRadius = self.userProfilePicture.layer.frame.size.width/2;
        
    });
    
    self.leftSwipeView.frame = self.bounds;
    
    // Make some layout adjustments to the image in the left swipe view
    BLCButtonSwipeView *leftView = (BLCButtonSwipeView *)self.leftSwipeView;
    leftView.aButton.contentHorizontalAlignment = (self.swipeEffect == YATableSwipeEffectUnmask) ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
    CGFloat leftInset = (self.swipeEffect == YATableSwipeEffectUnmask) ? 20.0 : 0;
    CGFloat rightInset = (self.swipeEffect == YATableSwipeEffectUnmask) ? 0 : 20.0;
    [leftView.aButton setImageEdgeInsets:UIEdgeInsetsMake(0, leftInset, 0, rightInset)];
    
    // Set the snap thresholds
    self.rightSwipeSnapThreshold = self.bounds.size.width * 0.3;
    self.leftSwipeSnapThreshold = self.bounds.size.width * 0.1;
    
}


-(void)layoutCell {
    
       
    CGSize cellSize = self.frame.size;

    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userProfilePicture.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.messagePreviewTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.connectionIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
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

    
    
    NSLayoutConstraint *connectionIconPositionX, *connectionIconPositionY, *connectionIconWidth, *connectionIconHeight;
    
    
    connectionIconPositionX = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeRight multiplier:1 constant:10];
    
    connectionIconPositionY = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeCenterY multiplier:0.9 constant:0];
    
    connectionIconHeight = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeHeight multiplier:0.7 constant:0];
    
    connectionIconWidth = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.connectionIconImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    [self addConstraints:@[contentViewTopBorder, contentViewBottomBorder, contentViewLeftBorder, contentViewRightBorder]];
    
    [self addConstraints:@[profilePictureTopBorder, profilePictureBottomBorder, profilePictureLeftBorder, profilePictureWidth]];
    
    [self addConstraints:@[usernameLabelTopBorder, usernameLabelLefBorder, usernameLabelHeight]];
    
    [self addConstraints:@[messagePreviewTextViewTopBorder, messagePreviewTextViewBottomBorder, messagePreviewTextViewLeftBorder, messagePreviewTextViewRightBorder]];
    
    [self addConstraints:@[connectionIconPositionX, connectionIconPositionY, connectionIconWidth, connectionIconHeight]];

}




-(void)animateConnectedToRecipientOfConversation {
    
    self.connectionIconImageView.alpha = 0;
    
    [UIView transitionWithView:self.connectionIconImageView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        self.connectionIconImageView.image = [UIImage imageNamed:@"connected_icon.png"];
        self.connectionIconImageView.alpha = 1;
        
    } completion:nil];
    
}

-(void)animateDisconnectedFromRecipientOfConversation {
    
    self.connectionIconImageView.alpha = 0;
    
    [UIView transitionWithView:self.connectionIconImageView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        self.connectionIconImageView.image = [UIImage imageNamed:@"disconnected_icon.png"];
        self.connectionIconImageView.alpha = 1;
        
    } completion:nil];
    
}


-(void)peerDidGetDisconnectedWithID:(MCPeerID *)peerID {
    
    NSLog(@"\n\nJust entering peerDidGetDisconnectedWithID method in BLCConversationCell");
    
    if ([self.dataSource doesConversationAlreadyExistForRecipients:self.conversation.recipients]) {
        NSLog(@"about to animate disconnected icon for recipients");
        [self animateDisconnectedFromRecipientOfConversation];
    }
    
}

-(void)peerDidGetConnectedWithID:(MCPeerID *)peerID {
    
    NSLog(@"Just entering peerDidGetConnectedWithID method in BLCConversationCell");
    
    if ([self.dataSource doesConversationAlreadyExistForRecipients:self.conversation.recipients]) {
        NSLog(@"about to animate connected icon for recipients");
        [self animateConnectedToRecipientOfConversation];
    }
    
}

@end
