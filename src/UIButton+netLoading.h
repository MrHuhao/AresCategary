//
//  UIButton+netLoading.h
//  PCShop
//
//  Created by 丁丁 on 14-4-2.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCFileDownLoadModel.h"

@interface UIButton (netLoading)<PCFileDownLoadModelDelegate>

-(void)asynchronousLoadImage:(NSString *)url name:(NSString *)name cachePath:(NSString *)path;

@end
