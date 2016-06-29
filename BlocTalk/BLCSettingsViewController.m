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
#import <UICKeyChainStore/UICKeyChainStore.h>

@interface BLCSettingsViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet BLCProfilePictureImageView *profilePicture;
@property (nonatomic, assign) BOOL hasSetupConstraints;

@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, assign) NSInteger textFieldLimit;

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;

@property (nonatomic, assign) NSInteger minimumUsernameLength;

@property (nonatomic, strong) NSString *usernameKey;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) UIImagePickerController *libraryImagePickerController;
@property (nonatomic, strong) UIImagePickerController *cameraSnapshotPickerController;
@property (nonatomic, strong) UIAlertController *imagePickerChoice;
@property (nonatomic, strong) UIAlertAction *selectFromLibraryAction;
@property (nonatomic, strong) UIAlertAction *selectFromCameraAction;

@property (nonatomic, assign) BOOL imageChosenFromGallery;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewDistanceFromTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameTextFieldDistanceFromProfilePicture;



@end

@implementation BLCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasSetupConstraints = NO;
    self.usernameKey = @"usernameKey";
    self.minimumUsernameLength = 5;
    
    NSString *storedUsername = [UICKeyChainStore stringForKey:self.usernameKey];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.62 green:0.77 blue:0.91 alpha:1.0];
    
    self.textFieldLimit = 25;
    [self.usernameTextField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:17.0f]];
    self.usernameTextField.backgroundColor = [UIColor lightGrayColor];
    
    if (storedUsername) {
        self.userName = storedUsername;
        [self.usernameTextField setText:storedUsername];
    }
    
    [self loadProfilePictureDataFromDisk];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.usernameTextField.leftView = paddingView;
    self.usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameTextField.delegate = self;
    self.usernameTextField.enabled = NO;
    
    
    self.doneButton = [self generateBarButtonItemWithImageNamed:@"Ok-icon.png" withAction:@selector(tapDoneButton:) isLeftSide:NO];
    
    self.editButton = [self generateBarButtonItemWithImageNamed:@"edit-textbox.png" withAction:@selector(tapEditButton:) isLeftSide:NO];
    [self.navigationItem setRightBarButtonItem:self.editButton animated:NO];
    self.editButton.enabled = YES;
    
    [self.view addSubview:self.usernameTextField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateViewConstraints {
    
    if (!self.hasSetupConstraints) {
        
        CGSize screenDimensions = [self screenDimensions];
        
        self.imageViewDistanceFromTop.constant = screenDimensions.height * 0.07;
        
        self.usernameTextFieldDistanceFromProfilePicture.constant = screenDimensions.height * 0.05;
        
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


#pragma mark - Actions


- (IBAction)tapImageView:(id)sender {
    
    self.imagePickerChoice = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIImagePickerControllerSourceType chooseFromLibraryType;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        chooseFromLibraryType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
        chooseFromLibraryType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    self.selectFromLibraryAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.libraryImagePickerController = [[UIImagePickerController alloc] init];
        self.libraryImagePickerController.delegate = self;
        self.libraryImagePickerController.allowsEditing = YES;
        self.libraryImagePickerController.sourceType = chooseFromLibraryType;
        self.imageChosenFromGallery = YES;
        [self presentViewController:self.libraryImagePickerController animated:YES completion:nil];
    }];
    
    self.selectFromCameraAction = [UIAlertAction actionWithTitle:@"Take Photo (Camera)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if([self isCameraAvailableOnDevice]){
            self.cameraSnapshotPickerController = [[UIImagePickerController alloc] init];
            self.cameraSnapshotPickerController.delegate = self;
            self.cameraSnapshotPickerController.allowsEditing = YES;
            self.cameraSnapshotPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imageChosenFromGallery = NO;
            [self presentViewController:self.cameraSnapshotPickerController animated:YES completion:nil];
        }
        else {
            UIAlertController *noCameraAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Camera Unavailable For Device" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [noCameraAlert addAction:okAction];
            
            [self presentViewController:noCameraAlert animated:YES completion:nil];
        }
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [self.imagePickerChoice addAction:self.selectFromLibraryAction];
    [self.imagePickerChoice addAction:self.selectFromCameraAction];
    [self.imagePickerChoice addAction:cancelAction];
    [self presentViewController:self.imagePickerChoice animated:YES completion:nil];
    
}


- (BOOL)isCameraAvailableOnDevice {
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    UIImage *imageToUse = info[UIImagePickerControllerEditedImage];
    self.profilePicture.image = imageToUse;
    self.profilePicture.hideLabel = YES;
    self.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
    [self persistNewProfilePictureToDisk];
    
    [picker dismissViewControllerAnimated:YES completion:^{
       
        if (!self.imageChosenFromGallery) {
             UIImageWriteToSavedPhotosAlbum(imageToUse, nil, nil, nil);
        }
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)tapDoneButton:(id)sender {
    
    NSLog(@"Done Button Tapped");
    
    [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
    [self setUsernameTextfieldStateActive:NO];
    
    [UICKeyChainStore setString:self.usernameTextField.text forKey:self.usernameKey];
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



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Check the segue identifier
    if([segue.identifier isEqualToString:@"toImagePicker"]) {
        
        
    }
    
    
}


- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

-(void)loadProfilePictureDataFromDisk {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //get the fullPath of the same file you saved/wrote to earlier
        NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(profilePicImage))];
        
        //unarchive the file into the SAME DATA/OBJECT TYPE YOU SAVED/WROTE it with
        BLCProfilePictureImageView *loadedImageView = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        //go back to the main queue as you've now finished the heavy lifting
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (loadedImageView) {
                self.profilePicture.image = loadedImageView.profilePicImage;
                self.profilePicture.hideLabel = YES;
                NSLog(@"ImageView succesfully loaded");
            }

        });
    });
    
}

- (BOOL)persistNewProfilePictureToDisk {
    
    NSData *dataToSave = [NSKeyedArchiver archivedDataWithRootObject:self.profilePicture];
    NSError *dataError = nil;
    
    NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(profilePicImage))];
    
    BOOL wroteSuccesfully = [dataToSave writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
    
    return wroteSuccesfully;
    
}


@end
