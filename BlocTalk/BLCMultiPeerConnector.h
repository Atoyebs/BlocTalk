//
//  BLCMultiPeerConnector.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 28/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCBrowserViewController, MCSession;

@interface BLCMultiPeerConnector : NSObject

@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCSession *peerSession;

- (void)advertisePeer:(BOOL)shouldAdvertise;

- (void)setupMCBrowser;

- (void)setupPeerAndSession;

@end
