//
//  BLCBaseConversationCellPrivateProperties.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 27/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#ifndef BLCBaseConversationCellPrivateProperties_h
#define BLCBaseConversationCellPrivateProperties_h

#import "BLCDataSource.h"
#import "BLCAppDelegate.h"

@interface BLCBaseConversationCell()

@property (nonatomic, strong) BLCAppDelegate *appDelegate;

@property (nonatomic, strong) BLCDataSource *dataSource;

@property (nonatomic, strong) UIFont *usernameFont;

@property (nonatomic, strong) UIFont *messagePreviewFont;

@end

#endif /* BLCBaseConversationCellPrivateProperties_h */
