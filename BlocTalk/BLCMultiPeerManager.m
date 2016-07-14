//
//  BLCMultiPeerManager.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 12/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCMultiPeerManager.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCUser.h"
#import "BLCTextMessage.h"
#import "BLCAppDelegate.h"
#import "BLCDataSource.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface BLCMultiPeerManager() <MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate> {
    
    NSMutableDictionary *_foundPeers;
    
}

@property (nonatomic, strong) BLCDataSource *dataSource;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) NSMutableArray *kvoConnectedDevicesMutableArray;

@end

static NSString *const ServiceType = @"bloctalk-chat";


@implementation BLCMultiPeerManager


-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.dataSource = [BLCDataSource sharedInstance];
        self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
        _foundPeers = [NSMutableDictionary new];
        self.peerID = [[MCPeerID alloc] initWithDisplayName:self.appDelegate.userName];
        self.session = [[MCSession alloc] initWithPeer:self.peerID];
        self.peerBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:ServiceType];
        self.peerAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:ServiceType];
        
        
        self.kvoConnectedDevicesMutableArray = [self.dataSource mutableArrayValueForKey:NSStringFromSelector(@selector(connectedDevices))];
        
        self.session.delegate = self;
        self.peerAdvertiser.delegate = self;
        self.peerBrowser.delegate = self;
        
    }
    
    return self;
}



#pragma mark - MCBrowserDelegate Methods

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    
    //Called when a peer has been found
    
    //HERE YOU WILL WANT TO IMPLEMENT AUTOMATICALLY REQUESTING A CONNECTION IF THEY'VE CONNECTED TO THE PERSON BEFORE
    
    if (![self.dataSource.unConnectedFoundDevices containsObject:peerID] && ![self.kvoConnectedDevicesMutableArray containsObject:peerID]){
        [self.dataSource.unConnectedFoundDevices addObject:peerID];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidFindPeerNotification" object:nil userInfo:info];
    
}


-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    
    //called when a peer has been lost
    
    if ([self.dataSource.unConnectedFoundDevices containsObject:peerID]) {
        [self.dataSource.unConnectedFoundDevices removeObject:peerID];
    }
    if ([self.kvoConnectedDevicesMutableArray containsObject:peerID]) {
        [self.dataSource.unConnectedFoundDevices removeObject:peerID];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidLosePeer" object:nil userInfo:nil];
    
    
}


-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    
    NSLog(@"\nError -> %@", error.localizedDescription);
}




#pragma mark - MCAdvertiserDelegate Methods

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    
    //if the user has accepted this information before then go ahead and automatically accept the information
    
    NSLog(@"You've just recieved an invitation from %@", peerID.displayName);
    
    invitationHandler(YES, self.session);
    
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    
}




#pragma mark - MCSessionDelegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSDictionary *dict = @{@"peerID": peerID, @"state" : [NSNumber numberWithInt:state], @"session" : session };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification" object:nil userInfo:dict];
    
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID,
                           @"session":session
                           };
    
    id receivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    /*
    //if i've recieved a first text message from someone
    if ([recievedData isKindOfClass:[BLCTextMessage class]]) {
        
        BLCTextMessage *textMessage = (BLCTextMessage *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (textMessage.isInitialMessageForChat) {
            
            NSData *profilePictureImageData = UIImagePNGRepresentation(self.appDelegate.userProfileImage);
            
            
        }
        
    }
    */
    
    if ([receivedData isKindOfClass:[BLCUser class]]) {
        
        NSBlockOperation *receiveInitialUserData = [NSBlockOperation blockOperationWithBlock:^{
           
            BLCUser *receivedUserObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            if (![self.dataSource.knownUsersDictionary objectForKey:receivedUserObject.initializingUserID]) {
                [self.dataSource.knownUsersDictionary setObject:receivedUserObject forKey:receivedUserObject.initializingUserID];
                NSLog(@"Just recived initial information from user: %@", receivedUserObject.username);
            }
            
        }];
        receiveInitialUserData.qualityOfService = NSQualityOfServiceUtility;
        receiveInitialUserData.queuePriority = NSOperationQueuePriorityVeryHigh;
        
        [self.appDelegate.multiPeerOperationQueue addOperation:receiveInitialUserData];
        
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                            object:nil
                                                          userInfo:dict];
    }
    
    
}



#pragma mark - BLCManager Methods

- (void)advertisePeer:(BOOL)shouldAdvertise {
    
    if(shouldAdvertise){
        
        if (!self.peerAdvertiser) {
            self.peerAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:ServiceType];
        }
        
        [self.peerAdvertiser startAdvertisingPeer];
    }
    else {
        
        if (self.peerAdvertiser) {
            [self.peerAdvertiser stopAdvertisingPeer];
            self.peerAdvertiser = nil;
        }
        
    }
    
}


-(void)startBrowsingForPeers {
    [self.peerBrowser startBrowsingForPeers];
}

-(void)refreshBrowsingForPeers {
    
    self.peerAdvertiser = nil;
    
    [self advertisePeer:YES];
    
    [self.peerBrowser stopBrowsingForPeers];
    self.peerBrowser = nil;
    
    self.peerBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:ServiceType];
    [self.peerBrowser startBrowsingForPeers];
    
    
}

-(void)stopBrowsingForPeers {
    [self.peerBrowser stopBrowsingForPeers];
}


-(void)invitePeer:(MCPeerID *)peer withUserInfo:(BLCUser *)myUserInfo {
    
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:myUserInfo];
    
    //Use [NSKeyedUnarchiver unarchiveObjectWithData:receivedData] to decode the data information
    
    [self.peerBrowser invitePeer:peer toSession:self.session withContext:dataToSend timeout:30.0];
    
}

@end
