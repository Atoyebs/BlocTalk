//
//  BLCMessageTableViewCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 30/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCMessageTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import <PureLayout/PureLayout.h>

@implementation BLCMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        
    }
    
    return self;
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize contentViewSize = self.contentView.frame.size;
    
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.masksToBounds = YES;
    
    CGFloat cellImageViewHeight = (contentViewSize.height * 0.85);
    
    CGFloat cellImageViewWidth = cellImageViewHeight;
    
    CGFloat cellImageViewPositionY = (contentViewSize.height/2) - (cellImageViewHeight/2);
    
    CGRect imageViewRect = CGRectMake(self.imageView.frame.origin.x, cellImageViewPositionY, cellImageViewWidth, cellImageViewHeight);
    
    self.imageView.frame = imageViewRect;
    
    self.imageView.layer.cornerRadius = self.imageView.layer.frame.size.width/2;
    
    [self.textLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.imageView withOffset:5];
    [self.textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.imageView withOffset:contentViewSize.width * 0.035];
    
    [self.detailTextLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.textLabel];
    [self.detailTextLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textLabel withOffset:7];
    
    self.contentView.frame = CGRectMake(20, 0, contentViewSize.width * 0.90, contentViewSize.height);
    
    CGFloat contentViewPositionX = (self.frame.size.width/2) - (self.contentView.frame.size.width/2);
}




@end
