//
//  TFY_EasyUtils.h
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//强弱引用
#define Blue_kWeakSelf(type)__weak typeof(type)weak##type = type;
#define Blue_kStrongSelf(type)__strong typeof(type)type = weak##type;


/***线程****/
#define Blue_queueGlobalStart dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

#define Blue_queueMainStart dispatch_async(dispatch_get_main_queue(), ^{

#define Blue_QueueStartAfterTime(time) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){

#define Blue_queueEnd  });

/**打印****/
#define Blue_ISSHOWLOG 1

//接受系统消息
#define Blue_ISSHOWRECEIVELOG 1

//调用API
#define Blue_ISSHOWSENDLOG 1

#define Blue_EasyLog(fmt, ...) if(Blue_ISSHOWLOG) { NSLog(fmt,##__VA_ARGS__); }

#define Blue_EasyLog_R(fmt, ...) if(Blue_ISSHOWRECEIVELOG && Blue_ISSHOWLOG) { NSLog(fmt,##__VA_ARGS__); }

#define Blue_EasyLog_S(fmt, ...) if(Blue_ISSHOWSENDLOG && Blue_ISSHOWLOG) { NSLog(fmt,##__VA_ARGS__); }

// 是否为空
#define Blue_ISEMPTY(_v) (_v == nil || _v.length == 0)



/********存储数据*********/
#define Blue_EFUserDefaults [NSUserDefaults standardUserDefaults]

#define Blue_EFUserDefaultsSetObj(obj, key) \
[Blue_EFUserDefaults setObject:obj forKey:key]; \
[Blue_EFUserDefaults synchronize];

#define Blue_EFUserDefaultsObjForKey(key) [Blue_EFUserDefaults objectForKey:key]


NS_ASSUME_NONNULL_BEGIN

typedef union
{
    UInt8 value;
    struct {
        // Reversed order
        UInt8 second : 4;
        UInt8 first : 4;
    };
} Nibble;

@interface TFY_EasyUtils : NSObject
/**
 * 将16进制的字符串转换成NSData
 */
+ (NSMutableData *)convertHexStrToData:(NSString *)str ;

/**
 *十六进制转换为普通字符串的。
 */
+ (NSString *)ConvertHexStringToString:(NSString *)hexString;
/**
  *  普通字符串转换为十六进制
 **/
+ (NSString *)ConvertStringToHexString:(NSString *)string;
/**
 *  int转data
 */
+(NSData *)ConvertIntToData:(int)i;
/**
 *  data转int
 */
+(int)ConvertDataToInt:(NSData *)data;
/**
 *  十六进制转换为普通字符串的。
 */
+ (NSData *)ConvertHexStringToData:(NSString *)hexString;

/**
 *  最上方的控制器
 */
+ (UIViewController *)topViewController ;
/*!
 * 内联函数，用于解码UInt8值。它会自动增加指针值。
 * p_encoded_data用于存储编码数据的缓冲区。
 */
+ (UInt8)readUInt8Value:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 内联函数，用于解码SInt8值。它会自动增加指针值
 *  [in] p_encoded_data用于存储编码数据的缓冲区。
 */
+ (SInt8)readSInt8Value:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 内联函数，用于解码UInt16值。它会自动增加指针值。
 * [in] p_encoded_data用于存储编码数据的缓冲区。
 */
+ (UInt16)readUInt16Value:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 用于解码SInt16值。它会自动增加指针值。
 *  p_encoded_data用于存储编码数据的缓冲区。
 */
+ (SInt16)readSInt16Value:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 用于解码UInt32值。它会自动增加指针值。
 * p_encoded_data用于存储编码数据的缓冲区。
 */
+ (UInt32)readUInt32Value:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 用于解码SInt32值。它会自动增加指针值。
 * p_encoded_data用于存储编码数据的缓冲区。
 */
+ (SInt32)readSInt32Value:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 用于解码SFloat值。它会自动增加指针值。
 * p_encoded_data用于存储编码数据的缓冲区。
 */
+ (Float32)readSFloatValue:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 用于解码Float值。它会自动增加指针值
 * p_encoded_data用于存储编码数据的缓冲区。
 */
+ (Float32)readFloatValue:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 用于解码日期和时间值。它会自动增加指针值。
 * p_encoded_data用于存储编码数据的缓冲区。
 */
+ (NSDate*)readDateTime:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

/*!
 * 用于对半字节值进行解码。它会自动增加指针值。半字节在一个字节中包含一对4位值。
 * p_encoded_data用于存储编码数据的缓冲区。
 */
+ (Nibble)readNibble:(uint8_t*_Nonnull*_Nonnull)p_encoded_data;

@end

NS_ASSUME_NONNULL_END
