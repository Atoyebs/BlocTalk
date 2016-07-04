//
//  BLCMessageTableViewCell.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCConversation;

@interface BLCConversationCell : UITableViewCell

@property (nonatomic, strong) BLCConversation *conversation;

-(void)setupCell;

-(void)updateConversationCell;

@end
