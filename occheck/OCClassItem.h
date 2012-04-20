//
//  OCClassItem.h
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCClassItem : NSObject{
    NSString *name;
    NSMutableSet *assignedMembers;
    NSMutableSet *retainedMembers;
    NSMutableSet *releasedMembers;
    NSMutableDictionary *synthesizeMap;
    BOOL shouldRemoveNotification;
    BOOL didRemoveNotification;
    BOOL hasImplemented;
    BOOL isSingleton;
}

- (BOOL)checkError;
@property(nonatomic, readonly) NSMutableSet *assignedMembers;
@property(nonatomic, readonly) NSMutableSet *retainedMembers;
@property(nonatomic, readonly) NSMutableSet *releasedMembers;
@property(nonatomic, readonly) NSMutableDictionary *synthesizeMap;
@property(nonatomic, retain) NSString *name;
@property(nonatomic) BOOL shouldRemoveNotification;
@property(nonatomic) BOOL hasImplemented;
@property(nonatomic) BOOL didRemoveNotification;
@property(nonatomic) BOOL isSingleton;
- (void)mergeWithOCClassItem:(OCClassItem*)item;
@end
