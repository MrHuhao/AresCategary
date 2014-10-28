//
//  UIImageView+netLoading.h
//  CRMSystemForHall
//
//  Created by  丁丁 on 13-3-20.
//
//

#import <UIKit/UIKit.h>

#import "PCFileDownLoadModel.h"

@interface UIImageView (netLoading)<PCFileDownLoadModelDelegate>

-(void)asynchronousLoadImage:(NSString *)url name:(NSString *)name cachePath:(NSString *)path;

@end
