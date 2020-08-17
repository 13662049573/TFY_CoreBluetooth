//
//  ViewController.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/27.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蓝牙列表";
    self.navigationController.tfy_titleColor = [UIColor redColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //1、局部变量截获 是值截获
    NSInteger num = 3;
    
    NSInteger(^block)(NSInteger) = ^NSInteger(NSInteger n){
        return n*num;
    };
    
    num = 1;
    
    NSLog(@"block====:%ld",block(2));
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"1",@"2", nil];
    
    void(^block2)(void) = ^{
        
        NSLog(@"block2=====:%@",array);//局部变量
        
        [array addObject:@"4"];
    };
    
    [array addObject:@"3"];
    
    array = nil;
    
    block2();
    
    //2、局部静态变量截获 是指针截获。
    static  NSInteger num3 = 3;
        
    NSInteger(^block3)(NSInteger) = ^NSInteger(NSInteger n3){
        
        return n3*num3;
    };
    
    num3 = 1;
    
    NSLog(@"block3=====:%zd",block3(2));

   //3、全局变量，静态全局变量截获：不截获,直接取值。
    [self blockTest];

    
   //分为全局Block(_NSConcreteGlobalBlock)、栈Block(_NSConcreteStackBlock)、堆Block(_NSConcreteMallocBlock)三种形式
    //其中栈Block存储在栈(stack)区，堆Block存储在堆(heap)区，全局Block存储在已初始化数据(.data)区
    
    NSLog(@"-----%@",[^{
        NSLog(@"---globalblock");
    } class]);
 
    //2、使用外部变量并且未进行copy操作的block是栈block
    NSInteger num4 = 10;
    NSLog(@"=======%@",[^{
        NSLog(@"====sttackBlock:%zd",num4);
    } class]);
    
    [self testWithBlock:^{
        NSLog(@"%@",self);
    }];
    
    //3、对栈block进行copy操作，就是堆block，而对全局block进行copy，仍是全局block
    void(^globalBlock)(void) = ^{
        NSLog(@"globaBlock");
    };
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"AM"];
    [formatter setPMSymbol:@"PM"];
    [formatter setDateFormat:@"YY-MM-dd hh:mm:ss aaa"];
    NSString * currentDate = [formatter stringFromDate:[NSDate date]];
    NSLog(@"=====================：%@",currentDate);
    
}
- (void)blockTest
{
    static NSInteger num3 = 300;

    NSInteger num4 = 3000;
    
    NSInteger num = 30;
    
    static NSInteger num2 = 3;
    
    __block NSInteger num5 = 30000;
    
    void(^block)(void) = ^{
        
        NSLog(@"%zd",num);//局部变量
        
        NSLog(@"%zd",num2);//静态变量
        
        NSLog(@"%zd",num3);//全局变量
        
        NSLog(@"%zd",num4);//全局静态变量
        
        NSLog(@"%zd",num5);//__block修饰变量
    };
    
    block();
}

- (void)testWithBlock:(dispatch_block_t)block{
    block();
    dispatch_block_t tempBlock = block;
    
    NSLog(@"%@,%@",[block class],[tempBlock class]);
}

@end
