//
//  TFY_DetailHeaderFooterView.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_DetailHeaderFooterView.h"

@interface TFY_DetailHeaderFooterView ()
TFY_PROPERTY_OBJECT_STRONG(UILabel, serviceNameLabel);
TFY_PROPERTY_OBJECT_STRONG(UIButton, showButton);
@end

@implementation TFY_DetailHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.frame = CGRectMake(0, 0, TFY_Width_W(), 40);
        self.backgroundView = nil;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self viewTemplate];
        [self configConstraint];
    }
    return self ;
}
- (void)viewTemplate {
    [self.contentView addSubview:self.serviceNameLabel];
    [self.contentView addSubview:self.showButton];
}

- (void)configConstraint {
    self.serviceNameLabel
    .tfy_LeftSpace(10)
    .tfy_TopSpace(10)
    .tfy_RightSpace(10)
    .tfy_Height(50);
    
    self.showButton
    .tfy_RightSpace(10)
    .tfy_TopSpaceEqualView(self.serviceNameLabel)
    .tfy_size(TFY_DEBI_width(50), 30);
}


- (void)setServiceName:(NSString *)serviceName {
    _serviceName = serviceName ;
    self.serviceNameLabel.text  =serviceName ;
}

- (void)setSectionState:(NSInteger)sectionState {
    _sectionState = sectionState ;
    self.showButton.hidden = sectionState==-1;
    if (sectionState) {
        [self.showButton setTitle:@"隐藏" forState:UIControlStateNormal];
    } else {
        [self.showButton setTitle:@"显示" forState:UIControlStateNormal];
    }
}
- (void)showButtonClick:(UIButton *)button {
    if (_callback) {
        _callback([button.titleLabel.text isEqualToString:@"显示"]);
    }
}

- (UILabel *)serviceNameLabel {
    if (!_serviceNameLabel) {
        _serviceNameLabel = UILabelSet();
        _serviceNameLabel.makeChain
        .textColor(UIColor.lightGrayColor)
        .font([UIFont boldSystemFontOfSize:20]);
    }
    return _serviceNameLabel ;
}

- (UIButton *)showButton {
    if (!_showButton) {
        _showButton = UIButtonSet();
        _showButton.makeChain
        .textColor(UIColor.blueColor, UIControlStateNormal)
        .text(@"展开", UIControlStateNormal)
        .addTarget(self, @selector(showButtonClick:), UIControlEventTouchUpInside);
    }
    return _showButton;
}
@end
