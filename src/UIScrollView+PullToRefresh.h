
#import <UIKit/UIKit.h>

#define RefreshViewHeight 60.0f

@interface DDPullToRefresh : UIView{
    
    NSString * _pullingText;                        // Customization
    NSString * _releaseText;
    NSString * _loadingText;
    NSString * _loadedText;
}

@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nonatomic, strong) NSDate *lastUpdatedDate;

@property (nonatomic, copy) NSString * pullingText;       // Displayed in _label while pulling
@property (nonatomic, copy) NSString * releaseText;       // Displayed in _label before releasing
@property (nonatomic, copy) NSString * loadingText;       // Displayed in _label while loading
@property (nonatomic, copy) NSString * loadedText;        // Displayed in _label when loading did finish

- (void)triggerRefresh;

- (void)stopAnimating;

- (void)refreshFinished;

-(void)removeKOV;

@end

@protocol UIScrollViewPullResfreshDelegate <NSObject>

-(void)scrollViewRefresh:(UIScrollView *)scrollView;

-(void)scrollViewLoadMore:(UIScrollView *)scrollView;

@end

// extends UIScrollView

@protocol UIScrollPullToRefreshViewDelegate;

@interface UIScrollView (DDPullToRefresh)

@property (nonatomic, strong) DDPullToRefresh *pullToRefreshView;

@property (nonatomic, strong) DDPullToRefresh *pullToLoadMoreView;

@property (nonatomic,assign) BOOL noMore;

@property (nonatomic,assign,setter = setRefresh:) BOOL isRefresh;

@property (nonatomic,assign,setter = setLoadMore:) BOOL isLoadMore;

@property (nonatomic,assign) NSUInteger pageNumber;

- (void)setPullToRefreshHandler:(void (^)(void))actionHandler;

- (void)setPullToLoadMoreHandler:(void (^)(void))actionHandler;

- (void)refreshFinished;

-(void)loadMoreFinished;

-(CGPoint)theBeiginContentOffset;

- (UILabel *)pullToRefreshLabel;
- (void)setPullToRefreshViewBackgroundColor:(UIColor *)backgroundColor;
- (void)setPullToRefreshViewActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
- (void)setPullToRefreshViewPullingText:(NSString *)pullingText;
- (void)setPullToRefreshViewReleaseText:(NSString *)releaseText;
- (void)setPullToRefreshViewLoadingText:(NSString *)loadingText;
- (void)setPullToRefreshViewLoadedText:(NSString *)loadedText;

- (UILabel *)pullToLoadMoreLabel;
- (void)setPullToLoadMoreViewBackgroundColor:(UIColor *)backgroundColor;
- (void)setPullToLoadMoreViewActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
- (void)setPullToLoadMoreViewPullingText:(NSString *)pullingText;
- (void)setPullToLoadMoreViewReleaseText:(NSString *)releaseText;
- (void)setPullToLoadMoreViewLoadingText:(NSString *)loadingText;
- (void)setPullToLoadMoreViewLoadedText:(NSString *)loadedText;

- (void)removeKVO;

@end

@protocol UIScrollPullToRefreshViewDelegate <UIScrollViewDelegate>

-(CGPoint)scrollViewBeginContentOffset:(UIScrollView *)scrollView;

@end