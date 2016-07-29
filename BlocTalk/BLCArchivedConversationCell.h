//
//  BLCArchivedConversationCell.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 29/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCBaseConversationCell.h"


@protocol BLCArchivedConversationCellDelegate;


@interface BLCArchivedConversationCell : BLCBaseConversationCell

-(void)showCustomEditAccessoryView;

-(void)showCellIsSelectedEditAccessoryView;

-(void)hideAllCellEditAccessoryControls;

-(void)changeEditAccessoryViewControl;


@end

