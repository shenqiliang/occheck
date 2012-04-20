//
//  OCInterfceScanner.m
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "OCInterfceScanner.h"

@implementation OCInterfceScanner
@synthesize scanItem;
- (id)initWithCodeText:(NSString*)codeText{
    self = [super init];
    if (self) {
        V2Log(@"Begin check interface %@", [codeText fistLineText]);
        NSScanner *scanner = [NSScanner scannerWithString:codeText];
        if ([scanner scanString:@"@interface" intoString:nil]) {
            scanItem = [[OCClassItem alloc] init];
            [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
            if ([scanner scanString:@"SINGLETON" intoString:nil]) {
                scanItem.isSingleton = YES;
                [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
            }
            NSString *className = nil;
            [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&className];
            if ([className length]>0) {
                scanItem.name = className;
                
                //类成员变量
                if ([codeText rangeOfString:@"{"].location!=NSNotFound) {
                    [scanner scanUpToString:@"{" intoString:nil];
                    if ([scanner scanString:@"{" intoString:nil]) {
                        NSString *classDefineString = nil;
                        [scanner scanToNextBoundRightBraceIntoString:&classDefineString];
                        if ([classDefineString hasSuffix:@"}"]) {
                            classDefineString = [classDefineString substringToIndex:[classDefineString length]-1];
                        }
                        if ([classDefineString length]>0) {
                            NSScanner *classDefineScanner = [NSScanner scannerWithString:classDefineString];
                            while (![classDefineScanner isAtEnd]) {
                                
                                //每一行
                                NSString *line = nil;
                                [classDefineScanner scanUpToString:@";" intoString:&line];
                                [classDefineScanner scanString:@";" intoString:nil];
                                [line addMemberInClassDefineToOCClassItem:scanItem];
                                
                            }
                        }
                    }
                }
                
                //属性
                while (![scanner isAtEnd]) {
                    [scanner scanUpToString:@"@property" intoString:nil];
                    NSString *defineStr = nil;
                    [scanner scanUpToString:@";" intoString:&defineStr];
                    [defineStr addMemberInClassPropertyToOCClassItem:scanItem];
                }
            }
        }
        else{
            NSLog(@"OCInterfceScanner is not begin @interface!");
        }
        
    }
    return self;
}

- (void)dealloc{
    [scanItem release];
    [super dealloc];
}
@end
