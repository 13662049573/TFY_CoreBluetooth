//
//  TFY_DetailHeaderFooterView.h
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DetailHeaderFooterView : UITableViewHeaderFooterView
TFY_PROPERTY_NSInteger(sectionState);
TFY_PROPERTY_NSString(serviceName);
TFY_PROPERTY_CHAIN_BLOCK(callback,BOOL isShow);
@end

NS_ASSUME_NONNULL_END
