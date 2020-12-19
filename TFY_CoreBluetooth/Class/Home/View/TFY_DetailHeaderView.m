//
//  TFY_DetailHeaderView.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_DetailHeaderView.h"

@interface TFY_DetailHeaderView ()
TFY_PROPERTY_OBJECT_STRONG(UILabel, nameLabel);
TFY_PROPERTY_OBJECT_STRONG(UILabel, uuidLabel);
TFY_PROPERTY_OBJECT_STRONG(UILabel, stateLabel);
TFY_PROPERTY_OBJECT_STRONG(TFY_EasyPeripheral, peripheral);
@end

@implementation TFY_DetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self viewTemplate];
        [self configConstraint];
    }
    return self;
}

- (void)viewTemplate {
    [self addSubview:self.nameLabel];
    [self addSubview:self.uuidLabel];
    [self addSubview:self.stateLabel];
}

- (void)configConstraint {
    self.nameLabel
    .tfy_LeftSpace(10)
    .tfy_TopSpace(10)
    .tfy_RightSpace(10)
    .tfy_Height(20);
    
    self.uuidLabel
    .tfy_LeftSpaceEqualView(self.nameLabel)
    .tfy_TopSpaceToView(0, self.nameLabel)
    .tfy_RightSpaceEqualView(self.nameLabel)
    .tfy_HeightEqualView(self.nameLabel);
    
    self.stateLabel
    .tfy_LeftSpaceEqualView(self.uuidLabel)
    .tfy_BottomSpace(10)
    .tfy_RightSpaceEqualView(self.uuidLabel)
    .tfy_HeightEqualView(self.uuidLabel);
}

+ (instancetype)headerViewWithPeripheral:(TFY_EasyPeripheral *)peripheral {
    TFY_DetailHeaderView *herder = [[TFY_DetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, TFY_Width_W(), 80)];
    herder.nameLabel.text = peripheral.name ;
    herder.uuidLabel.text = [NSString stringWithFormat:@"UUID:%@",peripheral.identifier.UUIDString] ;
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            herder.stateLabel.text = @"已连接";
            break;
        case CBPeripheralStateDisconnected:
            herder.stateLabel.text = @"已断开连接";
            break ;
        default:
            break;
    }
    herder.peripheral = peripheral ;
    return herder ;
}

- (void)dealloc {
    [self.peripheral.peripheral removeObserver:self forKeyPath:@"state"];
}

- (void)setPeripheral:(TFY_EasyPeripheral *)peripheral {
    _peripheral = peripheral ;
    [self.peripheral.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    TFY_WEAK;
    Blue_queueMainStart
    CBPeripheral *periheral = (CBPeripheral *)object ;
    NSLog(@" peripheral state changed-----> %zd",periheral.state );
    if (periheral.state == CBPeripheralStateDisconnected) {
        weakSelf.stateLabel.textColor = [UIColor redColor];
        weakSelf.stateLabel.text = @"设备失去连接...";
    }
    else{
        weakSelf.stateLabel.textColor = [UIColor blackColor];
        weakSelf.stateLabel.text = @"设备已连接";
    }
    Blue_queueEnd
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = UILabelSet();
        _nameLabel.makeChain
        .textColor(UIColor.blackColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold]);
    }
    return _nameLabel;
}

- (UILabel *)uuidLabel {
    if (!_uuidLabel) {
        _uuidLabel = UILabelSet();
        _uuidLabel.makeChain
        .textColor(UIColor.blueColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold]);
    }
    return _uuidLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = UILabelSet();
        _stateLabel.makeChain
        .textColor(UIColor.redColor)
        .font([UIFont systemFontOfSize:14 weight:UIFontWeightBold]);
    }
    return _stateLabel;
}
@end
