//
//  BLCButtonSwipeView.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 25/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+Swipe.h"

@interface BLCButtonSwipeView : UIView

@property (nonatomic, strong) UIButton *aButton;
@property (nonatomic, copy) void (^buttonTappedActionBlock)(void);
@property (nonatomic, strong) UIColor *swipeColor;

//@property (nonatomic, strong) UIImage *buttonImage;
//@property (nonatomic, strong) UIColor *swipeColorButton;

- (void)setButtonImage:(UIImage *)buttonImage;
- (void)setSwipeBackgroundColor:(UIColor *)color;
- (void)didSwipeWithTranslation:(CGPoint)translation;
- (void)didChangeMode:(YATableSwipeMode)mode;



@end
