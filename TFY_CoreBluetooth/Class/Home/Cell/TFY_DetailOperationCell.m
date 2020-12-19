//
//  TFY_DetailOperationCell.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_DetailOperationCell.h"

@interface TFY_DetailOperationCell ()
TFY_PROPERTY_OBJECT_STRONG(UILabel, titleLabel);
@end

@implementation TFY_DetailOperationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewTemplate];
        [self configConstraint];
    }
    return self;
}

#pragma mark - View Template -- 视图层级关系绘制

//视图层级关系
- (void)viewTemplate{
    [self.contentView addSubview:self.titleLabel];
}

#pragma mark - Config Constraint -- 布局配置

//布局、约束
- (void)configConstraint{
    [self.titleLabel tfy_AutoSize:10 top:10 right:10 bottom:10];
}

- (void)setTitle:(NSString *)title {
    _title = title ;
    self.titleLabel.text = [NSString stringWithFormat:@"%@",title] ;
}
- (void)setIsOperation:(BOOL)isOperation {
    _isOperation = isOperation ;
    self.titleLabel.textColor = isOperation ? [UIColor blueColor] : [UIColor darkTextColor];
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
