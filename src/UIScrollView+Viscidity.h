//
//  UIScrollView+Viscidity.h
//  PCShop
//
//  Created by 丁丁 on 14-3-29.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollViewViscidityView : UIView

@property (nonatomic,assign) UIScrollView *scrollView;

@property (nonatomic,strong) UIView *view;

-(id)initWithScrollView:(UIScrollView *)scrollView viscidityView:(UIView *)view;

-(void)removeKOV;

@end

//粘性
@interface UIScrollView (Viscidity)

@property (nonatomic,strong) UIView *headerViscidityView;

@property (nonatomic,strong) UIView *footerViscidityView;

-(UIScrollViewViscidityView *)viscidityView;

@end

@protocol UIScrollViewCustomDelegate <UIScrollViewDelegate>

-(CGPoint)scrollViewBeginContentOffset:(UIScrollView *)scrollView;

@end
