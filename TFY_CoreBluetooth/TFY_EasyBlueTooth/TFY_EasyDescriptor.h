//
//  TFY_EasyDescriptor.h
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TFY_EasyCharacteristic.h"

@class TFY_EasyDescriptor ;
@class TFY_EasyCharacteristic;

NS_ASSUME_NONNULL_BEGIN

typedef void (^blueToothDescriptorOperateCallback)(TFY_EasyDescriptor *descriptor , NSError *error);

@interface TFY_EasyDescriptor : NSObject

/**
 * 系统提供的描述
 */
@property (nonatomic,strong)CBDescriptor *descroptor ;

/**
 * 描述所述的特征
 */
@property(assign, readonly) CBCharacteristic *characteristic;

/**
 * 描述所属的设别
 */
@property (nonatomic,weak)TFY_EasyPeripheral *peripheral ;

/**
 * 描述的唯一标示
 */
@property (nonatomic,strong , readonly )CBUUID *UUID ;

/**
 * 当前描述上的值
 */
@property (nonatomic,strong , readonly) id value;

/**
 * 描述上读写操作的记录值
 */
@property (nonatomic,strong)NSMutableArray<NSData *> *readDataArray ;
@property (nonatomic,strong)NSMutableArray<NSData *> *writeDataArray ;

/**
 * 初始化方法
 */
- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor ;
- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor peripheral:(TFY_EasyPeripheral *)peripheral;

/**
 * 在描述上的读写操作
 */
- (void)writeByte:(int8_t)byte callback:(blueToothDescriptorOperateCallback)callback ;
- (void)writeValueWithData:(NSData *)data callback:(blueToothDescriptorOperateCallback)callback ;
- (void)readValueWithCallback:(blueToothDescriptorOperateCallback)callback ;


/**
 * 处理 easyPeripheral操作完的回到
 */
- (void)dealOperationDescriptorWithType:(OperationType)type error:(NSError *)error;


@end

NS_ASSUME_NONNULL_END
