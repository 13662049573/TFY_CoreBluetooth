//
//  TFY_EasyCenterManager.h
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TFY_EasyUtils.h"

@class TFY_EasyService ;
@class TFY_EasyPeripheral ;
@class TFY_EasyCharacteristic ;
@class TFY_EasyDescriptor ;
@class TFY_EasyCenterManager ;

typedef NS_ENUM(NSUInteger ,searchFlagType) {
    searchFlagTypeDefaut = 1 << 0,
    searchFlagTypeFinish = 1 << 1,//扫描时间到
    searchFlagTypeDisconnect = 1 << 2,//设备断开连接 删除设别
    searchFlagTypeAdded  = 1 << 3,//扫描到新设备
    searchFlagTypeChanged= 1 << 4,//已经扫描到设备，设备的状态改变
    searchFlagTypeDelete = 1 << 5 ,//设备超过时间未被发现
};

NS_ASSUME_NONNULL_BEGIN

/**
 * 搜索到设备的回到，只要系统搜索到设备，都会回调这个block
 * searchType 通知外部，对设备操作的类型
 */
typedef void (^blueToothSearchDeviceCallback)(TFY_EasyPeripheral *peripheral , searchFlagType searchType);

/**
 * 系统蓝牙状态改变
 */
typedef void (^blueToothStateChangedCallback)(TFY_EasyCenterManager *manager , CBManagerState state);


@interface TFY_EasyCenterManager : NSObject

/**
 * 中心管理者
 */
@property (nonatomic, strong ,readonly) CBCentralManager *manager;

/**
 * 当前的蓝牙状态
 */
@property(nonatomic, copy) blueToothStateChangedCallback stateChangeCallback;

/**
 * 是否正在扫描周围设备
 */
@property (assign) BOOL isScanning;

/*
 * 已经连接上的设备 key:设备的identifier value:连接上的设备
 */
@property (nonatomic,strong,readonly)NSMutableDictionary *connectedDeviceDict ;

/**
 * 已经发现的设备 key:设备的identifier value:连接上的设备 (已经去掉了重复的设备)
 */
@property (nonatomic,strong,readonly)NSMutableDictionary *foundDeviceDict ;



/**
 * 初始化方法
 * queue 为manager运行的线程，传空就是在主线程上
 * options 扫描条件
 */
- (instancetype)initWithQueue:(dispatch_queue_t)queue ;
- (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options ;

/*
 * 扫描周围设备
 * timeInterval 为扫描的时间 (不传 就会一直扫描)
 * searchDeviceCallBack 只要扫描到一个设备就会回调这个方法
 * service options 扫描条件
 */
- (void)startScanDevice ;

- (void)scanDeviceWithTimeCallback:(blueToothSearchDeviceCallback)searchDeviceCallBack  ;

- (void)scanDeviceWithTimeInterval:(NSTimeInterval)timeInterval
                          callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack  ;

- (void)scanDeviceWithTimeInterval:(NSTimeInterval)timeInterval
                          services:(NSArray<CBUUID *> *)service
                           options:(NSDictionary<NSString *, id>  *)options
                          callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack ;


/**
 * 停止扫描，当还没有达到扫描时间，但是已经找到了想要连接的设别，可以调用它来停止扫描
 */
- (void)stopScanDevice ;


/**
 * 清空所有发现的设备
 */
- (void)removeAllScanFoundDevice ;

/**
 *  断开所有连接的设备
 */
- (void)disConnectAllDevice ;


/**
 * 寻找当前连接的设备
 */
- (TFY_EasyPeripheral *)searchDeviceWithPeripheral:(CBPeripheral *)peripheral ;


/**
 * 回去已经连接上的设备
 */
- (NSArray<TFY_EasyPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers;
- (NSArray<TFY_EasyPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDS;

/**
 * 一段时间没有扫描到设备，通知外部处理
 */
- (void)foundDeviceTimeout:(TFY_EasyPeripheral *)perpheral ;

@end

NS_ASSUME_NONNULL_END
