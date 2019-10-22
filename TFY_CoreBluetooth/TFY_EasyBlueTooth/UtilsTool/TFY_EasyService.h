//
//  TFY_EasyService.h
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class TFY_EasyService ;
@class TFY_EasyPeripheral ;
@class TFY_EasyCharacteristic ;
@class TFY_EasyDescriptor ;

NS_ASSUME_NONNULL_BEGIN

/**
   * 发现服务上的特征回调
   */
typedef void (^blueToothFindCharacteristicCallback)(NSArray<TFY_EasyCharacteristic *> *characteristics , NSError *error );


@interface TFY_EasyService : NSObject

/**
   * 服务名称
   */
@property (nonatomic, strong,readonly) NSString *name;

/**
   * 系统提供出来的服务
   */
@property (nonatomic,strong)CBService *service ;
@property (nonatomic,strong)NSArray *includedServices ;

/**
   * 服务所在的设备
   */
@property (nonatomic,weak , readonly)TFY_EasyPeripheral *peripheral ;

/**
   * 服务的唯一标示
   */
@property (nonatomic,strong,readonly)CBUUID * UUID ;

/**
   * 服务是否是开启状态
   */
@property (nonatomic,assign)BOOL isOn ;

/**
   * 服务是否是可用状态
   */
@property (nonatomic,assign)BOOL isEnabled ;


/**
   * 服务中所有的特征
   */
@property(nonatomic, strong ,readonly) NSMutableArray<TFY_EasyCharacteristic *> *characteristicArray;


/**
   * 初始化方法
   */
- (instancetype)initWithService:(CBService *)service ;
- (instancetype)initWithService:(CBService *)service perpheral:(TFY_EasyPeripheral *)peripheral ;


/**
   * 查找服务中所有的特征
   */
- (TFY_EasyCharacteristic *)searchCharacteristciWithCharacteristic:(CBCharacteristic *)characteristic ;


/**
   * 查找服务上的特征
   */
- (void)discoverCharacteristicWithCallback:(blueToothFindCharacteristicCallback)callback ;

- (void)discoverCharacteristicWithCharacteristicUUIDs:(NSArray<CBUUID *> *)uuidArray
                                             callback:(blueToothFindCharacteristicCallback)callback ;

/**
   * 处理manager的连接结果
   */
- (void)dealDiscoverCharacteristic:(NSArray *)characteristics error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
