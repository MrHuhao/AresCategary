//
//  UIScrollView+Viscidity.m
//  PCShop
//
//  Created by 丁丁 on 14-3-29.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import "UIScrollView+Viscidity.h"

#import <objc/runtime.h>

static char *UIScrollViewHeaderViscidityView ="UIScrollViewHeaderViscidityView";
static char *UIScrollViewFooterViscidityView ="UIScrollViewFooterViscidityView";

@implementation UIScrollViewViscidityView

@synthesize scrollView =_scrollView;

@synthesize view =_view;

-(id)initWithScrollView:(UIScrollView *)scrollView viscidityView:(UIView *)view{

    if (self =[super initWithFrame:CGRectZero]) {
        
        self.scrollView =scrollView;
    
        self.view =view;
        
        self.view.frame =CGRectMake(0, self.scrollView.contentOffset.y +self.scrollView.contentInset.top -self.view.frame.size.height, self.view.frame .size.width, self.view.frame.size.height);
        
        [self.scrollView addSubview:self.view];
        
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"] ){
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
}

-(void)removeKOV{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    
    CGFloat fOffset =contentOffset.y +self.scrollView.contentInset.top;
    
    if ([self.scrollView headerViscidityView] ==self.view) {
        
        if (fOffset >=0) {
            
            CGRect frame = self.view.frame;
            frame.origin.y =fOffset -self.view.frame.size.height;
            self.view.frame =frame;
        }
    }
    else if([self.scrollView footerViscidityView] ==self.view){
    
    }
}


@end


@implementation UIScrollView (Viscidity)

@dynamic headerViscidityView;

@dynamic footerViscidityView;

-(void)setHeaderViscidityView:(UIView *)headerViscidityView{

    [self willChangeValueForKey:@"headerViscidityView"];
    objc_setAssociatedObject(self, &UIScrollViewHeaderViscidityView,
                             headerViscidityView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"headerViscidityView"];
    
    UIScrollViewViscidityView *view =[[UIScrollViewViscidityView alloc] initWithScrollView:self viscidityView:headerViscidityView];
    [self addSubview:view];
    
}

-(UIView *)headerViscidityView{

    UIView *view =objc_getAssociatedObject(self, &UIScrollViewHeaderViscidityView);
    return view;
}

-(void)setFooterViscidityView:(UIView *)footerViscidityView{
    
    [self willChangeValueForKey:@"footerViscidityView"];
    objc_setAssociatedObject(self, &UIScrollViewFooterViscidityView,
                             footerViscidityView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"footerViscidityView"];
}

-(UIView *)footerViscidityView{
    
    UIView *view =objc_getAssociatedObject(self, &UIScrollViewHeaderViscidityView);
    return view;
}

-(UIScrollViewViscidityView *)viscidityView{

    UIScrollViewViscidityView *view =nil;
    for (UIScrollViewViscidityView *v in self.subviews) {
        if ([v isKindOfClass:[UIScrollViewViscidityView class]]) {
            view =v;
            break;
        }
    }
    return view;
}

//- (void)removeKVO{
//    
//    [[self viscidityView] removeKOV];
//}



@end
