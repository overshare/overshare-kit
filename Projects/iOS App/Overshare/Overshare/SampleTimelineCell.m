//
//  SampleTimelineCell.m
//  Overshare
//
//  Created by Jared Sinclair on 10/30/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "SampleTimelineCell.h"

NSString * const SampleTimelineCellIdentifier = @"SampleTimelineCellIdentifier";
CGFloat const    SampleTimelineCellHeight = 214.0f;

@interface SampleTimelineCell ()

@property (weak, nonatomic) IBOutlet UIButton *shareButtonLight;
@property (weak, nonatomic) IBOutlet UIButton *shareButtonDark;

@end

@implementation SampleTimelineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (IBAction)lightModeShareButtonPressed:(UIButton *)sender {
    [self.delegate timelineCell:self didTapLightModeShareButtonInRect:sender.frame];
}

- (IBAction)darkModeShareButtonPressed:(UIButton *)sender {
    [self.delegate timelineCell:self didTapDarkModeShareButtonInRect:sender.frame];
}

- (CGRect)shareButtonRectLight {
    return self.shareButtonLight.frame;
}

- (CGRect)shareButtonRectDark {
    return self.shareButtonDark.frame;
}

@end
