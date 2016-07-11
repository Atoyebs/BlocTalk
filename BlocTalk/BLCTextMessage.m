//
//  BLCTextMessages.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 11/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCTextMessage.h"
#import "BLCAppDelegate.h"

@interface BLCTextMessage()


@end

@implementation BLCTextMessage

-(instancetype)initWithTextMessage:(NSString *)message {
    
    self = [super init];
    
    if (self) {
        self.textMessage = message;
        self.senderID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    }
    
    return self;
    
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self) {
        
        self.textMessage = [coder decodeObjectForKey:NSStringFromSelector(@selector(textMessage))];
        self.senderID = [coder decodeObjectForKey:NSStringFromSelector(@selector(senderID))];
        
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.textMessage forKey:NSStringFromSelector(@selector(textMessage))];
    [aCoder encodeObject:self.senderID forKey:NSStringFromSelector(@selector(senderID))];
    
}




@end
