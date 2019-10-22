//
//  TFY_BLEManager.h
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TFY_BLEConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BLEManager : NSObject

#pragma mark - properties
/** 蓝牙模块状态改变的回调 */
@property (copy, nonatomic) StateUpdateBlock                      stateUpdateBlock;
/** 发现一个蓝牙外设的回调 */
@property (copy, nonatomic) DiscoverPeripheralBlock               discoverPeripheralBlcok;
/** 连接外设完成的回调 */
@property (copy, nonatomic) ConnectCompletionBlock                connectCompleteBlock;
/** 发现服务的回调 */
@property (copy, nonatomic) DiscoveredServicesBlock               discoverServicesBlock;
/** 发现服务中的特性的回调 */
@property (copy, nonatomic) DiscoverCharacteristicsBlock          discoverCharacteristicsBlock;
/** 特性值改变的回调 */
@property (copy, nonatomic) NotifyCharacteristicBlock             notifyCharacteristicBlock;
/** 发现服务中的子服务的回调 */
@property (copy, nonatomic) DiscoveredIncludedServicesBlock       discoverdIncludedServicesBlock;
/** 发现特性的描述的回调 */
@property (copy, nonatomic) DiscoverDescriptorsBlock              discoverDescriptorsBlock;
/** 操作完成的统一回调 */
@property (copy, nonatomic) ECompletionBlock                    completionBlock;
/** 获取特性值回调 */
@property (copy, nonatomic) ValueForCharacteristicBlock           valueForCharacteristicBlock;
/** 获取描述值的回调 */
@property (copy, nonatomic) ValueForDescriptorBlock               valueForDescriptorBlock;
/** 将数据写入特性中的回调 */
@property (copy, nonatomic) WriteToCharacteristicBlock            writeToCharacteristicBlock;
/** 将数据写入描述中的回调*/
@property (copy, nonatomic) WriteToDescriptorBlock                writeToDescriptorBlock;
/** 获取蓝牙外设信号强度的回调  */
@property (copy, nonatomic) GetRSSIBlock                          getRSSIBlock;

@property (strong, nonatomic, readonly)   CBPeripheral            *connectedPerpheral;  /**< 当前连接的外设 */

/**
 * 每次发送的最大数据长度，因为部分型号的蓝牙打印机一次写入数据过长，会导致打印乱码。
 * iOS 9之后，会调用系统的API来获取特性能写入的最大数据长度。
 * 但是iOS 9之前需要自己测试然后设置一个合适的值。默认值是146，我使用佳博58MB-III的限度。
 * 所以，如果你打印乱码，你考虑将该值设置小一点再试试。
 */
@property (assign, nonatomic)   NSInteger             limitLength;

#pragma mark - method
+ (instancetype)sharedInstance;

/**
 *  开始搜索蓝牙外设，每次在block中返回一个蓝牙外设信息
 *  uuids         服务的CBUUID
 *  option        其他可选参数
 */
- (void)scanForPeripheralsWithServiceUUIDs:(NSArray<CBUUID *> *)uuids options:(NSDictionary<NSString *, id> *)options;
/**
 *  开始搜索蓝牙外设，每次在block中返回一个蓝牙外设信息
 *  返回的block参数可参考CBCentralManager 的 centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *  uuids         服务的CBUUID
 *  option        其他可选参数
 *  discoverBlock 搜索到蓝牙外设后的回调
 */
- (void)scanForPeripheralsWithServiceUUIDs:(NSArray<CBUUID *> *)uuids options:(NSDictionary<NSString *, id> *)options didDiscoverPeripheral:(DiscoverPeripheralBlock)discoverBlock;

/**
 *  连接某个蓝牙外设，并查询服务，特性，特性描述
 *  peripheral          要连接的蓝牙外设
 *  connectOptions      连接的配置参数
 *  stop                连接成功后是否停止搜索蓝牙外设
 *  serviceUUIDs        要搜索的服务UUID
 *  characteristicUUIDs 要搜索的特性UUID
 *  completionBlock     操作执行完的回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
           connectOptions:(NSDictionary<NSString *,id> *)connectOptions
   stopScanAfterConnected:(BOOL)stop
          servicesOptions:(NSArray<CBUUID *> *)serviceUUIDs
   characteristicsOptions:(NSArray<CBUUID *> *)characteristicUUIDs
            completeBlock:(ECompletionBlock)completionBlock;

/**
 *  查找某个服务的子服务
 *  includedServiceUUIDs 要查找的子服务的UUIDs
 *  service              父服务
 */
- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;

/**
 *  读取某个特性的值
 *  characteristic 要读取的特性
 */
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  读取某个特性的值
 *  characteristic  要读取的特性
 *  completionBlock 读取完后的回调
 */
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic completionBlock:(ValueForCharacteristicBlock)completionBlock;

/**
 *  往某个特性中写入数据
 *  data           写入的数据
 *  characteristic 特性对象
 *  type           写入类型
 */
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;


/**
 *  往某个特性中写入数据
 *  data           写入的数据
 *  characteristic 特性对象
 *  type           写入类型
 *  completionBlock 写入完成后的回调,只有type为CBCharacteristicWriteWithResponse时，才会回调
 */
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type completionBlock:(WriteToCharacteristicBlock)completionBlock;

/**
 *  读取某特性的描述信息
 *  descriptor 描述对象
 */
- (void)readValueForDescriptor:(CBDescriptor *)descriptor;

/**
 *  读取某特性的描述信息
 *  descriptor      描述对象
 *  completionBlock 读取结果返回时的回调
 */
- (void)readValueForDescriptor:(CBDescriptor *)descriptor completionBlock:(ValueForDescriptorBlock)completionBlock;

/**
 *  将数据写入特性的描述中
 *  data       数据
 *  descriptor 描述对象
 */
- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor;

/**
 *  将数据写入特性的描述中
 *  data       数据v
 *  descriptor 描述对象
 *  completionBlock 数据写入完成后的回调
 */
- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor completionBlock:(WriteToDescriptorBlock)completionBlock;

/**
 *  获取某外设的信号
 *  completionBlock 获取信号完成后的回调
 */
- (void)readRSSICompletionBlock:(GetRSSIBlock)getRSSIBlock;

/**
 *  停止扫描
 */
- (void)stopScan;

/**
 *  断开蓝牙连接
 */
- (void)cancelPeripheralConnection;





@end

NS_ASSUME_NONNULL_END
