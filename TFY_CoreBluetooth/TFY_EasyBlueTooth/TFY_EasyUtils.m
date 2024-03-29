//
//  TFY_EasyUtils.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/28.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_EasyUtils.h"

typedef enum {
    MDER_S_POSITIVE_INFINITY = 0x07FE,
    MDER_S_NaN = 0x07FF,
    MDER_S_NRes = 0x0800,
    MDER_S_RESERVED_VALUE = 0x0801,
    MDER_S_NEGATIVE_INFINITY = 0x0802
} ReservedSFloatValues;
static const UInt32 FIRST_S_RESERVED_VALUE = MDER_S_POSITIVE_INFINITY;

typedef enum {
    MDER_POSITIVE_INFINITY = 0x007FFFFE,
    MDER_NaN = 0x007FFFFF,
    MDER_NRes = 0x00800000,
    MDER_RESERVED_VALUE = 0x00800001,
    MDER_NEGATIVE_INFINITY = 0x00800002
} ReservedFloatValues;
static const UInt32 FIRST_RESERVED_VALUE = MDER_POSITIVE_INFINITY;

static const double reserved_float_values[5] = {INFINITY, NAN, NAN, NAN, -INFINITY};


@implementation TFY_EasyUtils

//将16进制的字符串转换成NSData
+ (NSData *)convertHexStrToData:(NSString *)str
{
    if (!str.length) {
        return nil;
    }
    
    NSMutableData *tempData = [NSMutableData dataWithCapacity:10];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
       
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [tempData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return [NSData dataWithData:tempData];
}

//将NSData转为16进制的字符串
+ (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *tempString = [NSMutableString stringWithCapacity:data.length];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange,BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i =0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) &0xff];
            if ([hexStr length] == 2) {
                [tempString appendString:hexStr];
            }
            else {
                [tempString appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return [NSString stringWithString:tempString];
}
//十进制准换为十六进制字符串
+ (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+(NSString *)parseByteArray2HexString:(Byte[])bytes
{
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    int i = 0;
    if(bytes){
        while (bytes[i] != '\0'){
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            i++;
        }
    }
    return hexStr;
}



+(NSString *)stringFromHexString:(NSString *)hexString
{//
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 +1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i =0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr] ;
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    return unicodeString;
}

//10进制转16进制
+(NSString *)ToHex:(long long int)tmpid{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i =0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}



//十六进制转换为普通字符串的。
+ (NSString *)ConvertHexStringToString:(NSString *)hexString {
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    //    BabyLog(@"===字符串===%@",unicodeString);
    return unicodeString;
}

//普通字符串转换为十六进制
+ (NSString *)ConvertStringToHexString:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for (int i=0;i<[myD length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if ([newHexStr length]==1) {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
        
    }
    return hexStr;
}


//int转data
+ (NSData *)ConvertIntToData:(int)i{
    
    NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
    return data;
}

//data转int
+ (int)ConvertDataToInt:(NSData *)data {
    int i;
    [data getBytes:&i length:sizeof(i)];
    return i;
}

//十六进制转换为普通字符串的。
+ (NSData *)ConvertHexStringToData:(NSString *)hexString {
    
    NSData *data = [[self ConvertHexStringToString:hexString] dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}


+ (UIViewController*)topViewController {
    UIWindow* window = nil;
    if (@available(iOS 13.0, *))
    {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                window = windowScene.windows.firstObject;

                break;
            }
        }
    }else{
        window = [UIApplication sharedApplication].keyWindow;
    }
    return (UIViewController*)[TFY_EasyUtils topViewControllerWithRootViewController:window.rootViewController];
}
+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:nav.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

+ (UInt8)readUInt8Value:(uint8_t **)p_encoded_data
{
    return *(*p_encoded_data)++;
}

+ (SInt8)readSInt8Value:(uint8_t **)p_encoded_data
{
    return *(*p_encoded_data)++;
}

+ (UInt16)readUInt16Value:(uint8_t **)p_encoded_data
{
    UInt16 value = (UInt16) CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    *p_encoded_data += 2;
    return value;
}

+ (SInt16)readSInt16Value:(uint8_t **)p_encoded_data
{
    SInt16 value = (SInt16) CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    *p_encoded_data += 2;
    return value;
}

+ (UInt32)readUInt32Value:(uint8_t **)p_encoded_data
{
    UInt32 value = (UInt32) CFSwapInt32LittleToHost(*(uint32_t*)*p_encoded_data);
    *p_encoded_data += 4;
    return value;
}

+ (SInt32)readSInt32Value:(uint8_t **)p_encoded_data
{
    SInt32 value = (SInt32) CFSwapInt32LittleToHost(*(uint32_t*)*p_encoded_data);
    *p_encoded_data += 4;
    return value;
}

+ (Float32)readSFloatValue:(uint8_t **)p_encoded_data
{
    UInt16 tempData = CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    
    SInt16 mantissa = tempData & 0x0FFF;
    SInt8 exponent = tempData >> 12;
    
    if (exponent >= 0x0008) {
        exponent = -((0x000F + 1) - exponent);
    }
    
    Float32 output = 0;
    
    if (mantissa >= FIRST_S_RESERVED_VALUE && mantissa <= MDER_S_NEGATIVE_INFINITY)
    {
        output = reserved_float_values[mantissa - FIRST_S_RESERVED_VALUE];
    }
    else
    {
        if (mantissa >= 0x0800)
        {
            mantissa = -((0x0FFF + 1) - mantissa);
        }
        double magnitude = pow(10.0f, exponent);
        output = (mantissa * magnitude);
    }
    
    *p_encoded_data += 2;
    return output;
}

+(Float32)readFloatValue:(uint8_t **)p_encoded_data
{
    SInt32 tempData = (SInt32) CFSwapInt32LittleToHost(*(uint32_t*)*p_encoded_data);
    
    SInt32 mantissa = tempData & 0xFFFFFF;
    SInt8 exponent = tempData >> 24;
    Float32 output = 0;
    
    if (mantissa >= FIRST_RESERVED_VALUE && mantissa <= MDER_NEGATIVE_INFINITY)
    {
        output = reserved_float_values[mantissa - FIRST_RESERVED_VALUE];
    }
    else
    {
        if (mantissa >= 0x800000)
        {
            mantissa = -((0xFFFFFF + 1) - mantissa);
        }
        double magnitude = pow(10.0f, exponent);
        output = (mantissa * magnitude);
    }
    
    *p_encoded_data += 4;
    return output;
}

+(NSDate *)readDateTime:(uint8_t **)p_encoded_data
{
    uint16_t year = [TFY_EasyUtils readUInt16Value:p_encoded_data];
    uint8_t month = [TFY_EasyUtils readUInt8Value:p_encoded_data];
    uint8_t day = [TFY_EasyUtils readUInt8Value:p_encoded_data];
    uint8_t hour = [TFY_EasyUtils readUInt8Value:p_encoded_data];
    uint8_t min = [TFY_EasyUtils readUInt8Value:p_encoded_data];
    uint8_t sec = [TFY_EasyUtils readUInt8Value:p_encoded_data];
    
    NSString * dateString = [NSString stringWithFormat:@"%d %d %d %d %d %d", year, month, day, hour, min, sec];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy MM dd HH mm ss"];
    return  [dateFormat dateFromString:dateString];
}

+(Nibble)readNibble:(uint8_t **)p_encoded_data
{
    Nibble nibble;
    nibble.value = [TFY_EasyUtils readUInt8Value:p_encoded_data];
    
    return nibble;
}
/**
 * 十进制转换为二进制
 */
+ (NSString *)getBinaryByDecimal:(NSInteger)decimal{
    
    NSString *binary = @"";
    while (decimal) {
        
        binary = [[NSString stringWithFormat:@"%ld", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}

/**
 * 十进制转换十六进制
 */
+ (NSString *)getHexByDecimal:(NSInteger)decimal{
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {break;}
    }
    if (hex.length==1) {
        hex = [NSString stringWithFormat:@"0%@",hex];
    }
    return hex;
}
/**
 * 二进制转换成十六进制
 */
+ (NSString *)getHexByBinary:(NSString *)binary{
    
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4) {
        
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}
/**
 * 十六进制转换为二进制
 */
+ (NSString *)getBinaryByHex:(NSString *)hex{
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}
/**
 * 二进制转换为十进制
 */
+ (NSInteger)getDecimalByBinary:(NSString *)binary{
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

/**
异或计算（XOR）
sourceData 第一个
 keyData 第二二
*/
+ (NSData *)encodeXorData:(NSData *)sourceData withKey:(NSData *)keyData {
   Byte *keyBytes = (Byte *)[keyData bytes]; //取关键字的Byte数组, keyBytes一直指向头部
   Byte *sourceDataPoint = (Byte *)[sourceData bytes]; //取需要加密的数据的Byte数组
   for (long i = 0; i < [sourceData length]; i++) {
       sourceDataPoint[i] = sourceDataPoint[i] ^ keyBytes[i]; //然后按位进行异或运算
   }
   return sourceData;
}

+ (NSString *)stringXOR:(NSString *)string {
    if (string.length%2) {
        string = [NSString stringWithFormat:@"0%@", string];
    }
    NSString *code = @"00";
    for (int i=0; i<string.length; i=i+2) {
        // 两位两位取出
        NSString *subString = [string substringWithRange:NSMakeRange(i, 2)];
        // subString转为16进制
        NSString *hexString = [self getHexByDecimal:[subString integerValue]];
        code = [self pinxCreator:code withPinv:hexString];
    }
    return code;
}

+ (NSString *)pinxCreator:(NSString *)pan withPinv:(NSString *)pinv {
    if (pan.length != pinv.length) {
        return nil;
    }
    const char *panchar = [pan UTF8String];
    const char *pinvchar = [pinv UTF8String];
    NSString *temp = [[NSString alloc] init];
    for (int i = 0; i < pan.length; i++) {
        int panValue = [self charToint:panchar[i]];
        int pinvValue = [self charToint:pinvchar[i]];
        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"%X",panValue^pinvValue]];
    }
    return temp;
}

+ (int)charToint:(char)tempChar {
    if (tempChar >= '0' && tempChar <='9') {
        return tempChar - '0';
    } else if (tempChar >= 'A' && tempChar <= 'F') {
        return tempChar - 'A' + 10;
    } else if (tempChar >= 'a' && tempChar <= 'f') {
        return tempChar - 'a' + 10;
    }
    return 0;
}

@end


@implementation NSData (bule)

/**
 contentData 需要校验的内容
 异或值
 */
- (int)contentCheckValue:(NSData *)contentData {
    Byte *testByte = (Byte *)[contentData bytes];
    int checksum = 0;
    for(int i=0; i<[contentData length]; i++) {
        checksum ^= testByte[i];
    }
    return checksum;
}

/**
 与一个固定的值异或异或后的值
 */
- (NSData *)xor_0X5A {
    NSMutableData *data = [NSMutableData dataWithLength:1];
    uint8_t num = 0x5A;
    [data replaceBytesInRange:NSMakeRange(0, 1) withBytes:&num];
    Byte *byte1 = (Byte *)[self.copy bytes];
    Byte *byte2 = (Byte *)[data bytes];
    for(int i = 0; i < self.length; i++) {
        byte1[i] ^= byte2[0];
    }
    NSData *data1 = [[NSData alloc] initWithBytes:byte1 length:self.length];
    return data1;
}


/**
 异或校验（每一字节分别异或）n 校验值
 */
- (int)contentCheckValue {
    Byte *testByte = (Byte *)[self bytes];
    int checksum = 0;
    for(int i=0; i<[self length]; i++) {
        checksum ^= testByte[i];
    }
    return checksum;
}


@end
