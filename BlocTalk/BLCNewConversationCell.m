//
//  BLCNewConversationCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 27/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCNewConversationCell.h"
#import "BLCButtonSwipeView.h"
#import "BLCMultiPeerManager.h"
#import "BLCBaseConversationCellPrivateProperties.h"
#import "BLCConversation.h"

@interface BLCNewConversationCell() <BLCMultiPeerSessionMonitorDelegate>

@property (nonatomic, strong) UIImageView *connectionIconImageView;

@property (nonatomic, strong) BLCButtonSwipeView *leftSwipeView;

@property (nonatomic, assign) CGPoint lastKnownTranslation;

@end


@implementation BLCNewConversationCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.appDelegate.mpManager.delegate = self;
        
        self.connectionIconImageView = [[UIImageView alloc] init];
        self.connectionIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.connectionIconImageView.alpha = 0;
        
        self.connectionIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.connectionIconImageView];
        
    }
    
    return self;
    
}




-(void)setupSwipeViews {
    
    BLCButtonSwipeView *swipeViewLeft = [[BLCButtonSwipeView alloc] init];
    
    [self setSwipeEffect:YATableSwipeEffectUnmask];
    self.allowMultiple = YES;
    self.swipeContainerViewBackgroundColor = swipeViewLeft.swipeColor;
    self.leftSwipeSnapThreshold = self.bounds.size.width * 0.30;
    
    __weak BLCNewConversationCell *weakSelf = self;
    
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
                weakSelf.lastKnownTranslation = CGPointZero;
            }
            
        }
        
        
        
    }];
    
    
    self.leftSwipeView = swipeViewLeft;
    [self addLeftView:self.leftSwipeView];
    
}


-(void)setupCell {
    
    [super setupCell];
    
    [self setupSwipeViews];
    
}


-(void)updateConversationCell {
    
    [super updateConversationCell];
    
    if (!self.conversation.isGroupConversation && [self.dataSource isPeerConnected:self.conversation.recipients.firstObject]) {
        [self animateConnectedToRecipientOfConversation];
    }
    else if (!self.conversation.isGroupConversation && ![self.dataSource isPeerConnected:self.conversation.recipients.firstObject]){
        [self animateDisconnectedFromRecipientOfConversation];
    }

    
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.leftSwipeView.frame = self.bounds;
    
    // Make some layout adjustments to the image in the left swipe view
    BLCButtonSwipeView *leftView = (BLCButtonSwipeView *)self.leftSwipeView;
    
    leftView.aButton.contentHorizontalAlignment = (self.swipeEffect == YATableSwipeEffectUnmask) ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
    CGFloat leftInset = (self.swipeEffect == YATableSwipeEffectUnmask) ? 20.0 : 0;
    CGFloat rightInset = (self.swipeEffect == YATableSwipeEffectUnmask) ? 0 : 20.0;
    
    [leftView.aButton setImageEdgeInsets:UIEdgeInsetsMake(0, leftInset, 0, rightInset)];
    
    // Set the snap thresholds
    self.rightSwipeSnapThreshold = self.bounds.size.width * 0.3;
    
}


-(void)updateConstraints {
    
    [super updateConstraints];
    
    NSLayoutConstraint *connectionIconPositionX, *connectionIconPositionY, *connectionIconWidth, *connectionIconHeight;
    
    connectionIconPositionX = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeRight multiplier:1 constant:10];
    
    connectionIconPositionY = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeCenterY multiplier:0.9 constant:0];
    
    connectionIconHeight = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeHeight multiplier:0.7 constant:0];
    
    connectionIconWidth = [NSLayoutConstraint constraintWithItem:self.connectionIconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.connectionIconImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
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
