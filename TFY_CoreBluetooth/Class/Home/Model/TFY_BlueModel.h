//
//  TFY_BlueModel.h
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BlueModel : NSObject

TFY_PROPERTY_NSString(macip);
TFY_PROPERTY_NSString(identifierString);
TFY_PROPERTY_NSString(name);
TFY_PROPERTY_OBJECT_STRONG(NSNumber, reportTime);
TFY_PROPERTY_OBJECT_STRONG(NSNumber, RSSI);

-(instancetype)initWithEasyCenterManager:(TFY_EasyPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
