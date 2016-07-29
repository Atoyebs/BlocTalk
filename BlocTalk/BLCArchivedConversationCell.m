//
//  BLCArchivedConversationCell.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 29/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCArchivedConversationCell.h"


@interface BLCArchivedConversationCell()

@property (nonatomic, strong) UIButton *unselectedArchiveEditAccessory;
@property (nonatomic, strong) UIButton *selectedForArchiveEditAccessory;

@property (nonatomic, assign) BOOL hasConstraintsSetup;
@property (nonatomic, strong) UIColor *cellHighlightedColor;

@end


@implementation BLCArchivedConversationCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
 
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    if (self) {
        
        self.hasConstraintsSetup = NO;
        
        self.unselectedArchiveEditAccessory = [[UIButton alloc] init];
        [self.unselectedArchiveEditAccessory setImage:[UIImage imageNamed:@"oval"] forState:UIControlStateNormal];
        
        self.unselectedArchiveEditAccessory.hidden = YES;
        
        self.selectedForArchiveEditAccessory = [[UIButton alloc] init];
        [self.selectedForArchiveEditAccessory setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
        
        self.selectedForArchiveEditAccessory.hidden = YES;
        
        
        [self.unselectedArchiveEditAccessory addTarget:self action:@selector(showCellIsSelectedEditAccessoryView) forControlEvents:UIControlEventTouchUpInside];
        
        [self.selectedForArchiveEditAccessory addTarget:self action:@selector(showCustomEditAccessoryView) forControlEvents:UIControlEventTouchUpInside];
        
        self.unselectedArchiveEditAccessory.translatesAutoresizingMaskIntoConstraints = NO;
        self.selectedForArchiveEditAccessory.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.selectedForArchiveEditAccessory.enabled = NO;
        self.unselectedArchiveEditAccessory.enabled = NO;
        
        [self.contentView addSubview:self.unselectedArchiveEditAccessory];
        [self.contentView addSubview:self.selectedForArchiveEditAccessory];
        
        self.cellHighlightedColor = [UIColor colorWithRed:0.89 green:0.98 blue:0.88 alpha:1.0];
    }
    
    return self;
    
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
}


-(void)setupCustomConstraints {
    
    NSLayoutConstraint *editAccessoryDistanceFromRightBorderContentView, *editAccessoryYPosition, *editAccesoryHeight, *editAccessoryWidth;
    
    editAccessoryDistanceFromRightBorderContentView = [NSLayoutConstraint constraintWithItem:self.unselectedArchiveEditAccessory attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-8];
    
    editAccessoryYPosition = [NSLayoutConstraint constraintWithItem:self.unselectedArchiveEditAccessory attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.1 constant:0];
    
    
    editAccesoryHeight = [NSLayoutConstraint constraintWithItem:self.unselectedArchiveEditAccessory attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.20 constant:0];
    
    editAccessoryWidth = [NSLayoutConstraint constraintWithItem:self.unselectedArchiveEditAccessory attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.unselectedArchiveEditAccessory attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    
    
    NSLayoutConstraint *editAccessory2DistanceFromRightBorderContentView, *editAccessory2YPosition, *editAccesory2Height, *editAccessory2Width;
    
    
    editAccessory2DistanceFromRightBorderContentView = [NSLayoutConstraint constraintWithItem:self.selectedForArchiveEditAccessory attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-8];
    
    editAccessory2YPosition = [NSLayoutConstraint constraintWithItem:self.selectedForArchiveEditAccessory attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.05 constant:0];
    
    
    editAccesory2Height = [NSLayoutConstraint constraintWithItem:self.selectedForArchiveEditAccessory attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.20 constant:0];
    
    editAccessory2Width = [NSLayoutConstraint constraintWithItem:self.selectedForArchiveEditAccessory attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.selectedForArchiveEditAccessory attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    
    [self addConstraints:@[editAccesoryHeight, editAccessoryWidth, editAccessoryYPosition, editAccessoryDistanceFromRightBorderContentView]];
    
    [self addConstraints:@[editAccesory2Height, editAccessory2Width, editAccessory2YPosition, editAccessory2DistanceFromRightBorderContentView]];
    
}


-(void)updateConstraints {
    
    [super updateConstraints];
    
    if (!self.hasConstraintsSetup) {
        [self setupCustomConstraints];
        self.hasConstraintsSetup = YES;
    }
    
}


-(void)showCustomEditAccessoryView {
    
    NSLog(@"Cell Has Just Been DeSelected");
    
    self.selectedForArchiveEditAccessory.hidden = YES;
    
    [UIView transitionWithView:self.unselectedArchiveEditAccessory duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.unselectedArchiveEditAccessory.hidden = NO;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.messagePreviewTextView.backgroundColor = [UIColor whiteColor];
    } completion:nil];
    
}


-(void)showCellIsSelectedEditAccessoryView {
    
    NSLog(@"Cell Has Been Selected For Addition");
    
    self.unselectedArchiveEditAccessory.hidden = YES;
    
    [UIView transitionWithView:self.selectedForArchiveEditAccessory duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.selectedForArchiveEditAccessory.hidden = NO;
        self.messagePreviewTextView.backgroundColor = self.cellHighlightedColor;
        self.contentView.backgroundColor = self.cellHighlightedColor;
    } completion:nil];
    
    #warning create a delegate method or two to add the list of conversations selected to an arrayList in the archiveListViewController, also change the icons/images used.

}


-(void)changeEditAccessoryViewControl {
    
    if (self.selectedForArchiveEditAccessory.hidden) {
        [self showCellIsSelectedEditAccessoryView];
    }
    else {
        [self showCustomEditAccessoryView];
    }
    
    
}


-(void)hideAllCellEditAccessoryControls {
    
    self.unselectedArchiveEditAccessory.hidden = YES;
    self.selectedForArchiveEditAccessory.hidden = YES;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.messagePreviewTextView.backgroundColor = [UIColor whiteColor];
    
}


@end
