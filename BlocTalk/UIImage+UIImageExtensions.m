//
//  UIImage+UIImageExtensions.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 21/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "UIImage+UIImageExtensions.h"

@implementation UIImage (UIImageExtensions)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
