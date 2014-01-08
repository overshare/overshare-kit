//
//  SampleTimelineCell.h
//  Overshare
//
//  Created by Jared Sinclair on 10/30/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import UIKit;

extern NSString * const SampleTimelineCellIdentifier;
extern CGFloat const    SampleTimelineCellHeight;

@class SampleTimelineCell;

@protocol SampleTimelineCellDelegate <NSObject>

- (void)timelineCell:(SampleTimelineCell *)cell didTapLightModeShareButtonInRect:(CGRect)rect;
- (void)timelineCell:(SampleTimelineCell *)cell didTapDarkModeShareButtonInRect:(CGRect)rect;

@end

@interface SampleTimelineCell : UITableViewCell

@property (weak, nonatomic) id <SampleTimelineCellDelegate> delegate;

- (CGRect)shareButtonRectLight;
- (CGRect)shareButtonRectDark;

@end
