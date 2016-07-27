//
//  BLCNewConversationCell.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 27/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCBaseConversationCell.h"
#import <UITableViewCell+Swipe.h>


@protocol BLCNewConversationCellSwipeDelegate;

@interface BLCNewConversationCell : BLCBaseConversationCell

-(void)animateConnectedToRecipientOfConversation;
-(void)animateDisconnectedFromRecipientOfConversation;

@property (nonatomic, copy) void (^swipeLeftCompleteActionBlock) (BOOL undo);
@property (nonatomic, copy) void (^leftButtonTappedActionBlock)(void);

@property (nonatomic, weak) id <BLCNewConversationCellSwipeDelegate> delegate;

@end


@protocol BLCNewConversationCellSwipeDelegate <NSObject>

- (void)swipeableTableViewCell:(BLCNewConversationCell *)cell didTriggerLeftViewButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(BLCNewConversationCell *)cell didCompleteSwipe:(YATableSwipeMode)swipeMode;

@end