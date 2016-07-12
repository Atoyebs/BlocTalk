//
//  BLCMultiPeerManager.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 12/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCNearbyServiceAdvertiser, MCNearbyServiceBrowser, MCSession, MCPeerID, BLCUser;

@interface BLCMultiPeerManager : NSObject

@property (nonatomic, strong) MCNearbyServiceBrowser *peerBrowser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *peerAdvertiser;
@property (nonatomic, strong, readonly) NSMutableDictionary *foundPeers;


- (void)advertisePeer:(BOOL)shouldAdvertise;

- (void)startBrowsingForPeers;

- (void)stopBrowsingForPeers;

- (void)invitePeer:(MCPeerID *)peer withUserInfo:(BLCUser *)myUserInfo;

@end
