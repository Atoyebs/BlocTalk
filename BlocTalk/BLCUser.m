//
//  BLCUser.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCUser.h"
#import "BLCAppDelegate.h"

@interface BLCUser()


@end


@implementation BLCUser


+(instancetype)currentDeviceUser {
    
    BLCAppDelegate *appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    BLCUser *user = [[BLCUser alloc] init];
    user.profilePicture = appDelegate.userProfileImage;
    user.username = appDelegate.userName;
    user.initializingUserID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    return user;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        self.profilePicture = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profilePicture))];
        self.username = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(username))];
        self.initializingUserID = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(initializingUserID))];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.profilePicture forKey:NSStringFromSelector(@selector(profilePicture))];
    [aCoder encodeObject:self.username forKey:NSStringFromSelector(@selector(username))];
    [aCoder encodeObject:self.initializingUserID forKey:NSStringFromSelector(@selector(initializingUserID))];
}

@end
