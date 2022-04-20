//
//  TFY_DetailViewController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_DetailViewController.h"
#import "TFY_DetailOneTableViewCell.h"
#import "TFY_DetailHeaderFooterView.h"
#import "TFY_DetailHeaderView.h"
#import "TFY_DetailOperationController.h"
@interface TFY_DetailViewController ()<UITableViewDelegate,UITableViewDataSource>
TFY_PROPERTY_OBJECT_STRONG(UITableView, tableView);
TFY_PROPERTY_NSArray(advertisementArray);
TFY_PROPERTY_BOOL(exitBreakUp);
TFY_PROPERTY_ASSIGN __block BOOL isShowfirstSection;//第一行是否打开

@end

@implementation TFY_DetailViewController

- (void)dealloc {
    //如果你想退出界面断开与设备的连接。就加上这句
    if (self.exitBreakUp) {
        [self.peripheral disconnectDevice];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蓝牙详情";
    self.exitBreakUp = YES;
    //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出断开连接" style:UIBarButtonItemStylePlain target:self action:@selector(barbuttonClick:)];
    
    self.advertisementArray = [self.peripheral.advertisementData allKeys];
    
    [self.view addSubview:self.tableView];
    [self.tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
    
    [TFY_ProgressHUD showWithStatus:@"获取服务数据..."];
    TFY_WEAK;
    [self.peripheral discoverAllDeviceServiceWithCallback:^(TFY_EasyPeripheral *peripheral, NSArray<TFY_EasyService *> *serviceArray, NSError *error) {
        
        NSLog(@"%@  =11111111= %@",serviceArray,error);

        for (TFY_EasyService *tempS in serviceArray) {
            NSLog(@" %@  22222222= %@",tempS.UUID ,tempS.description);

            [tempS discoverCharacteristicWithCallback:^(NSArray<TFY_EasyCharacteristic *> *characteristics, NSError *error) {
                NSLog(@" %@  33333333= %@",characteristics , error );
                
                for (TFY_EasyCharacteristic *tempC in characteristics) {
                    [tempC discoverDescriptorWithCallback:^(NSArray<TFY_EasyDescriptor *> *descriptorArray, NSError *error) {
                        NSLog(@"%@ 44444444444====", descriptorArray)  ;
                        if (descriptorArray.count > 0) {
                            for (TFY_EasyDescriptor *d in descriptorArray) {
                                NSLog(@"%@ 5555555555555- %@ %@ ", d,d.UUID ,d.value);
                            }
                        }
                        for (TFY_EasyDescriptor *desc in descriptorArray) {
                            [desc readValueWithCallback:^(TFY_EasyDescriptor *descriptor, NSError *error) {
                                NSLog(@"读取描述的值：---------6666666666666------------%@ ,%@ ",descriptor.value,error);
                            }];
                        }
                        Blue_queueMainStart
                        [TFY_ProgressHUD dismiss];
                        [weakSelf.tableView reloadData ];
                        Blue_queueEnd
                    }];
                }
            }];
        }
    }];
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.peripheral.serviceArray.count + 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) {
        TFY_EasyService *tempService = self.peripheral.serviceArray[section-1];
        return tempService.characteristicArray.count ;
    }
    if (_isShowfirstSection) {
        return self.peripheral.advertisementData.count ;
    }
    return 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TFY_DetailOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TFY_DetailOneTableViewCell.class)];
    cell.accessoryType = indexPath.section ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone ;
    if (indexPath.section) {
        TFY_EasyService *tempS = self.peripheral.serviceArray[indexPath.section-1] ;
        TFY_EasyCharacteristic *tempC = tempS.characteristicArray[indexPath.row];
        cell.character = tempC ;
    }
    else{
        cell.titleString = self.advertisementArray[indexPath.row];
        cell.subTitleString = self.peripheral.advertisementData[self.advertisementArray[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section) {
        
        TFY_EasyService *tempS = self.peripheral.serviceArray[indexPath.section-1];
        TFY_EasyCharacteristic *tempC = tempS.characteristicArray[indexPath.row];
        
        TFY_DetailOperationController *option = [[TFY_DetailOperationController alloc]init];
        option.characteristic = tempC;
        [self.navigationController pushViewController:option animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TFY_DetailHeaderFooterView *headerView = (TFY_DetailHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(TFY_DetailHeaderFooterView.class)];
    NSString *serviceName = @"广告数据" ;
    if (section) {
        TFY_EasyService *tempS = self.peripheral.serviceArray[section-1];
        serviceName = tempS.name ;
        NSLog(@"characteristicArray----%@--UUID-%@",tempS.characteristicArray,tempS.UUID);
    }
    headerView.serviceName = serviceName ;
    headerView.sectionState = section==0 ? self.isShowfirstSection : -1 ;
    TFY_WEAK;
    headerView.callback = ^(BOOL isHidden){
        weakSelf.isShowfirstSection = isHidden ;
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    };
    return headerView ;
}

- (void)barbuttonClick:(UIBarButtonItem *)button {
    if ([button.title isEqualToString:@"退出断开连接"]) {
        _exitBreakUp = NO ;
        [button setTitle:@"退出不断开连接"];
    } else {
        _exitBreakUp = YES ;
        [button setTitle:@"退出断开连接"];
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = UITableViewCreateWithStyle(UITableViewStyleGrouped);
        _tableView.makeChain
        .showsHorizontalScrollIndicator(NO)
        .showsVerticalScrollIndicator(NO)
        .adJustedContentIOS11()
        .rowHeight(55)
        .estimatedSectionHeaderHeight(0.01)
        .estimatedSectionFooterHeight(0.01)
        .delegate(self)
        .dataSource(self)
        .backgroundColor(UIColor.whiteColor)
        .registerCellClass(TFY_DetailOneTableViewCell.class, NSStringFromClass(TFY_DetailOneTableViewCell.class))
        .registerViewClass(TFY_DetailHeaderFooterView.class, NSStringFromClass(TFY_DetailHeaderFooterView.class))
        .tableHeaderView([TFY_DetailHeaderView headerViewWithPeripheral:self.peripheral]);
    }
    return _tableView;
}

@end
