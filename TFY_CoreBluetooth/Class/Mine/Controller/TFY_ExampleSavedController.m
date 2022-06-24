//
//  TFY_ExampleSavedController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ExampleSavedController.h"
#import "TFY_BindingDeviceView.h"
#import "TFY_DetailViewController.h"

static NSString *const savedUUID = @"0000FC00-0000-1000-8000-00805F9B34FB" ;

#define UUID_SERVICE @"0000FFF0-0000-1000-8000-00805F9B34FB"
#define UUID_WRITE @"0000FFF1-0000-1000-8000-00805F9B34FB"
#define UUID_NOTIFICATION @"0000FFF1-0000-1000-8000-00805F9B34FB"
#define CCCD_READ @"00002902-0000-1000-8000-00805f9b34fb"

@interface TFY_ExampleSavedController ()<BindingDeviceViewProtocol>
@property (nonatomic , strong)TFY_EasyPeripheral *peripheral;
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
        [self.bleManager scanAllDeviceWithName:@"BLE-GUC2" callback:^(NSArray<TFY_EasyPeripheral *> *deviceArray, NSError *error) {
          
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
    
    NSArray *arr = @[@"写入数据"];
    for (NSInteger i=0; i<arr.count; i++) {
        UIButton *button  =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor redColor]];
        [button setFrame:CGRectMake(0, 64+i*60, [UIScreen mainScreen].bounds.size.width, 50)];
        [button setTitle:arr[i] forState:UIControlStateNormal];
        button.tag = i+10;
        [button addTarget:self action:@selector(sendOrder:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)sendOrder:(UIButton *)btn {
   NSData *data = [TFY_EasyUtils convertHexStrToData:@"22HY63475E15"];//FA 03 12 04 0E 08 00 2F
   [self hhhhhhdata:data];
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
        self.peripheral = peripheral;
        
        TFY_BlueModel *model = [[TFY_BlueModel alloc] initWithEasyCenterManager:peripheral];
        
        NSLog(@"identifierString------%@============%@",model.macip,model.identifierString);
        Blue_queueMainStart
        [TFY_ProgressHUD showPromptWithStatus:@"设备连接成功"];
//        TFY_DetailViewController *tooD = [[TFY_DetailViewController alloc]init];
//        tooD.peripheral = peripheral ;
//        tooD.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:tooD animated:YES];
        Blue_queueEnd
    
    }];
}

-(void)hhhhhhdata:(NSData *)data{
    [TFY_ProgressHUD showPromptWithStatus:@"写入中..." duration:1.5];
    Blue_queueGlobalStart
    [self.bleManager writeDataWithPeripheral:self.peripheral serviceUUID:UUID_SERVICE writeUUID:UUID_WRITE data:data callback:^(NSData *data, NSError *error) {
             Blue_queueMainStart
            if (error!=nil) {
                [TFY_ProgressHUD showErrorWithStatus:error.domain duration:5];
            }
            else{
                
                NSString *string = [TFY_EasyUtils convertDataToHexStr:data];
                [TFY_ProgressHUD showPromptWithStatus:string duration:5];
            }
          Blue_queueEnd
    }];
    Blue_queueEnd
}

@end
