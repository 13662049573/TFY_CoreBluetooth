//
//  TFY_EasyManagerOptions.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_EasyManagerOptions.h"

@implementation TFY_EasyManagerOptions

- (instancetype)init
{
    if (self = [super init]) {
        _scanTimeOut = NSIntegerMax ;
        _connectTimeOut = 5 ;
    }
    return self ;
}
- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue managerDictionary:(NSDictionary *)managerDictionary
{
    return [self initWithManagerQueue:queue managerDictionary:managerDictionary scanOptions:@{} scanServiceArray:@[]];
}

- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue managerDictionary:(NSDictionary *)managerDictionary scanOptions:(NSDictionary *)scanOptions scanServiceArray:(NSArray *)scanServiceArray
{
    return [self initWithManagerQueue:queue managerDictionary:managerDictionary scanOptions:scanOptions scanServiceArray:scanServiceArray connectOptions:@{}];
}

- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue managerDictionary:(NSDictionary *)managerDictionary scanOptions:(NSDictionary *)scanOptions scanServiceArray:(NSArray *)scanServiceArray connectOptions:(NSDictionary *)connectOptions
{
    if (self = [self init]) {
        _managerQueue = queue ;
        _managerDictionary = managerDictionary ;
        _scanOptions = scanOptions ;
        _scanServiceArray = scanServiceArray ;
        _connectOptions = connectOptions ;
    }
    return self ;
}


@end
