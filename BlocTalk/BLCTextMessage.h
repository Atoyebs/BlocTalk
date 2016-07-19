//
//  BLCTextMessages.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 11/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCUser, MCPeerID;

@interface BLCTextMessage : NSObject <NSCoding>

@property (nonatomic, strong) NSString *textMessage;
@property (nonatomic, strong) BLCUser *user;
@property (nonatomic, assign) BOOL isInitialMessageForChat;
@property (nonatomic, strong) NSArray <MCPeerID *> *peersInConversation;


-(instancetype)initWithTextMessage:(NSString *)message withUser:(BLCUser *)user peersInConversation:(NSArray *)conversationPeers;

@end
