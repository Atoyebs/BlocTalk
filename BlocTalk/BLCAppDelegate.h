//
//  AppDelegate.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 20/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCMultiPeerConnector;


@interface BLCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) BLCMultiPeerConnector *multiPeerManager;
@property (nonatomic, strong) UIColor *appThemeColor;

@end

