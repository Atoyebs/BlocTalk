//
//  BLCCameraViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 22/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCCameraViewController.h"

@interface BLCCameraViewController ()

#pragma mark UI Controls

@property (weak, nonatomic) IBOutlet UIImageView *cameraPreview;

@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


#pragma mark Constraints

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation BLCCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasSetupConstraints = NO;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateViewConstraints {
    
    if (!self.hasSetupConstraints) {
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        
        NSLog(@"Testing!");
        
//        self.cancelButtonHeightFromTopOfView.constant = screenSize.height/65;
//        
//        self.takePhotoButtonDistanceFromCameraPreview.constant = screenSize.height/60;
        
    }
    
    [super updateViewConstraints];
    
}


- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
