//
//  AppDelegate.m
//  TFY_CoreBluetooth
//
//  Created by tiandengyou on 2019/9/27.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    //在创建新的场景会话时调用。
   //使用此方法选择用于创建新场景的配置。
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    //当用户放弃场景会话时调用。
    //如果在应用程序未运行时丢弃了任何会话，则会在application：didFinishLaunchingWithOptions之后不久调用此方法。
    //使用此方法释放特定于被丢弃场景的任何资源，因为它们不会返回。
}


@end
