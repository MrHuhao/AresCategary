//
//  NSString+Addtion.m
//  PCShop
//
//  Created by 丁丁 on 14-4-2.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import "NSString+Addtion.h"

@implementation NSString (Addtion)

-(NSString *)stringValue{
    
    return self;
}

-(BOOL)containsString:(NSString *)string{

    NSRange range =[self rangeOfString:string];
    
    return range.length >0;
}

@end
