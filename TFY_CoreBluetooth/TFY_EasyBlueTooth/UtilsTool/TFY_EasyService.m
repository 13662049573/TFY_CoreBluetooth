//
//  TFY_EasyService.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_EasyService.h"
#import "TFY_EasyPeripheral.h"
#import "TFY_EasyCharacteristic.h"
#import "TFY_EasyUtils.h"

@interface TFY_EasyService ()
@property(nonatomic, strong) NSMutableArray<TFY_EasyCharacteristic *> *characteristicArray;

@property(nonatomic,strong) NSMutableArray<blueToothFindCharacteristicCallback> *findCharacterCallbackArray ;

@end

@implementation TFY_EasyService
- (instancetype)initWithService:(CBService *)service
{
    if (self  = [self initWithService:service perpheral:_peripheral]) {
        
    }
    return self ;
}
- (instancetype)initWithService:(CBService *)service perpheral:(TFY_EasyPeripheral *)peripheral
{
    NSAssert(service, @"您应该具有创建easyservice的服务！");
    if (self = [super init]) {
        _peripheral = peripheral ;
        _service = service ;
        _isOn = YES ;
        _isEnabled = YES;
    }
    return self ;
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@",self.service.UUID ];
}
- (CBUUID *)UUID
{
    return self.service.UUID ;
}
- (NSArray *)includedServices
{
    return self.service.includedServices ;
}


- (void)discoverCharacteristicWithCallback:(blueToothFindCharacteristicCallback)callback
{
    [self discoverCharacteristicWithCharacteristicUUIDs:@[]
                                               callback:callback];
}

- (void)discoverCharacteristicWithCharacteristicUUIDs:(NSArray<CBUUID *> *)uuidArray
                                             callback:(blueToothFindCharacteristicCallback)callback
{
    NSAssert(callback, @"你应该处理回调");
    
    if (callback) {
        [self.findCharacterCallbackArray addObject:callback];
    }
    
    BOOL isAllUUIDExited = uuidArray.count > 0 ;//需要查找的UUID是否都存在
    for (CBUUID *tempUUID in uuidArray) {
        
        BOOL isExitedUUID = NO ;//数组里单个需要查找到UUID是否存在
        for (TFY_EasyCharacteristic *tempCharacter in self.characteristicArray) {
            if ([tempCharacter.UUID isEqual:tempUUID]) {
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
        if (self.findCharacterCallbackArray.count > 0) {
            NSError *error;
            blueToothFindCharacteristicCallback callback = self.findCharacterCallbackArray.firstObject ;
            callback(self.characteristicArray,error);
            callback = nil ;
            
            [self.findCharacterCallbackArray removeObjectAtIndex:0];
        }
       
    }
    else{
        
        Blue_EasyLog_S(@"寻找设备服务上的特征 %@  %@",self.peripheral.identifier.UUIDString,self.service.UUID);

        [self.peripheral.peripheral discoverCharacteristics:uuidArray forService:self.service];
    }
}

- (void)dealDiscoverCharacteristic:(NSArray *)characteristics error:(NSError *)error
{
    for (CBCharacteristic *tempCharacteristic in characteristics) {
        
        TFY_EasyCharacteristic *tempC  = [self searchCharacteristciWithCharacteristic:tempCharacteristic] ;
        if (nil == tempC) {
            TFY_EasyCharacteristic *character = [[TFY_EasyCharacteristic alloc]initWithCharacteristic:tempCharacteristic perpheral:self.peripheral];
            [self.characteristicArray addObject:character];
        }
    }
    
    if (self.findCharacterCallbackArray.count > 0) {
        NSError *error;
        blueToothFindCharacteristicCallback callback = self.findCharacterCallbackArray.firstObject ;
        callback(self.characteristicArray,error);
        callback = nil ;
        
        [self.findCharacterCallbackArray removeObjectAtIndex:0];
    }
    
}



- (TFY_EasyCharacteristic *)searchCharacteristciWithCharacteristic:(CBCharacteristic *)characteristic
{
    TFY_EasyCharacteristic *tempC = nil ;
    for (TFY_EasyCharacteristic *tCharacterstic in self.characteristicArray) {
        if ([characteristic.UUID isEqual:tCharacterstic.UUID]) {
            tempC = tCharacterstic ;
            break ;
        }
    }
    return tempC ;
    
}

- (NSMutableArray *)characteristicArray
{
    if (nil == _characteristicArray) {
        _characteristicArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _characteristicArray ;
}

- (NSMutableArray<blueToothFindCharacteristicCallback> *)findCharacterCallbackArray
{
    if (nil == _findCharacterCallbackArray) {
        _findCharacterCallbackArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _findCharacterCallbackArray ;
}

@end
