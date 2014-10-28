//
//  NSString+DrawLine.h
//  PCShop
//
//  Created by 丁丁 on 14-3-25.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DrawLine)

- (NSInteger)lineWhenDrawWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)sizeWhenDrawWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
