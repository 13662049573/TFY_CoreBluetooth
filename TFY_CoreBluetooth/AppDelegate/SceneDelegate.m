#import "SceneDelegate.h"
#import "ViewController.h"
@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
       UIWindowScene *windowScene = (UIWindowScene *)scene;
       self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
       self.window.backgroundColor = [UIColor whiteColor];
    
      TFY_NavigationController *nav = [[TFY_NavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
      self.window.rootViewController = nav;
       
       [self.window makeKeyAndVisible];
   
}


- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
   //在系统释放场景时调用。
    //这是在场景进入背景后不久或会话被丢弃时发生的。
    //释放与此场景关联的所有资源，这些资源可在场景下次连接时重新创建。
    //场景可能稍后会重新连接，因为它的会话没有必要被丢弃（请参阅`application：didDiscardSceneSessions`）。
}


- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    //当场景从非活动状态转换为活动状态时调用。
   //使用此方法重新启动场景处于非活动状态时已暂停（或尚未开始）的所有任务。
}


- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
   //当场景从活动状态转换为非活动状态时调用。
   //这可能是由于临时中断（例如打入电话）而发生的。
}


- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
   //当场景从背景过渡到前景时调用。
   //使用此方法撤消在输入背景时所做的更改。
}


- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    //当场景从前景过渡到背景时调用。
    //使用此方法保存数据，释放共享资源，并存储足够的特定于场景的状态信息
    //将场景恢复到当前状态。
}


@end
