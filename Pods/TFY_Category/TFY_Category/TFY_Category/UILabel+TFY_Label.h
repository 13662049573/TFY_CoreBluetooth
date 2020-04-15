//
//  UILabel+TFY_Label.h
//  TFY_CHESHI
//
//  Created by 田风有 on 2018/8/16.
//  Copyright © 2018年 田风有. All rights reserved.
//  https://github.com/13662049573/TFY_AutoLayoutModelTools

#import <UIKit/UIKit.h>

@protocol TFY_RichTextDelegate <NSObject>
@optional
/**
 *  RichTextDelegate  string  点击的字符串  range   点击的字符串range  index   点击的字符在数组中的index
 */
- (void)tfy_tapAttributeInLabel:(UILabel *)label string:(NSString *)string range:(NSRange)range index:(NSInteger)index;;
@end

@interface NSAttributedString (TFY_Chain)
/**lable点击颜色设置*/
+(NSAttributedString *)getAttributeId:(id)sender string:(NSString *)string orginFont:(CGFloat)orginFont orginColor:(UIColor *)orginColor attributeFont:(CGFloat)attributeFont attributeColor:(UIColor *)attributeColor;

@end


@interface UILabel (TFY_Label)

/**
 *  是否打开点击效果，默认是打开
 */
@property (nonatomic, assign) BOOL enabledTapEffect;

/**
 *  点击高亮色 默认是[UIColor lightGrayColor] 需打开enabledTapEffect才有效
 */
@property (nonatomic, strong) UIColor * tapHighlightedColor;
/**
 *  是否扩大点击范围，默认是打开
 */
@property (nonatomic, assign) BOOL enlargeTapArea;
/**
 *  给文本添加点击事件Block回调  strings  需要添加的字符串数组  tapClick 点击事件回调
 */
- (void)tfy_addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings tapClicked:(void (^) (UILabel * label, NSString *string, NSRange range, NSInteger index))tapClick;

/**
 *  给文本添加点击事件delegate回调  strings  需要添加的字符串数组  delegate delegate
 */
- (void)tfy_addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings delegate:(id <TFY_RichTextDelegate> )delegate;

/**
 *  根据range给文本添加点击事件Block回调 ranges 需要添加的Range字符串数组  tapClick 点击事件回调
 */
- (void)tfy_addAttributeTapActionWithRanges:(NSArray <NSString *> *)ranges tapClicked:(void (^) (UILabel * label, NSString *string, NSRange range, NSInteger index))tapClick;

/**
 *  根据range给文本添加点击事件delegate回调 ranges  需要添加的Range字符串数组 delegate delegate
 */
- (void)tfy_addAttributeTapActionWithRanges:(NSArray <NSString *> *)ranges delegate:(id <TFY_RichTextDelegate> )delegate;

/**
 *  删除label上的点击事件
 */
- (void)tfy_removeAttributeTapActions;
/**
 *  初始化Label
 */
UILabel *tfy_label(void);
/**
 *  文本输入
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_text)(NSString *text);
/**
 *  文本输入颜色和透明度 HexString 表示NSString或者UIColor
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_textcolor)(id HexString,CGFloat alpha);
/**
 *  文本字体大小
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_fontSize)(UIFont *fontSize);
/**
 *  文本字体位置 0 左 1 中 2 右
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_alignment)(NSInteger alignment);
/**
 *  文本可变字符串输入
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_attributrdString)(NSAttributedString *attributrdString);
/**
 *  文本的字体是否开始换行 0 自动换行
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_numberOfLines)(NSInteger numberOfLines);
/**
 *  文本是否开启随宽度文字超出自动缩小
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_adjustsWidth)(BOOL adjustsWidth);
/**
 *  背景颜色和 alpha透明度  HexString 字符串颜色
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_backgroundColor)(id HexString,CGFloat alpha);
/**
 *  按钮  cornerRadius 圆角
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_cornerRadius)(CGFloat cornerRadius);
/**
 *  添加四边框和color 颜色  borderWidth 宽度
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_borders)(CGFloat borderWidth, id color);
/**
 *  添加四边 color_str阴影颜色  shadowRadius阴影半径
 */
@property(nonatomic,copy,readonly)UILabel *(^tfy_bordersShadow)(id color_str, CGFloat shadowRadius);

@end

