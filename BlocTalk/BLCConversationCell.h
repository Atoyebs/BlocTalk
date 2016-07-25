//
//  BLCMessageTableViewCell.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YMSwipeTableViewCell/UITableViewCell+Swipe.h>


@class BLCConversation, BLCUser;

@protocol BLCConversationCellSwipeDelegate;

@interface BLCConversationCell : UITableViewCell

@property (nonatomic, strong) BLCConversation *conversation;

-(void)setupCell;
-(void)updateConversationCell;
-(void)updateConversationCellWithProfilePictureFromUser:(BLCUser *)user;
-(void)animateConnectedToRecipientOfConversation;
-(void)animateDisconnectedFromRecipientOfConversation;


@property (nonatomic, copy) void (^swipeLeftCompleteActionBlock) (BOOL undo);
@property (nonatomic, copy) void (^leftButtonTappedActionBlock)(void);

@property (nonatomic, strong) UIImageView *userProfilePicture;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextView *messagePreviewTextView;
@property (nonatomic, weak) id <BLCConversationCellSwipeDelegate> delegate;

@end


@protocol BLCConversationCellSwipeDelegate <NSObject>

- (void)swipeableTableViewCell:(BLCConversationCell *)cell didTriggerLeftViewButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(BLCConversationCell *)cell didCompleteSwipe:(YATableSwipeMode)swipeMode;

@end
