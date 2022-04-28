//
//  TFY_EasyDescriptor.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_EasyDescriptor.h"
#import "TFY_EasyPeripheral.h"
#import "TFY_EasyCharacteristic.h"
#import "TFY_EasyUtils.h"

@interface TFY_EasyDescriptor ()
{
    blueToothDescriptorOperateCallback _readCallback ;
    blueToothDescriptorOperateCallback _writeCallback ;
}

@property (nonatomic,strong)NSMutableArray<NSData *> *readCallbackArray ;
@end

@implementation TFY_EasyDescriptor

- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor
{
    return [self initWithDescriptor:descriptor peripheral:_peripheral];
}
- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor peripheral:(TFY_EasyPeripheral *)peripheral
{
    if (self = [super init]) {
        _descroptor = descriptor ;
        _peripheral = peripheral ;
    }
    return self ;
}
- (CBUUID *)UUID
{
    return _descroptor.UUID ;
}
- (id)value
{
    return _descroptor.value ;
}
- (CBCharacteristic *)characteristic
{
    return _descroptor.characteristic ;
}


- (void)writeByte:(int8_t)byte callback:(blueToothDescriptorOperateCallback)callback
{
    NSData *data = [NSData dataWithBytes:&byte length:1];
    [self writeValueWithData:data callback:callback];
}
- (void)writeValueWithData:(NSData *)data callback:(blueToothDescriptorOperateCallback)callback
{
    if (callback) {
        _writeCallback = [callback copy];
    }
    if (data) {
        [self.writeDataArray addObject:data];
        Blue_EasyLog_S(@"往描述上写数据 %@ %@",self.descroptor.UUID,data);
        [self.peripheral.peripheral writeValue:data forDescriptor:self.descroptor];
    }
    else{
        NSAssert(NO, @"数据为null");
    }
}
- (void)readValueWithCallback:(blueToothDescriptorOperateCallback)callback
{
    if (callback) {
        _readCallback = [callback copy];
    }
    Blue_EasyLog_S(@"读取描述上数据 %@",self.descroptor.UUID);
    [self.peripheral.peripheral readValueForDescriptor:self.descroptor];
}


- (void)dealOperationDescriptorWithType:(OperationType)type error:(NSError *)error
{
    switch (type) {
        case OperationTypeRead:
            if (_readCallback) {
                _readCallback(self,error);
                _readCallback = nil ;
            }
            
            break;
        case OperationTypeWrite:
            if (_writeCallback) {
                _writeCallback(self,error);
                _writeCallback = nil ;
            }
        default:
            break;
    }
}


- (NSMutableArray<NSData *> *)readDataArray
{
    if ( nil == _readDataArray) {
        _readDataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _readDataArray ;
}
- (NSMutableArray<NSData *> *)writeDataArray
{
    if (nil == _writeDataArray) {
        _writeDataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _writeDataArray ;
}

- (NSMutableArray<NSData *> *)readCallbackArray
{
    if (nil == _readCallbackArray) {
        _readCallbackArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _readCallbackArray ;
}
@end
