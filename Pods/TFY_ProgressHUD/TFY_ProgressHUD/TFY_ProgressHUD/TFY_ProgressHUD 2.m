//
//  TFY_ProgressHUD.m
//  TFY_AutoLayoutModelTools
//
//  Created by 田风有 on 2019/5/11.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_ProgressHUD.h"
#import <AvailabilityMacros.h>
#import <QuartzCore/QuartzCore.h>

#define NotificationCenter [NSNotificationCenter defaultCenter]

static const CGFloat kDefaultSpringDamping = 0.8;
static const CGFloat kDefaultSpringVelocity = 10.0;
static const CGFloat kDefaultAnimateDuration = 0.15;
static const NSInteger kAnimationOptionCurve = (7 << 16);
static NSString *const kParametersViewName = @"parameters.view";
static NSString *const kParametersLayoutName = @"parameters.layout";
static NSString *const kParametersCenterName = @"parameters.center-point";
static NSString *const kParametersDurationName = @"parameters.duration";

typedef enum : NSUInteger{
    ProgressHUD_ERROR = 0,  // 错误信息
    ProgressHUD_SUCCESS,    // 成功信息
    ProgressHUD_PROMPT,     // 提示信息
}ProgressHUDType;

PopupLayout XHPopupLayoutMake(PopupHorizontalLayout horizontal, PopupVerticalLayout vertical) {
    PopupLayout layout;
    layout.horizontal = horizontal;
    layout.vertical = vertical;
    return layout;
}

const PopupLayout PopupLayout_Center = { PopupHorizontalLayout_Center, PopupVerticalLayout_Center };

@interface NSValue (PopupLayout)
+ (NSValue *)valueWithXHPopupLayout:(PopupLayout)layout;
- (PopupLayout)PopupLayoutValue;
@end

@interface UIView (Popup)
- (void)containsPopupBlock:(void (^)(TFY_ProgressHUD *popup))block;
- (void)dismissShowingPopup:(BOOL)animated;
@end



@interface TFY_ProgressHUD ()
@property (nonatomic,  assign) ProgressHUDType type;
@property (nonatomic,  strong) NSTimer *fadeOutTimer;
@property (nonatomic,  strong) UIWindow *overlayWindow;
@property (nonatomic,  strong) UIView *hudView;
@property (nonatomic,  strong) UILabel *stringLabel;
@property (nonatomic,  strong) UIImageView *imageView;
@property (nonatomic,  strong) UIActivityIndicatorView *spinnerView;
@property (nonatomic,assign) CGFloat visibleKeyboardHeight;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isBeingShown;
@property (nonatomic, assign) BOOL isBeingDismissed;

- (void)showWithStatus:(NSString*)string maskType:(PopupMaskType)hudMaskType networkIndicator:(BOOL)show;
- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;

- (void)dismiss;
- (void)dismissWithStatus:(NSString*)string Status:(ProgressHUDType)status;
- (void)dismissWithStatus:(NSString*)string Status:(ProgressHUDType)status afterDelay:(NSTimeInterval)seconds;

@end

@implementation TFY_ProgressHUD

+ (TFY_ProgressHUD*)sharedView {
    static dispatch_once_t once;
    static TFY_ProgressHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[TFY_ProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (void)setStatus:(NSString *)string {
    [[TFY_ProgressHUD sharedView] setStatus:string];
}

#pragma mark - Touch Events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        if ([TFY_ProgressHUD isVisible]) {
            [TFY_ProgressHUD dismiss];
            [[TFY_ProgressHUD sharedView] dismissWithNoAni];
        }
    }
}

#pragma mark - 显示方法
+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView {
    TFY_ProgressHUD *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    [popup show];
    return popup;
}

+ (void)showToastVieWiththContent:(NSString *)content {
    [self showToastVieWiththContent:content showType:PopupShowType_GrowIn dismissType:PopupDismissType_ShrinkOut stopTime:1.5];
}

+ (void)showToastVieWithAttributedContent:(NSAttributedString *)attributedString {
    [self showToastViewWithAttributedContent:attributedString showType:PopupShowType_GrowIn dismissType:PopupDismissType_None stopTime:1.5];
}

+ (void)showToastViewWithAttributedContent:(NSAttributedString *)attributedString showType:(PopupShowType)showType dismissType:(PopupDismissType)dismissType stopTime:(NSInteger)time {
    TFY_ProgressHUD *popup = [[[self class] alloc] init];
    UIView *contentView = [popup toastViewWithContentString:@"" AttributedString:attributedString];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    [popup showWithDuration:time];
}

+ (void)showToastVieWiththContent:(NSString *)content showType:(PopupShowType)showType dismissType:(PopupDismissType)dismissType stopTime:(NSInteger)time {
    TFY_ProgressHUD *popup = [[[self class] alloc] init];
    UIView *contentView = [popup toastViewWithContentString:content AttributedString:nil];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    popup.maskType = PopupMaskType_None;
    [popup showWithDuration:time];
    
}
+ (TFY_ProgressHUD *)popupWithContentView:(UIView *)contentView showType:(PopupShowType)showType dismissType:(PopupDismissType)dismissType maskType:(PopupMaskType)maskType dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch {
    TFY_ProgressHUD *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    popup.maskType = maskType;
    popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
    popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch;
    return popup;
}

+ (void)dismissAllPopups {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        [window containsPopupBlock:^(TFY_ProgressHUD * _Nonnull popup) {
            [popup dismissAnimated:NO];
        }];
    }
}

+ (void)dismissPopupForView:(UIView *)view animated:(BOOL)animated {
    [view dismissShowingPopup:animated];
}

+ (void)dismissSuperPopupIn:(UIView *)view animated:(BOOL)animated {
    [view dismissShowingPopup:animated];
}

+ (void)show {
    [[TFY_ProgressHUD sharedView] showWithStatus:nil maskType:PopupMaskType_None networkIndicator:NO];
}

+ (void)showWithStatus:(NSString *)status {
    [[TFY_ProgressHUD sharedView] showWithStatus:status maskType:PopupMaskType_None networkIndicator:NO];
}

+ (void)showWithMaskType:(PopupMaskType)maskType {
    [[TFY_ProgressHUD sharedView] showWithStatus:nil maskType:maskType networkIndicator:NO];
}

+ (void)showWithStatus:(NSString*)status maskType:(PopupMaskType)maskType {
    [[TFY_ProgressHUD sharedView] showWithStatus:status maskType:maskType networkIndicator:NO];
}

+ (void)showSuccessWithStatus:(NSString *)string {
    [TFY_ProgressHUD showSuccessWithStatus:string duration:1];
}

+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration {
    [TFY_ProgressHUD show];
    [TFY_ProgressHUD dismissWithSuccess:string afterDelay:duration];
    
}

+ (void)showErrorWithStatus:(NSString *)string {
    [TFY_ProgressHUD showErrorWithStatus:string duration:1];
}

+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration {
    [TFY_ProgressHUD show];
    
    [TFY_ProgressHUD dismissWithError:string afterDelay:duration];
}

+ (void)showPromptWithStatus:(NSString *)string {
    
    [TFY_ProgressHUD showPromptWithStatus:string duration:1];
    
}
+ (void)showPromptWithStatus:(NSString *)string duration:(NSTimeInterval)duration {
    
    [TFY_ProgressHUD show];
    [TFY_ProgressHUD dismissWithPrompt:string afterDelay:duration];
}


#pragma mark - Dismiss Methods

+ (void)dismiss {
    [[TFY_ProgressHUD sharedView] dismiss_two];
}

+ (void)dismissWithSuccess:(NSString *)successString {
    [[TFY_ProgressHUD sharedView] dismissWithStatus:successString Status:ProgressHUD_SUCCESS];
}

+ (void)dismissWithSuccess:(NSString *)successString afterDelay:(NSTimeInterval)seconds {
    [[TFY_ProgressHUD sharedView] dismissWithStatus:successString Status:ProgressHUD_SUCCESS afterDelay:seconds];
}

+ (void)dismissWithError:(NSString*)errorString {
    [[TFY_ProgressHUD sharedView] dismissWithStatus:errorString Status:ProgressHUD_ERROR];
}

+ (void)dismissWithError:(NSString *)errorString afterDelay:(NSTimeInterval)seconds {
    [[TFY_ProgressHUD sharedView] dismissWithStatus:errorString Status:ProgressHUD_ERROR afterDelay:seconds];
}
+ (void)dismissWithPrompt:(NSString*)promptString {
    [[TFY_ProgressHUD sharedView] dismissWithStatus:promptString Status:ProgressHUD_PROMPT];
}
+ (void)dismissWithPrompt:(NSString *)promptString afterDelay:(NSTimeInterval)seconds {
    [[TFY_ProgressHUD sharedView] dismissWithStatus:promptString Status:ProgressHUD_PROMPT afterDelay:seconds];
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        self.shouldDismissOnBackgroundTouch = YES;
        self.shouldDismissOnContentTouch = NO;
        
        self.showType = PopupShowType_BounceInFromTop;
        self.dismissType = PopupDismissType_BounceOutToBottom;
        self.maskType = PopupMaskType_Dimmed;
        self.dimmedMaskAlpha = 0.5;
        self.toastMaskAlpha = 0.6;
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.containerView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusbarOrientation:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        if (_shouldDismissOnBackgroundTouch) {
            [self dismissAnimated:YES];
        }
        return _maskType == PopupMaskType_None ? nil : hitView;
    } else {
        if ([hitView isDescendantOfView:_containerView] && _shouldDismissOnContentTouch) {
            [self dismissAnimated:YES];
        }
        return hitView;
    }
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.maskType) {
        case PopupMaskType_None: {
            
            break;
        }
        case PopupMaskType_Clear: {
            
            break;
        }
        case PopupMaskType_Dimmed: {
            
            break;
        }
        case PopupMaskType_Black: {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            [self preferredStatusBarStyle];
            break;
        }
        case PopupMaskType_Gradient: {
            
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            break;
        }
    }
}

//计算文字的大小
- (CGSize)sizeWithText:(NSString *)text maxSize:(CGSize)maxSize fontSize:(UIFont *)font {
    CGSize nameSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return nameSize;
}
- (void)setStatus:(NSString *)string {
    
    CGFloat hudWidth = 100;
    CGFloat hudHeight = 100;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    if(string) {
        CGSize stringSize = [self sizeWithText:string maxSize:CGSizeMake(200, 300) fontSize:self.stringLabel.font];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        hudHeight = 80 + stringHeight;
        
        if (stringWidth > hudWidth)
            hudWidth = ceil(stringWidth / 2) * 2;
        
        if (hudHeight > 100) {
            labelRect = CGRectMake(12, 66, hudWidth, stringHeight);
            hudWidth += 24;
        } else {
            hudWidth += 24;
            labelRect = CGRectMake(0, 66, hudWidth, stringHeight);
        }
    }
    
    self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    
    if(string)
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36);
    else
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
    
    self.stringLabel.hidden = NO;
    self.stringLabel.text = string;
    self.stringLabel.frame = labelRect;
    
    if(string)
        self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, 40.5);
    else
        self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, ceil(self.hudView.bounds.size.height/2)+0.5);
}

- (void)registerNotifications {
    [NotificationCenter addObserver:self
                           selector:@selector(positionHUD:)
                               name:UIApplicationDidChangeStatusBarOrientationNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(positionHUD:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(positionHUD:)
                               name:UIKeyboardDidHideNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(positionHUD:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(positionHUD:)
                               name:UIKeyboardDidShowNotification
                             object:nil];
}


- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight;
    double animationDuration = 0.0;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default:
            //UI界面定向图
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    if(notification) {
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                         } completion:NULL];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = newCenter;
}

#pragma mark - Master show/dismiss methods

- (void)showWithStatus:(NSString*)string maskType:(PopupMaskType)hudMaskType networkIndicator:(BOOL)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        
        self.fadeOutTimer = nil;
        self.imageView.hidden = YES;
        self.maskType = hudMaskType;
        
        [self setStatus:string];
        [self.spinnerView startAnimating];
        
        if(self.maskType != PopupMaskType_None) {
            self.overlayWindow.userInteractionEnabled = NO;
        } else {
            self.overlayWindow.userInteractionEnabled = YES;
        }
        
        [self.overlayWindow makeKeyAndVisible];
        [self positionHUD:nil];
        
        if(self.alpha != 1) {
            [self registerNotifications];
            self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
            
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                                 self.alpha = 1;
                             }
                             completion:NULL];
        }
        
        [self setNeedsDisplay];
    });
}


- (void)dismissWithStatus:(NSString*)string Status:(ProgressHUDType)status {
    [self dismissWithStatus:string Status:status afterDelay:0.9];
    
}


- (void)dismissWithStatus:(NSString *)string Status:(ProgressHUDType)status afterDelay:(NSTimeInterval)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.alpha != 1)
            return;
        
        if(status == ProgressHUD_ERROR){
            self.imageView.image = [UIImage imageNamed:@"TFY_ProgressHUD.bundle/my_error"];
        }else if(status == ProgressHUD_SUCCESS) {
            self.imageView.image = [UIImage imageNamed:@"TFY_ProgressHUD.bundle/my_success"];
        }else if(status == ProgressHUD_PROMPT) {
            self.imageView.image = [UIImage imageNamed:@"TFY_ProgressHUD.bundle/my_prompt"];
        }
        self.imageView.hidden = NO;
        [self setStatus:string];
        [self.spinnerView stopAnimating];
        
        self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(dismiss_two) userInfo:nil repeats:NO];
    });
}

- (void)dismissWithNoAni{
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [NotificationCenter removeObserver:self];
    //    OMGLog(@"*****************");
    [self.hudView removeFromSuperview];
    self.hudView = nil;
    
    // 确保从窗口列表中删除覆盖窗口
    // 在尝试在同一列表中找到键窗口之前
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
    [self.overlayWindow setUserInteractionEnabled:YES];
    
    [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
        if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
            [window makeKeyWindow];
            *stop = YES;
        }
    }];
    windows = nil;
    [self.fadeOutTimer invalidate];
    self.fadeOutTimer = nil;
    
    [self.stringLabel removeFromSuperview];
    self.stringLabel = nil;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.spinnerView removeFromSuperview];
    self.spinnerView = nil;
    [self removeFromSuperview];
    [self.window removeFromSuperview];
}

- (void)dismiss_two {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
            self.alpha = 0;
            
        }completion:^(BOOL finished){
            
//            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            if(self.alpha == 0) {
                [NotificationCenter removeObserver:self];
                [self.hudView removeFromSuperview];
                self.hudView = nil;
                
                // 确保从窗口列表中删除覆盖窗口
                // 在尝试在同一列表中找到键窗口之前
                NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                [self.overlayWindow setUserInteractionEnabled:YES];
                
                [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                    if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                        [window makeKeyWindow];
                        *stop = YES;
                    }
                }];
                
                windows = nil;
                [self.fadeOutTimer invalidate];
                self.fadeOutTimer = nil;
                
                [self.stringLabel removeFromSuperview];
                self.stringLabel = nil;
                [self.imageView removeFromSuperview];
                self.imageView = nil;
                [self.spinnerView removeFromSuperview];
                self.spinnerView = nil;
                [self removeFromSuperview];
                [self.window removeFromSuperview];
            }
        }];
    });
}

#pragma mark - Public Instance Methods
- (void)show {
    [self showWithLayout:PopupLayout_Center];
}

- (void)showWithLayout:(PopupLayout)layout {
    [self showWithLayout:layout duration:0.0];
}

- (void)showWithDuration:(NSTimeInterval)duration {
    [self showWithLayout:PopupLayout_Center duration:duration];
}

- (void)showWithLayout:(PopupLayout)layout duration:(NSTimeInterval)duration {
    NSDictionary *parameters = @{kParametersLayoutName: [NSValue valueWithXHPopupLayout:layout],
                                 kParametersDurationName: @(duration)};
    [self showWithParameters:parameters];
}

- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view {
    [self showAtCenterPoint:point inView:view duration:0.0];
}

- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view duration:(NSTimeInterval)duration {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSValue valueWithCGPoint:point] forKey:kParametersCenterName];
    [parameters setValue:@(duration) forKey:kParametersDurationName];
    [parameters setValue:view forKey:kParametersViewName];
    [self showWithParameters:parameters.mutableCopy];
}

- (void)dismissAnimated:(BOOL)animated {
    [self dismiss:animated];
}

#pragma mark - Private Methods
- (UIView *)toastViewWithContentString:(NSString *)content AttributedString:(NSAttributedString *)attributedString {
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    bgView.alpha = self.toastMaskAlpha;
    bgView.layer.cornerRadius = 6;
    
    UILabel *toastLable = [UILabel new];
    toastLable.font = [UIFont systemFontOfSize:17];
    toastLable.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];;
    if (content.length > 0) {
        toastLable.text = content;
    }else {
        toastLable.attributedText = attributedString;
    }
    toastLable.numberOfLines = 0;
    [bgView addSubview:toastLable];
    [self setupTextToastWithLable:toastLable View:bgView];
    return bgView;
}

- (void)setupTextToastWithLable:(UILabel *)messageLabel View:(UIView *)bgView {
    
    bgView.frame = [self toastFrameWithLable:messageLabel];
    messageLabel.frame = [self  toastLabelFrameWithbgViewFrame:bgView.frame];
}

- (CGRect)toastFrameWithLable:(UILabel *)msgLable {
    
    CGRect frame = [UIScreen mainScreen].bounds;
    CGSize constrantSize = CGSizeMake(frame.size.width - 40, frame.size.height - 40);
    NSDictionary *attr = @{NSFontAttributeName:msgLable.font};
    NSString *msg = [NSString stringWithFormat:@"%@",msgLable.text];
    CGSize size = [msg boundingRectWithSize:constrantSize
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:attr
                                    context:nil].size;
    size = CGSizeMake(size.width + 46, size.height + 30);
    CGFloat x = 20 + (constrantSize.width - 46 - size.width) * 0.5;
    CGFloat y = 15 + (constrantSize.height - 30 - size.height) * 0.5;
    CGRect fr = CGRectMake(x ,y ,size.width ,size.height);
    return fr;
}

- (CGRect)toastLabelFrameWithbgViewFrame:(CGRect)bgFrame{
    CGRect fr = CGRectMake(23, 15,bgFrame.size.width - 23 * 2,bgFrame.size.height - 15 * 2);
    return fr;
}


- (void)showWithParameters:(NSDictionary *)parameters {
    //
    if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
        _isBeingShown = YES;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        if (self.willStartShowingBlock != nil) {
            self.willStartShowingBlock();
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //准备弹出
            if (!strongSelf.superview) {
                NSEnumerator *reverseWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
                for (UIWindow *window in reverseWindows) {
                    if (window.windowLevel == UIWindowLevelNormal) {
                        [window addSubview:self];
                        break;
                    }
                }
            }
            
            [strongSelf updateInterfaceOrientation];
            
            strongSelf.hidden = NO;
            strongSelf.alpha = 1.0;
            
            //设置背景视图
            strongSelf.backgroundView.alpha = 0.0;
            if (strongSelf.maskType == PopupMaskType_Dimmed) {
                strongSelf.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:strongSelf.dimmedMaskAlpha];
            } else {
                strongSelf.backgroundView.backgroundColor = UIColor.clearColor;
            }
            
            //判断是否需要动画
            void (^backgroundAnimationBlock)(void) = ^(void) {
                strongSelf.backgroundView.alpha = 1.0;
            };
            
            //展示动画
            if (strongSelf.showType != PopupShowType_None) {
                CGFloat showInDuration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                [UIView animateWithDuration:showInDuration
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:backgroundAnimationBlock
                                 completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            //设置自动消失事件
            NSNumber *durationNumber = parameters[kParametersDurationName];
            NSTimeInterval duration = durationNumber != nil ? durationNumber.doubleValue : 0.0;
            
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                strongSelf.isBeingShown = NO;
                strongSelf.isShowing = YES;
                strongSelf.isBeingDismissed = NO;
                if (strongSelf.didFinishShowingBlock) {
                    strongSelf.didFinishShowingBlock();
                }
                
                if (duration > 0.0) {
                    [strongSelf performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
                }
            };
            
            if (strongSelf.contentView.superview != strongSelf.containerView) {
                [strongSelf.containerView addSubview:strongSelf.contentView];
            }
            
            [strongSelf.contentView layoutIfNeeded];
            
            CGRect containerFrame = strongSelf.containerView.frame;
            containerFrame.size = strongSelf.contentView.frame.size;
            strongSelf.containerView.frame = containerFrame;
            
            CGRect contentFrame = strongSelf.contentView.frame;
            contentFrame.origin = CGPointZero;
            strongSelf.contentView.frame = contentFrame;
            
            UIView *contentView = strongSelf.contentView;
            NSDictionary *viewsDict = NSDictionaryOfVariableBindings(contentView);
            [strongSelf.containerView removeConstraints:strongSelf.containerView.constraints];
            [strongSelf.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:viewsDict]];
            [strongSelf.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:viewsDict]];
            
            CGRect finalContainerFrame = containerFrame;
            UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
            
            NSValue *centerValue = parameters[kParametersCenterName];
            if (centerValue) {
                CGPoint centerInView = centerValue.CGPointValue;
                CGPoint centerInSelf;
                /// Convert coordinates from provided view to self.
                UIView *fromView = parameters[kParametersViewName];
                centerInSelf = fromView != nil ? [self convertPoint:centerInView toView:fromView] : centerInView;
                finalContainerFrame.origin.x = centerInSelf.x - CGRectGetWidth(finalContainerFrame)*0.5;
                finalContainerFrame.origin.y = centerInSelf.y - CGRectGetHeight(finalContainerFrame)*0.5;
                containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            } else {
                
                NSValue *layoutValue = parameters[kParametersLayoutName];
                PopupLayout layout = layoutValue ? [layoutValue PopupLayoutValue] : PopupLayout_Center;
                switch (layout.horizontal) {
                    case PopupHorizontalLayout_Left:
                        finalContainerFrame.origin.x = 0.0;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case PopupHoricontalLayout_Right:
                        finalContainerFrame.origin.x = CGRectGetWidth(strongSelf.bounds) - CGRectGetWidth(containerFrame);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
                        break;
                    case PopupHorizontalLayout_LeftOfCenter:
                        finalContainerFrame.origin.x = floorf(CGRectGetWidth(strongSelf.bounds) / 3.0 - CGRectGetWidth(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case PopupHorizontalLayout_RightOfCenter:
                        finalContainerFrame.origin.x = floorf(CGRectGetWidth(strongSelf.bounds) * 2.0 / 3.0 - CGRectGetWidth(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case PopupHorizontalLayout_Center:
                        finalContainerFrame.origin.x = floorf((CGRectGetWidth(strongSelf.bounds) - CGRectGetWidth(containerFrame)) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    default:
                        break;
                }
                
                switch (layout.vertical) {
                    case PopupVerticalLayout_Top:
                        finalContainerFrame.origin.y = 0.0;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case PopupVerticalLayout_AboveCenter:
                        finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) / 3.0 - CGRectGetHeight(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case PopupVerticalLayout_Center:
                        finalContainerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame)) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case PopupVerticalLayout_BelowCenter:
                        finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) * 2.0 / 3.0 - CGRectGetHeight(containerFrame) * 0.5);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case PopupVerticalLayout_Bottom:
                        finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
                        break;
                    default:
                        break;
                }
            }
            
            strongSelf.containerView.autoresizingMask = containerAutoresizingMask;
            
            switch (strongSelf.showType) {
                case PopupShowType_FadeIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    strongSelf.containerView.frame = finalContainerFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                        strongSelf.containerView.alpha = 1.0;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_GrowIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_ShrinkIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.frame = finalContainerFrame;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_SlideInFromTop: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = - CGRectGetHeight(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_SlideInFromBottom: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_SlideInFromLeft: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_SlideInFromRight: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kDefaultAnimateDuration animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_BounceIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_BounceInFromTop: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = - CGRectGetHeight(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_BounceInFromBottom: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_BounceInFromLeft: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case PopupShowType_BounceInFromRight: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                default: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    completionBlock(YES);
                }   break;
            }
        });
    }
}

- (void)dismiss:(BOOL)animated {
    if (_isShowing && !_isBeingDismissed) {
        _isShowing = NO;
        _isBeingShown = NO;
        _isBeingDismissed = YES;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
        
        if (self.willStartDismissingBlock) {
            self.willStartDismissingBlock();
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = self;
            void (^backgroundAnimationBlock)(void) = ^(void) {
                strongSelf.backgroundView.alpha = 0.0;
            };
            
            if (animated && strongSelf.showType != PopupShowType_None) {
                CGFloat duration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
                [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:backgroundAnimationBlock completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                [strongSelf removeFromSuperview];
                strongSelf.isBeingShown = NO;
                strongSelf.isShowing = NO;
                strongSelf.isBeingDismissed = NO;
                if (strongSelf.didFinishDismissingBlock) {
                    strongSelf.didFinishDismissingBlock();
                }
            };
            
            NSTimeInterval duration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
            NSTimeInterval bounceDurationA = duration * 1.0 / 3.0;
            NSTimeInterval bounceDurationB = duration * 2.0 / 3.0;
            
            /// Animate contentView if needed.
            if (animated) {
                NSTimeInterval dismissOutDuration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
                switch (strongSelf.dismissType) {
                    case PopupDismissType_FadeOut: {
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                            strongSelf.containerView.alpha = 0.0;
                        } completion:completionBlock];
                    }   break;
                    case PopupDismissType_GrowOut: {
                        [UIView animateKeyframesWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.alpha = 0.0;
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                        } completion:completionBlock];
                    }   break;
                    case PopupDismissType_ShrinkOut: {
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.alpha = 0.0;
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                        } completion:completionBlock];
                    }   break;
                    case PopupDismissType_SlideOutToTop: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.y = - CGRectGetHeight(finalFrame);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case PopupDismissType_SlideOutToBottom: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.y = CGRectGetHeight(strongSelf.bounds);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case PopupDismissType_SlideOutToLeft: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.x = - CGRectGetWidth(finalFrame);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case PopupDismissType_SlideOutToRight: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.x = CGRectGetWidth(strongSelf.bounds);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case PopupDismissType_BounceOut: {
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.alpha = 0.0;
                                strongSelf.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                            } completion:completionBlock];
                        }];
                    }   break;
                    case PopupDismissType_BounceOutToTop: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.y += 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.y = - CGRectGetHeight(finalFrameB);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case PopupDismissType_BounceOutToBottom: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.y -= 20;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.y = CGRectGetHeight(self.bounds);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case PopupDismissType_BounceOutToLeft: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.x += 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.x = - CGRectGetWidth(finalFrameB);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case PopupDismissType_BounceOutToRight: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.x -= 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.x = CGRectGetWidth(strongSelf.bounds);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    default: {
                        strongSelf.containerView.alpha = 0.0;
                        completionBlock(YES);
                    }   break;
                }
            } else {
                strongSelf.containerView.alpha = 0.0;
                completionBlock(YES);
            }
        });
    }
}

- (void)didChangeStatusbarOrientation:(NSNotification *)notification {
    [self updateInterfaceOrientation];
}

- (void)updateInterfaceOrientation {
    self.frame = self.window.bounds;
}

-(void)dismiss {
    [self dismiss:YES];
}

#pragma mark - Utilities

+ (BOOL)isVisible {
    return ([TFY_ProgressHUD sharedView].alpha == 1);
}


#pragma mark - Getters

- (UIWindow *)overlayWindow {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    _overlayWindow = window;
    return _overlayWindow;
}

- (UIView *)hudView {
    
    if(!_hudView) {
        
        self.hudView = [[UIView alloc] initWithFrame:CGRectZero];
        self.hudView.layer.cornerRadius = 10;
        self.hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin     | UIViewAutoresizingFlexibleRightMargin   | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:self.hudView];
    }
    return _hudView;
}

- (UILabel *)stringLabel {
    if (_stringLabel == nil) {
        
        self.stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.stringLabel.textColor = [UIColor whiteColor];
        self.stringLabel.backgroundColor = [UIColor clearColor];
        self.stringLabel.adjustsFontSizeToFitWidth = YES;
        self.stringLabel.textAlignment = NSTextAlignmentCenter;
        self.stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.stringLabel.font = [UIFont boldSystemFontOfSize:16];
        self.stringLabel.shadowColor = [UIColor blackColor];
        self.stringLabel.shadowOffset = CGSizeMake(0, -1);
        self.stringLabel.numberOfLines = 0;
    }
    
    if(!_stringLabel.superview)
        [self.hudView addSubview:_stringLabel];
    
    return _stringLabel;
}
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = UIColor.clearColor;
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;
    }
    return _backgroundView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.autoresizesSubviews = NO;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = UIColor.clearColor;
    }
    return _containerView;
}

- (UIImageView *)imageView {
    if (_imageView == nil)
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    
    if(!_imageView.superview)
        [self.hudView addSubview:_imageView];
    
    return _imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    if (_spinnerView == nil) {
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinnerView.hidesWhenStopped = YES;
        self.spinnerView.bounds = CGRectMake(0, 0, 37, 37);
    }
    
    if(!_spinnerView.superview)
        [self.hudView addSubview:_spinnerView];
    
    return _spinnerView;
}

- (CGFloat)visibleKeyboardHeight {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    // Locate UIKeyboard.
    UIView *foundKeyboard = nil;
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        
        // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
        if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
            possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
        }
        
        if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
            foundKeyboard = possibleKeyboard;
            break;
        }
    }
    
    if(foundKeyboard && foundKeyboard.bounds.size.height > 100)
        return foundKeyboard.bounds.size.height;
    
    return 0;
}

- (void)dealloc {
    self.fadeOutTimer = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NotificationCenter removeObserver:self];
}

@end

@implementation NSValue (PopupLayout)
+ (NSValue *)valueWithXHPopupLayout:(PopupLayout)layout {
    return [NSValue valueWithBytes:&layout objCType:@encode(PopupLayout)];
}

- (PopupLayout)PopupLayoutValue{
    PopupLayout layout;
    [self getValue:&layout];
    return layout;
}

@end

@implementation UIView (Popup)
- (void)containsPopupBlock:(void (^)(TFY_ProgressHUD *popup))block {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[TFY_ProgressHUD class]]) {
            block((TFY_ProgressHUD *)subview);
        } else {
            [subview containsPopupBlock:block];
        }
    }
}

- (void)dismissShowingPopup:(BOOL)animated {
    UIView *view = self;
    while (view) {
        if ([view isKindOfClass:[TFY_ProgressHUD class]]) {
            [(TFY_ProgressHUD *)view dismissAnimated:animated];
            break;
        }
        view = view.superview;
    }
}

@end
