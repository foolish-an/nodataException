//
//  ALExceptionView.m
//  nodataShow
//
//  Created by apple on 2018/5/30.
//  Copyright © 2018年 anlong. All rights reserved.
//

#import "ALExceptionView.h"
#import "NSObject+TXProperty.h"
#import "UIView+Additions.h"
#import <objc/runtime.h>
static void *al_placeholder = &al_placeholder;
static void *al_placeholder_first_null_data_visible = &al_placeholder_first_null_data_visible;
@interface ALExceptionView()

@property (nonatomic, strong) NSMutableDictionary *imagesKeyValues;

@property (nonatomic, strong) NSMutableDictionary *explainKeyValues;

@property (nonatomic, strong) UIImageView *exceptionImageView;

@property (nonatomic, strong) UILabel *exceptionLabel;

@end

@implementation ALExceptionView

- (NSMutableDictionary *)imagesKeyValues
{
    if (!_imagesKeyValues) {
        _imagesKeyValues = [[NSMutableDictionary alloc] init];
    }
    return _imagesKeyValues;
}

- (NSMutableDictionary *)explainKeyValues
{
    if (!_explainKeyValues) {
        _explainKeyValues = [[NSMutableDictionary alloc] init];
    }
    return _explainKeyValues;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupBaseSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setupBaseSubViews];
    }
    return self;
}

- (void)setupBaseSubViews
{
    self.mode = ALExceptionViewModeDefault;
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self setupSubViews];
}

- (UIImageView *)exceptionImageView
{
    if (!_exceptionImageView) {
        _exceptionImageView = [[UIImageView alloc] init];
        _exceptionImageView.userInteractionEnabled = YES;
        _exceptionImageView.contentMode = UIViewContentModeCenter;
        _exceptionImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_exceptionImageView];
    }
    return _exceptionImageView;
}

- (UILabel *)exceptionLabel
{
    if (!_exceptionLabel) {
        _exceptionLabel = [[UILabel alloc] init];
        _exceptionLabel.textAlignment = NSTextAlignmentCenter;
        _exceptionLabel.userInteractionEnabled = YES;
        _exceptionLabel.numberOfLines = 0;
        _exceptionLabel.font = [UIFont systemFontOfSize:14];
        _exceptionLabel.textColor = [UIColor grayColor];
        [self addSubview:_exceptionLabel];
    }
    return _exceptionLabel;
}

- (void)reset
{
    [self setupSubViews];
}

- (void)setupSubViews
{
    //此处更改默认设置
    [self setImage:[UIImage imageNamed:@"list_nodata"] forMode:ALExceptionViewModeNoData];
    [self setExplain:@"暂无数据" forMode:ALExceptionViewModeNoData];
    [self setImage:[UIImage imageNamed:@"networkerror"] forMode:ALExceptionViewModeNoNetwork];
    [self setExplain:@"无法连接网络,请检查网络并刷新重试" forMode:ALExceptionViewModeNoNetwork];
}

- (void)setMode:(ALExceptionViewMode)mode
{
    _mode = mode;
    self.hidden = YES;
    if (mode == ALExceptionViewModeDefault) return;
    if (self.superview) {
        [self.superview bringSubviewToFront:self];
    }
    self.exceptionLabel.text = self.explainKeyValues[@(self.mode)];
    self.exceptionImageView.image = self.imagesKeyValues[@(self.mode)];
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image forMode:(ALExceptionViewMode)mode
{
    if (mode == ALExceptionViewModeDefault) return;
    if (!image) {
        if (self.imagesKeyValues[@(mode)]) {
            [self.imagesKeyValues removeObjectForKey:@(mode)];
        }
        return;
    }
    self.imagesKeyValues[@(mode)] = image;
}

- (void)setExplain:(NSString *)explain forMode:(ALExceptionViewMode)mode
{
    if (mode == ALExceptionViewModeDefault) return;
    if (!explain) {
        if (self.explainKeyValues[@(mode)]) {
            [self.explainKeyValues removeObjectForKey:@(mode)];
        }
        return;
    }
    self.explainKeyValues[@(mode)] = explain;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:(self.mode == ALExceptionViewModeDefault)];
}

- (CGRect)explainRectForContentRect:(CGRect)contentRect
{
    return contentRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return contentRect;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.update) {
        self.update();
        return;
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.y = self.ignoredScrollViewContentInsetTop;
    self.height = self.superview.bounds.size.height - self.ignoredScrollViewContentInsetTop;
    
    [self.exceptionImageView sizeToFit];
    CGFloat imageW = self.exceptionImageView.bounds.size.width;
    CGFloat imageH = self.exceptionImageView.frame.size.height;
    CGFloat imageX = (self.bounds.size.width - imageW) * 0.5;
    CGFloat imageY = (self.bounds.size.height - imageH - 60) * 0.3;
    self.exceptionImageView.frame = [self imageRectForContentRect:CGRectMake(imageX, imageY, imageW, imageH)];
    
    CGFloat explainX = 0;
    CGFloat explainY = CGRectGetMaxY(self.exceptionImageView.frame) + 10;
    CGFloat explainW = [UIScreen mainScreen].bounds.size.width;
    CGFloat explainH = 50;
    self.exceptionLabel.frame = [self explainRectForContentRect:CGRectMake(explainX, explainY, explainW, explainH)];
}

- (void)setIgnoredScrollViewContentInsetTop:(CGFloat)ignoredScrollViewContentInsetTop
{
    _ignoredScrollViewContentInsetTop = ignoredScrollViewContentInsetTop;
    [self setNeedsLayout];
}

@end
@implementation UIView (ALException)

-(ALExceptionView *)al_insertExceptionView
{
    if (self.al_exceptionView) {
        return self.al_exceptionView;
    }
    self.al_exceptionView = [[ALExceptionView alloc] initWithFrame:self.bounds];
    return self.al_exceptionView;
}

- (void)al_networkError
{
    if (!self.al_exceptionView) return;
    self.al_exceptionView.mode = ALExceptionViewModeNoNetwork;
}

- (void)al_quiteNormal
{
    if (!self.al_exceptionView) return;
    self.al_exceptionView.mode = ALExceptionViewModeDefault;
}

- (__kindof ALExceptionView *)al_exceptionView
{
    return objc_getAssociatedObject(self, al_placeholder);
}

- (void)setAl_exceptionView:(__kindof ALExceptionView *)al_exceptionView
{
    if (self.al_exceptionView && self.al_exceptionView != al_exceptionView) {
        [self.al_exceptionView removeFromSuperview];
    }
    [self addSubview:al_exceptionView];
    objc_setAssociatedObject(self, al_placeholder, al_exceptionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UITableView (DLException)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tx_exchangeOriginalMethod:@selector(reloadData) otherMethod:@selector(al_reloadData)];
    });
}

- (BOOL)isFistNullDataVisibled
{
    return [objc_getAssociatedObject(self, al_placeholder_first_null_data_visible) boolValue];
}

- (void)setFistNullDataVisibled:(BOOL)fistNullDataVisibled
{
    objc_setAssociatedObject(self, al_placeholder_first_null_data_visible, @(fistNullDataVisibled), OBJC_ASSOCIATION_ASSIGN);
}

- (void)al_reloadData
{
    [self al_reloadData];
    [self al_matchingDataWithPlaceholderView];
}

- (void)al_matchingDataWithPlaceholderView
{
    if (!self.al_exceptionView) return;
    if (!self.isFistNullDataVisibled) {
        [self setFistNullDataVisibled:YES];
        return;
    }
    
    BOOL isClear = YES;
    NSInteger sections = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [self.dataSource numberOfSectionsInTableView:self];
    }
    for (NSInteger i = 0; i < sections; i++) {
        if ([self.dataSource tableView:self numberOfRowsInSection:i]) {
            isClear = NO;
            break;
        }
    }
    self.al_exceptionView.mode = isClear ? ALExceptionViewModeNoData : ALExceptionViewModeDefault;
}
@end

@implementation UICollectionView (ALException)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tx_exchangeOriginalMethod:@selector(reloadData) otherMethod:@selector(al_reloadData)];
    });
}

- (void)al_reloadData
{
    [self al_reloadData];
    [self al_matchingDataWithPlaceholderView];
}

- (void)al_matchingDataWithPlaceholderView
{
    if (!self.al_exceptionView) return;
    
    BOOL isClear = YES;
    NSInteger sections = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        sections = [self.dataSource numberOfSectionsInCollectionView:self];
    }
    for (NSInteger i = 0; i < sections; i++) {
        if ([self.dataSource collectionView:self numberOfItemsInSection:i]) {
            isClear = NO;
            break;
        }
    }
    self.al_exceptionView.mode = isClear ? ALExceptionViewModeNoData : ALExceptionViewModeDefault;
}

@end
