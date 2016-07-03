//
//  Conversation.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSQMessagesBubbleImage;

@interface BLCConversation : NSObject

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSArray *recipients;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;

@end
