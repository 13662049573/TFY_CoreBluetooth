//
//  TFY_ExampleScanRuleController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ExampleScanRuleController.h"

@interface TFY_ExampleScanRuleController ()

@end

@implementation TFY_ExampleScanRuleController

- (void)dealloc {
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"条件扫描设备名称";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [TFY_ProgressHUD showPromptWithStatus:@"正在扫描设备" duration:3];
    [self.bleManager scanAllDeviceAsyncWithRule:^BOOL(TFY_EasyPeripheral *peripheral) {
        
        NSLog(@"%@ == %@ == %@",peripheral.advertisementData.allValues,peripheral.name,peripheral.RSSI) ;
        return  peripheral.name.length > 5 ;
        
    } callback:^(TFY_EasyPeripheral *peripheral, searchFlagType searchFlagType, NSError *error) {
        
        NSLog(@"%@ == %lu == %@",peripheral,(unsigned long)searchFlagType ,error) ;
    }];
}


@end
