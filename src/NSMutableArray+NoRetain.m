//
//  NSMutableArray+NoRetain.m
//  PCShop
//
//  Created by 丁丁 on 14-4-3.
//  Copyright (c) 2014年 丁丁. All rights reserved.
//

#import "NSMutableArray+NoRetain.h"

static const void* RetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void ReleaseNoOp(CFAllocatorRef allocator, const void *value) { }


///////////////////////////////////////////////////////////////////////////////////////////////////
NSMutableArray* CreateNonRetainingArray() {
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = RetainNoOp;
    callbacks.release = ReleaseNoOp;
    return (NSMutableArray*)CFBridgingRelease(CFArrayCreateMutable(nil, 0, &callbacks));
}


@implementation NSMutableArray (NoRetain)

+(NSMutableArray *)arrayNoretain{

    return CreateNonRetainingArray();
}

@end
