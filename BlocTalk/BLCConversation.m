//
//  Conversation.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversation.h"
#import "UIColor+JSQMessages.h"
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessageBubbleImageDataSource.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>

@interface BLCConversation()

@property (nonatomic, assign) BOOL isEmpty;


@end


@implementation BLCConversation


-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        if (!self.messages || self.messages.count == 0) {
            
            self.messages = [NSMutableArray array];
            self.isEmpty = YES;
            self.isGroupConversation = YES;
        }
        
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



@end
