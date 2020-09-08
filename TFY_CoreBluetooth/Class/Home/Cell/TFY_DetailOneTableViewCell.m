//
//  TFY_DetailOneTableViewCell.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_DetailOneTableViewCell.h"

@interface TFY_DetailOneTableViewCell ()
TFY_PROPERTY_OBJECT_STRONG(UILabel, titleLabel);
TFY_PROPERTY_OBJECT_STRONG(UILabel, subTitleLabel);
@end

@implementation TFY_DetailOneTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewTemplate];
        [self configConstraint];
    }
    return self;
}

- (void)viewTemplate {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
}

- (void)configConstraint {
    self.titleLabel
    .tfy_LeftSpace(10)
    .tfy_TopSpace(10)
    .tfy_RightSpace(10)
    .tfy_Height(20);
    
    self.subTitleLabel
    .tfy_SizeEqualView(self.titleLabel)
    .tfy_BottomSpace(10);
}

- (void)setTitleString:(NSString *)titleString {
    self.titleLabel.text = titleString;
}
- (void)setSubTitleString:(NSString *)subTitleString {
    if ([subTitleString isKindOfClass:[NSArray class]]) {
        NSString *allString = @"" ;
        NSArray *tempArray = (NSArray *)subTitleString;
        for (NSString *tempS in tempArray) {
            allString = [allString stringByAppendingString:[NSString stringWithFormat:@"%@ ",tempS]];
        }
        self.subTitleLabel.text = allString;
    } else
    self.subTitleLabel.text  =[NSString stringWithFormat:@"%@",subTitleString] ;
}

-(void)setCharacter:(TFY_EasyCharacteristic *)character {
    self.titleLabel.text = character.name;
    self.subTitleLabel.text = [NSString stringWithFormat:@"属性:%@",character.propertiesString];
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

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = UILabelSet();
        _subTitleLabel.makeChain
        .textColor(UIColor.blackColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold])
        .textAlignment(NSTextAlignmentRight);
    }
    return _subTitleLabel;
}
@end
