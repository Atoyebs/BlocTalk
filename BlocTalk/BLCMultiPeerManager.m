//
//  BLCMultiPeerManager.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 12/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "HDNotificationView.h"
#import "BLCPersistanceObject.h"
#import "BLCMultiPeerManager.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCConversationListViewController.h"
#import "BLCUser.h"
#import "BLCTextMessage.h"
#import "BLCAppDelegate.h"
#import "BLCDataSource.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <AFDropdownNotification/AFDropdownNotification.h>

@interface BLCMultiPeerManager() <MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, AFDropdownNotificationDelegate> {
    
    NSMutableDictionary *_foundPeers;
    
}

@property (nonatomic, strong) BLCDataSource *dataSource;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) NSMutableArray *kvoConnectedDevicesMutableArray;
@property (nonatomic, strong) AFDropdownNotification *ddNotification;

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
    
    NSLog(@"We have found a peer");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![self.dataSource.unConnectedFoundDevices containsObject:peerID] && ![self.kvoConnectedDevicesMutableArray containsObject:peerID]){
            [self.dataSource.unConnectedFoundDevices addObject:peerID];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidFindPeerNotification" object:nil userInfo:info];

    });
    
}


-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    
    //called when a peer has been lost
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.dataSource.unConnectedFoundDevices containsObject:peerID]) {
            [self.dataSource.unConnectedFoundDevices removeObject:peerID];
        }
        if ([self.kvoConnectedDevicesMutableArray containsObject:peerID]) {
            [self.dataSource.unConnectedFoundDevices removeObject:peerID];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidLosePeer" object:nil userInfo:nil];

    });
    
}


-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    
    NSLog(@"\nDid Not Start Browsing For Peers Error -> %@", error.localizedDescription);
}




#pragma mark - MCAdvertiserDelegate Methods

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    
    //if the user has accepted this information before then go ahead and automatically accept the information
    NSLog(@"You've just recieved an invitation from %@", peerID.displayName);
    
    self.ddNotification = [[AFDropdownNotification alloc] init];
    self.ddNotification.titleText = @"Peer Request";
    self.ddNotification.subtitleText = [NSString stringWithFormat:@"%@ has requested to connect!", peerID.displayName];
    self.ddNotification.image = [UIImage imageNamed:@"handshake.png"];
    self.ddNotification.topButtonText = @"Yes";
    self.ddNotification.bottomButtonText = @"No";
    self.ddNotification.dismissOnTap = YES;
    
    [self.ddNotification presentInView:[self topViewController].view withGravityAnimation:YES];
    
    [self.ddNotification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
        
        switch (event) {
            case AFDropdownNotificationEventTopButton:
                // Top button
                invitationHandler(YES, self.session);
                [self.ddNotification dismissWithGravityAnimation:YES];
                break;
                
            case AFDropdownNotificationEventBottomButton:
                // Bottom button
                invitationHandler(NO, self.session);
                [self.ddNotification dismissWithGravityAnimation:YES];
                break;
                
            case AFDropdownNotificationEventTap:
                // Tap
                invitationHandler(NO, self.session);
                [self.ddNotification dismissWithGravityAnimation:YES];
                break;
                
            default: invitationHandler(NO, self.session);
                [self.ddNotification dismissWithGravityAnimation:YES];
                break;
        }
    }];
    
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"Did not start advertising this peer -> %@", error.localizedDescription);
}



#pragma mark - MCSessionDelegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *dict = @{@"peerID": peerID, @"state" : [NSNumber numberWithInt:state], @"session" : session };
        
        //if the session is NOT connecting
        if (state != MCSessionStateConnecting) {
            
            
            //if the state is connected then
            if (state == MCSessionStateConnected) {
                
                //if the found devices contain the peer id that has just changed state remove it from the unconnected found devices
                if ([self.dataSource.unConnectedFoundDevices containsObject:peerID]) {
                    [self.dataSource.unConnectedFoundDevices removeObject:peerID];
                }
                
                //if the connected devices array DOESN'T contain the peerID then add the name to the arrayList
                if (![self.kvoConnectedDevicesMutableArray containsObject:peerID]) {
                    [self.kvoConnectedDevicesMutableArray insertObject:peerID atIndex:0];
                }
                
                [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"checked_icon2.png"] title:@"Succesful Connection" message:[NSString stringWithFormat:@"Made Succesful Connection To %@", peerID.displayName] ];
                
                [self.delegate peerDidGetConnectedWithID:peerID];
                
            }
            else if (state == MCSessionStateNotConnected){
                    
                NSLog(@"Peer %@ was disconnected", peerID.displayName);
                
                if ([self.dataSource.unConnectedFoundDevices containsObject:peerID]) {
                    [self.dataSource.unConnectedFoundDevices removeObject:peerID];
                }
                
                if ([self.kvoConnectedDevicesMutableArray containsObject:peerID]) {
                    [self.kvoConnectedDevicesMutableArray removeObject:peerID];
                }
                
                [self.delegate peerDidGetDisconnectedWithID:peerID];
                
                [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"disconnected_icon.png"] title:@"Warning" message:[NSString stringWithFormat:@"Disconnected From Peer: %@", peerID.displayName] ];
                
            }
            
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification" object:nil userInfo:dict];

    });
    
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID,
                           @"session":session
                           };
    
    id receivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if ([receivedData isKindOfClass:[BLCUser class]]) {
        
        NSBlockOperation *receiveInitialUserData = [NSBlockOperation blockOperationWithBlock:^{
           
            BLCUser *receivedUserObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            [self.dataSource.knownUsersDictionary setObject:receivedUserObject forKey:receivedUserObject.initializingUserID];
            NSLog(@"Just recived initial information from user: %@", receivedUserObject.username);
        
            [BLCPersistanceObject persistObjectToMemory:self.dataSource.knownUsersDictionary forFileName:NSStringFromSelector(@selector(knownUsersDictionary)) withCompletionBlock:^(BOOL persistSuccesful) {
           
                if (!persistSuccesful) {
                    NSLog(@"Something went wrong when trying to persist the knownUsersDictionary to memory.");
                }
                
            }];
            
        }];
        receiveInitialUserData.qualityOfService = NSQualityOfServiceUtility;
        receiveInitialUserData.queuePriority = NSOperationQueuePriorityVeryHigh;
        
        [self.appDelegate.multiPeerOperationQueue addOperation:receiveInitialUserData];
        
    }
    else if([receivedData isKindOfClass:[BLCTextMessage class]]){
        
        BLCTextMessage *receivedTextMessage = (BLCTextMessage *)receivedData;
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                            object:nil
                                                          userInfo:dict];
            
            [self.txtMssgDelegate didReceiveTextMessage:receivedTextMessage withPeerID:peerID];
            
        });
        
    }
    
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([streamName isEqualToString:@"typing"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCPeerIsTypingNotification" object:nil];
        }
        else if([streamName isEqualToString:@"stopped_typing"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCPeerStoppedTypingNotification" object:nil];
        }
        

    });
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
    
    [self.peerAdvertiser stopAdvertisingPeer];
    [self.peerBrowser stopBrowsingForPeers];
        
    
    [self.peerAdvertiser startAdvertisingPeer];
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


- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
    
}

@end
