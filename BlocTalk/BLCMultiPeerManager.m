//
//  BLCMultiPeerManager.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 12/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCMultiPeerManager.h"
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
    
//    NSArray *arrayInvitationHandler = [NSArray arrayWithObject:[invitationHandler copy]];
    
    NSLog(@"You've just recieved an invitation from %@", peerID.displayName);
    
    invitationHandler(YES, self.session);
    
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    
}




#pragma mark - MCSessionDelegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSDictionary *dict = @{@"peerID": peerID, @"state" : [NSNumber numberWithInt:state] };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification" object:nil userInfo:dict];
    
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID,
                           @"session":session
                           };
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
    
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
