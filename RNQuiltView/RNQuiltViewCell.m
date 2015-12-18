//
//  RNQuiltViewCell.m
//  RNQuiltView
//
//  Created by linyize on 26.11.15.
//  Copyright (c) 2015 mmslate. All rights reserved.
//

#import "RNQuiltViewCell.h"

@implementation RNQuiltViewCell

- (void)setCellView:(RNCellView *)cellView {
    if (_cellView) {
        [_cellView removeFromSuperview];
    }
    _cellView = cellView;
    if (_cellView) {
        [self.contentView addSubview:cellView];
        [_cellView setFrame:self.contentView.bounds];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_cellView) {
        [_cellView setFrame:self.contentView.bounds];
    }
    self.clipsToBounds = YES;
}

@end
