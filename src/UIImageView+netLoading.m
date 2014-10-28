//
//  UIImageView+netLoading.m
//  CRMSystemForHall
//
//  Created by  丁丁 on 13-3-20.
//
//

#import "UIImageView+netLoading.h"

@implementation UIImageView (netLoading)

-(void)asynchronousLoadImage:(NSString *)url name:(NSString *)name cachePath:(NSString *)path{
    
    NSString *strPath =[path stringByAppendingPathComponent:name];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:strPath]) {

        self.image =[UIImage imageWithContentsOfFile:strPath];
    }
    else{
        
        PCFileDownLoadModel *model =[PCFileDownLoadModel modelWithUrl:url path:path];
        model.saveNameString =name;
        [model addDelegate:self];
        
        [model download];
    }
}

//-(void)model:(PCFileDownLoadModel *)model receiveDataWithLength:(long long)length totalLength:(long long)totalLength{
//    
//    UIImage *image =[UIImage imageWithData:model.downLoadData];
//    
//    [self setImage:image];
//}

-(void)model:(PCFileDownLoadModel *)model downloadSuccsess:(BOOL)isSuccess error:(NSString *)error{

    NSString *strPath =[model.pathString stringByAppendingPathComponent:model.saveNameString];
    
    self.image =[UIImage imageWithContentsOfFile:strPath];
}

@end
