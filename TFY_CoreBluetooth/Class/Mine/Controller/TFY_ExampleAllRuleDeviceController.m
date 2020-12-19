//
//  TFY_ExampleAllRuleDeviceController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ExampleAllRuleDeviceController.h"

@interface TFY_ExampleAllRuleDeviceController ()
TFY_PROPERTY_NSMutableArray(connectArray);
@end

@implementation TFY_ExampleAllRuleDeviceController

- (void)dealloc {
    [self.bleManager disconnectAllPeripheral];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.connectArray = NSMutableArray.array;
    
    [self.bleManager scanAndConnectAllDeviceWithRule:^BOOL(TFY_EasyPeripheral *peripheral) {
        
        NSLog(@"===========%@",peripheral.advertisementData.allValues);
        return peripheral.name.length > 5 ;
        
    } callback:^(NSArray<TFY_EasyPeripheral *> *deviceArray, NSError *error) {
        
        for (TFY_EasyPeripheral *tempP in deviceArray) {
            if (!tempP.connectErrorDescription) {
                [self.connectArray addObject:tempP];
            }
        }
    }];
}



@end
