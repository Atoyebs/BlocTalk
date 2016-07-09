//
//  Conversation.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversation.h"
#import "BLCUser.h"
#import "UIColor+JSQMessages.h"
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessageBubbleImageDataSource.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import "BLCAppDelegate.h"

@interface BLCConversation()

@property (nonatomic, assign) BOOL isEmpty;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;

@end


@implementation BLCConversation


-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
        
        if (!self.messages || self.messages.count == 0) {
            
            self.isEmpty = YES;
            self.isGroupConversation = YES;
            self.messages = [NSMutableArray array];
        }
        
        BLCUser *thisUser = [[BLCUser alloc] init];
        thisUser.username = self.appDelegate.userName;
        thisUser.userID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        self.user = thisUser;
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubblePurplePinkColor]];
        
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
        
    }
    
    return self;
}


-(NSString *)conversationTitle {
    
    NSMutableString *convTitle = [[self.recipients firstObject] mutableCopy];
    
    if (self.isGroupConversation) {
        [convTitle appendString:@" - (Group Conv)"];
    }
    
    return convTitle;
}


-(void)insertObject:(JSQMessage *)object inMessagesAtIndex:(NSUInteger)index {
    [self.messages insertObject:object atIndex:index];
}

-(void)removeObjectFromMessagesAtIndex:(NSUInteger)index {
    [self.messages removeObjectAtIndex:index];
}

-(JSQMessage *)objectInMessagesAtIndex:(NSUInteger)index {
    return [self.messages objectAtIndex:index];
}


@end
