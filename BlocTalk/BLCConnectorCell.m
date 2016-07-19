//
//  BLCConnectorCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 12/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConnectorCell.h"

@interface BLCConnectorCell()

@property (nonatomic, strong) UIActivityIndicatorView *attemptingConnectionIndicator;

@end


@implementation BLCConnectorCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.attemptingConnectionIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        [self.contentView addSubview:self.attemptingConnectionIndicator];
        
        self.accessoryView = self.attemptingConnectionIndicator;
        
//        [self layoutCell];
        
    }
    
    
    return self;
}



-(void)layoutCell {
    
//    CGSize cellSize = self.frame.size;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.attemptingConnectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.attemptingConnectionIndicator.hidden = YES;
    
    NSLayoutConstraint *indicatorYPosition, *indicatorDistanceFromCellRightMargin, *indicatorWidth, *indicatorHeight;
    
    indicatorYPosition = [NSLayoutConstraint constraintWithItem:self.attemptingConnectionIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    indicatorDistanceFromCellRightMargin = [NSLayoutConstraint constraintWithItem:self.attemptingConnectionIndicator attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
    
    indicatorWidth = [NSLayoutConstraint constraintWithItem:self.attemptingConnectionIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:10];
    
    indicatorHeight = [NSLayoutConstraint constraintWithItem:self.attemptingConnectionIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.attemptingConnectionIndicator attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [self.contentView addConstraints:@[indicatorYPosition, indicatorDistanceFromCellRightMargin, indicatorWidth, indicatorHeight]];
    
}


-(void)startAnimatingConnectionIndicator {
    self.attemptingConnectionIndicator.hidden = NO;
    [self.attemptingConnectionIndicator startAnimating];
}


-(void)stopAnimatingConnectionIndicator {
    [self.attemptingConnectionIndicator stopAnimating];
    self.attemptingConnectionIndicator.hidden = NO;
}

@end
