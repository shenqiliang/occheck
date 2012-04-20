//
//  OCMessageScanner.m
//  occheck
//
//  Created by 启亮 谌 on 12-3-1.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "OCMethordImplementationScanner.h"

@implementation OCMethordImplementationScanner

- (id)initWithCodeText:(NSString*)codeText andClassItem:(OCClassItem*)scanItem{
    self = [super init];
    if (self) {
        V3Log(@"Begin check message %@", [codeText fistLineText]);
        NSScanner *scanner = [NSScanner scannerWithString:codeText];
        if ([scanner scanString:@"+" intoString:nil]) {
            isClassMessage = YES;
        }
        else if ([scanner scanString:@"-" intoString:nil]) {
            isClassMessage = NO;
        }

        
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
        
        NSString *returnType = @"id";
        if ([scanner scanString:@"(" intoString:nil]) {
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
            [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&returnType];
            [scanner scanUpToString:@")" intoString:nil];
            [scanner scanString:@")" intoString:nil];
        }
        
        
        //消息名
        NSString *messageName = @"";
        NSString *messageNamePart = nil;
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
        if ([scanner scanCharactersFromSet:OCNameCharacterSet intoString:&messageNamePart]) {
            messageName = [messageName stringByAppendingString:messageNamePart];
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
        }
        if ([scanner scanString:@":" intoString:nil]) {
            messageName = [messageName stringByAppendingString:@":"];
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
            
            NSString *paramType = nil;
            if ([scanner scanString:@"(" intoString:nil]) {
                [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
                [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&paramType];
                [scanner scanUpToString:@")" intoString:nil];
                [scanner scanString:@")" intoString:nil];
            }
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
            
            NSString *param = nil;
            [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&param];
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
            
            if ([scanner scanString:@"," intoString:nil]) {
                [scanner scanUpToString:@"{" intoString:nil];
            }
        }
        
        if ([scanner scanString:@";" intoString:nil]) {
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
        }
        
        [scanner scanUpToString:@"{" intoString:nil];
        [scanner scanString:@"{" intoString:nil];

        if ([messageName isEqualToString:@"dealloc"]) {
            NSString *deallocLinesString = nil;
            [scanner scanToNextBoundRightBraceIntoString:&deallocLinesString];
            if ([deallocLinesString hasSuffix:@"}"]) {
                deallocLinesString = [deallocLinesString substringToIndex:[deallocLinesString length]-1];
            }
            if ([deallocLinesString length]>0) {
                NSScanner *classDefineScanner = [NSScanner scannerWithString:deallocLinesString];
                while (![classDefineScanner isAtEnd]) {
                    NSString *line = nil;
                    [classDefineScanner scanUpToString:@";" intoString:&line];
                    [classDefineScanner scanString:@";" intoString:nil];
                    
                    //每一行
                    NSString *var = [line releasedVarName];
                    if(var!=nil) [scanItem.releasedMembers addObject:var];
                }
            }
        }

    }
    return self;
}

@end
