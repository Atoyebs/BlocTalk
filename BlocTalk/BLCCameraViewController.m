//
//  BLCCameraViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 22/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+UIImageExtensions.h"
#import "BLCSettingsViewController.h"

@interface BLCCameraViewController ()

#pragma mark UI Controls

@property (weak, nonatomic) IBOutlet UIImageView *capturedImageImageView;

@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIView *cameraImagePreview;

@property (weak, nonatomic) IBOutlet UIButton *useImageButton;

@property (nonatomic, strong) UIImage *mostRecentCapturedImage;



#pragma mark AVFoundation

@property (nonatomic, strong) AVCaptureSession *cameraSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *cameraStillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;


#pragma mark Constraints

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation BLCCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupImageCapture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)takePicture:(id)sender {
    
    NSLog(@"Take Picture Button Pressed");
 
    [self cameraButtonPressed];
    
}


- (IBAction)changeCamera:(id)sender {
    
    NSLog(@"Change Camera Button Pressed");
    
    [self switchInUseCamera];
}


-(void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    self.captureVideoPreviewLayer.frame = self.cameraImagePreview.bounds;
    
}


- (void) setupImageCapture {
    
    
    self.cameraSession = [[AVCaptureSession alloc] init];
    self.cameraSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cameraSession];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.cameraImagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (granted) {
                
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                NSError *error = nil;
                
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                
                if (!input) {
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    
                    [alertController addAction:okAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                }
                else {
                    
                    [self.cameraSession addInput:input];
                    self.cameraStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                    self.cameraStillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
                    
                    [self.cameraSession addOutput:self.cameraStillImageOutput];
                    
                    [self.cameraSession startRunning];
                    
                }
                
            }
            else {
                
                 UIAlertController *cameraPermisisonsAlertController = [UIAlertController alertControllerWithTitle:@"Camera Permission Denied" message:@"This app doesn't have permission to use the camera; please update your privacy settings." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [cameraPermisisonsAlertController addAction:okAction];
                
                [self presentViewController:cameraPermisisonsAlertController animated:YES completion:nil];
                
            }
            
        });
        
    }];
    
}


- (void) cameraButtonPressed {
    
    AVCaptureConnection *videoConnection;
    
    // Find the right connection object
    for (AVCaptureConnection *connection in self.cameraStillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [self.cameraStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            image = [image imageWithFixedOrientation];
            image = [image imageResizedToMatchAspectRatioOfSize:self.captureVideoPreviewLayer.bounds.size];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (image) {
                    self.cameraImagePreview.hidden = YES;
                    [self.cameraSession stopRunning];
                    self.capturedImageImageView.image = image;
                    self.cameraImagePreview.contentMode = UIViewContentModeRedraw;
                    self.useImageButton.enabled = YES;
                    self.mostRecentCapturedImage = image;
                    
                }
                
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                [alert show];
            });
            
        }
    }];
    
}


- (void) switchInUseCamera {
    
    AVCaptureDeviceInput *currentCameraInput = self.cameraSession.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 1) {
        
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex + 1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        if (newVideoInput) {
            UIView *fakeView = [self.cameraImagePreview snapshotViewAfterScreenUpdates:YES];
            fakeView.frame = self.cameraImagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.cameraImagePreview];
            
            [self.cameraSession beginConfiguration];
            [self.cameraSession removeInput:currentCameraInput];
            [self.cameraSession addInput:newVideoInput];
            [self.cameraSession commitConfiguration];
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                fakeView.alpha = 0;
            } completion:^(BOOL finished) {
                [fakeView removeFromSuperview];
            }];
        }
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"selectUseImageSegue"]) {
        
        [self.delegate useImageButtonPressed:self.mostRecentCapturedImage];
    }
    
}



@end
