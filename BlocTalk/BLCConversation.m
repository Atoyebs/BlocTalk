//
//  Conversation.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversation.h"
#import "BLCMessageData.h"
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
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubblePurplePinkColor]];
        
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
        
    }
    
    return self;
}


-(NSString *)conversationTitle {
    
    MCPeerID *peer = (MCPeerID *)[self.recipients firstObject];
    
    NSMutableString *convTitle = [NSMutableString stringWithFormat:@"%@", peer.displayName];
    
    if (self.isGroupConversation) {
        [convTitle appendString:@" - (Group Conv)"];
    }
    
    return convTitle;
}


-(void)insertObject:(BLCMessageData *)object inMessagesAtIndex:(NSUInteger)index {
    [self.messages insertObject:object atIndex:index];
}

-(void)removeObjectFromMessagesAtIndex:(NSUInteger)index {
    [self.messages removeObjectAtIndex:index];
}

-(BLCMessageData *)objectInMessagesAtIndex:(NSUInteger)index {
    return [self.messages objectAtIndex:index];
}


@end
