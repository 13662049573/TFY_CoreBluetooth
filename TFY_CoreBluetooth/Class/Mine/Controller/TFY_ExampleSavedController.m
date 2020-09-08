//
//  TFY_ExampleSavedController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ExampleSavedController.h"
#import "TFY_BindingDeviceView.h"

static NSString *const savedUUID = @"0000FC00-0000-1000-8000-00805F9B34FB" ;

@interface TFY_ExampleSavedController ()<BindingDeviceViewProtocol>

@end

@implementation TFY_ExampleSavedController

- (void)dealloc {
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设备保存到本地";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"解绑设备" style:UIBarButtonItemStylePlain target:self action:@selector(barbuttonClick)];
    self.navigationItem.rightBarButtonItem = item ;
    
    NSString *saveduuid = [TFY_Utils getStrValueInUDWithKey:savedUUID];
    TFY_WEAK;
    if (saveduuid.tfy_isNotBlank) {
        [weakSelf connectDevices];
    } else {
        [TFY_ProgressHUD showPromptWithStatus:@"寻找设备中..."];
        [self.bleManager scanAllDeviceWithName:@"GS-BBT" callback:^(NSArray<TFY_EasyPeripheral *> *deviceArray, NSError *error) {
          
            Blue_queueMainStart
            [TFY_ProgressHUD dismiss];
            
            if (deviceArray.count) {
                TFY_BindingDeviceView *view = [TFY_BindingDeviceView BindingDeviceViewDelegate:self dataArray:deviceArray];
                [weakSelf.view addSubview:view];
            }
            else{
                [TFY_ProgressHUD showPromptWithStatus:@"没搜索到设备..."];
            }
            Blue_queueEnd
        }];
    }
}
-(void)barbuttonClick
{
    [TFY_Utils saveStrValueInUD:@"" forKey:savedUUID];
    [TFY_ProgressHUD showPromptWithStatus:@"解绑成功"];
}
- (void)BindingDeviceViewSure:(TFY_BindingDeviceView *)view device:(NSString *)device
{
    [TFY_Utils saveStrValueInUD:device forKey:savedUUID];
    [self connectDevices];
    
    Blue_queueMainStart
    [TFY_ProgressHUD showPromptWithStatus:@"设备绑定成功"];
    Blue_queueEnd
    
}
- (void)BindingDeviceViewCancel:(TFY_BindingDeviceView *)view
{

}

- (void)connectDevices
{
    NSString *unsavedUUID = [TFY_Utils getStrValueInUDWithKey:savedUUID];
    [TFY_ProgressHUD showWithStatus:@"正在连接设备..."];
    [self.bleManager connectDeviceWithIdentifier:unsavedUUID callback:^(TFY_EasyPeripheral *peripheral, NSError *error) {
        Blue_queueMainStart
        [TFY_ProgressHUD showPromptWithStatus:@"设备连接成功"];
        Blue_queueEnd
    }];
}


@end
