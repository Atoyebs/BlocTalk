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

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;

@property (nonatomic, assign) NSInteger minimumUsernameLength;


@end

@implementation BLCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasSetupConstraints = NO;
    
    self.minimumUsernameLength = 5;
    
    self.view = [UIView new];
    self.profilePicture = [[BLCProfilePictureImageView alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:0.62 green:0.77 blue:0.91 alpha:1.0];
    
    self.textFieldLimit = 25;
    
    self.usernameTextField = [[UITextField alloc] init];
    [self.usernameTextField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:15.0f]];
    self.usernameTextField.backgroundColor = [UIColor lightGrayColor];
    [self.usernameTextField setPlaceholder:@"Username"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.usernameTextField.leftView = paddingView;
    self.usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameTextField.delegate = self;
    self.usernameTextField.enabled = NO;
    
    
    self.doneButton = [self generateBarButtonItemWithImageNamed:@"Ok-icon.png" withAction:@selector(tapDoneButton:) isLeftSide:NO];
    
    self.editButton = [self generateBarButtonItemWithImageNamed:@"edit-textbox.png" withAction:@selector(tapEditButton:) isLeftSide:NO];
    [self.navigationItem setRightBarButtonItem:self.editButton animated:NO];
    self.editButton.enabled = YES;
    
    
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
        
        [self.usernameTextField autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.usernameTextField autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.usernameTextField autoSetDimension:ALDimensionHeight toSize:(screenDimensions.height * 0.06)];
        
        [self.usernameTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.profilePicture withOffset:screenDimensions.height * 0.05];
        
        self.hasSetupConstraints = YES;
    }
    
    [super updateViewConstraints];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString * stringAfterMethodRuns = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if([string isEqualToString:@" "]) {
        return NO;
    }
    
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    else if ([self.navigationItem.rightBarButtonItem isEqual:self.editButton]) {
        
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
        
    }
    
    if (stringAfterMethodRuns.length >= self.minimumUsernameLength) {
         self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= self.textFieldLimit;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.text.length >= self.minimumUsernameLength) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}



- (CGSize)screenDimensions {
    return [UIScreen mainScreen].bounds.size;
}


- (UIBarButtonItem *) generateBarButtonItemWithImageNamed:(NSString*)imageNamed withAction:(SEL)customAction isLeftSide:(BOOL)leftSide {
    
    
    CGFloat deviceWidth = [UIScreen mainScreen].bounds.size.width;
    
    //create a UIImage from an image name "imageNamed" (variable)
    UIImage *rightSideButtonBarImage = [UIImage imageNamed:imageNamed];
    
    //calculate the height of the image relative to the navigation bar, its 1.5 times shorter than the height of the navigation bar
    CGFloat heightOfImageFromNavigationBar = self.navigationController.navigationBar.frame.size.height / 1.5;
    
    if (heightOfImageFromNavigationBar == 0) {
        heightOfImageFromNavigationBar = 65/1.5;
    }
    
    //get the ratio between the height and width to keep the image proportional when its put in the navigation bar
    CGFloat imageRatioHeightToWidth = rightSideButtonBarImage.size.height/rightSideButtonBarImage.size.width;
    
    /* create the frame for the button that will hold the image IN THE NAVIGATION BAR
     the width will be = (the height you want your icon to be in the nav bar / the ratio between height and width)
     the height will just be the height of the image that was calculated earlier
     */
    
    CGRect frameForShareButton;
    
    if (leftSide) {
        frameForShareButton = CGRectMake(0, 0, (heightOfImageFromNavigationBar/imageRatioHeightToWidth), heightOfImageFromNavigationBar);
    }
    else {
        frameForShareButton = CGRectMake((deviceWidth - 5), 0, (heightOfImageFromNavigationBar/imageRatioHeightToWidth), heightOfImageFromNavigationBar);
    }
    
    //create a button with the size and frame you just created above
    UIButton *customBarButton = [[UIButton alloc] initWithFrame:frameForShareButton];
    
    //set the background image for the button as the image we created as a very first step
    [customBarButton setBackgroundImage:rightSideButtonBarImage forState:UIControlStateNormal];
    
    //add an action for when the button is touched/clicked by using @selector syntax, it means when this button is touched it will execute the backWasClicked: method, you can name this to whatever you want as long as the method exists in this class
    [customBarButton addTarget:self action:customAction forControlEvents:UIControlEventTouchUpInside];
    
    //create a UIBarButtonItem (not to be confused with a normal UIButton) this button is specifically for navigationBars
    UIBarButtonItem *createdBarButton = [[UIBarButtonItem alloc] initWithCustomView:customBarButton];
    
    //return the newly created UIBarButtonItem
    return createdBarButton;
}


-(void)tapDoneButton:(id)sender {
    
    NSLog(@"Done Button Tapped");
    
    [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
    [self setUsernameTextfieldStateActive:NO];
}


-(void)tapEditButton:(id)sender {
    
    NSLog(@"Edit Button Tapped");
    [self setUsernameTextfieldStateActive:YES];
}


-(void)setUsernameTextfieldStateActive:(BOOL)shouldActivate {
    
    if (shouldActivate) {
        self.usernameTextField.enabled = YES;
        self.usernameTextField.backgroundColor = [UIColor whiteColor];
        [self.usernameTextField becomeFirstResponder];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        [self.usernameTextField resignFirstResponder];
        self.usernameTextField.backgroundColor = [UIColor lightGrayColor];
        self.usernameTextField.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}



@end
