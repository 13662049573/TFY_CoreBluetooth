//
//  TFY_ExampleScanNameController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ExampleScanNameController.h"

#define UUID_SERVICE @"0000FFF0-0000-1000-8000-00805F9B34FB"
#define UUID_WRITE @"0000FFF1-0000-1000-8000-00805F9B34FB"
#define UUID_NOTIFICATION @"0000FFF1-0000-1000-8000-00805F9B34FB"
#define CCCD_READ @"00002902-0000-1000-8000-00805f9b34fb"

@interface TFY_ExampleScanNameController ()
TFY_PROPERTY_OBJECT_STRONG(TFY_EasyPeripheral, peripheral);
@end

@implementation TFY_ExampleScanNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描设备名称";
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.bleManager.bluetoothStateChanged = ^(TFY_EasyPeripheral *peripheral, bluetoothState state) {
        Blue_queueMainStart
        switch (state) {
            case bluetoothStateSystemReadly:
                [TFY_ProgressHUD showSuccessWithStatus:@"蓝牙已准备就绪.."];
                break;
            case bluetoothStateDeviceFounded:
                [TFY_ProgressHUD showSuccessWithStatus:@"已发现设备"];
                break ;
                case bluetoothStateDeviceConnected:
                [TFY_ProgressHUD showSuccessWithStatus:@"设备连成功"];
            default:
                break;
        }
        Blue_queueEnd
    };
    [TFY_ProgressHUD showWithStatus:@"正在扫描并连接设别..."];
    TFY_WEAK;
    [self.bleManager scanAndConnectDeviceWithName:@"HS_BLE" callback:^(TFY_EasyPeripheral *peripheral, NSError *error) {
        if (!error) {
            weakSelf.peripheral = peripheral ;
            
            TFY_BlueModel *model = [[TFY_BlueModel alloc] initWithEasyCenterManager:peripheral];
            
            NSLog(@"identifierString------%@============%@",model.macip,model.identifierString);
        }
    }];
    NSArray *arr = @[@"APP设定时间",@"APP设定单位",@"APP同意连接",@"APP请求同步-APP读取记忆",@"APP同步成功-APP读取成功",@"读取实时温度",@"读取数据",@"监听数据",@"取消监听"];
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

- (void)sendOrder:(UIButton *)btn
{
    NSData *data;
    if (btn.tag==10) {
           data = [TFY_EasyUtils convertHexStrToData:@"22HY63475E15"];//FA 03 12 04 0E 08 00 2F
        [self hhhhhhdata:data];
    }
    if (btn.tag==11) {
         data = [TFY_EasyUtils convertHexStrToData:@"22HY63475E15"];//
        [self hhhhhhdata:data];
    }
    if (btn.tag==12) {
        data = [TFY_EasyUtils convertHexStrToData:@"22HY63475E15"];
        NSLog(@"===========================%@",[TFY_EasyUtils convertDataToHexStr:data]);
        [self hhhhhhdata:data];
    }
    if (btn.tag==13) {
        data = [TFY_EasyUtils convertHexStrToData:@"22HY63475E15"];//
        [self hhhhhhdata:data];
    }
    if (btn.tag==14) {
        data = [TFY_EasyUtils convertHexStrToData:@"22HY63475E15"];//
        [self hhhhhhdata:data];
    }
    if (btn.tag==15) {
        data = [TFY_EasyUtils convertHexStrToData:@"22HY63475E15"];//
        [self hhhhhhdata:data];
    }
    if (btn.tag==16) {
        [TFY_ProgressHUD showWithStatus:@"提示...."];
        Blue_queueGlobalStart
        
        [self.bleManager readValueWithPeripheral:self.peripheral serviceUUID:UUID_SERVICE readUUID:@"00002902-0000-1000-8000-00805f9b34fb" callback:^(NSData *data, NSError *error) {
            
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
    if (btn.tag==17) {
        [TFY_ProgressHUD showWithStatus:@"提示...."];
        Blue_queueGlobalStart
        
         [self.bleManager notifyDataWithPeripheral:self.peripheral serviceUUID:UUID_SERVICE notifyUUID:UUID_NOTIFICATION notifyValue:YES withCallback:^(NSData *data, NSError *error) {
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
    if (btn.tag==18) {
        [TFY_ProgressHUD showWithStatus:@"提示...."];
        Blue_queueGlobalStart
        
         [self.bleManager notifyDataWithPeripheral:self.peripheral serviceUUID:UUID_SERVICE notifyUUID:UUID_NOTIFICATION notifyValue:NO withCallback:^(NSData *data, NSError *error) {
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
