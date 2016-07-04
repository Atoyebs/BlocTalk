//
//  BLCDataSource.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCConversation;

@interface BLCDataSource : NSObject

+ (instancetype) sharedInstance;

- (NSMutableArray *)getConnectedDevices;

- (NSMutableArray *)getConversations;

- (void)changeUserName:(NSString *)userName;

- (NSString *)getUserName;

- (void)addConversation:(BLCConversation *)conversation;

- (BOOL)doesConversationAlreadyExistForRecipients:(NSArray *)recipients;

- (BLCConversation *)findExistingConversationWithRecipients:(NSArray *)recipients;

@end
