//
//  OSKQuoteSmartener.h
//  Overshare
//
//  Created by Jared on 1/25/14.
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

@import UIKit;

@interface OSKSmartPunctuation : NSObject

/**
 Changes dumb quotes to smart quotes, dashes to en- and em- dashes, and dots to elipses.
 
 This method is designed to be used inside the NSTextStorageDelegate method
 `textStorage:willProcessEditing:editedRange:changeInLength:`. 
 
 @param textStorage The NSTextStorage of the UIKit text editing view (likely a UITextView).
 
 @param editedRange The editedRange from the NSTextStorageDelegate method listed above.
 
 @param textInputObject An object conforming to the UITextInput protocol. This is ususally
 to be your UITextView. This object is used to obtain writing directions.
 
 @return Returns the change in length after the edits.
 */
+ (NSInteger)fixDumbPunctuation:(NSTextStorage *)textStorage
               editedRange:(NSRange)editedRange
           textInputObject:(id <UITextInput>)textInputObject;

@end
