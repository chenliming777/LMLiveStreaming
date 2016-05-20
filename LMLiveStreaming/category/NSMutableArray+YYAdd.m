//
//  NSMutableArray+YYAdd.m
//  YYKit
//
//  Created by admin on 16/5/20.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "NSMutableArray+YYAdd.h"

@implementation NSMutableArray (YYAdd)

- (void)removeFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

- (id)popFirstObject {
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self removeFirstObject];
    }
    return obj;
}

@end
