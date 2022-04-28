//
//  TFY_EasyCenterManager.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_EasyCenterManager.h"
#import <UIKit/UIKit.h>
#import "TFY_EasyService.h"
#import "TFY_EasyPeripheral.h"
#import "TFY_EasyDescriptor.h"
#import "TFY_EasyCharacteristic.h"

@interface TFY_EasyCenterManager ()<CBCentralManagerDelegate>
{
    CBManagerState _centerState ;//当前系统蓝牙状态
    
    NSTimeInterval _scanTimeInterval ;      //当前扫描的时间
    NSArray<CBUUID *> *_scanServicesArray ;//扫描的条件
    NSDictionary<NSString *, id> *_scanOptionsDictionary ;//扫描条件
    blueToothSearchDeviceCallback _blueToothSearchDeviceCallback ;
    
}
@property (nonatomic, strong) NSMutableDictionary *foundDeviceDict;
@property (nonatomic, strong) NSMutableDictionary *connectedDeviceDict;
@end

@implementation TFY_EasyCenterManager

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    return [self initWithQueue:queue options:@{}];
}
- (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options
{
    if (self = [super init]) {
        Blue_EasyLog(@"manager 创建 %@",queue);
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:queue options:options];
        _scanTimeInterval = LONG_MAX ;
    }
    return self ;
}
- (void)startScanDevice
{
    [self scanDeviceWithTimeInterval:_scanTimeInterval
                            callBack:_blueToothSearchDeviceCallback];
}
- (void)scanDeviceWithTimeCallback:(blueToothSearchDeviceCallback)searchDeviceCallBack
{
    [self scanDeviceWithTimeInterval:_scanTimeInterval
                            callBack:searchDeviceCallBack];
}
- (void)scanDeviceWithTimeInterval:(NSTimeInterval)timeInterval
                          callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack
{
    [self scanDeviceWithTimeInterval:timeInterval
                            services:_scanServicesArray
                             options:_scanOptionsDictionary
                            callBack:searchDeviceCallBack];
}

- (void)scanDeviceWithTimeInterval:(NSTimeInterval)timeInterval
                          services:(NSArray<CBUUID *> *)service
                           options:(NSDictionary<NSString *, id> *)options
                          callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack
{
    NSAssert(searchDeviceCallBack, @"搜索设备回调为零");
    _scanTimeInterval = timeInterval ;
    _scanOptionsDictionary = options ;
    _scanServicesArray = service ;
    if (searchDeviceCallBack) {
        _blueToothSearchDeviceCallback = [searchDeviceCallBack copy] ;
    }
    
    [self stopScanDevice];
    
    _isScanning = YES ;
    
    NSArray *connectedArray = [self retrieveConnectedPeripheralsWithServices:service];
    [connectedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //如果不在扫描设备、已连接设备的集合中就加入其中，并通知外部调用者
        TFY_EasyPeripheral *easyP = (TFY_EasyPeripheral *)obj ;
        BOOL isExited = NO ;
        for (NSString *tempIdentify in [self.foundDeviceDict allKeys]) {
            if ([tempIdentify isEqualToString:easyP.identifierString]) {
                isExited = YES ;
                break  ;
            }
        }
        if (!isExited) {
            [self.foundDeviceDict setObject:easyP forKey:easyP.identifierString];
        }
        
        if (_blueToothSearchDeviceCallback) {
            _blueToothSearchDeviceCallback(easyP , isExited?searchFlagTypeChanged : searchFlagTypeAdded );
        }
    }];
    
    Blue_EasyLog_S(@"开始扫描设备 - 倒计时时长%.0f秒",timeInterval);
    [self.manager scanForPeripheralsWithServices:service options:options];

    //指定时间通知外部，扫描完成
    Blue_kWeakSelf(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self->_isScanning = NO ;
        
        if (weakself.manager.isScanning && self->_blueToothSearchDeviceCallback) {
            [weakself stopScanDevice];
            TFY_EasyPeripheral *PERIPHEERAL;
            self->_blueToothSearchDeviceCallback(PERIPHEERAL,searchFlagTypeFinish);
        }

        for (TFY_EasyPeripheral *tempP in self.foundDeviceDict.allValues) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
            [NSObject cancelPreviousPerformRequestsWithTarget:tempP
                                                     selector:@selector(devicenotFoundTimeout)
                                                       object:nil];
#pragma clang diagnostic pop
        }

    });
}

- (void)stopScanDevice
{
    if (_isScanning) {
        _isScanning = NO ;
    }
    Blue_EasyLog_S(@"停止扫描设备");
    [self.manager stopScan];
}

- (void)removeAllScanFoundDevice
{
    [self.foundDeviceDict removeAllObjects];
}

- (void)disConnectAllDevice
{
    for (TFY_EasyPeripheral *tempPeripheral in [self.connectedDeviceDict allValues]) {
        [tempPeripheral disconnectDevice];
    }
}

- (TFY_EasyPeripheral *)searchDeviceWithPeripheral:(CBPeripheral *)peripheral
{
    TFY_EasyPeripheral *result = nil;
    NSArray *tempArray = [NSArray arrayWithArray:[self.connectedDeviceDict allValues]];
    for (TFY_EasyPeripheral *tempPeripheral in tempArray) {
        if ([tempPeripheral.peripheral isEqual: peripheral]) {
            result = tempPeripheral;
            break;
        }
    }
    return result;
}
- (void)foundDeviceTimeout:(TFY_EasyPeripheral *)perpheral
{
    NSArray *allValues = [self.connectedDeviceDict allValues];
    [allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:perpheral]) {
            *stop = YES ;
            return  ;
        }
    }];
    
    __block BOOL isExitDevice ;
    NSArray *tempAllValues = self.foundDeviceDict.allValues;
    [tempAllValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:perpheral]) {
            isExitDevice = YES ;
            *stop = YES ;
        }
    }];
    if (isExitDevice) {
        [self.foundDeviceDict removeObjectForKey:perpheral.identifierString];
        
        if (_blueToothSearchDeviceCallback) {
            _blueToothSearchDeviceCallback(perpheral , searchFlagTypeDelete );
        }
    }
}

#pragma mark - centeral manager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //状态改变，清除所有连接 和发现的设别
    if (_centerState != central.state) {
//        [self disConnectAllDevice];
//        [self removeAllScanFoundDevice];
        
        if (_stateChangeCallback) {
            _stateChangeCallback(self , central.state );
        }
        
        Blue_EasyLog_R(@"系统蓝牙发生改变：之前状态：%zd ，改变后状态：%zd",_centerState,central.state) ;
        
    }
    _centerState = central.state ;
    
    if (_centerState == CBManagerStateUnsupported) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此设备不支持BLE4.0,请更换设备" preferredStyle:UIAlertControllerStyleAlert];
        [UIApplication sharedApplication].keyWindow.rootViewController = alert ;
    }
    switch (central.state) {
        case CBManagerStatePoweredOn:
            //            [self startScanDevice];
            break ;
        case CBManagerStatePoweredOff:
            break ;
        default:
            break ;
    }
    
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict
{
    Blue_EasyLog_R(@"蓝牙状态即将重置：%@ - %@",central , dict);

    //dict中会传入如下键值对
    /*
     3 //恢复连接的外设数组
     4 NSString *const CBCentralManagerRestoredStatePeripheralsKey;
     5 //恢复连接的服务UUID数组
     6 NSString *const CBCentralManagerRestoredStateScanServicesKey;
     7 //恢复连接的外设扫描属性字典数组
     8 NSString *const CBCentralManagerRestoredStateScanOptionsKey;
     9 */
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
//    if (peripheral.name.length == 0) {
        Blue_EasyLog_R(@"%@", [NSString stringWithFormat:@"发现一个设备 - %@ - %@" ,peripheral.name,peripheral.identifier] );
//    }
    //去掉重复搜索到的设备
    NSInteger existedIndex = -1 ;
    for (NSString *tempIndefy in [self.foundDeviceDict allKeys]) {
        if ([tempIndefy isEqualToString:peripheral.identifier.UUIDString]) {
            TFY_EasyPeripheral *tempP = self.foundDeviceDict[tempIndefy];
            tempP.deviceScanCount++ ;
            existedIndex = tempP.deviceScanCount ;
            break ;
        }
    }
    
    if (existedIndex == -1 ) {//扫描到了新设别
        TFY_EasyPeripheral *easyP = [[TFY_EasyPeripheral alloc]initWithPeripheral:peripheral central:self];
        easyP.RSSI = RSSI ;
        easyP.advertisementData = advertisementData ;
        [self.foundDeviceDict setObject:easyP forKey:easyP.identifierString];
        if (_blueToothSearchDeviceCallback) {
            _blueToothSearchDeviceCallback(easyP ,searchFlagTypeAdded );
        }
    }else if (existedIndex%10 == 0){//扫描到的此个设备超过10次
        TFY_EasyPeripheral *tempP = self.foundDeviceDict[peripheral.identifier.UUIDString];
        tempP.RSSI = RSSI ;
        tempP.deviceScanCount = 0 ;
        tempP.advertisementData = advertisementData ;
        if (_blueToothSearchDeviceCallback) {
            _blueToothSearchDeviceCallback(tempP , searchFlagTypeChanged );
        }
    }
}

#pragma mark - connect peripheral

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    Blue_EasyLog_R(@"蓝牙连接上一个设备：%@ , %@",peripheral,peripheral.identifier);
    
    TFY_EasyPeripheral *existedP = nil ;
    for (NSString *tempIden in [self.connectedDeviceDict allKeys]) {
        if ([tempIden isEqualToString:peripheral.identifier.UUIDString]) {
            existedP = self.connectedDeviceDict[tempIden] ;
            break  ;
        }
    }
    
    if (!existedP) {
        for (NSString *tempIden in [self.foundDeviceDict allKeys]) {
            if ([tempIden isEqualToString:peripheral.identifier.UUIDString]) {
                existedP = self.foundDeviceDict[tempIden] ;
                break  ;
            }
        }
        
        if (existedP) {
            [self.connectedDeviceDict setObject:existedP forKey:peripheral.identifier.UUIDString];
        }
        else{
            existedP = [[TFY_EasyPeripheral alloc]initWithPeripheral:peripheral central:self];
            [self.connectedDeviceDict setObject:existedP forKey:peripheral.identifier.UUIDString];
//            if (_blueToothSearchDeviceCallback) {
//                _blueToothSearchDeviceCallback(existedP,searchFlagTypeAdded);
//            }
            [self.foundDeviceDict setObject:existedP forKey:peripheral.identifier.UUIDString];
        }
        
    }
    NSError *error;
    [existedP dealDeviceConnectWithError:error deviceConnectType:deviceConnectTypeSuccess];

}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    Blue_EasyLog_R(@"蓝牙连接一个设备失败：uuid:%@  error:%@ ",peripheral.identifier,error);

    TFY_EasyPeripheral *existedP = nil ;
    for (NSString *tempP in [self.connectedDeviceDict allKeys]) {
        if ([tempP isEqualToString:peripheral.identifier.UUIDString]) {
            existedP = self.connectedDeviceDict[tempP];
            break  ;
        }
    }
    
    if (existedP) {
        [self.connectedDeviceDict removeObjectForKey:existedP.identifierString];
        existedP = nil ;
    }
    else{
        
        for (NSString *tempIden in [self.foundDeviceDict allKeys]) {
            if ([tempIden isEqualToString:peripheral.identifier.UUIDString]) {
                existedP = self.foundDeviceDict[tempIden] ;
                break  ;
            }
        }
        Blue_EasyLog(@"注意：您应该处理此错误");
    }
    
    NSAssert(existedP, @"注意：您应该处理此错误");
    
    if (_blueToothSearchDeviceCallback && existedP) {
        _blueToothSearchDeviceCallback(existedP,searchFlagTypeDisconnect);
    }
//    existedP.errorDescription = error ;
    if (existedP) {
        [existedP dealDeviceConnectWithError:error deviceConnectType:deviceConnectTypeFaild];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    Blue_EasyLog_R(@"蓝牙一个设备失去连接：uuid:%@ error:%@",peripheral.identifier,error);

    TFY_EasyPeripheral *existedP = nil ;
    for (NSString *tempIden in [self.connectedDeviceDict allKeys]) {
        if ([tempIden isEqualToString:peripheral.identifier.UUIDString]) {
            existedP = self.connectedDeviceDict[tempIden] ;
            break  ;
        }
    }
    
    if (existedP) {
        for (TFY_EasyService *tempS in existedP.serviceArray) {
            [tempS.characteristicArray removeAllObjects];
            tempS.isOn = NO;
            tempS.isEnabled = NO;
        }
        [existedP.serviceArray removeAllObjects];
        
        [self.connectedDeviceDict removeObjectForKey:existedP.identifierString];
        [self.foundDeviceDict removeObjectForKey:existedP.identifierString];
    }
    else{
        NSAssert(NO, @"注意：您应该处理此错误");
    }
    
//    existedP.errorDescription = error ;
    
    if (_blueToothSearchDeviceCallback && existedP) {
        _blueToothSearchDeviceCallback(existedP,searchFlagTypeDisconnect);
    }

    if (error && existedP) {
        [existedP dealDeviceConnectWithError:error deviceConnectType:deviceConnectTypeDisConnect];
    }
    if (existedP) {
        existedP = nil ;
    }
}


- (NSArray<TFY_EasyPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs
{
    Blue_EasyLog_R(@"根据服务的id获取所有系统已连接上的设备：%@",serviceUUIDs);
    if (!serviceUUIDs.count) {return @[];}
    
    NSArray *resultArray = [self.manager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (CBPeripheral *tempP in resultArray) {
        TFY_EasyPeripheral *tempPer = [[TFY_EasyPeripheral alloc]initWithPeripheral:tempP central:self];
        [tempArray addObject:tempPer];
    }
    return tempArray ;
}

- (NSArray<TFY_EasyPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers
{
    Blue_EasyLog_R(@"蓝牙获取系统所有已知设备：%@",identifiers);

    NSArray *resultArray = [self.manager retrievePeripheralsWithIdentifiers:identifiers];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (CBPeripheral *tempP in resultArray) {
        TFY_EasyPeripheral *tempPer = [[TFY_EasyPeripheral alloc]initWithPeripheral:tempP central:self];
        [tempArray addObject:tempPer];
    }
    return tempArray ;
}


#pragma mark - getter
- (NSMutableDictionary *)connectedDeviceDict
{
    if (nil == _connectedDeviceDict) {
        _connectedDeviceDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _connectedDeviceDict ;
}
- (NSMutableDictionary *)foundDeviceDict
{
    if (nil == _foundDeviceDict) {
        _foundDeviceDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _foundDeviceDict ;
}
@end
