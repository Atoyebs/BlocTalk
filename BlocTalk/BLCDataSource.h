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

- (void)changeUserName:(NSString *)userName;

- (NSString *)getUserName;

- (BOOL)doesConversationAlreadyExistForRecipients:(NSArray *)recipients;

- (BLCConversation *)findExistingConversationWithRecipients:(NSArray *)recipients;


-(NSUInteger)countOfConversations;

- (NSMutableArray *)getConnectedDevices;

@property (nonatomic, strong, readonly) NSMutableArray *conversations;

@end
