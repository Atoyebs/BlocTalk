//
//  BLCConversationMessagesViewController.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
@class BLCConversation;

static NSString *const BLCPostToExistingConversation = @"PostToExistingConversationNotification";
static NSString *const PostToIndividualConversation = @"DidPostToIndividualConversaiton";
static NSString *const PostToGroupConversation = @"DidPostToGroupConversation";

@interface BLCConversationViewController : JSQMessagesViewController

@property (nonatomic, strong) BLCConversation *conversation;
@property (nonatomic, assign) BOOL selectedFromArchiveVC;


@end
