//
//  NSScanner+occheck.h
//  occheck
//
//  Created by 启亮 谌 on 12-4-17.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSScanner (occheck)

- (BOOL)scanToNextBoundRightBraceIntoString:(NSString**)outString;

@end
