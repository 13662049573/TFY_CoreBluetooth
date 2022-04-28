//
//  TFY_MineController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_MineController.h"
#import "TFY_MineTableViewCell.h"
#import "TFY_ExampleScanNameController.h"
#import "TFY_ExampleScanRuleController.h"
#import "TFY_ExampleSavedController.h"
#import "TFY_ExampleOneLineCodeController.h"
#import "TFY_ExampleAllRuleDeviceController.h"

@interface TFY_MineController ()<UITableViewDelegate,UITableViewDataSource>
TFY_PROPERTY_NSArray(dataArray);
TFY_PROPERTY_OBJECT_STRONG(TFY_EasyBlueToothManager, bleManager);
TFY_PROPERTY_OBJECT_STRONG(UITableView, tableView);
@end

@implementation TFY_MineController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蓝牙分布处理";
    
    [self.view addSubview:self.tableView];
    [self.tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
}

#pragma mark - Tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFY_MineTableViewCell *cell = [TFY_MineTableViewCell tfy_cellFromCodeWithTableView:tableView];
    cell.titleString = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self tableViewDidSelectIndex:indexPath.row];
}

#pragma mark - ble manager
- (void)tableViewDidSelectIndex:(long)index {
    UIViewController *vc =nil ;
    switch (index) {
        case 0:vc = [[TFY_ExampleScanNameController alloc]init]; break;
        case 1:vc = [[TFY_ExampleScanRuleController alloc]init];  break;
        case 2:vc = [[TFY_ExampleSavedController alloc]init];break ;
        case 3:vc = [[TFY_ExampleOneLineCodeController alloc]init];break ;
        default:vc= [[TFY_ExampleAllRuleDeviceController alloc]init]; break;
    }
    ((TFY_ExampleSavedController *)vc).bleManager = self.bleManager;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - getter

- (UIView *)tableHeaderView
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, TFY_Width_W() , 100)];
    label.text = @"请选择一种连接方式";
    label.textAlignment = NSTextAlignmentCenter ;
    label.font = [UIFont boldSystemFontOfSize:20];
    return label ;
}


- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"指定名称连接设备",
                       @"指定规则连接设备",
                       @"扫描指定保存到本地的设备",
                       @"一行代码连接设备"];
    }
    return _dataArray;
}

- (TFY_EasyBlueToothManager *)bleManager {
    if (!_bleManager) {
        _bleManager = [TFY_EasyBlueToothManager shareInstance];
        CBUUID *dfuServiceUUID = [CBUUID UUIDWithString:@"08AA381C-5777-F298-8747-7BA47F4B3673"];
        dispatch_queue_t queue = dispatch_queue_create("tfy.TFY-CoreBluetooth", 0);
        NSDictionary *managerDict = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
        NSDictionary *scanDict = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
        NSDictionary *connectDict = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
        
        TFY_EasyManagerOptions *options = [[TFY_EasyManagerOptions alloc]initWithManagerQueue:queue managerDictionary:managerDict scanOptions:scanDict scanServiceArray:@[] connectOptions:connectDict];
        options.scanTimeOut = 6 ;
        options.connectTimeOut = 5 ;
        options.autoConnectAfterDisconnect = YES ;
        
        [TFY_EasyBlueToothManager shareInstance].managerOptions = options ;
    }
    return _bleManager ;
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
