//
//  BLCMessageTableViewCell.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *roundedImageView;

@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) IBOutlet UILabel *messagePreviewLabel;


@end
