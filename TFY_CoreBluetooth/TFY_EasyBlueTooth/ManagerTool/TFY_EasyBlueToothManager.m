//
//  TFY_EasyBlueToothManager.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_EasyBlueToothManager.h"
/**
 * 寻找特征的回调
 */
typedef void (^blueToothFindCharacteristic)(TFY_EasyCharacteristic *character ,NSError *error);

@interface TFY_EasyBlueToothManager ()
@property (nonatomic,strong)TFY_EasyCenterManager *centerManager ;
@end

@implementation TFY_EasyBlueToothManager

+ (instancetype)shareInstance
{
    static TFY_EasyBlueToothManager *share = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[TFY_EasyBlueToothManager alloc]init];
    });
    return share;
}

#pragma mark - 扫描设备 （单个设别）

- (void)scanDeviceWithName:(NSString *)name
                  callback:(blueToothScanCallback)callback
{
    [self scanDeviceWithCondition:name
                         callback:callback];
}
- (void)scanDeviceWithRule:(blueToothScanRule)rule
                  callback:(blueToothScanCallback)callback
{
    [self scanDeviceWithCondition:rule
                         callback:callback];
}
- (void)scanDeviceWithCondition:(id)condition
                       callback:(blueToothScanCallback)callback
{
    NSAssert(condition, @"条件不能为零！");
    NSAssert(callback, @"回调应该处理！");
    TFY_EasyPeripheral *peripheral=nil;
    if (!condition) {
        
        NSError *tempError = [NSError errorWithDomain:@"条件为零" code:bluetoothErrorStateNoDevice userInfo:@{}];
        callback(peripheral,tempError);
        return ;
    }
    
    if (self.centerManager.manager.state == CBManagerStatePoweredOn) {
        self.bluetoothState = bluetoothStateSystemReadly ;
        TFY_EasyPeripheral *peripheral;
        if (self.bluetoothStateChanged) {
            self.bluetoothStateChanged(peripheral,bluetoothStateSystemReadly);
        }
    }
    else if(self.centerManager.manager.state == CBManagerStatePoweredOff){
        NSError *tempError = [NSError errorWithDomain:@"中心经理状态已关闭，并准备开启！" code:bluetoothErrorStateNoReadlyTring userInfo:nil];
        callback(peripheral,tempError);
    }
    
    Blue_kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray options:self.managerOptions.scanOptions callBack:^(TFY_EasyPeripheral *peripheral, searchFlagType searchType) {
        
        NSLog(@"外围设备 - %@  - %@ ,检索类别 - %zd",peripheral.name,peripheral.identifierString,searchType);
        if (searchType&searchFlagTypeFinish) {//扫描完成
            //说明在规定的时间没有扫描到设备
            //1，停止扫描
            [weakself.centerManager stopScanDevice];
            
            //2，通知外部调用者。  此时没找到设备有两种原因。1，系统蓝牙未开启。 2，周围没有设备。
            NSError *tempError = nil ;
            if (weakself.centerManager.manager.state == CBManagerStatePoweredOff ) {
                tempError = [NSError errorWithDomain:@"中心经理状态已关闭" code:bluetoothErrorStateNoReadly userInfo:nil];
            }
            else{
                tempError = [NSError errorWithDomain:@"没有找到设备 ！" code:bluetoothErrorStateNoDevice userInfo:nil];
            }
            callback(peripheral , tempError);
            
            //3，不用往下了。下面是：发现了一个设备，判断是否是需要寻找的设备。
            return  ;
        }
        
        if ([condition isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)condition ;
            
            //能进入if里面。说明返回的设备是查找的设备。如果不能就不予处理这个设备
            if ([(peripheral.name) isEqualToString:(name)] && searchType&searchFlagTypeAdded) {
                
                //1，停止扫描
                [weakself.centerManager stopScanDevice];
                
                //2，改变当前状态
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                NSError *tempError = nil ;
                //3，通知外部
                callback(peripheral,tempError);
                
            }
        }
        else{
            
            blueToothScanRule rule = (blueToothScanRule)condition ;
            if (rule(peripheral) && searchType&searchFlagTypeAdded ) {//能进if里面。说明这个设备是符合要求的
                
                [weakself.centerManager stopScanDevice];
                
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                NSError *tempError = nil ;
                callback(peripheral,tempError);
            }
        }
        
    }];
}

- (void)scanAllDeviceAsyncWithRule:(blueToothScanRule)rule
                          callback:(blueToothScanAsyncCallback)callback
{
    if (self.managerOptions.scanTimeOut == NSIntegerMax) {
        self.managerOptions.scanTimeOut = 20 ;//默认一个时间
        NSAssert(NO, @"您应该在EasyManagerOptions类上设置scanTimeOut值");
    }
    NSAssert(callback, @"回调应该处理！");
    
    Blue_kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(TFY_EasyPeripheral *peripheral, searchFlagType searchType) {
        
        if (searchType&searchFlagTypeFinish) { //扫描时间到
            //1，停止扫描
            [weakself.centerManager stopScanDevice];
            //2，收集错误信息
            NSError *tempError = nil ;
            if (weakself.centerManager.manager.state == CBManagerStatePoweredOff ) {
                tempError = [NSError errorWithDomain:@"中心经理状态已关闭" code:bluetoothErrorStateNoReadly userInfo:nil];
            }
            TFY_EasyPeripheral *peripheral=nil;
            
            //3，通知外部
            callback(peripheral , searchFlagTypeFinish ,tempError);
            return ;
        }
        
        if (rule(peripheral) ) {
            NSError *tempError = nil ;
            if (searchType&searchFlagTypeAdded) {
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
            }
            callback(peripheral , searchType ,tempError);
        }
        
    }];
}

#pragma mark 扫描所有符合条件的设备
- (void)scanAllDeviceWithName:(NSString *)name callback:(blueToothScanAllCallback)callback
{
    [self scanAllDeviceWithCondition:name
                            callback:callback];
}
- (void)scanAllDeviceWithRule:(blueToothScanRule)rule callback:(blueToothScanAllCallback)callback
{
    [self scanAllDeviceWithCondition:rule
                            callback:callback];
}
- (void)scanAllDeviceWithCondition:(id)condition
                          callback:(blueToothScanAllCallback)callback
{
    if (self.managerOptions.scanTimeOut == NSIntegerMax) {
        self.managerOptions.scanTimeOut = 20 ;//默认一个时间
        NSAssert(NO, @"您应该在EasyManagerOptions类上设置scanTimeOut值");
    }
    NSAssert(condition, @"条件不能为零！");
    NSAssert(callback, @"回调应该处理！");
    
    Blue_kWeakSelf(self)
    __block NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(TFY_EasyPeripheral *peripheral, searchFlagType searchType) {
        
        if (searchType&searchFlagTypeFinish) { //扫描时间到
            
            //1，停止扫描
            [weakself.centerManager stopScanDevice];
            //2，收集错误信息
            NSError *tempError = nil ;
            if (weakself.centerManager.manager.state == CBManagerStatePoweredOff ) {
                tempError = [NSError errorWithDomain:@"中心经理状态已关闭" code:bluetoothErrorStateNoReadly userInfo:nil];
            }
            else{
                if (tempArray.count == 0) {
                    tempError = [NSError errorWithDomain:@"没有找到设备 ！" code:bluetoothErrorStateNoDevice userInfo:nil];
                }
            }
            //3，通知外部
            callback(tempArray,tempError);
            return ;
        }
        
        if ([condition isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)condition ;
            if ([peripheral.name isEqualToString:name]) {
                BOOL isEixt = [TFY_EasyBlueToothManager isExitObject:peripheral inArray:tempArray];
                if (!isEixt) {
                    [tempArray addObject:peripheral];
                }
            }
        }
        else{
            blueToothScanRule rule = (blueToothScanRule) condition ;
            if (rule(peripheral)) {
                BOOL isEixt = [TFY_EasyBlueToothManager isExitObject:peripheral inArray:tempArray];
                if (!isEixt) {
                    [tempArray addObject:peripheral];
                }
            }
        }
    }];
}

+ (BOOL)isExitObject:(TFY_EasyPeripheral *)peripheral inArray:(NSMutableArray *)tempArray
{
    __block BOOL isExited = NO ;
    [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TFY_EasyPeripheral class]]) {
            TFY_EasyPeripheral *tempP = (TFY_EasyPeripheral *)obj ;
            if ([tempP.identifier isEqual:peripheral.identifier]) {
                isExited = YES ;
                *stop = YES ;
            }
        }
        else{
            NSAssert(NO, @"tempArray有一个未定义的对象！");
        }
    }];
    return isExited ;
    
}


#pragma mark - 连接设备

- (void)connectDeviceWithIdentifier:(NSString *)identifier
                           callback:(blueToothConnectCallback)callback
{
    NSAssert(identifier, @"你不能连接一个空的uuid");
    TFY_EasyPeripheral *peripheral=nil;
    if (Blue_ISEMPTY(identifier)) {
        NSError *error = [NSError errorWithDomain:@"标识符为空！" code:bluetoothErrorStateIdentifierError userInfo:nil];
        callback(peripheral,error);
        return ;
    }
    Blue_kWeakSelf(self)
    NSUUID *UUID = [[NSUUID alloc]initWithUUIDString:identifier];
    NSString *UUIDString = UUID.UUIDString ;
    if (Blue_ISEMPTY(UUIDString)) {
        NSError *error = [NSError errorWithDomain:@"标识符无效！" code:bluetoothErrorStateIdentifierError userInfo:nil];
        callback(peripheral,error);
        NSAssert(NO, @"您应该检查标识符!") ;
        return ;
    }
    
    if ([self.centerManager.connectedDeviceDict objectForKey:UUIDString]) {
        NSError *error =nil;
        //如果此设备已经连接成功，就直接返回
        TFY_EasyPeripheral *peripheral = weakself.centerManager.connectedDeviceDict[UUIDString];
        callback(peripheral ,error);
    }
    else if ([self.centerManager.foundDeviceDict objectForKey:UUIDString]){
        
        //如果此设备已经被发现，
        TFY_EasyPeripheral *peripheral = weakself.centerManager.foundDeviceDict[UUIDString];
        [self connectDeviceWithPeripheral:peripheral
                                 callback:callback];
    }
    else{
        
        [weakself scanDeviceWithRule:^BOOL(TFY_EasyPeripheral *peripheral) {
            return [peripheral.identifierString isEqualToString:UUIDString];
        } callback:^(TFY_EasyPeripheral *peripheral, NSError *error) {
            
            if (error) {//寻找设备中发生错误，直接回调给外面。只要不是扫描时间到，还会继续扫描
                if (callback) {
                    callback(peripheral,error);//此时的 peripheral 一定是 nil
                }
            }
            else {
                
                if (!peripheral) return  ;
                
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                
                //找到设备后，调用连接设备
                [weakself connectDeviceWithPeripheral:peripheral
                                             callback:callback];
            }
        }] ;
    }
}

- (void)connectDeviceWithPeripheral:(TFY_EasyPeripheral *)peripheral
                           callback:(blueToothConnectCallback)callback
{
    if (!peripheral) {
        NSAssert(NO, @"设备为空！");
        return ;
    }
    NSError *error=nil;
    for (TFY_EasyPeripheral *tempP in [self.centerManager.connectedDeviceDict allValues]) {
        if ([tempP isEqual:peripheral]) {
            self.bluetoothState = bluetoothStateDeviceConnected ;
            if (self.bluetoothStateChanged) {
                self.bluetoothStateChanged(peripheral,bluetoothStateDeviceConnected);
            }
            callback(peripheral , error);
            return ;
        }
    }
    
    Blue_kWeakSelf(self)
    [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut Options:self.managerOptions.connectOptions callback:^(TFY_EasyPeripheral *perpheral, NSError *error, deviceConnectType deviceConnectType) {
        
        switch (deviceConnectType) {
            case deviceConnectTypeDisConnect:
            {
                NSInteger errorCode = bluetoothErrorStateDisconnect ;
                if (weakself.managerOptions.autoConnectAfterDisconnect) {
                    //设备失去连接。正在重连...
                    [peripheral reconnectDevice];
                    errorCode = bluetoothErrorStateDisconnectTring ;
                }
                
                NSError *tempError = nil ;
                if (error) {
                    tempError = [NSError errorWithDomain:error.domain code:errorCode userInfo:nil];
                }
                callback(peripheral,tempError);
            }break;
            case deviceConnectTypeSuccess :
            {
                weakself.bluetoothState = bluetoothStateDeviceConnected ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceConnected);
                }
                
                callback(peripheral , error);
            }break ;
            case deviceConnectTypeFaild:
            case deviceConnectTypeFaildTimeout:
            {
                NSError *tempError = nil ;
                if (error) {
                    tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateConnectError userInfo:nil];
                }
                callback(peripheral,tempError);
            }break ;
            default:
                break;
        }
        
    }];
    
}

#pragma mark - 扫描设备 后 直接连接 设备 （上面两步操作同时完成）

- (void)scanAndConnectDeviceWithName:(NSString *)name
                            callback:(blueToothScanCallback)callback
{
    NSAssert(callback, @"您应该处理回调！");
    Blue_kWeakSelf(self)
    [self scanDeviceWithName:name callback:^(TFY_EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            callback(peripheral,error);
            return ;
        }
        
        if (peripheral) {
            [weakself connectDeviceWithPeripheral:peripheral
                                         callback:callback];
        }
    }];
}

- (void)scanAndConnectDeviceWithRule:(blueToothScanRule)rule
                            callback:(blueToothScanCallback)callback
{
    Blue_kWeakSelf(self)
    [self scanDeviceWithRule:rule callback:^(TFY_EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            callback(peripheral,error);
            return ;
        }
        
        if (peripheral) {
            [weakself connectDeviceWithPeripheral:peripheral callback:callback];
        }
    }];
}

- (void)scanAndConnectDeviceWithIdentifier:(NSString *)identifier
                                  callback:(blueToothScanCallback)callback
{
    [self connectDeviceWithIdentifier:identifier
                             callback:callback];
}


- (void)scanAndConnectAllDeviceWithName:(NSString *)name
                               callback:(blueToothScanAllCallback)callback
{
   
    Blue_kWeakSelf(self)
    [self scanAllDeviceWithName:name callback:^(NSArray<TFY_EasyPeripheral *> *deviceArray, NSError *error) {
        
        if (deviceArray.count > 0) {
            [weakself dealScanedAllDeviceWithArray:deviceArray error:error callback:callback] ;
        }
        else{
            
            callback(@[],error);
        }
    }];
}

- (void)scanAndConnectAllDeviceWithRule:(blueToothScanRule)rule
                               callback:(blueToothScanAllCallback)callback
{
    Blue_kWeakSelf(self)
    [self scanAllDeviceWithRule:rule callback:^(NSArray<TFY_EasyPeripheral *> *deviceArray, NSError *error) {
        
        if (deviceArray.count > 0) {
            [weakself dealScanedAllDeviceWithArray:deviceArray error:error callback:callback] ;
        }
        else{
            
            callback(@[],error);
        }
    }];
}

- (void)dealScanedAllDeviceWithArray:(NSArray *)deviceArray error:(NSError *)error callback:(blueToothScanAllCallback)callback
{
    
    Blue_kWeakSelf(self)
    for (int i = 0; i < deviceArray.count; i++) {
        Blue_QueueStartAfterTime(0.3*i)
        TFY_EasyPeripheral *tempPeripheral = deviceArray[i];
        [weakself connectDeviceWithPeripheral:tempPeripheral callback:^(TFY_EasyPeripheral *peripheral, NSError *error) {
            if (error) {
                peripheral.connectErrorDescription = error ;
            }
            if (i == deviceArray.count-1) {
                callback(deviceArray,error);
            }
        }];
        Blue_queueEnd
    }
}

#pragma mark - 读写操作

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * uuid 数据需要写入到哪个特征下面
 * writeCallback 写入数据后的回调
 */

- (void)writeDataWithPeripheral:(TFY_EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                      writeUUID:(NSString *)writeUUID
                           data:(NSData *)data
                       callback:(blueToothOperationCallback)callback
{
    Blue_kWeakSelf(self)
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:writeUUID callback:^(TFY_EasyCharacteristic *character, NSError *error) {
        NSData *data=nil;
        if (error) {
            callback(data ,error);
            return  ;
        }
        
        NSAssert(character, @"注意：特征为空");
        [character writeValueWithData:data callback:^(TFY_EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            
            NSError *tempError = nil ;
            if (error) {
                tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateWriteError userInfo:nil];
            }else{
                weakself.bluetoothState = bluetoothStateWriteDataSuccess ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateWriteDataSuccess);
                }
            }
            callback(data,tempError);
            
        }];
        
    }];
    
}

/**
 * peripheral 写数据的设备
 * uuid 需要读取数据的特征
 * writeCallback 读取数据后的回调
 */
- (void)readValueWithPeripheral:(TFY_EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                       readUUID:(NSString *)readUUID
                       callback:(blueToothOperationCallback)callback
{
    Blue_kWeakSelf(self)
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:readUUID callback:^(TFY_EasyCharacteristic *character, NSError *error) {
        NSData *data=nil;
        if (error) {
            callback(data ,error);
            return ;
        }
        
        NSAssert(character, @"注意：特征为空");
        [character readValueWithCallback:^(TFY_EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            
            NSError *tempError = nil ;
            if (error) {
                tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateReadError userInfo:nil];
            }
            else{
                weakself.bluetoothState = bluetoothStateReadSuccess ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateReadSuccess);
                }
            }
            callback(data,tempError);
            
        }];
    }];
    
}

/**
 * peripheral 写数据的设备
 * uuid 需要监听的特征值
 * writeCallback 读取数据后的回调
 */
- (void)notifyDataWithPeripheral:(TFY_EasyPeripheral *)peripheral
                     serviceUUID:(NSString *)serviceUUID
                      notifyUUID:(NSString *)notifyUUID
                     notifyValue:(BOOL)notifyValue
                    withCallback:(blueToothOperationCallback)callback
{
    Blue_kWeakSelf(self)
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:notifyUUID callback:^(TFY_EasyCharacteristic *character, NSError *error) {
        NSData *data=nil;
        if (error) {
            callback(data ,error);
            return  ;
        }
        
        NSAssert(character, @"注意：特征为空");
        [character notifyWithValue:notifyValue callback:^(TFY_EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            
            NSError *tempError = nil ;
            if (error) {
                tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateNotifyError userInfo:nil];
            }
            else{
                weakself.bluetoothState = bluetoothStateNotifySuccess ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateNotifySuccess);
                }
            }
            callback(data,tempError);
            
        }];
    }];
    
}


/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)writeDescriptorWithPeripheral:(TFY_EasyPeripheral *)peripheral
                          serviceUUID:(NSString *)serviceUUID
                        characterUUID:(NSString *)characterUUID
                                 data:(NSData *)data
                             callback:(blueToothOperationCallback)callback
{
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:characterUUID callback:^(TFY_EasyCharacteristic *character, NSError *error) {
        NSData *data=nil;
        if (error) {
            callback(data ,error );
            return ;
        }
        NSAssert(character, @"注意：特征为空");
        
        if (character.descriptorArray) {
            for (TFY_EasyDescriptor *tempD in character.descriptorArray) {
                [tempD writeValueWithData:data callback:^(TFY_EasyDescriptor *descriptor, NSError *error) {
                    
                    callback(descriptor.value,error);
                    
                }];
            }
        }
        else{
            
            NSError *tempError = [NSError errorWithDomain:@"特点无说明" code:bluetoothErrorStateNoDescriptor userInfo:nil];
            callback(data,tempError);
        }
    }];
}

/**
 * peripheral 需要读取描述的设备
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)readDescriptorWithPeripheral:(TFY_EasyPeripheral *)peripheral
                         serviceUUID:(NSString *)serviceUUID
                       characterUUID:(NSString *)characterUUID
                            callback:(blueToothOperationCallback)callback
{
    
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:characterUUID callback:^(TFY_EasyCharacteristic *character, NSError *error) {
        NSData *data=nil;
        if (error) {
            callback(data ,error );
            return  ;
        }
        NSAssert(character, @"注意：特征为空");
        
        if (character.descriptorArray) {
            for (TFY_EasyDescriptor *tempD in character.descriptorArray) {
                [tempD readValueWithCallback:^(TFY_EasyDescriptor *descriptor, NSError *error) {
                    
                    callback(descriptor.value,error);
                }];
            }
        }
        else{
            
            NSError *tempError = [NSError errorWithDomain:@"特点无说明" code:bluetoothErrorStateNoDescriptor userInfo:nil];
            callback(data,tempError);
        }
    }];
    
}


- (void)searchCharacteristicWithPeripheral:(TFY_EasyPeripheral *)peripheral
                               serviceUUID:(NSString *)serviceUUID
                             operationUUID:(NSString *)operationUUID
                                  callback:(blueToothFindCharacteristic)callback
{
    
    NSAssert([serviceUUID isKindOfClass:[NSString class]], @"您应该更改uuid ti nsstring！");
    
    CBUUID *serviceuuid = [CBUUID UUIDWithString:serviceUUID];
    CBUUID *operationuuid =[CBUUID UUIDWithString:operationUUID];
    
    if (peripheral.state != CBPeripheralStateConnected) {
        NSError *error = [NSError errorWithDomain:@"设备未连接！连接后请操作！" code:bluetoothErrorStateNoConnect userInfo:nil] ;
        callback(nil,error);
    }
    
    Blue_kWeakSelf(self)
    [peripheral discoverDeviceServiceWithUUIDArray:@[serviceuuid] callback:^(TFY_EasyPeripheral *peripheral, NSArray<TFY_EasyService *> *serviceArray, NSError *error) {
        
        TFY_EasyService * exitedService = nil ;
        for (TFY_EasyService *tempService in serviceArray) {
            if ([tempService.UUID isEqual:serviceuuid]) {
                exitedService = tempService ;
                break ;
            }
        }
        
        NSAssert(exitedService, @"您提供的serviceUUID已被删除！请更换服务") ;
        
        if (exitedService) {
            
            weakself.bluetoothState = bluetoothStateServiceFounded ;
            if (weakself.bluetoothStateChanged) {
                weakself.bluetoothStateChanged(peripheral,bluetoothStateServiceFounded);
            }
            
            
            [exitedService discoverCharacteristicWithCharacteristicUUIDs:@[operationuuid] callback:^(NSArray<TFY_EasyCharacteristic *> *characteristics, NSError *error) {
                
                TFY_EasyCharacteristic *exitedCharacter = nil ;
                for (TFY_EasyCharacteristic *tempCharacter in characteristics) {
                    if ([tempCharacter.UUID isEqual:operationuuid]) {
                        exitedCharacter = tempCharacter ;
                        break ;
                    }
                }
                
                NSAssert(exitedCharacter, @"您提供的operationUUID已被删除！请更改UUID") ;
                
                if (exitedCharacter) {
                    
                    weakself.bluetoothState = bluetoothStateCharacterFounded ;
                    if (weakself.bluetoothStateChanged) {
                        weakself.bluetoothStateChanged(peripheral,bluetoothStateCharacterFounded);
                    }
                    
                    callback(exitedCharacter ,error) ;
                }
                else{
                    
                    NSError *error = [NSError errorWithDomain:@"您提供的服务uuid​​不会退出！" code:bluetoothErrorStateNoCharcter userInfo:nil] ;
                    callback(nil,error);
                    
                }
                
            }];
            
        }
        else{
            
            NSError *error = [NSError errorWithDomain:@"您提供的服务uuid​​不会退出！" code:bluetoothErrorStateNoService userInfo:nil] ;
            callback(nil,error);
        }
        
    }];
}

#pragma mark - rssi

- (void)readRSSIWithPeripheral:(TFY_EasyPeripheral *)peripheral
                      callback:(blueToothReadRSSICallback)callback
{
    [peripheral readDeviceRSSIWithCallback:^(TFY_EasyPeripheral *peripheral, NSNumber *RSSI, NSError *error) {
        
        callback(peripheral,RSSI,error);
    }];
}


#pragma mark - 扫描 断开操作


- (void)startScanDevice
{
    [self.centerManager startScanDevice];
}

- (void)stopScanDevice
{
    [self.centerManager stopScanDevice];
}

/*
 * peripheral 需要断开的设备
 */
- (void)disconnectWithPeripheral:(TFY_EasyPeripheral *)peripheral
{
    [peripheral disconnectDevice];
}

/*
 * identifier 需要断开的设备UUID
 */
- (void)disconnectWithIdentifier:(NSUUID *)identifier
{
    TFY_EasyPeripheral *tempPeripheral = self.centerManager.connectedDeviceDict[identifier];
    
    if (tempPeripheral) {
        [tempPeripheral disconnectDevice];
    }
}

/**
 * 断开所有连接的设备
 */
- (void)disconnectAllPeripheral
{
    [self.centerManager disConnectAllDevice];
}

#pragma mark - 简便方法

- (void)connectDeviceWithName:(NSString *)name
                  serviceUUID:(NSString *)serviceUUID
                   notifyUUID:(NSString *)notifyUUID
                    wirteUUID:(NSString *)writeUUID
                    writeData:(NSData *)data
                     callback:(blueToothOperationCallback)callback
{
    
    Blue_kWeakSelf(self)
    [self scanAndConnectDeviceWithName:name callback:^(TFY_EasyPeripheral *peripheral, NSError *error) {
        
        if (!error) {
            [weakself notifyDataWithPeripheral:peripheral serviceUUID:serviceUUID notifyUUID:notifyUUID notifyValue:YES withCallback:^(NSData *data, NSError *error) {
                
                callback(data , error);
            }];
            
            if (!Blue_ISEMPTY(data)) {
                [weakself writeDataWithPeripheral:peripheral serviceUUID:serviceUUID writeUUID:writeUUID data:data callback:^(NSData *data, NSError *error) {
                    
                    callback(data , error);
                }] ;
            }
        }
        else{
            NSData *data=nil;
            callback(data , error);
        }
    }];
}
- (void)connectDeviceWithIdentifier:(NSString *)identifier
                        serviceUUID:(NSString *)serviceUUID
                         notifyUUID:(NSString *)notifyUUID
                          wirteUUID:(NSString *)writeUUID
                          writeData:(NSData *)data
                           callback:(blueToothOperationCallback)callback
{
    
}

#pragma mark - getter

- (TFY_EasyCenterManager *)centerManager
{
    if (nil == _centerManager) {
        
        _centerManager = [[TFY_EasyCenterManager alloc]initWithQueue:self.managerOptions.managerQueue options:self.managerOptions.managerDictionary];
        Blue_kWeakSelf(_centerManager)
        Blue_kWeakSelf(self)
        _centerManager.stateChangeCallback = ^(TFY_EasyCenterManager *manager, CBManagerState state) {
            if (state == CBManagerStatePoweredOn) {
                weakself.bluetoothState = bluetoothStateSystemReadly ;
                if (weakself.bluetoothStateChanged) {
                    TFY_EasyPeripheral *peripheral=nil;
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateSystemReadly);
                }
                
                [weak_centerManager startScanDevice];
            }
        };
    }
    return _centerManager ;
}
- (TFY_EasyManagerOptions *)managerOptions
{
    if (nil == _managerOptions) {
        _managerOptions = [[TFY_EasyManagerOptions alloc]init];
    }
    return _managerOptions ;
}

@end
