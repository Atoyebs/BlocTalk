//
//  BLCRemoveMiddleVCSegue.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 02/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCRemoveMiddleVCSegue.h"

@implementation BLCRemoveMiddleVCSegue

-(void)perform {
    
    
    
    UIViewController *sourceVC = (UIViewController *)self.sourceViewController;
    
    UIViewController *destinationVC = (UIViewController *)self.destinationViewController;
    
    UINavigationController *navController = self.sourceViewController.navigationController;
    
    if (navController) {
        [navController popViewControllerAnimated:NO];
        [navController pushViewController:destinationVC animated:YES];
    }
    
}

@end
