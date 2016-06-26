    //
//  BLCProfilePictureImageView.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 21/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "UIImage+UIImageExtensions.h"
#import "BLCProfilePictureImageView.h"
#import <QuartzCore/QuartzCore.h>
#import <PureLayout/PureLayout.h>

@interface BLCProfilePictureImageView()

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation BLCProfilePictureImageView

-(instancetype)init {
    
    self = [super init];
 
    if (self) {
        [self basicImageViewSetup];
    }
    
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self basicImageViewSetup];
    }
    
    return self;
    
}


-(void)basicImageViewSetup {
    
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:13.5f];
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.descriptionLabel];
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
}



-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.descriptionLabel setText:@"Select Image"];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.layer.cornerRadius = self.frame.size.width/2;
    
}

-(void)updateConstraints {
    [self.descriptionLabel autoCenterInSuperview];
    [self.descriptionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
    [self.descriptionLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-10];
    [super updateConstraints];
}

-(void)setHideLabel:(BOOL)hideLabel {
    self.descriptionLabel.hidden = hideLabel;
}


@end
