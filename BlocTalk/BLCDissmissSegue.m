//
//  BLCDissmissSegue.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 26/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCDissmissSegue.h"

@implementation BLCDissmissSegue

-(void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
