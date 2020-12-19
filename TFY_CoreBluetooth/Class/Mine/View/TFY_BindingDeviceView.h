//
//  TFY_BindingDeviceView.h
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TFY_BindingDeviceView ;

@protocol BindingDeviceViewProtocol <NSObject>

- (void)BindingDeviceViewCancel:(TFY_BindingDeviceView *)view ;
- (void)BindingDeviceViewSure:(TFY_BindingDeviceView *)view device:(NSString *)device;

@end

@interface TFY_BindingDeviceView : UIView

+ (instancetype)BindingDeviceViewDelegate:(id<BindingDeviceViewProtocol>)Delegate dataArray:(NSArray *)dataArray ;
@end

NS_ASSUME_NONNULL_END
