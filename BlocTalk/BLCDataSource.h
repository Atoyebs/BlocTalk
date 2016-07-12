//
//  BLCDataSource.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCConversation, MCPeerID;

@interface BLCDataSource : NSObject

+ (instancetype) sharedInstance;

- (void)changeUserName:(NSString *)userName;

- (NSString *)getUserName;

- (BOOL)doesConversationAlreadyExistForRecipients:(NSArray *)recipients;

- (BLCConversation *)findExistingConversationWithRecipients:(NSArray *)recipients;

- (NSArray *)getPeerIDsForSelectedRecipients:(NSArray *)recipients;

- (void)addNewlyRecievedConversation:(BLCConversation *)conversation;

-(NSUInteger)countOfConversations;


@property (nonatomic, strong, readonly) NSMutableArray <BLCConversation *> *conversations;

@property (nonatomic, strong, readonly) NSMutableArray <MCPeerID *> *connectedDevices;

@property (nonatomic, strong) NSMutableArray *unConnectedFoundDevices;

@property (nonatomic, strong) NSMutableArray *historicallyConnectedPeers;

@end
