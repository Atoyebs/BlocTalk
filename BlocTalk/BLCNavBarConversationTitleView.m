//
//  BLCNavBarConversationTitleView.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 15/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCNavBarConversationTitleView.h"
#import <PureLayout/PureLayout.h>

@interface BLCNavBarConversationTitleView()

@end


@implementation BLCNavBarConversationTitleView


-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self initializeView];
        
    }
    
    return self;
}


-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self initializeView];
    }
    
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.conversationUserNameLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.conversationUserNameLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-5];
    [self.conversationUserNameLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
    
    [self.connectionStatusLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
    [self.connectionStatusLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.conversationUserNameLabel withOffset:0];
    
}


-(void)animateConnectionStatusLabelToShowConnected {
    
    [UIView transitionWithView:self.connectionStatusLabel duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        self.connectionStatusLabel.text = @"Connected";
        self.connectionStatusLabel.alpha = 1;
        self.connectionStatusLabel.textColor = [UIColor colorWithRed:0.11 green:0.75 blue:0.14 alpha:1.0];
        
    } completion:^(BOOL finished) {
        
        [UIView transitionWithView:self.connectionStatusLabel duration:1.0  options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.connectionStatusLabel.textColor = [UIColor lightGrayColor];
        } completion:nil];
        
    }];
    
}

-(void)animateConnectionStatusLabelToShowDisconnected {
    
    [UIView transitionWithView:self.connectionStatusLabel duration:0.8 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.connectionStatusLabel.text = @"Not Connected";
        self.connectionStatusLabel.alpha = 1;
        self.connectionStatusLabel.textColor = [UIColor redColor];
        
    } completion:nil];
    
    
    
}


-(void)initializeView {
    
    UIFont *titleViewMainLabelFont = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:20.0];
    UIFont *titleViewConnectionStatusLabelFont = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:10.0];
    
    self.connectionStatusLabel = [UILabel new];
    self.connectionStatusLabel.numberOfLines = 1;
    self.connectionStatusLabel.font = titleViewConnectionStatusLabelFont;
    self.connectionStatusLabel.hidden = NO;
    
    self.conversationUserNameLabel = [UILabel new];
    self.conversationUserNameLabel.numberOfLines = 1;
    self.conversationUserNameLabel.font = titleViewMainLabelFont;
    self.conversationUserNameLabel.textColor = [UIColor blackColor];
    
    self.connectionStatusLabel.alpha = 0;
    
    [self addSubview:self.conversationUserNameLabel];
    [self addSubview:self.connectionStatusLabel];
    
}

@end
