//
//  NSString+DrawLine.m
//  PCShop
//
//  Created by 丁丁 on 14-3-25.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import "NSString+DrawLine.h"

@implementation NSString (DrawLine)

- (NSInteger)lineWhenDrawWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode{

    CGSize size =[self sizeWithFont:font forWidth:MAXFLOAT lineBreakMode:lineBreakMode];
    
    NSInteger i_width =(NSInteger)width;
    NSInteger i_newWidth =(NSInteger)size.width;
    
    NSInteger numberOfLine =i_newWidth/i_width +(i_width%i_newWidth >0 ? 1:0);
    
    return numberOfLine;
}

- (CGSize)sizeWhenDrawWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode{

    CGSize size =[self sizeWithFont:font forWidth:MAXFLOAT lineBreakMode:lineBreakMode];
    
    NSInteger numberOfLine =[self lineWhenDrawWithFont:font forWidth:width lineBreakMode:lineBreakMode];
    
    return CGSizeMake(width, numberOfLine *size.height);
}

@end
