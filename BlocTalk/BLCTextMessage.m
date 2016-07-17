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

-(instancetype)initWithTextMessage:(NSString *)message withUser:(BLCUser *)user peersInConversation:(NSArray *)conversationPeers {
    
    self = [super init];
    
    if (self) {
        self.textMessage = message;
        self.user = user;
        self.isInitialMessageForChat = NO;
        self.peersInConversation = conversationPeers;
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
        self.peersInConversation = [coder decodeObjectForKey:NSStringFromSelector(@selector(peersInConversation))];
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.textMessage forKey:NSStringFromSelector(@selector(textMessage))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.peersInConversation forKey:NSStringFromSelector(@selector(peersInConversation))];
    
}




@end
