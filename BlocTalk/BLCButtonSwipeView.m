//
//  BLCButtonSwipeView.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 25/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCButtonSwipeView.h"
#import <PureLayout/PureLayout.h>

@interface BLCButtonSwipeView()

@property (nonatomic, strong) UILabel *swipeFunctionDescriptionLabel;

@end


@implementation BLCButtonSwipeView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _aButton = [[UIButton alloc] init];
        
        self.swipeFunctionDescriptionLabel = [UILabel new];
        [self.swipeFunctionDescriptionLabel setText:@"Archive"];
        self.swipeFunctionDescriptionLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:15.5];
        self.swipeFunctionDescriptionLabel.textColor = [UIColor whiteColor];
        
        UIImage *checkView = [UIImage imageNamed:@"archive.png"];
        [_aButton setImage:checkView forState:UIControlStateNormal];
        
        _aButton.backgroundColor = [self swipeColorButton];
        [_aButton.titleLabel setFont:[self defaultFont]];
        [_aButton.titleLabel setNumberOfLines:0];
        _aButton.userInteractionEnabled = YES;
        _aButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_aButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_aButton];
        [self addSubview:_swipeFunctionDescriptionLabel];
        
    }
    
    
    return self;
}


-(void)setButtonImage:(UIImage *)buttonImage {
    
//    self.buttonImage = buttonImage;
    [_aButton setImage:buttonImage forState:UIControlStateNormal];
    
}


-(UIColor *)swipeColorButton {
    return [UIColor colorWithRed:0.42 green:0.62 blue:0.94 alpha:1.0];
}


# pragma mark - Cell Swipe State Change Blocks
- (void)didSwipeWithTranslation:(CGPoint)translation
{
    CGFloat contentOffsetX = fabs(translation.x);
    CGFloat textAlpha = contentOffsetX / CGRectGetWidth(self.bounds);
    self.aButton.imageView.alpha = textAlpha;
}

- (void)didChangeMode:(YATableSwipeMode)mode
{
    if ((mode == YATableSwipeModeLeftON) || (mode == YATableSwipeModeRightON)) {
        self.aButton.imageView.alpha = 1.0;
    }
}

# pragma mark - Button Methods
- (void)buttonTapped:(id)sender
{
    if (self.buttonTappedActionBlock) {
        self.buttonTappedActionBlock();
    }
}

# pragma mark - Helper Methods
- (UIFont *)defaultFont
{
    return [UIFont fontWithName:@"SegoeUI-Semibold" size:15.0];
}


-(void)updateConstraints {
    
    [super updateConstraints];
    
    [self.aButton autoSetDimensionsToSize:CGSizeMake(60, 40)];
    [self.aButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:30];
    [self.aButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.swipeFunctionDescriptionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.aButton withOffset:10];
    [self.swipeFunctionDescriptionLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.aButton];
    
}


-(UIColor *)swipeColor {
    return [self swipeColorButton];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
