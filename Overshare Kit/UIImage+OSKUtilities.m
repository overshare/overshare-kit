//
//  UIImage+OSKUtilities.m
//  Overshare
//
//  Created by Jared on 10/29/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//
//  Based on code by Ole Zorn (https://gist.github.com/omz/1102091)
//

#import "UIImage+OSKUtilities.h"

@implementation UIImage (OSKUtilities)

+ (UIImage *)osk_maskedImage:(UIImage *)image color:(UIColor *)color {
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef c = UIGraphicsGetCurrentContext();
	[image drawInRect:rect];
	CGContextSetFillColorWithColor(c, [color CGColor]);
	CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
	CGContextFillRect(c, rect);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	return result;
}

@end
