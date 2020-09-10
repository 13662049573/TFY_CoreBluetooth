//
//  TFY_EasyBlueTooth.h
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/10.
//  Copyright © 2020 田风有. All rights reserved.
//  最新版本号:2.1.6

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double TFY_EasyBlueToothVersionNumber;

FOUNDATION_EXPORT const unsigned char TFY_EasyBlueToothVersionString[];

#define TFY_EasyBlueToothKitRelease 0

#if TFY_EasyBlueToothRelease

#import <TFY_EasyBlueTooth/TFY_EasyCenterManager.h>
#import <TFY_EasyBlueTooth/TFY_EasyBlueToothManager.h>
#import <TFY_EasyBlueTooth/TFY_EasyUtils.h>

#else

#import "TFY_EasyCenterManager.h"
#import "TFY_EasyBlueToothManager.h"
#import "TFY_EasyUtils.h"

#endif
