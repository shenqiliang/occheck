//
//  NSString+occheck.h
//  occheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCClassItem.h"
@interface NSString (occheck)
- (NSString*)fistLineText;
- (void)addMemberInClassPropertyToOCClassItem:(OCClassItem*)item;
- (void)addMemberInClassDefineToOCClassItem:(OCClassItem*)item;
- (NSString*)releasedVarName;

@end
