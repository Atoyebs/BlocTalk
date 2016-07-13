//
//  Conversation.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSQMessagesBubbleImage, BLCUser, JSQMessage, BLCMessageData;

@interface BLCConversation : NSObject

@property (nonatomic, strong) NSMutableArray <BLCMessageData *>  *messages;

@property (nonatomic, strong) NSArray *recipients;

@property (nonatomic, strong) BLCUser *user;

@property (nonatomic, assign) BOOL isGroupConversation;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (nonatomic, strong, readonly) NSString *conversationTitle;

@property (nonatomic, assign) NSInteger conversationID;

@end
