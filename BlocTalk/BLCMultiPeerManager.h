//
//  BLCMultiPeerManager.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 12/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCNearbyServiceAdvertiser, MCNearbyServiceBrowser, MCSession, MCPeerID, BLCUser, BLCMultiPeerSessionMonitorDelegate, BLCMultiPeerTextMessageDelegate, BLCTextMessage;


@protocol BLCMultiPeerSessionMonitorDelegate <NSObject>

@optional
-(void)peerDidGetDisconnectedWithID:(MCPeerID *)peerID;
-(void)peerDidGetConnectedWithID:(MCPeerID *)peerID;

@end


@protocol BLCMultiPeerTextMessageDelegate <NSObject>

@required
-(void)didReceiveTextMessage:(BLCTextMessage *)message withPeerID:(MCPeerID *)peerID;

@end


@interface BLCMultiPeerManager : NSObject

@property (nonatomic, strong) MCNearbyServiceBrowser *peerBrowser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *peerAdvertiser;
@property (nonatomic, strong, readonly) NSMutableDictionary *foundPeers;
@property (nonatomic, strong) MCSession *session;


@property (nonatomic, weak) id <BLCMultiPeerSessionMonitorDelegate> delegate;
@property (nonatomic, weak) id <BLCMultiPeerTextMessageDelegate> txtMssgDelegate;


- (void)advertisePeer:(BOOL)shouldAdvertise;

- (void)startBrowsingForPeers;

- (void)refreshBrowsingForPeers;

- (void)stopBrowsingForPeers;

- (void)invitePeer:(MCPeerID *)peer withUserInfo:(BLCUser *)myUserInfo;

@end
