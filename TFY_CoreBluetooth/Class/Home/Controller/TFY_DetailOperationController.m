//
//  TFY_DetailOperationController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_DetailOperationController.h"
#import "TFY_DetailOperationCell.h"
#import "TFY_DetailHeaderFooterView.h"

@interface TFY_DetailOperationController ()<UITableViewDelegate,UITableViewDataSource>
TFY_PROPERTY_OBJECT_STRONG(UITableView, tableView);
TFY_PROPERTY_NSMutableArray(dataArray);
TFY_PROPERTY_OBJECT_STRONG(UITextField, currentField);
@end

@implementation TFY_DetailOperationController

- (void)dealloc {
    [self.characteristic removeObserver:self forKeyPath:@"notifyDataArray"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
    
    NSArray *array  = [self.characteristic.propertiesString componentsSeparatedByString:@" "];
    self.dataArray = [NSMutableArray arrayWithArray:array];
    
    [self.tableView reloadData];
    
    [self.characteristic addObserver:self forKeyPath:@"notifyDataArray" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"notifyDataArray"]) {
        TFY_WEAK;
        Blue_queueMainStart
        [weakSelf.tableView reloadData];
        Blue_queueEnd
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count + 2 ;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.dataArray.count ) {
        NSString *tempString = self.dataArray[section];
        if ([tempString isEqualToString:@"Write"]||[tempString isEqualToString:@"WithoutResponse"]) {
            return self.characteristic.writeDataArray.count + 1 ;
        }
        else if ([tempString isEqualToString:@"Read"]){
            return self.characteristic.readDataArray.count + 1;
        }
        else if ([tempString isEqualToString:@"Notify"]||[tempString isEqualToString:@"Indicate"]){
            return self.characteristic.notifyDataArray.count + 1 ;
        }
        else{
            return 0 ;
        }
    }
    else if(section == self.dataArray.count){
        return self.characteristic.descriptorArray.count ;
    }
    else{
        return self.dataArray.count ;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFY_DetailOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TFY_DetailOperationCell.class)];
  
    cell.isOperation  = (indexPath.section<self.dataArray.count)&&(!indexPath.row);
 
    if (indexPath.section < self.dataArray.count ) {
        
        NSString *tempString = self.dataArray[indexPath.section];
        if (indexPath.row == 0) {
            cell.title = [NSString stringWithFormat:@"%@ 新的价值",tempString] ;
            if ([tempString isEqualToString:@"Notify"]) {
                cell.title = [NSString stringWithFormat:@"%@",self.characteristic.isNotifying?@"停止通知 ":@"点击开始通知"];
            }
        }else{
            if ([tempString isEqualToString:@"Write"] ||[tempString isEqualToString:@"WithoutResponse"]) {
                cell.title = [TFY_EasyUtils convertDataToHexStr:self.characteristic.writeDataArray[indexPath.row-1]];
            }
            else if ([tempString isEqualToString:@"Read"]){
                cell.title = [TFY_EasyUtils convertDataToHexStr:self.characteristic.readDataArray[indexPath.row-1]];
            }
            else if ([tempString isEqualToString:@"Notify"]||[tempString isEqualToString:@"Indicate"]){
                cell.title = [TFY_EasyUtils convertDataToHexStr:self.characteristic.notifyDataArray[indexPath.row-1]];
            }
            
        }
        
    }
    else if (indexPath.section == self.dataArray.count){
        TFY_EasyDescriptor *tempD = self.characteristic.descriptorArray[indexPath.row];
        cell.title = [NSString stringWithFormat:@"%@",tempD.UUID];
    }
    else{
        cell.title = self.dataArray[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section < self.dataArray.count && !indexPath.row) {
        NSString *tempString = self.dataArray[indexPath.section];
        
        if ([tempString isEqualToString:@"Write"]||[tempString isEqualToString:@"WithoutResponse"]) {
            TFY_AlertControllerAlertCreate(@"提示", @"输入文本")
            .tfy_addCancelAction(@"取消", 0)
            .tfy_addDefaultAction(@"确定", 1)
            .tfy_alertTitleAttributeFontWithColor([UIFont systemFontOfSize:14], UIColor.blackColor)
            .tfy_addTextField(^(UITextField * _Nonnull textField) {
                textField.makeChain.placeholder(@"文本").font([UIFont systemFontOfSize:13]).textColor(UIColor.blackColor);
                self.currentField = textField;
            })
            .tfy_actionTap(^(NSInteger index, UIAlertAction * _Nonnull action) {
                if (index==1) {
                    if (self.currentField.text.length == 0) {
                        return;
                    }
                    NSData *data = [TFY_EasyUtils convertHexStrToData:self.currentField.text];
                     [self.characteristic writeValueWithData:data callback:^(TFY_EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                         TFY_WEAK;
                         Blue_queueMainStart
                          if (error!=nil) {
                              [TFY_ProgressHUD showErrorWithStatus:error.domain duration:5];
                          }
                          else{
                              NSString *string = [TFY_EasyUtils convertDataToHexStr:data];
                              [TFY_ProgressHUD showPromptWithStatus:string duration:5];
                          }
                         [weakSelf.tableView reloadData];
                         Blue_queueEnd
                     }];
                }
            })
            .tfy_showFromViewController(self);
        }
        else if ([tempString isEqualToString:@"Read"]){
            [self.characteristic readValueWithCallback:^(TFY_EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                TFY_WEAK;
                Blue_queueMainStart
                 if (error!=nil) {
                     [TFY_ProgressHUD showErrorWithStatus:error.domain duration:5];
                 }
                 else{
                     NSString *string = [TFY_EasyUtils convertDataToHexStr:data];
                     [TFY_ProgressHUD showPromptWithStatus:string duration:5];
                 }
                [weakSelf.tableView reloadData];
                Blue_queueEnd
            
            }];
        }
        else if ([tempString isEqualToString:@"Notify"]||[tempString isEqualToString:@"Indicate"]){
            [self.characteristic notifyWithValue:!self.characteristic.isNotifying callback:^(TFY_EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                TFY_WEAK;
                Blue_queueMainStart
                if (error!=nil) {
                    [TFY_ProgressHUD showErrorWithStatus:error.domain duration:5];
                }
                else{
                    NSString *string = [TFY_EasyUtils convertDataToHexStr:data];
                    [TFY_ProgressHUD showPromptWithStatus:string duration:5];
                }
                [weakSelf.tableView reloadData];
                Blue_queueEnd
            }];
            
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TFY_DetailHeaderFooterView *headerView = (TFY_DetailHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(TFY_DetailHeaderFooterView.class)];
    if (section < self.dataArray.count ) {
        headerView.serviceName = self.dataArray[section];
    }
    else if (section == self.dataArray.count){
        headerView.serviceName = @"描述";
    }else{
        headerView.serviceName = @"性能";
    }
    return headerView ;
}

- (NSMutableArray *)dataArray
{
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray ;
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
        .backgroundColor(UIColor.whiteColor)
        .registerCellClass(TFY_DetailOperationCell.class, NSStringFromClass(TFY_DetailOperationCell.class))
        .registerViewClass(TFY_DetailHeaderFooterView.class, NSStringFromClass(TFY_DetailHeaderFooterView.class));
    }
    return _tableView;
}
@end
