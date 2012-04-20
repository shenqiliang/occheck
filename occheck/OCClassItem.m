//
//  OCClassItem.m
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "OCClassItem.h"

@implementation OCClassItem
@synthesize name;
@synthesize retainedMembers;
@synthesize releasedMembers;
@synthesize assignedMembers;
@synthesize shouldRemoveNotification;
@synthesize didRemoveNotification;
@synthesize hasImplemented;
@synthesize synthesizeMap;
@synthesize isSingleton;

- (NSString*)description{
    return [NSString stringWithFormat:@"Class %@:\nretainedMembers:%@\nreleasedMembers:%@\nassignedMembers:%@",name,retainedMembers,releasedMembers,assignedMembers];
}



- (id)init{
    self = [super init];
    if (self) {
        retainedMembers = [[NSMutableSet alloc] init];
        releasedMembers = [[NSMutableSet alloc] init];
        assignedMembers = [[NSMutableSet alloc] init];
        synthesizeMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)checkError{
    if ([name rangeOfString:@"OCManager"].location!=NSNotFound) {
        
    }
    
    if (!hasImplemented) {
        //printf("WARNING: %s is not implemented.\n", [name UTF8String]);
        return NO;
    }
    BOOL hasErr = NO;
    if (!isSingleton) {
        [synthesizeMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([retainedMembers containsObject:key]) {
                [retainedMembers removeObject:key];
                [retainedMembers addObject:obj];
            }
            if ([assignedMembers containsObject:key]) {
                [assignedMembers removeObject:key];
                [assignedMembers addObject:obj];
            }
            if ([releasedMembers containsObject:key]) {
                [releasedMembers removeObject:key];
                [releasedMembers addObject:obj];
            }

        }];
        NSMutableSet *errorSet = [NSMutableSet setWithSet:retainedMembers];
        [errorSet minusSet:assignedMembers];
        [errorSet minusSet:releasedMembers];
        hasErr = [errorSet count]>0;
        for (NSString *m in errorSet) {
            printf("ERROR: %s 中 %s 成员没有在dealloc中release.\n", [name UTF8String], [m UTF8String]);
        }
    }
    if (shouldRemoveNotification&&!didRemoveNotification) {
        hasErr = YES;
        printf("ERROR: %s is notificaiton observer but not removed in dealloc.\n", [name UTF8String]);
    }
    return hasErr;
}

- (void)mergeWithOCClassItem:(OCClassItem*)item{
    if ([name rangeOfString:@"QSimpleTableViewController"].location!=NSNotFound) {
    }
    if ([item.name isEqualToString:name]) {
        [self.assignedMembers unionSet:item.assignedMembers];
        [self.retainedMembers unionSet:item.retainedMembers];
        [self.releasedMembers unionSet:item.releasedMembers];
        if (item.hasImplemented) {
            self.hasImplemented = YES;
        }
        [self.synthesizeMap addEntriesFromDictionary:item.synthesizeMap];
        if (item.isSingleton) {
            self.isSingleton = YES;
        }
    }
}


- (void)dealloc{
    [name release];
    [retainedMembers release];
    [releasedMembers release];
    [assignedMembers release];
    [synthesizeMap release];
    [super dealloc];
}
@end
