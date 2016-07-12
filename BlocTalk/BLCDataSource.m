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
#import <MultiPeerConnectivity/MultipeerConnectivity.h>

@interface BLCDataSource() {
    
    NSMutableArray <BLCConversation *> *_conversations;
    NSMutableArray *_connectedDevices;
}


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
        
        _connectedDevices = [NSMutableArray new];
        _conversations = [NSMutableArray new];
        self.unConnectedFoundDevices = [NSMutableArray new];
        
        self.userName = [UICKeyChainStore stringForKey:@"usernameKey"];
     
        if (!self.userName) {
            self.userName = [[UIDevice currentDevice] name];
        }
        
    }
    
    return self;
    
}

- (NSString *)getUserName {
    return self.userName;
}



-(void)changeUserName:(NSString *)userName {
    
    self.userName = userName;
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


#pragma mark - KVO Compliance Methods (Conversations)

-(NSMutableArray *)conversations {
    return _conversations;
}

-(NSUInteger)countOfConversations {
    return _conversations.count;
}

-(id)objectInConversationsAtIndex:(NSUInteger)index {
    return [_conversations objectAtIndex:index];
}

-(NSArray *)conversationsAtIndexes:(NSIndexSet *)indexes {
    return [_conversations objectsAtIndexes:indexes];
}

-(void)removeConversationsAtIndexes:(NSIndexSet *)indexes {
    [_conversations objectsAtIndexes:indexes];
}

-(void)insertConversations:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [_conversations insertObjects:array atIndexes:indexes];
}

-(void)insertObject:(BLCConversation *)object inConversationsAtIndex:(NSUInteger)index {
    
    object.conversationID = _conversations.count;
    
    if (index == -1) {
        [_conversations insertObject:object atIndex:0];
    }
    else {
        [_conversations insertObject:object atIndex:object.conversationID];
    }
    
}

-(void)replaceObjectInConversationsAtIndex:(NSUInteger)index withObject:(BLCConversation *)object {
    [_conversations replaceObjectAtIndex:index withObject:object];
}


-(void)addNewlyRecievedConversation:(BLCConversation *)conversation {
    conversation.conversationID = _conversations.count;
    [_conversations insertObject:conversation atIndex:0];
}


#pragma mark - KVO Compliance Methods (Connected Devices)

-(NSArray *)connectedDevicesAtIndexes:(NSIndexSet *)indexes {
    return [_connectedDevices objectsAtIndexes:indexes];
}

-(NSUInteger)countOfConnectedDevices {
    return _connectedDevices.count;
}


-(void)insertObject:(id)object inConnectedDevicesAtIndex:(NSUInteger)index {
    [_connectedDevices insertObject:object atIndex:index];
}

-(id)objectInConnectedDevicesAtIndex:(NSUInteger)index {
    return [_connectedDevices objectAtIndex:index];
}

-(void)removeConnectedDevicesAtIndexes:(NSIndexSet *)indexes {
    [_connectedDevices removeObjectsAtIndexes:indexes];
}

-(void)removeObjectFromConnectedDevicesAtIndex:(NSUInteger)index {
    [_connectedDevices removeObjectAtIndex:index];
}

-(void)removeConnectedDevicesObject:(id )object {
    [_connectedDevices removeObject:object];
}

-(void)replaceObjectInConnectedDevicesAtIndex:(NSUInteger)index withObject:(id)object {
    [_connectedDevices replaceObjectAtIndex:index withObject:object];
}



@end
