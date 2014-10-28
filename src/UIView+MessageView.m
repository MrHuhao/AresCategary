//
//  UIView+MessageView.m
//  CRMSystemForHall
//
//  Created by  丁丁 on 13-6-26.
//
//

#import "UIView+MessageView.h"

#import "NSObject+Block.h"

#import <objc/runtime.h>

#define MessageViewKey @"__MessageViewKey"


@implementation UIView (MessageView)

-(void)setMessageView:(UIView *)waitView{
    
    objc_setAssociatedObject(self, MessageViewKey, waitView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView *)messageView{
    
    return objc_getAssociatedObject(self, MessageViewKey);
}

-(void)showMessage:(NSString *)messageString{

    UILabel *viewOfMessage =(UILabel *)[self messageView];
    
    if (viewOfMessage ==nil || ![viewOfMessage isKindOfClass:[UILabel class]]) {
        viewOfMessage =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 21)];
        viewOfMessage.font =[UIFont systemFontOfSize:14.0f];
        viewOfMessage.backgroundColor =[UIColor grayColor];
        viewOfMessage.textColor =[UIColor whiteColor];
        viewOfMessage.textAlignment =NSTextAlignmentCenter;
        viewOfMessage.center =CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self setMessageView:viewOfMessage];
    }
    
    [viewOfMessage setText:messageString];
    }

-(void)showMessageView:(UIView *)view{

    view.alpha =0;
    
    [self addSubview:view];
    
    __weak id tmpSelf =self;
    
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha =1.0;
        
    } completion:^(BOOL finish){
        
        if (finish) {
            
            [tmpSelf perform:^{
                
                [UIView animateWithDuration:0.2 animations:^{
                    
                    view.alpha =0;
                } completion:^(BOOL finish){
                    
                    if (finish) {
                        [view removeFromSuperview];
                    }
                }];
                
            } andDelay:1.0f];
        }
        
    }];

}

@end
