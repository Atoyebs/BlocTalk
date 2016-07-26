//
//  Conversation.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversation.h"
#import "BLCPersistanceObject.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCUser.h"
#import "UIColor+JSQMessages.h"
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessageBubbleImageDataSource.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import "BLCAppDelegate.h"
#import "BLCDataSource.h"

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
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
        
        self.isArchived = NO;
        
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        
    }
    
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.messages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messages))];
        self.recipients = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(recipients))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.isGroupConversation = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isGroupConversation))];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.conversationID = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(conversationID))];
        self.isArchived = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isArchived))];
        
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.messages forKey:NSStringFromSelector(@selector(messages))];
    [aCoder encodeObject:self.recipients forKey:NSStringFromSelector(@selector(recipients))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeBool:self.isGroupConversation forKey:NSStringFromSelector(@selector(isGroupConversation))];
    [aCoder encodeInteger:self.conversationID forKey:NSStringFromSelector(@selector(conversationID))];
    [aCoder encodeBool:self.isArchived forKey:NSStringFromSelector(@selector(isArchived))];
}


-(NSString *)conversationTitle {
    
    MCPeerID *peer = (MCPeerID *)[self.recipients firstObject];
    
    NSMutableString *convTitle = [NSMutableString stringWithFormat:@"%@", peer.displayName];
    
    if (self.isGroupConversation) {
        [convTitle appendString:@" - (Group Conv)"];
    }
    
    return convTitle;
}

-(void)insertObject:(BLCJSQMessageWrapper *)object inMessagesAtIndex:(NSUInteger)index {
    
    [self.messages insertObject:object atIndex:index];
    
    [BLCPersistanceObject persistObjectToMemory:[BLCDataSource sharedInstance].conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
        
        if (!persistSuccesful) {
            NSLog(@"persisting the message to the conversation list was unsuccesful!");
        }
        
    }];
    
}

-(void)removeObjectFromMessagesAtIndex:(NSUInteger)index {
    
    [self.messages removeObjectAtIndex:index];
    
    [BLCPersistanceObject persistObjectToMemory:[BLCDataSource sharedInstance].conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
        
        if (!persistSuccesful) {
            NSLog(@"persisting the message to the conversation list was unsuccesful!");
        }
        
    }];
    
}

-(BLCJSQMessageWrapper *)objectInMessagesAtIndex:(NSUInteger)index {
    return [self.messages objectAtIndex:index];
}


@end
