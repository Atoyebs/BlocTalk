//
//  BLCMultiPeerConnector.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 28/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCMultiPeerConnector.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>



static NSString *const ServiceType = @"bloctalk-chat";


@interface BLCMultiPeerConnector() <MCSessionDelegate>

#pragma mark Multi-Peer Properties
@property (nonatomic, strong) MCPeerID *devicePeerID;
@property (nonatomic, strong) MCAdvertiserAssistant *serviceAdvertiser;

#pragma mark Standard Properties
@property (nonatomic, strong) NSString *displayName;

@end


@implementation BLCMultiPeerConnector

#pragma mark - Initializing Multi-Peer Objects

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.displayName = [UICKeyChainStore stringForKey:@"usernameKey"];
        
        if (!self.displayName) {
            self.displayName = [[UIDevice currentDevice] name];
        }
        
        self.devicePeerID = nil;
        self.peerSession = nil;
        self.browser = nil;
        self.serviceAdvertiser = nil;
        
    }
    
    
    return self;
}


- (void)advertisePeer:(BOOL)shouldAdvertise {
    
    if(shouldAdvertise){
        
        self.serviceAdvertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:ServiceType discoveryInfo:nil session:self.peerSession];
        [self.serviceAdvertiser start];
    }
    else {
        
        if (self.serviceAdvertiser) {
            [self.serviceAdvertiser stop];
            self.serviceAdvertiser = nil;
        }
        
    }
        
}


-(void)setupMCBrowser {
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:ServiceType session:self.peerSession];
}

-(void)setupPeerAndSession {
    
    self.devicePeerID = [[MCPeerID alloc] initWithDisplayName:self.displayName];
    self.peerSession = [[MCSession alloc] initWithPeer:self.devicePeerID];
    self.peerSession.delegate = self;
}



#pragma mark - Multi-Peer Delegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSDictionary *dict = @{@"peerID": peerID, @"state" : [NSNumber numberWithInt:state] };
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification" object:nil userInfo:dict];
    
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
 
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID,
                           @"session":session
                           };
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
    
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}



@end
