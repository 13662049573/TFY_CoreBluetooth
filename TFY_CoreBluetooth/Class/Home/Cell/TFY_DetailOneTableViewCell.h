//
//  TFY_DetailOneTableViewCell.h
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DetailOneTableViewCell : UITableViewCell
TFY_PROPERTY_OBJECT_STRONG(TFY_EasyCharacteristic, character);
TFY_PROPERTY_NSString(titleString);
TFY_PROPERTY_NSString(subTitleString);
@end

NS_ASSUME_NONNULL_END
