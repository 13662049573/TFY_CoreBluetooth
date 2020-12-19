//
//  TFY_MineTableViewCell.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_MineTableViewCell.h"

@interface TFY_MineTableViewCell ()
TFY_PROPERTY_OBJECT_STRONG(UILabel, titleLabel);
@end

@implementation TFY_MineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewTemplate];
        [self configConstraint];
    }
    return self;
}

- (void)viewTemplate {
    [self.contentView addSubview:self.titleLabel];
}

- (void)configConstraint {
    [self.titleLabel tfy_AutoSize:10 top:10 right:10 bottom:10];
}

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString ;
    _titleLabel.text = titleString ;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = UILabelSet();
        _titleLabel.makeChain
        .textColor(UIColor.blackColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold])
        .textAlignment(NSTextAlignmentLeft);
    }
    return _titleLabel;
}
@end
