//
//  UIScrollView+RemoveKVO.m
//  PCShop
//
//  Created by 丁丁 on 14-4-5.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import "UIScrollView+RemoveKVO.h"

#import "UIScrollView+PullToRefresh.h"
#import "UIScrollView+Viscidity.h"

@implementation UIScrollView (RemoveKVO)

- (void)removeKVO{
    
    [self.pullToRefreshView removeKOV];
    [self.pullToLoadMoreView removeKOV];
    
    [self.viscidityView removeKOV];
}

@end
