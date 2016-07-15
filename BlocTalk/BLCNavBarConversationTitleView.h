//
//  BLCNavBarConversationTitleView.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 15/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCNavBarConversationTitleView : UIView

@property (nonatomic, strong) UILabel *conversationUserNameLabel;
@property (nonatomic, strong) UILabel *connectionStatusLabel;


-(void)animateConnectionStatusLabelToShowConnected;

-(void)animateConnectionStatusLabelToShowDisconnected;

@end
