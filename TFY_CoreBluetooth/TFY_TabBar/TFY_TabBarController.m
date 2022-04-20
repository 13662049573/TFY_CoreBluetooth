//
//  TFY_TabBarController.m
//  TFY_CoreBluetooth
//
//  Created by 田风有 on 2020/9/8.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_TabBarController.h"
#import "TFY_HomeController.h"
#import "TFY_MineController.h"
#import "TFY_SubjectController.h"

@interface TFY_TabBarController ()<TfySY_TabBarDelegate>

@end

@implementation TFY_TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 去掉顶部的黑线
    self.tabBar.backgroundImage = [UIImage tfy_createImage:UIColor.clearColor];
    [self.tabBar setShadowImage:[UIImage tfy_createImage:UIColor.clearColor]];
    
    [self addChildViewControllers];
}

- (void)addChildViewControllers {
    
    NSArray <NSDictionary *>*VCArray =
    @[@{@"vc":[TFY_HomeController new],@"normalImg":@"icon_tabbar_home_no",@"selectImg":@"icon_tabbar_home",@"itemTitle":@"发现"},
      @{@"vc":[TFY_SubjectController new],@"normalImg":@"icon_tabbar_subscription_no",@"selectImg":@"icon_tabbar_subscription",@"itemTitle":@"关注"},
      @{@"vc":[UIViewController new],@"normalImg":@"",@"selectImg":@"",@"itemTitle":@" "},
      @{@"vc":[UIViewController new],@"normalImg":@"icon_tabbar_notification_no",@"selectImg":@"icon_tabbar_notification",@"itemTitle":@"消息"},
      @{@"vc":[TFY_MineController new],@"normalImg":@"icon_tabbar_me_no",@"selectImg":@"icon_tabbar_me",@"itemTitle":@"我的"}];
    
    NSMutableArray *tabBarConfs = @[].mutableCopy;
    NSMutableArray *tabBarVCs = @[].mutableCopy;
    [VCArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TfySY_TabBarConfigModel *model = [TfySY_TabBarConfigModel new];
        model.itemTitle = [obj objectForKey:@"itemTitle"];
        model.selectImageName = [obj objectForKey:@"selectImg"];
        model.normalImageName = [obj objectForKey:@"normalImg"];
        // 4.设置单个选中item标题状态下的颜色
        model.selectColor = TfySY_TabBarRGB(224, 111, 97);
        model.normalColor = TfySY_TabBarRGB(140, 140, 140);

        if (idx == 2 ) { // 如果是中间的
            CGFloat height = self.tabBar.frame.size.height - 10;
            // 设置凸出
            model.bulgeStyle = TfySY_TabBarConfigBulgeStyleSquare;
            // 设置凸出高度
            model.bulgeHeight = -5;
            model.bulgeRoundedCorners = height/2; // 修角
            // 设置成纯图片展示
            model.itemLayoutStyle = TfySY_TabBarItemLayoutStylePicture;
            model.normalImageName = model.selectImageName = @"button_write";
            model.componentMargin = UIEdgeInsetsMake(0, 0, 0, 0);// 无边距
            // 设置大小/边长
            model.itemSize = CGSizeMake(self.tabBar.frame.size.width / 5 - 15.0 ,height);
        }
        UIViewController *vc = [obj objectForKey:@"vc"];
        vc.view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.f
                                                  green:arc4random()%255/255.f
                                                   blue:arc4random()%255/255.f alpha:1];
        vc.title = [obj objectForKey:@"itemTitle"];
        // 5.将VC添加到系统控制组
        TFY_NavigationController *nav = [[TFY_NavigationController alloc] initWithRootViewController:vc];
        [tabBarVCs addObject:nav];
        // 5.1添加构造Model到集合
        [tabBarConfs addObject:model];
    }];

    self.ControllerArray = tabBarVCs;
    self.tfySY_TabBar = [[TfySY_TabBar alloc] initWithTabBarConfig:tabBarConfs];
    self.tfySY_TabBar.delegate = self;
    self.tfySY_TabBar.backgroundColor = UIColor.greenColor;
    [self.tabBar addSubview:self.tfySY_TabBar];
    
}
// 9.实现代理，如下：
static NSInteger lastIdx = 0;
- (void)TfySY_TabBar:(TfySY_TabBar *)tabbar selectIndex:(NSInteger)index{
    if (index != 2) { // 不是中间的就切换
        [self setSelectedIndex:index]; // 通知 切换视图控制器
        lastIdx = index;
    } else { // 点击了中间的
        [self.tfySY_TabBar setSelectIndex:lastIdx WithAnimation:NO]; // 换回上一个选中状态
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"点击了中间的,不切换视图"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"好的！！！！");
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


@end
