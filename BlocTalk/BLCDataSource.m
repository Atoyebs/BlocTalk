//
//  BLCDataSource.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCDataSource.h"
#import "BLCConversation.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <UIKit/UIKit.h>

@interface BLCDataSource()

@property (nonatomic, strong) NSMutableArray *connectedDevices;
@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, strong) NSString *userName;

@end

@implementation BLCDataSource

+ (instancetype) sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.connectedDevices = [NSMutableArray new];
        self.conversations = [NSMutableArray new];
        
        self.userName = [UICKeyChainStore stringForKey:@"usernameKey"];
     
        if (!self.userName) {
            self.userName = [[UIDevice currentDevice] name];
        }
        
    }
    
    return self;
    
}

- (NSMutableArray *)getConnectedDevices {
    return self.connectedDevices;
}

- (NSMutableArray *)getConversations {
    return self.conversations;
}

- (NSString *)getUserName {
    return self.userName;
}



-(void)changeUserName:(NSString *)userName {
    
    self.userName = userName;
}

-(void)addConversation:(BLCConversation *)conversation {
    
    if (self.conversations.count == 0) {
        conversation.conversationID = self.conversations.count;
    }
    
    [self.conversations addObject:conversation];
}

- (BOOL)doesConversationAlreadyExistForRecipients:(NSArray *)recipients {
    
    BOOL conversationWithRecipientsExists = NO;
    
    NSInteger numberOfUsersMatched = 0;
    
    for (BLCConversation *conv in self.conversations) {
            
        if (recipients.count == conv.recipients.count) {
            
            for (id selectedRecipient in recipients) {
                
                if ([conv.recipients containsObject:selectedRecipient]) {
                    numberOfUsersMatched++;
                }
                
            }
            
            if (numberOfUsersMatched == conv.recipients.count) {
                conversationWithRecipientsExists = YES;
                break;
            }
            else {
                numberOfUsersMatched = 0;
            }
            
        }
        
    }
    
    return conversationWithRecipientsExists;
}


- (BLCConversation *)findExistingConversationWithRecipients:(NSArray *)recipients {
    
    BLCConversation *foundConversation = nil;
    
    NSInteger numberOfUsersMatched = 0;
    
    for (BLCConversation *conv in self.conversations) {
        
        if (recipients.count == conv.recipients.count) {
            
            for (id selectedRecipient in recipients) {
                
                if ([conv.recipients containsObject:selectedRecipient]) {
                    numberOfUsersMatched++;
                }
                
            }
            
            if (numberOfUsersMatched == conv.recipients.count) {
                foundConversation = conv;
                break;
            }
            else {
                numberOfUsersMatched = 0;
            }
            
        }
        
    }

    
    return foundConversation;
    
}

@end
