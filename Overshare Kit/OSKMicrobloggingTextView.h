//
//  OSKTextView.h
//  Based on JTSTextView by Jared Sinclair
//
//  Created by Jared Sinclair on 10/26/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import "OSKUITextViewSubstitute.h"

@import UIKit;

#import "OSKSyntaxHighlighting.h"
#import "OSKTextViewAttachment.h"

/// ------------------------------------------------------------
/// OSKMicrobloggingTextViewAttachmentsDelegate 
/// ------------------------------------------------------------

@class OSKMicrobloggingTextView;

@protocol OSKMicrobloggingTextViewAttachmentsDelegate <NSObject>

- (void)textViewDidTapRemoveAttachment:(OSKMicrobloggingTextView *)textView;

@end

/// ------------------------------------------------------------
/// OSKTextView
/// ------------------------------------------------------------

@interface OSKMicrobloggingTextView : OSKUITextViewSubstitute

@property (weak, nonatomic) id <OSKMicrobloggingTextViewAttachmentsDelegate> oskAttachmentsDelegate;
@property (strong, nonatomic) OSKTextViewAttachment *oskAttachment;
@property (assign, nonatomic) OSKSyntaxHighlightingStyle syntaxHighlighting;
@property (strong, nonatomic, readonly) NSArray *detectedLinks; // array of OSKTwitterTextEntities

- (void)removeAttachment;

@end




