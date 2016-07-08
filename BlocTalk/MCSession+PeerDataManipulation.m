//
//  MCSession+PeerDataManipulation.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 07/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "MCSession+PeerDataManipulation.h"

@implementation MCSession (PeerDataManipulation)

-(NSArray *)connectedPeersDisplayNames {
    
    NSMutableArray <NSString *> *connectedPeersStrings = nil;
    
    if (self.connectedPeers > 0) {
        
        connectedPeersStrings = [NSMutableArray new];
        
        for (MCPeerID *peerID in self.connectedPeers) {
            [connectedPeersStrings addObject:peerID.displayName];
        }
    }
    
    return connectedPeersStrings;
    
}

@end
