//
//  OSKQuoteSmartener.h
//  Overshare
//
//  Created by Jared on 1/25/14.
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

@import UIKit;

@interface OSKSmartPunctuation : NSObject

+ (NSInteger)fixDumbPunctuation:(NSTextStorage *)textStorage
               editedRange:(NSRange)editedRange
           textInputObject:(id <UITextInput>)textInputObject;

@end
