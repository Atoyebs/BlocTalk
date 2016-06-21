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

@end

@implementation BLCProfilePictureImageView

-(instancetype)init {
    
    self = [super init];
 
    if (self) {
        self.image = [UIImage imageNamed:@"profile-placeholder.jpg"];
        self.descriptionLabel = [UILabel new];
        self.descriptionLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:13.5f];
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.descriptionLabel];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
    }
    
    return self;
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.descriptionLabel setText:@"Select Image"];
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.layer.cornerRadius = self.frame.size.width/2;
    
    [self.descriptionLabel autoSetDimensionsToSize:CGSizeMake(self.frame.size.width * 0.7, self.frame.size.height * 0.5)];
    
}

-(void)updateConstraints {
    [self.descriptionLabel autoCenterInSuperview];
    [super updateConstraints];
}


@end
