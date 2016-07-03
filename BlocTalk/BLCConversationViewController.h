//
//  BLCConversationMessagesViewController.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
@class BLCConversation;

@interface BLCConversationViewController : JSQMessagesViewController

@property (nonatomic, strong) BLCConversation *conversation;

@end
