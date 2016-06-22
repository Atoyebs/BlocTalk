//
//  BLCCameraViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 22/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCCameraViewController.h"

@interface BLCCameraViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *changeCameraInUseButton;

@property (weak, nonatomic) IBOutlet UIImageView *cancelCameraViewButton;
@property (weak, nonatomic) IBOutlet UIImageView *cameraPreview;

@property (weak, nonatomic) IBOutlet UIImageView *pickerViewButton;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewDistanceFromRightMargin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenCancelButtonAndCameraPreview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenTakePhotoButtonAndCameraPreview;



@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *cancelButtonGesutureRecognizer;

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
        
        CGSize screenDimensions = [UIScreen mainScreen].bounds.size;
        
        CGFloat distanceBetweenTopOfPreviewAndTopOfScreen = self.cameraPreview.frame.origin.y;
        
        self.distanceBetweenCancelButtonAndCameraPreview.constant = (distanceBetweenTopOfPreviewAndTopOfScreen/2) - 20;
        
        self.distanceBetweenTakePhotoButtonAndCameraPreview.constant = screenDimensions.height/30;
        
        self.pickerViewDistanceFromRightMargin.constant = screenDimensions.width/30;
        
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
