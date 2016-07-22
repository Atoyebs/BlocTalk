//
//  BLCUser.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MultiPeerConnectivity/MultipeerConnectivity.h>


@interface BLCUser : NSObject <NSCoding>

@property (nonatomic, strong) UIImage *profilePicture;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *initializingUserID;
@property (nonatomic, strong) NSDate *dateLastUpdated;

+(instancetype)currentDeviceUser;

+(NSData *)currentDeviceUserInDataFormat;

+(instancetype)currentDeviceUserNoProfilePic;

+(NSData *)currentDeviceUserInDataFormatNoProfilePic;

@end
