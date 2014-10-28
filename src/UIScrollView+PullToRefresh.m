

#import <QuartzCore/QuartzCore.h>

#import "UIScrollView+PullToRefresh.h"

#import "NSObject+Block.h"

#import <objc/runtime.h>

enum {
    DDPullToRefreshStateHidden = 1,
	DDPullToRefreshStateVisible,
    DDPullToRefreshStateTriggered,
    DDPullToRefreshStateLoading,
    DDPullToRefreshStateLoaded,
};

typedef NSUInteger DDPullToRefreshState;

//scrollview 是否在动画中
static BOOL isScrollViewAnimation =NO;

@interface DDPullToRefresh ()

- (id)initWithScrollView:(UIScrollView*)scrollView;
- (void)rotateArrow:(float)degrees hide:(BOOL)hide;
- (void)setScrollViewContentOffset:(CGPoint)contentoffset;
- (void)scrollViewDidScroll:(CGPoint)contentOffset;

@property (nonatomic, copy) void (^pullToRefreshHandler)(void);
@property (nonatomic, copy) void (^pullToLoadMoreHandler)(void);

@property (nonatomic, readwrite) DDPullToRefreshState state;

@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong, readonly) UIImage *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong, readonly) UILabel *dateLabel;
@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) UIScrollView *scrollView;

@property (nonatomic, readwrite) UIEdgeInsets originalScrollViewContentInset;

@end



@implementation DDPullToRefresh

// public properties
@synthesize pullToRefreshHandler;
@synthesize pullToLoadMoreHandler;
@synthesize arrowColor;
@synthesize textColor;
@synthesize activityIndicatorViewStyle;
@synthesize lastUpdatedDate;

@synthesize state =_state;

@synthesize scrollView = _scrollView;

@synthesize arrow, arrowImage, activityIndicatorView, titleLabel, dateLabel, dateFormatter, originalScrollViewContentInset;

@synthesize pullingText = _pullingText;
@synthesize releaseText = _releaseText;
@synthesize loadingText = _loadingText;
@synthesize loadedText = _loadedText;


-(void)removeKOV{

    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"frame"];
}

- (id)initWithScrollView:(UIScrollView *)scrollView {
    self = [super initWithFrame:CGRectZero];
    self.scrollView = scrollView;
    [_scrollView addSubview:self];
    
    // default styling values
    self.arrowColor = [UIColor grayColor];
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.textColor = [UIColor darkGrayColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 150, 20)];
    titleLabel.text = NSLocalizedString(@"Pull to refresh...",);
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = textColor;
    [self addSubview:titleLabel];
    
    [self addSubview:self.arrow];
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    self.originalScrollViewContentInset = scrollView.contentInset;
	
    self.state = DDPullToRefreshStateHidden;
    
    return self;
}

- (void)layoutSubviews {
    
    self.originalScrollViewContentInset = self.scrollView.contentInset;
    
    CGFloat remainingWidth = self.superview.bounds.size.width-200;
    float position = 0.50;
    
    CGRect titleFrame = titleLabel.frame;
    titleFrame.origin.x = ceil(remainingWidth*position+44);
    titleLabel.frame = titleFrame;
    
    CGRect dateFrame = dateLabel.frame;
    dateFrame.origin.x = titleFrame.origin.x;
    dateLabel.frame = dateFrame;
    
    CGRect arrowFrame = arrow.frame;
    arrowFrame.origin.x = ceil(remainingWidth*position);
    arrow.frame = arrowFrame;
    
    self.activityIndicatorView.center = self.arrow.center;
    
    if (self.pullToRefreshHandler) {
        CGFloat top =self.scrollView.contentInset.top;
        CGFloat top1 =[self.scrollView theBeiginContentOffset].y;
        
        self.frame = CGRectMake(0, -RefreshViewHeight -(top +top1), _scrollView.bounds.size.width, RefreshViewHeight);
    }
    else if (self.pullToLoadMoreHandler){
        
        if (_scrollView.contentSize.height <_scrollView.bounds.size.width) {
            self.hidden =YES;
        }
        else{
            self.hidden =NO;
        }
        self.frame = CGRectMake(0, _scrollView.contentSize.height, _scrollView.bounds.size.width, RefreshViewHeight);
    }
    
}

#pragma mark - Getters

- (UIImageView *)arrow {
    if(!arrow) {
        arrow = [[UIImageView alloc] initWithImage:self.arrowImage];
        arrow.frame = CGRectMake(0, 6, 22, 48);
        arrow.backgroundColor = [UIColor clearColor];
    }
    return arrow;
}

- (UIImage *)arrowImage {
    
    CGRect rect = CGRectMake(0, 0, 22, 48);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);
    
    [self.arrowColor set];
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, [[UIImage imageNamed:@"DDPullToRefresh.bundle/arrow.png"] CGImage]);
    CGContextFillRect(context, rect);
    
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if(!activityIndicatorView) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:activityIndicatorView];
    }
    return activityIndicatorView;
}

- (UILabel *)dateLabel {
    if(!dateLabel) {
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, 220, 20)];
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = textColor;
        [self addSubview:dateLabel];
        
        CGRect titleFrame = titleLabel.frame;
        titleFrame.origin.y = 12;
        titleLabel.frame = titleFrame;
    }
    return dateLabel;
}

- (NSDateFormatter *)dateFormatter {
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		dateFormatter.locale = [NSLocale currentLocale];
    }
    return dateFormatter;
}

#pragma mark - Setters

- (void)setArrowColor:(UIColor *)newArrowColor {
    arrowColor = newArrowColor;
    self.arrow.image = self.arrowImage;
}

- (void)setTextColor:(UIColor *)newTextColor {
    textColor = newTextColor;
    titleLabel.textColor = newTextColor;
	dateLabel.textColor = newTextColor;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)viewStyle {
    self.activityIndicatorView.activityIndicatorViewStyle = viewStyle;
}

- (void)setScrollViewContentOffset:(CGPoint)contentoffset{
    
    isScrollViewAnimation =YES;
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [_scrollView setContentOffset:contentoffset animated:NO];
        
    } completion:^(BOOL finished) {
        
        isScrollViewAnimation =NO;
        
        if(_state == DDPullToRefreshStateHidden)
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                arrow.alpha = 0;
            } completion:NULL];
    }];
    
}

- (void)setLastUpdatedDate:(NSDate *)newLastUpdatedDate {
    self.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@",), newLastUpdatedDate?[self.dateFormatter stringFromDate:newLastUpdatedDate]:NSLocalizedString(@"Never",)];
}

- (void)setLastUpdatedDate:(NSDate *)newLastUpdatedDate title:(NSString *)strTile{
    
    if (newLastUpdatedDate) {
        self.dateLabel.text = [NSString stringWithFormat:@"%@%@", strTile,newLastUpdatedDate?[self.dateFormatter stringFromDate:newLastUpdatedDate]:@"无"];
    }
    else{
        self.dateLabel.text =@"";
    }
}


- (void)setState:(DDPullToRefreshState)newState {
    _state = newState;
    
    if (self.pullToRefreshHandler) {
        
        switch (newState) {
                
            case DDPullToRefreshStateHidden:{
                
                [self.activityIndicatorView stopAnimating];
                
                CGPoint p =CGPointMake(self.scrollView.contentOffset.x, -self.scrollView.contentInset.top);
                [self setScrollViewContentOffset:p];
                [self rotateArrow:0 hide:YES];
            }
                break;
                
            case DDPullToRefreshStateVisible:{
                
                titleLabel.text = self.pullingText;
                arrow.alpha = 1;
                [self.activityIndicatorView stopAnimating];
                [self rotateArrow:0 hide:NO];
            }
                
                break;
                
            case DDPullToRefreshStateTriggered:{
                
                titleLabel.text =self.releaseText;
                [self rotateArrow:M_PI hide:NO];
            }
                
                break;
                
            case DDPullToRefreshStateLoading:{
                
                titleLabel.text = self.loadingText;
                [self.activityIndicatorView startAnimating];
                [self setScrollViewContentOffset:CGPointMake(0, self.frame.origin.y -self.scrollView.contentInset.top)];
                [self rotateArrow:0 hide:YES];
                _scrollView.isRefresh =YES;
                _scrollView.isLoadMore =NO;
                pullToRefreshHandler();
                
            }
                break;
                
            case DDPullToRefreshStateLoaded:{
                
                titleLabel.text =self.loadedText;
                [self setLastUpdatedDate:[NSDate date] title:@"上次更新时间："];
                [self.activityIndicatorView stopAnimating];
                
                CGPoint p =CGPointMake(0, -self.scrollView.contentInset.top);
//                [self setScrollViewContentOffset:p];
                
                __weak id tempSelf =self;
                
                if (isScrollViewAnimation) {
                    
                    [self perform:^{
                        
                        [tempSelf setScrollViewContentOffset:p];
                        
                    } andDelay:0.35];
                }
                else{
                
                    [self setScrollViewContentOffset:p];
                }
                

                [self rotateArrow:0 hide:YES];
            }
                break;
        }
        
    }
    else if (self.pullToLoadMoreHandler){
        
        
        if (_scrollView.noMore) {
            
            //无更多数据
            self.activityIndicatorView.hidden =YES;
            
            self.arrow.hidden =YES;
            
            self.titleLabel.text =@"已加载全部数据";
            
        }
        else {
            
            //
            
            switch (newState) {
                    
                case DDPullToRefreshStateHidden:{
                    
                    if (_scrollView.contentSize.height <_scrollView.frame.size.height) {
                        self.hidden =YES;
                    }
                    else{
                        [self.activityIndicatorView stopAnimating];
                        [self setScrollViewContentOffset:CGPointMake(0,  _scrollView.contentSize.height -_scrollView.frame.size.height)];
                        [self rotateArrow:0 hide:YES];
                    }
                }
                    break;
                    
                case DDPullToRefreshStateVisible:{
                    titleLabel.text = self.pullingText;
                    arrow.alpha = 1;
                    [self.activityIndicatorView stopAnimating];
                    [self rotateArrow:M_PI hide:NO];
                }
                    break;
                    
                case DDPullToRefreshStateTriggered:{
                    titleLabel.text = self.releaseText;
                    [self rotateArrow:0 hide:NO];
                }
                    
                    break;
                    
                case DDPullToRefreshStateLoading:{
                    
                    titleLabel.text = self.loadingText;
                    [self.activityIndicatorView startAnimating];
                    [self setScrollViewContentOffset:CGPointMake(0,  _scrollView.contentSize.height -_scrollView.frame.size.height +RefreshViewHeight)];
                    [self rotateArrow:0 hide:YES];
                    _scrollView.isLoadMore =YES;
                    _scrollView.isRefresh =NO;
                    pullToLoadMoreHandler();
                }
                    break;
                    
                case DDPullToRefreshStateLoaded:{
                    
                    titleLabel.text = self.loadedText;
                    [self.activityIndicatorView stopAnimating];
                    [self setScrollViewContentOffset:CGPointMake(0,  _scrollView.contentSize.height -_scrollView.frame.size.height)];
                    [self rotateArrow:0 hide:YES];
                }
            }
            
        }
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"] && self.state != DDPullToRefreshStateLoading){
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
}

#pragma mark -scrollViewDidScroll

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    
    CGFloat scrollTop =self.originalScrollViewContentInset.top;
    CGFloat scrollOffsetThreshold = self.frame.origin.y-scrollTop;
    
    if (self.pullToRefreshHandler) {
        
        if (self.state ==DDPullToRefreshStateLoading ) {
            
        }
        else if (self.state ==DDPullToRefreshStateLoaded){
            self.state =DDPullToRefreshStateHidden;
        }
        else if(!self.scrollView.isDragging && self.state == DDPullToRefreshStateTriggered){
            
            self.state = DDPullToRefreshStateLoading;
        }
        else if(contentOffset.y > scrollOffsetThreshold && contentOffset.y < -self.originalScrollViewContentInset.top && self.scrollView.isDragging && self.state != DDPullToRefreshStateLoading){
            
            self.state = DDPullToRefreshStateVisible;
        }
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == DDPullToRefreshStateVisible){
            
            self.state = DDPullToRefreshStateTriggered;
        }
        else if(contentOffset.y >= -self.originalScrollViewContentInset.top && self.state != DDPullToRefreshStateHidden){
            
            self.state = DDPullToRefreshStateHidden;
        }
    }
    else if(self.pullToLoadMoreHandler){
        
        CGFloat scrollOffsetYThreshold = _scrollView.contentSize.height - _scrollView.frame.size.height;
        
        if (self.state ==DDPullToRefreshStateLoading) {
        }
        else if (self.state ==DDPullToRefreshStateLoaded){
            self.state =DDPullToRefreshStateHidden;
        }
        else if(!self.scrollView.isDragging && self.state == DDPullToRefreshStateTriggered){
            self.state = DDPullToRefreshStateLoading;
        }
        else if(contentOffset.y > scrollOffsetYThreshold && contentOffset.y <scrollOffsetYThreshold +RefreshViewHeight && scrollOffsetYThreshold >0 && self.scrollView.isDragging && self.state != DDPullToRefreshStateLoading){
            
            self.state = DDPullToRefreshStateVisible;
        }
        else if(contentOffset.y > scrollOffsetYThreshold && scrollOffsetYThreshold >0 &&  self.scrollView.isDragging && self.state == DDPullToRefreshStateVisible){
            
            self.state = DDPullToRefreshStateTriggered;
        }
        else if(contentOffset.y < scrollOffsetYThreshold && scrollOffsetYThreshold >0 &&  self.state != DDPullToRefreshStateHidden){
            
            self.state = DDPullToRefreshStateHidden;
        }
    }
}

- (void)triggerRefresh {
    self.state = DDPullToRefreshStateLoading;
}

- (void)refreshFinished {
    
    [self setNeedsLayout];
    
    self.state =DDPullToRefreshStateLoaded;
}

- (void)stopAnimating {
    self.state = DDPullToRefreshStateHidden;
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
        self.arrow.layer.opacity = !hide;
    } completion:NULL];
}



@end


#pragma mark - UIScrollView (DDPullToRefresh)

static char *UIScrollViewPullToRefreshView ="UIScrollViewPullToRefreshView";
static char *UIScrollViewPullToLoadMoreView ="UIScrollViewPullToLoadMoreView";

static char *UIScrollViewPullNoMore ="UIScrollViewPullNoMore";
static char *UIScollViewPullIsRefresh ="UIScollViewPullIsRefresh";
static char *UIScollViewPullIsLoadMore ="UIScollViewPullIsLoadMore";

@implementation UIScrollView (DDPullToRefresh)

@dynamic pullToRefreshView;

@dynamic pullToLoadMoreView;

@dynamic noMore;

@dynamic isLoadMore;

@dynamic isRefresh;

@dynamic pageNumber;


//-(void)dealloc{
//
//    //测试 UIScrollView 是否销毁
//    
//    NSLog(@"dealloc");
//}

#pragma mark -

- (void)setPullToRefreshHandler:(void (^)(void))actionHandler {
    
    DDPullToRefresh *pullToRefreshView = [[DDPullToRefresh alloc] initWithScrollView:self];
    pullToRefreshView.pullToRefreshHandler =actionHandler;
    self.pullToRefreshView = pullToRefreshView;
}

- (void)setPullToLoadMoreHandler:(void (^)(void))actionHandler {
    
    DDPullToRefresh *pullToLoadMoreView = [[DDPullToRefresh alloc] initWithScrollView:self];
    pullToLoadMoreView.pullToLoadMoreHandler =actionHandler;
    self.pullToLoadMoreView = pullToLoadMoreView;
}

- (void)refreshFinished{
    
    [self.pullToRefreshView refreshFinished];
}

-(void)loadMoreFinished{
    
    [self.pullToLoadMoreView refreshFinished];
}

#pragma mark > Customization

- (UILabel *)pullToRefreshLabel {
    
    return [self.pullToRefreshView titleLabel];
}

- (void)setPullToRefreshViewBackgroundColor:(UIColor *)backgroundColor {
    
    [self.pullToRefreshView setBackgroundColor:backgroundColor];
}

- (void)setPullToRefreshViewActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    
    //    [self.pullToRefreshView. setActivityIndicatorStyle:style];
    [self.pullToRefreshView.activityIndicatorView setActivityIndicatorViewStyle:style];
}

- (void)setPullToRefreshViewPullingText:(NSString *)pullingText {
    
    [self.pullToRefreshView setPullingText:pullingText];
}

- (void)setPullToRefreshViewReleaseText:(NSString *)releaseText {
    
    [self.pullToRefreshView setReleaseText:releaseText];
}

- (void)setPullToRefreshViewLoadingText:(NSString *)loadingText {
    
    [self.pullToRefreshView setLoadingText:loadingText];
}

- (void)setPullToRefreshViewLoadedText:(NSString *)loadedText {
    
    DDPullToRefresh *view =self.pullToRefreshView;
    
    [view setLoadedText:loadedText];
}

- (UILabel *)pullToLoadMoreLabel {
    
    return [self.pullToLoadMoreView titleLabel];
}

- (void)setPullToLoadMoreViewBackgroundColor:(UIColor *)backgroundColor {
    
    [self.pullToLoadMoreView setBackgroundColor:backgroundColor];
}

- (void)setPullToLoadMoreViewActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    
    [self.pullToLoadMoreView.activityIndicatorView setActivityIndicatorViewStyle:style];
}

- (void)setPullToLoadMoreViewPullingText:(NSString *)pullingText {
    
    DDPullToRefresh *view =self.pullToLoadMoreView;
    
    [view setPullingText:pullingText];
}

- (void)setPullToLoadMoreViewReleaseText:(NSString *)releaseText {
    
    [self.pullToLoadMoreView setReleaseText:releaseText];
}

- (void)setPullToLoadMoreViewLoadingText:(NSString *)loadingText {
    
    [self.pullToLoadMoreView setLoadingText:loadingText];
}

- (void)setPullToLoadMoreViewLoadedText:(NSString *)loadedText {
    
    [self.pullToLoadMoreView setLoadedText:loadedText];
}


#pragma mark -getter & setter


-(CGPoint)theBeiginContentOffset{
    
    CGPoint point =CGPointZero;
    
    id <UIScrollPullToRefreshViewDelegate> aDelegate =self.delegate;
    
    if ([aDelegate respondsToSelector:@selector(scrollViewBeginContentOffset:)]) {
        point =[aDelegate scrollViewBeginContentOffset:self];
    }
    
    return point;
}

-(NSUInteger)pageNumber{
    NSNumber *n =objc_getAssociatedObject(self, "TablePageNumber");
    return [n unsignedIntegerValue];
}

-(void)setPageNumber:(NSUInteger)number{
    NSNumber *n =[NSNumber numberWithUnsignedInteger:number];
    objc_setAssociatedObject(self, "TablePageNumber", n, OBJC_ASSOCIATION_ASSIGN);
}


-(BOOL)noMore{
    
    NSNumber *n =objc_getAssociatedObject(self, &UIScrollViewPullNoMore);
    if (n ==nil || ![n isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    
    return [n boolValue];
}

-(void)setNoMore:(BOOL)noMore{
    
    objc_setAssociatedObject(self, &UIScrollViewPullNoMore,
                             [NSNumber numberWithBool:noMore],
                             OBJC_ASSOCIATION_ASSIGN);
}

-(void)setRefresh:(BOOL)isRefresh{
    
    objc_setAssociatedObject(self, &UIScollViewPullIsRefresh,
                             [NSNumber numberWithBool:isRefresh],
                             OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)isRefresh{
    
    NSNumber *n =objc_getAssociatedObject(self, &UIScollViewPullIsRefresh);
    if (n ==nil || ![n isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    return [n boolValue];
}

-(void)setLoadMore:(BOOL)isLoadMore{
    
    objc_setAssociatedObject(self, &UIScollViewPullIsLoadMore,
                             [NSNumber numberWithBool:isLoadMore],
                             OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)isLoadMore{
    
    NSNumber *n =objc_getAssociatedObject(self, &UIScollViewPullIsLoadMore);
    if (n ==nil || ![n isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    
    return [n boolValue];
}


- (void)setPullToRefreshView:(DDPullToRefresh *)pullToRefreshView {
    [self willChangeValueForKey:@"pullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"pullToRefreshView"];
}

- (DDPullToRefresh *)pullToRefreshView {
    DDPullToRefresh *view =objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
    return view;
}

- (void)setPullToLoadMoreView:(DDPullToRefresh *)pullToLoadMoreView{
    
    [self willChangeValueForKey:@"pullToLoadMoreView"];
    
    objc_setAssociatedObject(self, &UIScrollViewPullToLoadMoreView,
                             pullToLoadMoreView,
                             OBJC_ASSOCIATION_ASSIGN);
    
    [self didChangeValueForKey:@"pullToLoadMoreView"];
}

- (DDPullToRefresh *)pullToLoadMoreView {
    
    DDPullToRefresh *view  =objc_getAssociatedObject(self, &UIScrollViewPullToLoadMoreView);
    return view;
}

//- (void)removeKVO{
//    
//    [self.pullToLoadMoreView removeKOV];
//    [self.pullToRefreshView removeKOV];
//}

@end
