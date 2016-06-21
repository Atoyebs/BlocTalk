//
//  ViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 20/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCProfilePictureImageView.h"
#import "BLCSettingsViewController.h"
#import <PureLayout/PureLayout.h>

@interface BLCSettingsViewController () <UITextFieldDelegate>

@property (nonatomic, strong) BLCProfilePictureImageView *profilePicture;
@property (nonatomic, assign) BOOL hasSetupConstraints;

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, assign) NSInteger textFieldLimit;



@end

@implementation BLCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasSetupConstraints = NO;
    
    self.view = [UIView new];
    self.profilePicture = [[BLCProfilePictureImageView alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:0.62 green:0.77 blue:0.91 alpha:1.0];
    
    self.textFieldLimit = 25;
    
    self.usernameTextField = [[UITextField alloc] init];
    [self.usernameTextField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.5f]];
    self.usernameTextField.backgroundColor = [UIColor whiteColor];
    [self.usernameTextField setPlaceholder:@"Name"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.usernameTextField.leftView = paddingView;
    self.usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameTextField.delegate = self;
    
    [self.view addSubview:self.profilePicture];
    [self.view addSubview:self.usernameTextField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    [self.view setNeedsUpdateConstraints];
    
}


-(void)updateViewConstraints {
    
    if (!self.hasSetupConstraints) {
        
        CGSize screenDimensions = [self screenDimensions];
        
        [self.profilePicture autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.profilePicture autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:(0.17 * screenDimensions.height)];
        
        [self.profilePicture autoSetDimensionsToSize:CGSizeMake(110, 110)];
        
        [self.usernameTextField autoSetDimensionsToSize:CGSizeMake(screenDimensions.width, screenDimensions.height * 0.05)];
        
        [self.usernameTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.profilePicture withOffset:screenDimensions.height * 0.05];
        
        self.hasSetupConstraints = YES;
    }
    
    [super updateViewConstraints];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= self.textFieldLimit;
}


- (CGSize)screenDimensions {
    return [UIScreen mainScreen].bounds.size;
}

@end
