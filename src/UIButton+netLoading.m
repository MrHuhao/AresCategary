//
//  UIButton+netLoading.m
//  PCShop
//
//  Created by 丁丁 on 14-4-2.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import "UIButton+netLoading.h"


@implementation UIButton (netLoading)

-(void)asynchronousLoadImage:(NSString *)url name:(NSString *)name cachePath:(NSString *)path{
    
    NSString *strPath =[path stringByAppendingPathComponent:name];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:strPath]) {
        
        UIImage *image =[UIImage imageWithContentsOfFile:strPath];
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
    else{
        
        PCFileDownLoadModel *model =[[PCFileDownLoadModel alloc] initWithUrl:url path:path];
        model.saveNameString =name;
        [model addDelegate:self];

        [model download];
    }
    
}

//-(void)model:(PCFileDownLoadModel *)model receiveDataWithLength:(long long)length totalLength:(long long)totalLength{
//
//    UIImage *image =[UIImage imageWithData:model.downLoadData];
//    
//    [self setBackgroundImage:image forState:UIControlStateNormal];
//}

-(void)model:(PCFileDownLoadModel *)model downloadSuccsess:(BOOL)isSuccess error:(NSString *)error{
    
    NSString *strPath =[model.pathString stringByAppendingPathComponent:model.saveNameString];
    
    UIImage *image =[UIImage imageWithContentsOfFile:strPath];
    
    [self setBackgroundImage:image forState:UIControlStateNormal];
}


@end
