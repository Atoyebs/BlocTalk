//
//  BLCMessageTableViewCell.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCConversation, BLCUser;

@interface BLCConversationCell : UITableViewCell

@property (nonatomic, strong) BLCConversation *conversation;

-(void)setupCell;

-(void)updateConversationCell;

-(void)updateConversationCellWithProfilePictureFromUser:(BLCUser *)user;

@property (nonatomic, strong) UIImageView *userProfilePicture;

@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) UITextView *messagePreviewTextView;

@end
