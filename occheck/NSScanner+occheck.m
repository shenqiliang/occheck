//
//  NSScanner+occheck.m
//  occheck
//
//  Created by 启亮 谌 on 12-4-17.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "NSScanner+occheck.h"

@implementation NSScanner (occheck)

- (BOOL)scanToNextBoundRightBraceIntoString:(NSString**)outString{
    NSUInteger startLocation = [self scanLocation];
    int level = 1;
    [self scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"] intoString:nil];
    while (![self isAtEnd]) {
        if ([self scanString:@"{" intoString:nil]) {
            level++;
        }
        else if ([self scanString:@"}" intoString:nil]){
            level--;
            if (level==0) {
                break;
            }
        }
        [self scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"] intoString:nil];
    }
    NSString *result = [self.string substringWithRange:NSMakeRange(startLocation, [self scanLocation]-startLocation)];
    if(outString) *outString = result;
    return [result length]>0;
}

@end
