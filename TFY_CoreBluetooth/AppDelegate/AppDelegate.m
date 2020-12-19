//
//  AppDelegate.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/27.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![ScenePackage defaultPackage].isSceneApp) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }
    [[ScenePackage defaultPackage] addBeforeWindowEvent:^(ScenePackage * _Nonnull application) {
        TFY_NavigationController *nav = [[TFY_NavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
        [UIApplication window].rootViewController = nav;
    }];
    return YES;
}

@end
