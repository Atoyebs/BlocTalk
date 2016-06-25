//
//  BLCCameraViewController.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 22/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLCCameraViewControllerDelegate <NSObject>

- (void)useImageButtonPressed:(UIImage *)capturedImage;

@end


@interface BLCCameraViewController : UIViewController

@property (nonatomic, strong) id <BLCCameraViewControllerDelegate> delegate;

@end
