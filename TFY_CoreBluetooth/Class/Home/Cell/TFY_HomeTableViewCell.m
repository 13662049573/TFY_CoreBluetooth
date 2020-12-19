//
//  TFY_HomeTableViewCell.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_HomeTableViewCell.h"

@interface TFY_HomeTableViewCell ()
TFY_PROPERTY_OBJECT_STRONG(UILabel, nameLabel);
TFY_PROPERTY_OBJECT_STRONG(UILabel, RSSILabel);
TFY_PROPERTY_OBJECT_STRONG(UILabel, stateLabel);
TFY_PROPERTY_OBJECT_STRONG(UILabel, servicesLabel);

@end

@implementation TFY_HomeTableViewCell

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
    [self.contentView addSubview:self.RSSILabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.servicesLabel];
    [self.contentView addSubview:self.stateLabel];
}


#pragma mark - Config Constraint -- 布局配置

//布局、约束
- (void)configConstraint{
    self.RSSILabel
    .tfy_LeftSpace(10)
    .tfy_Width(TFY_Width_W()*0.3)
    .tfy_TopSpace(10)
    .tfy_BottomSpace(10);
    
    self.nameLabel
    .tfy_LeftSpaceToView(10, self.RSSILabel)
    .tfy_TopSpaceEqualView(self.RSSILabel)
    .tfy_RightSpace(10)
    .tfy_Height(25);
    
    self.servicesLabel
    .tfy_LeftSpaceEqualView(self.nameLabel)
    .tfy_BottomSpaceEqualView(self.RSSILabel)
    .tfy_RightSpaceEqualView(self.nameLabel)
    .tfy_Height(25);
    
    self.stateLabel
    .tfy_RightSpace(10)
    .tfy_TopSpaceEqualView(self.RSSILabel)
    .tfy_size(TFY_DEBI_width(60), 30);
}


-(void)setPeripheral:(TFY_EasyPeripheral *)peripheral {
    _peripheral = peripheral;
    self.nameLabel.text = peripheral.name ;
    self.RSSILabel.text = [NSString stringWithFormat:@"RSSI\n%@",peripheral.RSSI];
    NSArray *serviceArray = [peripheral.advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    self.servicesLabel.text = [NSString stringWithFormat:@"%zd 服务",serviceArray.count];
    
    if (peripheral.state == CBPeripheralStateConnected) {
        self.stateLabel.text = @"已连接";
        self.stateLabel.backgroundColor = [UIColor greenColor];
    }else{
        self.stateLabel.backgroundColor = [UIColor orangeColor];
        self.stateLabel.text = @"未连接";
    }
}

- (UILabel *)RSSILabel {
    if (!_RSSILabel) {
        _RSSILabel = UILabelSet();
        _RSSILabel.makeChain
        .numberOfLines(0)
        .font([UIFont systemFontOfSize:15 weight:UIFontWeightBold])
        .textColor(UIColor.blackColor)
        .backgroundColor(UIColor.lightGrayColor)
        .clipRadius(CornerClipTypeAll, 8)
        .textAlignment(NSTextAlignmentCenter);
    }
    return _RSSILabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = UILabelSet();
        _nameLabel.makeChain
        .textColor(UIColor.blackColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold])
        .textAlignment(NSTextAlignmentLeft);
    }
    return _nameLabel;
}

- (UILabel *)servicesLabel {
    if (!_servicesLabel) {
        _servicesLabel = UILabelSet();
        _servicesLabel.makeChain
        .textColor(UIColor.blackColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold])
        .textAlignment(NSTextAlignmentLeft);
    }
    return _servicesLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = UILabelSet();
        _stateLabel.makeChain
        .textColor(UIColor.blackColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold])
        .textAlignment(NSTextAlignmentRight);
    }
    return _stateLabel;
}
@end
