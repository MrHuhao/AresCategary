//
//  UIView+UIViewAdditions.h
//  CRMSystemForPrivate
//
//  Created by  丁丁 on 13-4-20.
//
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAdditions)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

-(void)cleanViewBackgroudcolorWith:(Class)cls;

-(id)copy;

@end
