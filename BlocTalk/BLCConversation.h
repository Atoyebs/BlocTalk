//
//  Conversation.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSQMessagesBubbleImage, BLCUser;

@interface BLCConversation : NSObject

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSArray *recipients;

@property (nonatomic, strong) BLCUser *user;

@property (nonatomic, assign) BOOL isGroupConversation;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;

@end
