# nodataException
无数据/无网络  默认图

/**************************************************************
 如果加载本地数据需立即刷新UI 需写到主线程     正常网络请求数据无需加到主线程
 **************************************************************/

/*!

ignoredScrollViewContentInsetTop    设置占位图的偏移量


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
