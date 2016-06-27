//
//  BLCProfilePictureImageView.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 21/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCProfilePictureImageView : UIImageView <NSCoding>

@property (nonatomic, assign) BOOL hideLabel;
@property (nonatomic, strong) UIImage *profilePicImage;

@end
