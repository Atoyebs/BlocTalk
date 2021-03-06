//
//  BLCDataSource.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCDataSource.h"
#import "BLCPersistanceObject.h"
#import "BLCUser.h"
#import "BLCConversation.h"
#import "BLCPersistanceObject.h"
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
        
        [BLCPersistanceObject loadObjectFromMemoryForFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL loadSuccesful, id loadedObject) {
           
            if (loadSuccesful) {
                _conversations = (NSMutableArray <BLCConversation *> *) loadedObject;
            }
            
        }];
        
        [BLCPersistanceObject loadObjectFromMemoryForFileName:NSStringFromSelector(@selector(knownUsersDictionary)) withCompletionBlock:^(BOOL loadSuccesful, id loadedObject) {
           
            if (loadedObject) {
                _knownUsersDictionary = (NSMutableDictionary <NSString *,BLCUser *> *) loadedObject;
            }
            
        }];
        
        if (!_conversations) {
            _conversations = [NSMutableArray new];
        }
        
        if (!_knownUsersDictionary) {
            _knownUsersDictionary = [NSMutableDictionary new];
        }
        
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


#pragma mark - Querying The Datasource

-(BOOL)doesConversationAlreadyExistForRecipients:(NSArray *)recipients {
    
    BOOL conversationWithRecipientsExists = NO;
    
    NSInteger numberOfUsersMatched = 0;
    
    for (BLCConversation *conv in self.conversations) {
            
        if (recipients.count == conv.recipients.count) {
            
            for (MCPeerID *selectedRecipient in recipients) {
                
                for (MCPeerID *currRecipient in conv.recipients) {
                    
                    if ([currRecipient.displayName isEqualToString:selectedRecipient.displayName]) {
                        numberOfUsersMatched++;
                        break;
                    }
                    
                    
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

-(BLCConversation *)findExistingConversationWithRecipients:(NSArray *)recipients {
    
    BLCConversation *foundConversation = nil;
    
    NSInteger numberOfUsersMatched = 0;
    
    for (BLCConversation *conv in self.conversations) {
        
        if (recipients.count == conv.recipients.count) {
            
            for (MCPeerID *selectedRecipient in recipients) {
                
                for (MCPeerID *currRecipient in conv.recipients) {
                    
                    if ([currRecipient.displayName isEqualToString:selectedRecipient.displayName]) {
                        numberOfUsersMatched++;
                        break;
                    }

                    
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

-(NSArray *)getPeerIDsForSelectedRecipients:(NSArray *)recipients {

    NSMutableArray *peerIDsToReturn = [NSMutableArray array];
    
    for (NSString *peer in recipients) {
        
        for (MCPeerID *peerID in self.connectedDevices) {
            
            if ([peer isEqualToString:peerID.displayName]) {
                [peerIDsToReturn addObject:peerID];
            }
            
        }
        
    }
    
    return peerIDsToReturn;
    
}

-(BLCUser *)findUserObjectWithPeerID:(MCPeerID *)peerID {
    
    BLCUser *userObject = nil;
    
    for (BLCUser *user in self.knownUsersDictionary.allValues) {
        
        if ([user.username isEqualToString:peerID.displayName]) {
            userObject = user;
            break;
        }
        
    }
    
    return userObject;
}


-(BLCUser *)findUserObjectWithPeerName:(NSString *)peerName {
    
    BLCUser *userObject = nil;
    
    for (BLCUser *user in self.knownUsersDictionary.allValues) {
        
        if ([user.username isEqualToString:peerName]) {
            userObject = user;
            break;
        }
        
    }
    
    return userObject;
    
}

-(UIImage *)findImageForPeerDisplayName:(NSString *)peerName {
    
    BLCUser *user = [self findUserObjectWithPeerName:peerName];
    
    UIImage *imageOfUser = nil;
    
    if (user) {
        imageOfUser = user.profilePicture;
    }
    
    
    return imageOfUser;
}

-(NSIndexPath *)getIndexPathForConversation:(BLCConversation *)conversation {
    
    NSIndexPath *indexPath = nil;
    
    for (BLCConversation *conv in self.conversations) {
        
        if ([conversation isEqual:conv]) {
            
            NSInteger section = [self.conversations indexOfObject:conv];
            indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
            break;
        }
        
    }
    
    return indexPath;
    
}

-(BOOL)isPeerConnected:(MCPeerID *)peerID {
    
    BOOL isPeerConnected = NO;
    
    for (MCPeerID *peer in self.connectedDevices) {
        
        if ([peerID.displayName isEqualToString:peer.displayName]) {
            isPeerConnected = YES;
            break;
        }
        
    }
    
    return isPeerConnected;
}


-(MCPeerID *)connectedPeerWithPeerDisplayName:(NSString *)peerDisplayName {
    
    MCPeerID *foundPeerID = nil;
    
    for (MCPeerID *peerID in self.connectedDevices) {
        
        if ([peerID.displayName isEqualToString:peerDisplayName]) {
            foundPeerID = peerID;
            break;
        }
        
    }
    
    return foundPeerID;
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
    [_conversations removeObjectsAtIndexes:indexes];
    
    [BLCPersistanceObject persistObjectToMemory:_conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
        
        if (!persistSuccesful) {
            NSLog(@"persisting the conversation list was unsuccesful!");
        }
        
    }];
    
}

-(void)insertConversations:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    
    [_conversations insertObjects:array atIndexes:indexes];
    
    [BLCPersistanceObject persistObjectToMemory:_conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
        
        if (!persistSuccesful) {
            NSLog(@"persisting the conversation list was unsuccesful!");
        }
        
    }];
    
}

-(void)insertObject:(BLCConversation *)object inConversationsAtIndex:(NSUInteger)index {
    
    object.conversationID = _conversations.count;
    
    if (index == -1) {
        [_conversations insertObject:object atIndex:0];
    }
    else {
        [_conversations insertObject:object atIndex:object.conversationID];
    }
    
    [BLCPersistanceObject persistObjectToMemory:_conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
        
        if (!persistSuccesful) {
            NSLog(@"persisting the conversation list was unsuccesful!");
        }
        
    }];
    
}

-(void)replaceObjectInConversationsAtIndex:(NSUInteger)index withObject:(BLCConversation *)object {
    
    [_conversations replaceObjectAtIndex:index withObject:object];
    
    [BLCPersistanceObject persistObjectToMemory:_conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
        
        if (!persistSuccesful) {
            NSLog(@"persisting the conversation list was unsuccesful!");
        }
        
    }];
}


-(void)addNewlyRecievedConversation:(BLCConversation *)conversation {
    conversation.conversationID = _conversations.count;
    [_conversations insertObject:conversation atIndex:0];
    
    [BLCPersistanceObject persistObjectToMemory:_conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
        
        if (!persistSuccesful) {
            NSLog(@"persisting the conversation list was unsuccesful!");
        }
        
    }];
    
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
