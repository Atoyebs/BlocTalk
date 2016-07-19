//
//  UIColor+JSQMessages.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 03/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (JSQMessages)

#pragma mark - Message bubble colors


+ (UIColor *)jsq_messageBubblePurplePinkColor;

/**
 *  @return A color object containing HSB values similar to the iOS 7 messages app green bubble color.
 */
+ (UIColor *)jsq_messageBubbleGreenColor;

/**
 *  @return A color object containing HSB values similar to the iOS 7 messages app blue bubble color.
 */
+ (UIColor *)jsq_messageBubbleBlueColor;

/**
 *  @return A color object containing HSB values similar to the iOS 7 red color.
 */
+ (UIColor *)jsq_messageBubbleRedColor;

/**
 *  @return A color object containing HSB values similar to the iOS 7 messages app light gray bubble color.
 */
+ (UIColor *)jsq_messageBubbleLightGrayColor;


#pragma mark - Utilities

/**
 *  Creates and returns a new color object whose brightness component is decreased by the given value, using the initial color values of the receiver.
 *
 *  @param value A floating point value describing the amount by which to decrease the brightness of the receiver.
 *
 *  @return A new color object whose brightness is decreased by the given values. The other color values remain the same as the receiver.
 */
- (UIColor *)jsq_colorByDarkeningColorWithValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END


