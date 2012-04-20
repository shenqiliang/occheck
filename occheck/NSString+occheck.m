//
//  NSString+occheck.m
//  occheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "NSString+occheck.h"

@implementation NSString (occheck)

- (NSString*)fistLineText{
    NSRange range = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (range.location!=NSNotFound) {
        return [self substringToIndex:range.location];
    }
    else {
        return self;
    }
}

- (void)addMemberInClassPropertyToOCClassItem:(OCClassItem*)item{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner scanUpToString:@"@property" intoString:nil];
    BOOL isRetained = NO;
    if ([scanner scanString:@"@property" intoString:nil]) {
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
        if ([scanner scanString:@"(" intoString:nil]) {
            NSString *property_attr = nil;
            [scanner scanUpToString:@")" intoString:&property_attr];
            if ([property_attr rangeOfString:@"retain"].location!=NSNotFound) {
                isRetained = YES;
            }
            else if ([property_attr rangeOfString:@"readonly"].location!=NSNotFound) {
                return;
            }

            [scanner scanString:@")" intoString:&property_attr];
        }
    }
    
    [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
    
    [scanner scanString:@"IBOutlet" intoString:nil];
    if ([scanner scanString:@"const" intoString:nil]) {
        isRetained = NO;
    }
    
    NSString *type = nil;
    [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
    [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&type];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\t \r"] intoString:nil];
    if ([scanner scanString:@"<" intoString:nil]) {
        [scanner scanUpToString:@">" intoString:nil];
        [scanner scanString:@">" intoString:nil];
    }
    
    //添加变量
    if (isRetained) {
        [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        while (![scanner isAtEnd]) {
            NSString *varName = nil;
            [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&varName];
            if(varName) [item.retainedMembers addObject:varName];
            [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        }
    }
    else{
        [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        while (![scanner isAtEnd]) {
            NSString *varName = nil;
            [scanner scanCharactersFromSet:OCNameCharacterSet intoString:&varName];
            if(varName) [item.assignedMembers addObject:varName];
            [scanner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        }
    }
}

- (void)addMemberInClassDefineToOCClassItem:(OCClassItem*)item{
    NSScanner *scaner = [NSScanner scannerWithString:self];
    NSString *type = nil;
    BOOL isRetain = NO;
    BOOL isExpAssign = NO;
    [scaner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\t \r"] intoString:nil];
    if ([scaner scanString:@"@" intoString:nil]) {
        [scaner scanCharactersFromSet:OCNameCharacterSet intoString:nil];
    }
    [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
    
    if ([scaner scanString:@"IBOutlet" intoString:nil]) {
        isRetain = YES;
    }
    [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];

    if ([scaner scanString:@"const" intoString:nil]) {
        return;
    }
    [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];

    if ([scaner scanString:@"ASSIGN" intoString:nil]) {
        isExpAssign = YES;
    }
    [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
    
    [scaner scanCharactersFromSet:OCNameCharacterSet intoString:&type];
    if ([type isEqualToString:@"id"]) {
        isRetain = YES;
    }
    else if([self rangeOfString:@"*"].location!=NSNotFound){
        isRetain = YES;
    }
    [scaner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\t \r"] intoString:nil];
    if ([scaner scanString:@"<" intoString:nil]) {
        [scaner scanUpToString:@">" intoString:nil];
        [scaner scanString:@">" intoString:nil];
    }
    
    //添加变量
    if (isRetain&&!isExpAssign) {
        [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        while (![scaner isAtEnd]) {
            NSString *varName = nil;
            [scaner scanCharactersFromSet:OCNameCharacterSet intoString:&varName];
            if(varName) [item.retainedMembers addObject:varName];
            [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        }
    }
    else{
        [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        while (![scaner isAtEnd]) {
            NSString *varName = nil;
            [scaner scanCharactersFromSet:OCNameCharacterSet intoString:&varName];
            if(varName) [item.assignedMembers addObject:varName];
            [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        }
    }
}

- (NSString*)releasedVarName{
    if ([self rangeOfString:@"release" options:NSCaseInsensitiveSearch].location!=NSNotFound) {
        NSScanner *scaner = [NSScanner scannerWithString:self];
        [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        NSMutableArray *elements = [NSMutableArray array];
        while (![scaner isAtEnd]) {
            NSString *varName = nil;
            [scaner scanCharactersFromSet:OCNameCharacterSet intoString:&varName];
            if(varName!=nil) [elements addObject:varName];
            [scaner scanUpToCharactersFromSet:OCNameCharacterSet intoString:nil];
        }
        
        if ([elements count]>=2) {
            if ([elements containsObject:@"release"]) {
                [elements removeObject:@"release"];
                return [elements objectAtIndex:0];
            }
            else if ([elements containsObject:@"free"]) {
                [elements removeObject:@"free"];
                return [elements objectAtIndex:1];
            }
            else{
                for (NSString *element in elements) {
                    if ([element rangeOfString:@"release" options:NSCaseInsensitiveSearch].location==NSNotFound) {
                        return element;
                    }
                }
            }
        }
        
    }
    else{
        NSScanner *scaner = [NSScanner scannerWithString:self];
        if ([scaner scanString:@"self" intoString:nil]) {
            [scaner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
            if ([scaner scanString:@"." intoString:nil]) {
                [scaner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
                NSString *propertyName = nil;
                if ([scaner scanCharactersFromSet:OCNameCharacterSet intoString:&propertyName]) {
                    [scaner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
                    if ([scaner scanString:@"=" intoString:nil]) {
                        [scaner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
                        if ([scaner scanString:@"nil" intoString:NULL]||[scaner scanString:@"NULL" intoString:NULL]) {
                            return propertyName;
                        }
                    }
                }
            }
        }
    }
    return nil;
}

@end
