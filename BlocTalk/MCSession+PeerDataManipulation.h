//
//  MCSession+PeerDataManipulation.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 07/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCSession (PeerDataManipulation)

-(NSArray *)connectedPeersDisplayNames;

@end
