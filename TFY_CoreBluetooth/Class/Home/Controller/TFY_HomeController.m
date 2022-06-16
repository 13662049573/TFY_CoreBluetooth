//
//  TFY_HomeController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_HomeController.h"
#import "TFY_HomeTableViewCell.h"
#import "TFY_DetailViewController.h"
@interface TFY_HomeController ()<UITableViewDelegate,UITableViewDataSource>
TFY_PROPERTY_OBJECT_STRONG(UITableView, tableView);
TFY_PROPERTY_OBJECT_STRONG(TFY_EasyCenterManager, centerManager);
TFY_PROPERTY_NSMutableArray(dataArray);
@end

@implementation TFY_HomeController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.centerManager startScanDevice];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.centerManager stopScanDevice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"蓝牙列表";
    [self.view addSubview:self.tableView];
    [self.tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
    // 0000FC00-0000-1000-8000-00805F9B34FB
    CBUUID *dfuServiceUUID = [CBUUID UUIDWithString:@"0000FFF0-0000-1000-8000-00805F9B34FB"];
    TFY_WEAK;
    [self.centerManager scanDeviceWithTimeInterval:LONG_MAX services:@[] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }  callBack:^(TFY_EasyPeripheral *peripheral, searchFlagType searchType) {
       
        TFY_BlueModel *model = [[TFY_BlueModel alloc] initWithEasyCenterManager:peripheral];
        
        NSLog(@"==================================%@-------%@",model.name,model.identifierString);
        
        if (peripheral) {
             if(searchType&searchFlagTypeAdded){
                [weakSelf.dataArray addObject:peripheral];
            }
            else if (searchType&searchFlagTypeDisconnect || searchType&searchFlagTypeDelete){
                [weakSelf.dataArray removeObject:peripheral];
            }
            Blue_queueMainStart
            // 排序key, 某个对象的属性名称，是否升序, YES-升序, NO-降序
            NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"RSSI" ascending:NO];
            //给数组添加排序规则
            // //给数组添加排序规则
            NSArray *arr = [self.dataArray sortedArrayUsingDescriptors:@[sort1]];
               
            self.dataArray = [NSMutableArray arrayWithArray:arr];
            
            [weakSelf.tableView reloadData];
            Blue_queueEnd
        }
    }];
    
    self.centerManager.stateChangeCallback = ^(TFY_EasyCenterManager *manager, CBManagerState state) {
        [weakSelf managerStateChanged:state];
    };
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *iden = [NSString stringWithFormat:@"%ld%ld",indexPath.row,indexPath.section];
    TFY_HomeTableViewCell *cell = [TFY_HomeTableViewCell tfy_cellFromCodeWithTableView:tableView identifier:iden];
    cell.peripheral = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.centerManager stopScanDevice];
    TFY_WEAK;
    TFY_EasyPeripheral *peripheral = self.dataArray[indexPath.row];
    if (peripheral.state == CBPeripheralStateConnected) {
        
        TFY_DetailViewController *tooD = [[TFY_DetailViewController alloc]init];
        tooD.peripheral = peripheral ;
        tooD.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:tooD animated:YES];
        
    } else {
        [TFY_ProgressHUD showWithStatus:@"正在连接设备..."];
        [peripheral connectDeviceWithCallback:^(TFY_EasyPeripheral *perpheral, NSError *error, deviceConnectType deviceConnectType) {
            [TFY_ProgressHUD dismissAllPopups];
            if (deviceConnectType == deviceConnectTypeDisConnect) {
                [weakSelf deviceDisconnect:peripheral error:error];
            }
            else{
                [weakSelf deviceConnect:peripheral error:error];
            }
        }];
    }
}

#pragma mark - bluetooth callback

- (void)managerStateChanged:(CBManagerState)state {
    Blue_queueMainStart
    if (state == CBManagerStatePoweredOn) {
        UIView *coverView = [[UIApplication sharedApplication].keyWindow viewWithTag:1011];
        if (coverView) {
            [coverView removeFromSuperview];
            coverView = nil ;
        }
        UIViewController *vc = [TFY_EasyUtils topViewController];
        if ([vc isKindOfClass:[self class]]) {
            [self.centerManager startScanDevice];
        }
    } else if (state == CBManagerStatePoweredOff){
        UILabel *coverLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, TFY_Width_W(), TFY_Height_H())];
        coverLabel.font = [UIFont systemFontOfSize:20];
        coverLabel.tag = 1011;
        coverLabel.textAlignment = NSTextAlignmentCenter;
        coverLabel.text = @"系统蓝牙已关闭，请打开系统蓝牙";
        coverLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [[UIApplication sharedApplication].keyWindow addSubview:coverLabel];
    }
    Blue_queueEnd
}
- (void)deviceDisconnect:(TFY_EasyPeripheral *)peripheral error:(NSError *)error {
    TFY_WEAK;
    Blue_queueMainStart
    TFY_AlertControllerAlertCreate(@"设备失去连接", error.localizedDescription)
    .tfy_addDefaultAction(@"重新连接", 1)
    .tfy_addCancelAction(@"取消", 2)
    .tfy_actionTap(^(NSInteger index, UIAlertAction * _Nonnull action) {
        if (index==1) {
            //重新连接设备
            [peripheral reconnectDevice];
        } else {
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    }).tfy_showFromViewController(self);
    Blue_queueEnd
}

- (void)deviceConnect:(TFY_EasyPeripheral *)peripheral error:(NSError *)error {
    Blue_queueMainStart
    [TFY_ProgressHUD dismiss];
    if (error) {
        [TFY_ProgressHUD showErrorWithStatus:error.domain];
    } else {
        TFY_DetailViewController *tooD = [[TFY_DetailViewController alloc]init];
        tooD.peripheral = peripheral ;
        tooD.hidesBottomBarWhenPushed = YES;
        [self.navigationController  pushViewController:tooD animated:YES];
    }
    Blue_queueEnd
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = NSMutableArray.array;
    }
    return _dataArray;
}

- (TFY_EasyCenterManager *)centerManager {
    if (!_centerManager) {
        dispatch_queue_t queue = dispatch_queue_create("lmeng.tempvision.bluetoothManager", DISPATCH_QUEUE_SERIAL);
        _centerManager = [[TFY_EasyCenterManager alloc] initWithQueue:queue options:@{}];
    }
    return _centerManager;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = UITableViewCreateWithStyle(UITableViewStyleGrouped);
        _tableView.makeChain
        .showsHorizontalScrollIndicator(NO)
        .showsVerticalScrollIndicator(NO)
        .adJustedContentIOS11()
        .rowHeight(80)
        .estimatedSectionHeaderHeight(0.01)
        .estimatedSectionFooterHeight(0.01)
        .delegate(self)
        .dataSource(self)
        .backgroundColor(UIColor.whiteColor);
    }
    return _tableView;
}

@end
