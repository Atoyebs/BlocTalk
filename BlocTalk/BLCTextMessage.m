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

-(instancetype)initWithTextMessage:(NSString *)message withUser:(BLCUser *)user {
    
    self = [super init];
    
    if (self) {
        self.textMessage = message;
        self.user = user;
        self.isInitialMessageForChat = NO;
    }
    
    return self;
    
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self) {
        
        self.textMessage = [coder decodeObjectForKey:NSStringFromSelector(@selector(textMessage))];
        self.user = [coder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.textMessage forKey:NSStringFromSelector(@selector(textMessage))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    
}




@end
