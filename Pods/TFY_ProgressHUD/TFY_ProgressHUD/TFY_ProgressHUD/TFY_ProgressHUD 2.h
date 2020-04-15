//
//  TFY_ProgressHUD.h
//  TFY_AutoLayoutModelTools
//
//  Created by 田风有 on 2019/5/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PopupShowType) {
    PopupShowType_None,              //没有
    PopupShowType_FadeIn,            //淡入
    PopupShowType_GrowIn,            //成长
    PopupShowType_ShrinkIn,           //收缩
    PopupShowType_SlideInFromTop,     //从顶部，底部，左侧，右侧滑入
    PopupShowType_SlideInFromBottom,
    PopupShowType_SlideInFromLeft,
    PopupShowType_SlideInFromRight,
    PopupShowType_BounceIn,           //从顶部，底部，左侧，右侧，中心弹跳
    PopupShowType_BounceInFromTop,
    PopupShowType_BounceInFromBottom,
    PopupShowType_BounceInFromLeft,
    PopupShowType_BounceInFromRight
};

typedef NS_ENUM(NSUInteger, PopupDismissType) {
    PopupDismissType_None,
    PopupDismissType_FadeOut,
    PopupDismissType_GrowOut,
    PopupDismissType_ShrinkOut,
    PopupDismissType_SlideOutToTop,
    PopupDismissType_SlideOutToBottom,
    PopupDismissType_SlideOutToLeft,
    PopupDismissType_SlideOutToRight,
    PopupDismissType_BounceOut,
    PopupDismissType_BounceOutToTop,
    PopupDismissType_BounceOutToBottom,
    PopupDismissType_BounceOutToLeft,
    PopupDismissType_BounceOutToRight
};
//在水平方向上布置弹出窗口
typedef NS_ENUM(NSUInteger, PopupHorizontalLayout) {
    PopupHorizontalLayout_Custom,
    PopupHorizontalLayout_Left,
    PopupHorizontalLayout_LeftOfCenter,           //中心左侧
    PopupHorizontalLayout_Center,
    PopupHorizontalLayout_RightOfCenter,
    PopupHoricontalLayout_Right
};
//在垂直方向上布置弹出窗口
typedef NS_ENUM(NSUInteger, PopupVerticalLayout) {
    PopupVerticalLayout_Custom,
    PopupVerticalLayout_Top,
    PopupVerticalLayout_AboveCenter,              //中心偏上
    PopupVerticalLayout_Center,
    PopupVerticalLayout_BelowCenter,
    PopupVerticalLayout_Bottom
};

typedef NS_ENUM(NSUInteger, PopupMaskType) {
    //允许与底层视图交互
    PopupMaskType_None,
    //不允许与底层视图交互。
    PopupMaskType_Clear,
    //不允许与底层视图、背景进行交互。
    PopupMaskType_Dimmed,
    // 用户不可以做其他操作，并且背景色是黑色
    PopupMaskType_Black,
    // 用户不可以做其他操作，并且背景色是渐变的
    PopupMaskType_Gradient
};

struct PopupLayout {
    PopupHorizontalLayout horizontal;
    PopupVerticalLayout vertical;
};

typedef struct PopupLayout PopupLayout;

extern PopupLayout PopupLayoutMake(PopupHorizontalLayout horizontal, PopupVerticalLayout vertical);

extern const PopupLayout PopupLayout_Center;


@interface TFY_ProgressHUD : UIView
/**
 *   自定义视图
 */
@property (nonatomic, strong) UIView *contentView;
/**
 *  弹出动画
 */
@property (nonatomic, assign) PopupShowType showType;
/**
 *  消失动画
 */
@property (nonatomic, assign) PopupDismissType dismissType;
/**
 *  交互类型
 */
@property (nonatomic, assign) PopupMaskType maskType;
/**
 *  默认透明的0.5，通过这个属性可以调节
 */
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;
/**
 *  提示透明度
 */
@property (nonatomic, assign) CGFloat toastMaskAlpha;
/**
 *  动画出现时间默认0.15
 */
@property (nonatomic, assign) CGFloat showInDuration;
/**
 *  动画消失时间默认0.15
 */
@property (nonatomic, assign) CGFloat dismissOutDuration;
/**
 *   当背景被触摸时，弹出窗口会消失。
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;
/**
 *  当内容视图被触摸时，弹出窗口会消失默认no
 */
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;
/**
 *   显示动画启动时回调。
 */
@property (nonatomic, copy, nullable) void(^willStartShowingBlock)(void);
/**
 *  显示动画完成启动时回调。
 */
@property (nonatomic, copy, nullable) void(^didFinishShowingBlock)(void);
/**
 *  显示动画将消失时回调。
 */
@property (nonatomic, copy, nullable) void(^willStartDismissingBlock)(void);
/**
 *  显示动画已经消失时回调。
 */
@property (nonatomic, copy, nullable) void(^didFinishDismissingBlock)(void);
/**
 *  背景视图
 */
@property (nonatomic, strong, readonly) UIView *backgroundView;
/**
 *  展现内容视图
 */
@property (nonatomic, strong, readonly) UIView *containerView;
/**
 *  是否开始展现
 */
@property (nonatomic, assign, readonly) BOOL isBeingShown;
/**
 *  正在展现
 */
@property (nonatomic, assign, readonly) BOOL isShowing;
/**
 *  开始消失
 */
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;
/**
 *  弹出一个自定义视图
 */
+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView;
/**
 *  弹出自定义文字提示框
 */
+ (void)showToastVieWiththContent:(NSString *)content showType:(PopupShowType)showType dismissType:(PopupDismissType)dismissType stopTime:(NSInteger)time;
/**
 *  弹出自定义文字提示框
 */
+ (void)showToastViewWithAttributedContent:(NSAttributedString *)attributedString showType:(PopupShowType)showType dismissType:(PopupDismissType)dismissType stopTime:(NSInteger)time;
/**
 *   弹出一个自定义视图
 */
+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView showType:(PopupShowType)showType dismissType:(PopupDismissType)dismissType maskType:(PopupMaskType)maskType dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;
/**
 *  结束弹框
 */
+ (void)dismissAllPopups;
+ (void)dismissPopupForView:(UIView *)view animated:(BOOL)animated;
+ (void)dismissSuperPopupIn:(UIView *)view animated:(BOOL)animated;
/**
 *  不带任何文字的弹出框
 */
+ (void)show;
/**
 *  提示弹框 输入文字
 */
+ (void)showWithStatus:(NSString*)status;
/**
 *  展示状态  status   显示状态  maskType 枚举类型
 */
+ (void)showWithStatus:(NSString*)status maskType:(PopupMaskType)maskType;

+ (void)showWithMaskType:(PopupMaskType)maskType;
/**
 *  展示成功的状态  string 传字符串
 */
+ (void)showSuccessWithStatus:(NSString*)string;
/**
 *  展示成功的状态 string   传字符串  duration 设定显示时间
 */
+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  展示失败的状态 string 字符串
 */
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  展示提示信息  string 字符串
 */
+ (void)showPromptWithStatus:(NSString *)string;
+ (void)showPromptWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  在显示时更改HUD的加载状态。
 */
+ (void)setStatus:(NSString*)string;
/**
 *  提示框 结束简单地用淡出+缩放动画来解散HUD。
 */
+ (void)dismiss;
/**
 *  显示成功图标图像
 */
+ (void)dismissWithSuccess:(NSString*)successString;
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
/**
 *  显示错误图标图像。
 */
+ (void)dismissWithError:(NSString*)errorString;
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithPrompt:(NSString *)promptString;
+ (void)dismissWithPrompt:(NSString *)promptString afterDelay:(NSTimeInterval)seconds;

+ (BOOL)isVisible;

+ (TFY_ProgressHUD*)sharedView;

- (void)dismissWithNoAni;
/**
 *  添加View弹出
 */
- (void)show;

- (void)showWithLayout:(PopupLayout)layout;

- (void)showWithDuration:(NSTimeInterval)duration;

- (void)showWithLayout:(PopupLayout)layout duration:(NSTimeInterval)duration;

- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view;

- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view duration:(NSTimeInterval)duration;
/**
 *  自己添加View 取消所有提示
 */
- (void)dismissAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
