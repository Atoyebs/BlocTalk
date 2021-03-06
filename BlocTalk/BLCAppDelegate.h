//
//  AppDelegate.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 20/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCMultiPeerConnector, BLCMultiPeerManager, MCSession, MCPeerID;


@interface BLCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) BLCMultiPeerManager *mpManager;
@property (nonatomic, strong) UIColor *appThemeColor;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) UIImage *userProfileImage;
@property (nonatomic, strong) UIImage *profilePicturePlaceholderImage;
@property (nonatomic, strong) NSOperationQueue *multiPeerOperationQueue;


-(UIImage *)compressedUserProfileImage:(CGFloat)compressionRatio;

@end

