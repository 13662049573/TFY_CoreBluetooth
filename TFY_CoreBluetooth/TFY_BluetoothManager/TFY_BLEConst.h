//
//  TFY_BLEConst.h
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#ifndef TFY_BLEConst_h
#define TFY_BLEConst_h

typedef NS_ENUM(NSInteger, OptionStage) {
    OptionStageConnection,            //蓝牙连接阶段
    OptionStageSeekServices,          //搜索服务阶段
    OptionStageSeekCharacteristics,   //搜索特性阶段
    OptionStageSeekdescriptors,        //搜索描述信息阶段
};

#pragma mark ------------------- 通知的定义 --------------------------
/** 蓝牙状态改变的通知 */
#define kCentralManagerStateUpdateNoticiation @"kCentralManagerStateUpdateNoticiation"

#pragma mark ------------------- block的定义 --------------------------
/** 蓝牙状态改变的block */
typedef void(^StateUpdateBlock)(CBCentralManager *central);

/** 发现一个蓝牙外设的block */
typedef void(^DiscoverPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

/** 连接完成的block,失败error就不为nil */
typedef void(^ConnectCompletionBlock)(CBPeripheral *peripheral, NSError *error);

/** 搜索到连接上的蓝牙外设的服务block */
typedef void(^DiscoveredServicesBlock)(CBPeripheral *peripheral, NSArray *services, NSError *error);

/** 搜索某个服务的子服务 的回调 */
typedef void(^DiscoveredIncludedServicesBlock)(CBPeripheral *peripheral,CBService *service, NSArray *includedServices, NSError *error);

/** 搜索到某个服务中的特性的block */
typedef void(^DiscoverCharacteristicsBlock)(CBPeripheral *peripheral, CBService *service, NSArray *characteristics, NSError *error);

/** 收到某个特性值更新的回调 */
typedef void(^NotifyCharacteristicBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);

/** 查找到某个特性的描述 block */
typedef void(^DiscoverDescriptorsBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSArray *descriptors, NSError *error);

/** 统一返回使用的block */
typedef void(^ECompletionBlock)(OptionStage stage, CBPeripheral *peripheral,CBService *service, CBCharacteristic *character, NSError *error);

/** 获取特性中的值 */
typedef void(^ValueForCharacteristicBlock)(CBCharacteristic *characteristic, NSData *value, NSError *error);

/** 获取描述中的值 */
typedef void(^ValueForDescriptorBlock)(CBDescriptor *descriptor,NSData *data,NSError *error);

/** 往特性中写入数据的回调 */
typedef void(^WriteToCharacteristicBlock)(CBCharacteristic *characteristic, NSError *error);

/** 往描述中写入数据的回调 */
typedef void(^WriteToDescriptorBlock)(CBDescriptor *descriptor, NSError *error);

/** 获取蓝牙外设信号的回调 */
typedef void(^GetRSSIBlock)(CBPeripheral *peripheral,NSNumber *RSSI, NSError *error);


#endif /* TFY_BLEConst_h */
