//
//  AppDelegate.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/27.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "AppDelegate.h"
#import "TFY_TabBarController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (!TFY_ScenePackage.isSceneApp) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }
    
    [TFY_ScenePackage addBeforeWindowEvent:^(TFY_Scene * _Nonnull application) {
        application.window.rootViewController = TFY_TabBarController.new;
    }];
    
    return YES;
}

@end
