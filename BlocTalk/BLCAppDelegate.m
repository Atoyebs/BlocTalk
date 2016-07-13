//
//  AppDelegate.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 20/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCAppDelegate.h"
#import "BLCMultiPeerManager.h"
#import "BLCProfilePictureImageView.h"
#import "BLCSettingsViewController.h"
#import "BLCConversationListViewController.h"
#import "BLCPersistanceObject.h"
#import "UIImage+UIImageExtensions.h"
#import "BLCMultiPeerConnector.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

@interface BLCAppDelegate ()

@end

@implementation BLCAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.appThemeColor = [UIColor colorWithRed:208.0f/255.0f green:246.0f/255.0f blue:249.0f/255.0f alpha:1.0];
    
    NSString *storedUsername = [UICKeyChainStore stringForKey:@"usernameKey"];
    
    self.userName = [[UIDevice currentDevice] name];
    
    if (storedUsername) {
        self.userName = storedUsername;
    }
    
    [BLCPersistanceObject loadProfilePictureDataFromDisk:^(BLCProfilePictureImageView *loadedImageView) {
        self.userProfileImage = loadedImageView.profilePicImage;
        NSLog(@"ImageView succesfully loaded");
    } nothingFound:^{
        self.userProfileImage = [UIImage imageNamed:@"profile-placeholder.jpg"];
    }];
    
    self.multiPeerManager = [[BLCMultiPeerConnector alloc] init];
    self.mpManager = [[BLCMultiPeerManager alloc] init];
    
    NSLog(@"Unique ID For %@ is = %@", self.userName, [[UIDevice currentDevice] identifierForVendor].UUIDString);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
