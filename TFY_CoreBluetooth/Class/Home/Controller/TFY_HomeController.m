//
//  TFY_HomeController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_HomeController.h"

@interface TFY_HomeController ()
TFY_PROPERTY_OBJECT_STRONG(UITableView, tableView);
TFY_PROPERTY_OBJECT_STRONG(TFY_EasyCenterManager, centerManager);
TFY_PROPERTY_NSMutableArray(dataArray);
@end

@implementation TFY_HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蓝牙列表";
}



@end
