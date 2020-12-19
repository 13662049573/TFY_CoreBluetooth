//
//  TFY_ExampleOneLineCodeController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ExampleOneLineCodeController.h"

@interface TFY_ExampleOneLineCodeController ()

@end

@implementation TFY_ExampleOneLineCodeController

- (void)dealloc {
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
         self.title = @"一行代码连接设备";
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.bleManager.bluetoothStateChanged = ^(TFY_EasyPeripheral *peripheral, bluetoothState state) {
            NSLog(@" ====== %lu ", (unsigned long)state);
        } ;
    
        Byte bytes[6]= {0xfe ,0x81,0x00,0x00,0x00,0x01};
        NSData *D = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
        [self.bleManager connectDeviceWithName:@"F5:E:13:A1:22:A6" serviceUUID:@"00001809-0000-1000-8000-00805F9B34FB" notifyUUID:@"00002A1C-0000-1000-8000-00805F9B34FB" wirteUUID:@"00002A19-0000-1000-8000-00805F9B34FB" writeData:D callback:^(NSData *data, NSError *error) {
            NSLog(@"%@ -- %@",data ,error );
        }];
}



@end
