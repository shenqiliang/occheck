//
//  OCImplementationScanner.m
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "OCImplementationScanner.h"
#import "NSString+occheck.h"
#import "OCMethordImplementationScanner.h"

@implementation OCImplementationScanner
@synthesize scanItem;
- (id)initWithCodeText:(NSString*)codeText{
    self = [super init];
    if (self) {
        V2Log(@"Begin check implementation %@", [codeText fistLineText]);
        scanItem = [[OCClassItem alloc] init];
        NSScanner *scanner = [NSScanner scannerWithString:codeText];
        if ([scanner scanString:@"@implementation" intoString:nil]) {
            [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
            NSString *className = nil;
            [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&className];
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
            if ([className length]>0) {
                scanItem.name = className;
                scanItem.hasImplemented = YES;
                
                //扫描私有成员变量定义
                if ([scanner scanString:@"{" intoString:nil]) {
                    NSString *privateDefines = nil;
                    if ([scanner scanToNextBoundRightBraceIntoString:&privateDefines]) {
                        if ([privateDefines length]>0) {
                            NSScanner *classDefineScanner = [NSScanner scannerWithString:privateDefines];
                            while (![classDefineScanner isAtEnd]) {
                                
                                //每一行成员变量
                                NSString *line = nil;
                                [classDefineScanner scanUpToString:@";" intoString:&line];
                                [classDefineScanner scanString:@";" intoString:nil];
                                [line addMemberInClassDefineToOCClassItem:scanItem];
                            }
                        }
                        
                    }
                }

                //扫描方法
                NSString *scanedString = nil;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"@{"] intoString:&scanedString];
                while (![scanner isAtEnd]) {
                    
                    if ([scanner scanString:@"@synthesize" intoString:nil]) {                    //@synthesize
                        NSString *synthesizeDefines = nil;
                        if ([scanner scanUpToString:@";" intoString:&synthesizeDefines]) {
                            synthesizeDefines = [synthesizeDefines stringByReplacingOccurrencesOfString:@" " withString:@""];
                            for (NSString *synthesizeDefine in [synthesizeDefines componentsSeparatedByString:@","]) {
                                NSArray *array = [synthesizeDefine componentsSeparatedByString:@"="];
                                if ([array count]==2) {
                                    [scanItem.synthesizeMap setObject:[array objectAtIndex:1] forKey:[array objectAtIndex:0]];
                                }
                            }
                        }
                        [scanner scanString:@";" intoString:nil];
                    }
                    else if ([scanner scanString:@"@end" intoString:nil]) {
                        break;
                    }
                    else if ([scanner scanString:@"@" intoString:nil]) {
                        [scanner scanString:@";" intoString:nil];
                    }
                    else if ([scanner scanString:@"{" intoString:nil]) {
                        NSString *braceString = nil;
                        if ([scanner scanToNextBoundRightBraceIntoString:&braceString]) {
                            NSString *methordDefine = [scanedString stringByAppendingFormat:@"{%@",braceString];
                            methordDefine = [methordDefine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([methordDefine hasPrefix:@"+"]||[methordDefine hasPrefix:@"-"]) {
                                [[[OCMethordImplementationScanner alloc] initWithCodeText:methordDefine andClassItem:scanItem] autorelease];
                            }
                        }
                    }
                    
                    scanedString = nil;
                    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"@{"] intoString:&scanedString];
                }
            }
        }
    }
    return self;
}

- (void)dealloc{
    [scanItem release];
    [super dealloc];
}
@end
