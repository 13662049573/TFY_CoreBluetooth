//
//  TFY_BlueModel.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_BlueModel.h"

@implementation TFY_BlueModel

-(NSNumber *)reportTime{
    time_t t;
    t = time(NULL);
    NSInteger time_now = time(&t);
    return [NSNumber numberWithInteger:time_now*1000];
}
-(instancetype)initWithEasyCenterManager:(TFY_EasyPeripheral *)peripheral{
    
    if (self=[super init]) {
        
        self.RSSI = peripheral.RSSI;
        self.name = peripheral.name;
        self.identifierString = peripheral.identifierString;
        NSData *data = peripheral.advertisementData[@"kCBAdvDataManufacturerData"];
        NSString *mac = [TFY_EasyUtils convertDataToHexStr:data];
    
        NSMutableDictionary *dict = [self buledata:[self reversalString:mac]];
        
        self.macip = [NSString stringWithFormat:@"%@",dict[@"macip"]];
    }
    return self;
}

-(NSNumber*)temperaturethree:(NSString *)temperaturethree {
    NSNumber *nuber;
    if (![self judgeIsEmptyWithString:temperaturethree]) {
        NSString *shiliu = [TFY_EasyUtils getBinaryByHex:temperaturethree];
        
        NSInteger shi = [TFY_EasyUtils getDecimalByBinary:shiliu];
        
        NSMutableString* str1=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%ld",(long)shi]];
        if (str1.length>2) {
            [str1 insertString:@"." atIndex:2];
        }
        nuber = [self numberWithString:str1];
    }
    return nuber;
}
-(BOOL)judgeIsEmptyWithString:(NSString *)string{
    if (string.length == 0 || [string isEqualToString:@""] || string == nil || string == NULL || [string isEqual:[NSNull null]] || [string isEqualToString:@" "] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    return NO;
}

-(NSMutableDictionary *)buledata:(NSString *)data{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (data.length==16) {
        NSString *types = [data substringWithRange:NSMakeRange(0, 12)].uppercaseString;
        NSMutableString *sting = [[NSMutableString alloc] initWithString:types];
        for (NSInteger i=0; i<sting.length; i++) {
            if (i==1 || i== 3 || i==5 || i==7 || i==9) {
                if (i==1) {
                    [sting insertString:@":" atIndex:2*i-0];
                }
                if (i==3) {
                    [sting insertString:@":" atIndex:2*i-1];
                }
                if (i==5) {
                    [sting insertString:@":" atIndex:2*i-2];
                }
                if (i==7) {
                    [sting insertString:@":" atIndex:2*i-3];
                }
                if (i==9) {
                    [sting insertString:@":" atIndex:2*i-4];
                }
            }
            else{
                continue;
            }
        }
        [dict setObject:sting forKey:@"macip"];
    }
    return dict;
}
- (NSString *)reversalString:(NSString *)originString{
    NSString *resultStr = @"";
    for (NSInteger i = originString.length -2; i >= 0; i-=2) {
      NSString *indexStr = [originString substringWithRange:NSMakeRange(i, 2)];
      resultStr = [resultStr stringByAppendingString:indexStr];
    }
  return resultStr;
}

- (NSString*)reverseWordsInString:(NSString*)oldStr{

   NSMutableString *newStr = [NSMutableString stringWithCapacity:oldStr.length];

   [oldStr enumerateSubstringsInRange:NSMakeRange(0, oldStr.length) options:NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){

     [newStr appendString:substring];

  }];
  return newStr;

}

- (NSNumber *)numberWithString:(NSString *)string {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *str = [[string stringByTrimmingCharactersInSet:set] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true" :   @(YES),
                @"yes" :    @(YES),
                @"false" :  @(NO),
                @"no" :     @(NO),
                @"nil" :    [NSNull null],
                @"null" :   [NSNull null],
                @"<null>" : [NSNull null]};
    });
    id num = dic[str];
    if (num) {
        if (num == [NSNull null]) return nil;
        return num;
    }
    
    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    // normal number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}
@end
