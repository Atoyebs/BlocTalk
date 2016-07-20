//
//  BLCDataSource.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BLCConversation, MCPeerID, BLCUser;

@interface BLCDataSource : NSObject

+ (instancetype) sharedInstance;

- (BOOL)doesConversationAlreadyExistForRecipients:(NSArray *)recipients;

- (BLCConversation *)findExistingConversationWithRecipients:(NSArray *)recipients;

- (BLCUser *)findUserObjectWithPeerID:(MCPeerID *)peerID;

- (UIImage *)findImageForPeerDisplayName:(NSString *)peerName;

- (NSArray *)getPeerIDsForSelectedRecipients:(NSArray *)recipients;

- (NSIndexPath *)getIndexPathForConversation:(BLCConversation *)conversation;

- (BOOL)isPeerConnected:(MCPeerID *)peerID;

- (MCPeerID *)connectedPeerWithPeerDisplayName:(NSString *)peerDisplayName;

- (NSUInteger)countOfConversations;





@property (nonatomic, strong, readonly) NSMutableArray <BLCConversation *> *conversations;

@property (nonatomic, strong, readonly) NSMutableArray <MCPeerID *> *connectedDevices;

@property (nonatomic, strong) NSMutableArray *unConnectedFoundDevices;

@property (nonatomic, strong) NSMutableDictionary <NSString *,BLCUser *> *knownUsersDictionary;

@end
