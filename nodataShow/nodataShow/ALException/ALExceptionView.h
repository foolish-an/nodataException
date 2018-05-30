//
//  ALExceptionView.h
//  nodataShow
//
//  Created by apple on 2018/5/30.
//  Copyright © 2018年 anlong. All rights reserved.
//

#import <UIKit/UIKit.h>

/**************************************************************
 如果加载本地数据需立即刷新UI 需写到主线程     正常网络请求数据无需加到主线程
 **************************************************************/

/*!
 数据加载完毕的占位图
 */
typedef NS_ENUM(NSInteger, ALExceptionViewMode) {
    ALExceptionViewModeDefault = 10086,       //default is no problem
    ALExceptionViewModeNoNetwork,             //no network or network fault
    ALExceptionViewModeNoData                 //no data
};
@interface ALExceptionView : UIView

/***  通过设置mode更改状态,不需要做任何添加隐藏逻辑  **/
@property (nonatomic, assign) ALExceptionViewMode mode;

@property (nonatomic, assign) CGFloat ignoredScrollViewContentInsetTop;

- (void)reset;

/***  若有点击刷新需求,实现该block即可  **/
@property (nonatomic, copy) void(^update)(void);
/***  不需要默认状态图片,通过此方法更改对应状态的图片  **/
- (void)setImage:(UIImage *)image forMode:(ALExceptionViewMode)mode;
/***  不需要默认状态文字,通过此方法更改对应状态的文字,可以传nil  **/
- (void)setExplain:(NSString *)explain forMode:(ALExceptionViewMode)mode;

/***  子类实现更改默认图片布局  **/
- (CGRect)explainRectForContentRect:(CGRect)contentRect;
/***  子类实现更改默认文字布局  **/
- (CGRect)imageRectForContentRect:(CGRect)contentRect;
@end

@interface UIView (ALException)
/*@!
 在不同状态完成后设置此视图的mode值可以自动更改占位图状态
 <包括网络加载失败,网络错误等,网络加载成功但是无数据状态已经处理不需要设置>
 **/
@property (nonatomic, strong) __kindof ALExceptionView *al_exceptionView;

/***  某个视图需要占位图,直接调用该方法,就可完成默认配置  **/
- (ALExceptionView *)al_insertExceptionView;
/***  默认设置情况网络错误调用  **/
- (void)al_networkError;
/***  正常获取数据,不是列表视图方便调用  **/
- (void)al_quiteNormal;
@end

