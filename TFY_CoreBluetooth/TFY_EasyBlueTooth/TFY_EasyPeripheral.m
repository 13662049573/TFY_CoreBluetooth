//
//  TFY_EasyPeripheral.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_EasyPeripheral.h"


@interface TFY_EasyPeripheral ()<CBPeripheralDelegate>
{
    NSUInteger       _connectTimeOut ;//连接设备超时时间
    NSDictionary    *_connectOpertion ;//需要连接设备所遵循的条件
    __block BOOL     _isReconnectDevice ;//用来处理发起连接时的参数问题。因为没调用连接一次，只能返回一次连接结果。

    //读取rssi回调结果
    blueToothReadRSSICallback _blueToothReadRSSICallback ;
    
    NSTimer *_deviceTimeoutTimer ;
}
//设备发现服务回调
@property (nonatomic,strong)NSMutableArray<blueToothFindServiceCallback> *findServiceCallbackArray ;
@end

@implementation TFY_EasyPeripheral

- (void)dealloc
{
     Blue_EasyLog(@"\n%@设备已销毁 %@",self.name,self.identifierString);
    _peripheral.delegate = nil ;
    _peripheral = nil ;
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
{
    if ([self initWithPeripheral:peripheral central:_centerManager]) {
        
    }
    return self ;
}
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(TFY_EasyCenterManager *)manager
{
    if (self = [super init]) {
        _centerManager = manager ;
        _peripheral = peripheral ;
        peripheral.delegate = self ;
        
        _connectTimeOut = 5 ;
        _isReconnectDevice = YES ;
        
        Blue_kWeakSelf(self)
        Blue_queueMainStart
        [weakself performSelector:@selector(devicenotFoundTimeout)
                       withObject:nil
                       afterDelay:5.0f];
        Blue_queueEnd
    }
    return self ;
}
- (void)setDeviceScanCount:(NSUInteger)deviceScanCount
{
    _deviceScanCount = deviceScanCount ;
    
        Blue_kWeakSelf(self)
        Blue_queueMainStart
        [NSObject cancelPreviousPerformRequestsWithTarget:weakself
                                                 selector:@selector(devicenotFoundTimeout)
                                                   object:nil];
        [weakself performSelector:@selector(devicenotFoundTimeout)
                       withObject:nil
                       afterDelay:5.0f];
        Blue_queueEnd
}
- (void)devicenotFoundTimeout
{
    [self.centerManager foundDeviceTimeout:self];
}
- (NSUUID *)identifier
{
    return self.peripheral.identifier ;
}
- (NSString *)identifierString
{
    return self.peripheral.identifier.UUIDString ;
}
- (CBPeripheralState)state
{
    return self.peripheral.state ;
}

- (NSString *)name
{
    NSString* localName = [_advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (Blue_ISEMPTY(localName)) {
        localName = self.peripheral.name ;
        if (Blue_ISEMPTY(localName)) {
            localName = @"无名称";
        }
    }
    return localName ;
}
- (NSNumber *)RSSI
{
    if (_RSSI.intValue == 127) {
        return [NSNumber new] ;
    }
    return _RSSI ;
}

- (BOOL)isConnected
{
    BOOL connect = NO ;
    if (self.peripheral.state == CBPeripheralStateConnected) {
        connect = YES ;
    }
    return connect ;
}

- (void)connectDeviceWithCallback:(blueToothConnectDeviceCallback)callback
{
  [self connectDeviceWithTimeOut:_connectTimeOut
                          callback:callback];
}

- (void)connectDeviceWithTimeOut:(NSUInteger)timeout
                        callback:(blueToothConnectDeviceCallback)callback
{
    [self connectDeviceWithTimeOut:timeout
                           Options:@{}
                          callback:callback];
}

- (void)connectDeviceWithTimeOut:(NSUInteger)timeout
                         Options:(NSDictionary *)options
                        callback:(blueToothConnectDeviceCallback)callback
{

//    if (disconnectCallback) {
//        _disconnectCallback = [disconnectCallback copy];
//    }
//    else{
//        EasyLog(@"attention ! disconnectCallback is very importent , you should handle this callback");
//    }
    
    NSAssert(callback, @"您应该处理连接设备回调！");

    if (callback) {
        _connectCallback = [callback copy] ;
    }

    _connectTimeOut = timeout ;
    _connectOpertion = options ;

    _isReconnectDevice = YES ;
    
    
    if (self.peripheral.state == CBPeripheralStateConnected) {
        Blue_EasyLog(@"注意！设备已正确连接！");
        [self disconnectDevice];
    }

    Blue_EasyLog_S(@"开始连接设备 - 超时时间:%zd",timeout);
    [self.centerManager.manager connectPeripheral:self.peripheral options:options];
    
    //如果设定的时间内系统没有回调连接的结果。直接返回错误信息
    Blue_kWeakSelf(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_connectTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (!self->_isReconnectDevice) {
            return  ;
        }
        NSError *error =[NSError errorWithDomain:@"连接设备超时 ~~" code:-101 userInfo:nil];
        if (self->_connectCallback) {
            self->_connectCallback(self,error,deviceConnectTypeFaildTimeout);
        }
        self->_isReconnectDevice = NO ;
        
        [weakself disconnectDevice];
    });

}

- (void)reconnectDevice
{
    _isReconnectDevice = YES ;
    [self connectDeviceWithTimeOut:_connectTimeOut
                           Options:_connectOpertion
                          callback:_connectCallback];
}

//- (void)dealDeviceDisconnectWithError:(NSError *)error
//{
//    if (_disconnectCallback) {
//        _disconnectCallback(self ,error);
//    }
//}

- (void)dealDeviceConnectWithError:(NSError *)error deviceConnectType:(deviceConnectType)deviceConnectType
{
    _isReconnectDevice = NO ;

    if (_connectCallback) {
        _connectCallback(self, error , deviceConnectType);
    }
}


//- (void)setStateChangedCallback:(blueToothDeviceStateChangedCallback)stateChangedCallback
//{
//    NSAssert(stateChangedCallback, @"you should set a callback ！");
//
//    _stateChangedCallback = [stateChangedCallback copy];
//
//    [self.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CBPeripheral *periheral = (CBPeripheral *)object ;
    
//    if (_stateChangedCallback) {
//        _stateChangedCallback( self , periheral.state) ;
//    }
    Blue_EasyLog(@"_stateChangedCallback = %zd",periheral.state );
    
}


/**
 * 断开连接
 */
- (void)disconnectDevice
{
    if (self.state == CBPeripheralStateConnected) {
        Blue_EasyLog_S(@"断开设备连接 %@",self.peripheral.identifier.UUIDString);
        [self.centerManager.manager cancelPeripheralConnection:self.peripheral];
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self.centerManager.manager
                                             selector:@selector(connectPeripheral:options:)
                                               object:_connectOpertion];
//    [self.centerManager.connectedDeviceDict removeObjectForKey:self.identifier];
}

- (void)resetDeviceScanCount
{
    self.deviceScanCount = -1 ;
}

- (void)discoverAllDeviceServiceWithCallback:(blueToothFindServiceCallback)callback
{
    
    [self discoverDeviceServiceWithUUIDArray:@[]
                                    callback:callback];
}

- (void)discoverDeviceServiceWithUUIDArray:(NSArray<CBUUID *> *)uuidArray
                                  callback:(blueToothFindServiceCallback)callback
{
    NSAssert(callback, @"你应该处理回调");
    
    if (callback) {
        [self.findServiceCallbackArray addObject:callback];
    }

    BOOL isAllUUIDExited = uuidArray.count > 0 ;//需要查找的UUID是否都存在
    
    for (CBUUID *tempUUID in uuidArray) {
        
        BOOL isExitedUUID = NO ;//数组里单个需要查找到UUID是否存在
        for (TFY_EasyService *tempSerevice in self.serviceArray) {
            if ([tempSerevice.UUID isEqual:tempUUID]) {
                isExitedUUID = YES ;
                break ;
            }
        }
        if (!isExitedUUID) {
            isAllUUIDExited = NO ;
            break ;
        }
    }
   
    if (isAllUUIDExited) {
        
        if (self.findServiceCallbackArray.count > 0) {
            NSError *ERROR;
            blueToothFindServiceCallback callback = self.findServiceCallbackArray.firstObject ;
            callback(self,self.serviceArray,ERROR);
            callback = nil ;
            
            [self.findServiceCallbackArray removeObjectAtIndex:0];
        }
    }
    else{
        
        Blue_EasyLog_S(@"寻找设备上的服务 %@",self.peripheral.identifier.UUIDString);
        [self.peripheral discoverServices:uuidArray];
    }
}

- (TFY_EasyService *)searchServiceWithService:(CBService *)service
{
    TFY_EasyService *tempService = nil ;
    for (TFY_EasyService *tempS in self.serviceArray) {
        if ([tempS.UUID isEqual:service.UUID]) {
            tempService = tempS ;
            break ;
        }
    }
    return tempService ;
}


- (void)readDeviceRSSIWithCallback:(blueToothReadRSSICallback)callback
{
    NSAssert(callback, @"你应该处理回调");
    
    if (callback) {
        _blueToothReadRSSICallback = [callback copy];
    }
    
    Blue_EasyLog_S(@"读取设备的rssi %@",self.peripheral.identifier.UUIDString);
    [self.peripheral readRSSI];
}


#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    Blue_EasyLog_R(@"\n设备的rssi读取 %@ rssi:%@ error:%@",peripheral.identifier,RSSI,error);

    self.RSSI = RSSI ;
    if (_blueToothReadRSSICallback) {
        _blueToothReadRSSICallback(self , RSSI ,error );
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    Blue_EasyLog_R(@"设备发现服务%@ serviceArray:%@ error:%@",peripheral.identifier,peripheral.services,error);

    for (CBService *tempService in peripheral.services) {
        TFY_EasyService *tempS  = [self searchServiceWithService:tempService] ;
        if (nil == tempS) {
            TFY_EasyService *easyS = [[TFY_EasyService alloc]initWithService:tempService perpheral:self];
            [self.serviceArray addObject:easyS];
        }
    }
    
    if (self.findServiceCallbackArray.count > 0) {
        
        blueToothFindServiceCallback callback = self.findServiceCallbackArray.firstObject ;
        callback(self,self.serviceArray,error);
        callback = nil ;
        
        [self.findServiceCallbackArray removeObjectAtIndex:0];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    Blue_EasyLog_R(@"已连接上行的设备发现了服务%@ serviceArray:%@ error:%@",peripheral.identifier,peripheral.services,error);

    NSAssert(NO, @"");

}

#pragma mark characteristic

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    Blue_EasyLog_R(@"发现了服务上的特征 %@ characterArray:%@ error:%@",service.UUID,service.characteristics,error);

    TFY_EasyService *tempService = [self searchServiceWithService:service];
    
    if (tempService) {
        [tempService dealDiscoverCharacteristic:service.characteristics error:error];
    }
    else{
        NSAssert(NO, @"你应该解决这个错误");
    }
    
}

#pragma mark - write read notify operition

//监听notify后
//或者写入数据后，数据会在这个接口里回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    TFY_EasyService *tempService = [self searchServiceWithService:characteristic.service];
    TFY_EasyCharacteristic *character = [tempService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"注意！这个字符是空的。");
    
    if (character.isNotifying) {
        
        Blue_EasyLog_R(@"特征上的数据更新: %@ data:%@ error:%@",characteristic.UUID,characteristic.value ,error);

        [character dealOperationCharacterWithType:OperationTypeNotify error:error];
    }
    else{
        Blue_EasyLog_R(@"读 特征的回调: %@ data:%@ error:%@",characteristic.UUID,characteristic.value ,error);

        [character dealOperationCharacterWithType:OperationTypeRead error:error];
    }
}

//当特征注册通知后 会回调此方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    Blue_EasyLog_R(@"监听 特征的回调: %@ error:%@",characteristic.UUID ,error);

    if (characteristic.isNotifying) {
        //        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        Blue_EasyLog(@"通知已在%@停止断开", characteristic);
        //        [self disconnectDevice];
    }
    
    
    TFY_EasyService *easyService = [self searchServiceWithService:characteristic.service];
    TFY_EasyCharacteristic *character = [easyService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"注意！这个字符是空的。");
    
    [character dealOperationCharacterWithType:OperationTypeNotify error:error];
    
    
}

// 当写入某个特征值后 外设代理执行的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    Blue_EasyLog_R(@"写 特征的回调: %@ error:%@",characteristic.UUID ,error);

    TFY_EasyService *tempService = [self searchServiceWithService:characteristic.service];
    TFY_EasyCharacteristic *character = [tempService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"注意！这个字符是空的。");
    
    [character dealOperationCharacterWithType:OperationTypeWrite error:error];
    
}


#pragma mark - descriptor

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    Blue_EasyLog_R(@"发现特征上的描述: %@ descripterArray %@ error:%@",characteristic.UUID ,characteristic.descriptors ,error);

    
    TFY_EasyService *easyService = [self searchServiceWithService:characteristic.service];
    TFY_EasyCharacteristic *character = [easyService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"注意！这个字符是空的。");
    
    [character dealDiscoverDescriptorWithError:error];
    
}

//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
    Blue_EasyLog_R(@"获取到Descriptors的值 uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
    
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    for (TFY_EasyService *tempS in self.serviceArray) {
        for (TFY_EasyCharacteristic *tempC in tempS.characteristicArray) {
            for (TFY_EasyDescriptor *tempD in tempC.descriptorArray) {
                if ([tempD.descroptor isEqual:descriptor]) {
                    [tempD dealOperationDescriptorWithType:OperationTypeRead error:error];
                    return;
                }
            }
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    Blue_EasyLog_R(@"写 特征上的描述的回调: %@ error:%@",descriptor.UUID ,error);
    
    for (TFY_EasyService *tempS in self.serviceArray) {
        for (TFY_EasyCharacteristic *tempC in tempS.characteristicArray) {
            for (TFY_EasyDescriptor *tempD in tempC.descriptorArray) {
                if ([tempD.descroptor isEqual:descriptor]) {
                    [tempD dealOperationDescriptorWithType:OperationTypeWrite error:error];
                    return;
                }
            }
        }
    }
}


- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    Blue_EasyLog(@"peripheralDidUpdateName");
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    
    Blue_EasyLog_R(@"didRetrievePeripherals%@\n%@\n",central,peripherals);
    
    int i = 0;
    for(CBPeripheral *peripheral in peripherals) {
        Blue_EasyLog(@"%@",[NSString stringWithFormat:@"[%d] - 外围设备 : %@ with UUID : %@",i,peripheral,peripheral.identifier]);
        i++;
        //Do something on each known peripheral.
    }
    
}
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    Blue_EasyLog_R(@"didRetrieveConnectedPeripherals:%@\n%@",peripherals,central);
    
    
    int i = 0;
    for(CBPeripheral *peripheral in peripherals) {
        i++;
        Blue_EasyLog(@"%@",[NSString stringWithFormat:@"[%d] - 外围设备 : %@ with UUID : %@",i,peripheral,peripheral.identifier]);
        //Do something on each connected peripheral.
    }
    
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    Blue_EasyLog_R(@"peripheralDidInvalidateServices  %@",peripheral);
}
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    Blue_EasyLog_R(@"didModifyServices%@ \n%@",invalidatedServices,peripheral);
}

- (NSMutableArray *)serviceArray
{
    if (nil == _serviceArray) {
        _serviceArray = [NSMutableArray array];
    }
    return _serviceArray ;
}
- (NSMutableArray<blueToothFindServiceCallback> *)findServiceCallbackArray
{
    if (nil == _findServiceCallbackArray) {
        _findServiceCallbackArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _findServiceCallbackArray ;
}

@end
