//
//  OCScanner.m
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "OCFileScanner.h"
#import "OCInterfceScanner.h"
#import "OCImplementationScanner.h"

@implementation OCFileScanner
@synthesize ocitems;
- (id)initWithFile:(NSString*)file{
    self = [super init];
    isHeaderFile = [file hasSuffix:@".h"];
    if (self) {
        @autoreleasepool {
            V1Log(@"Begin check file %@", file);
            ocitems = [[NSMutableArray alloc] initWithCapacity:5];
            NSString *codeText = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
            if (codeText!=nil) {
                NSMutableString *noCommentCode = [NSMutableString stringWithCapacity:[codeText length]];
                NSScanner *removeCommentScanner = [NSScanner scannerWithString:codeText];
                [removeCommentScanner setCaseSensitive:YES];
                removeCommentScanner.charactersToBeSkipped = nil;
                while (![removeCommentScanner isAtEnd]) {
                    NSString *scannedString = nil;
                    [removeCommentScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"/#"] intoString:&scannedString];
                    if (scannedString) {
                        [noCommentCode appendString:scannedString];
                    }
                    if ([removeCommentScanner scanString:@"//" intoString:nil]) {
                        [removeCommentScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
                        [removeCommentScanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
                    }
                    else if ([removeCommentScanner scanString:@"//ͬ" intoString:nil]) {
                        [removeCommentScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
                        [removeCommentScanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:nil];
                    }
                    else if([removeCommentScanner scanString:@"/*" intoString:nil]) {
                        [removeCommentScanner scanUpToString:@"*/" intoString:nil];
                        [removeCommentScanner scanString:@"*/" intoString:nil];
                    }
                    else if([removeCommentScanner scanString:@"\"" intoString:nil]) {
                        [removeCommentScanner scanUpToString:@"\"" intoString:nil];
                        while ([removeCommentScanner.string characterAtIndex:[removeCommentScanner scanLocation]-1]=='\\') {
                            [removeCommentScanner scanString:@"\"" intoString:nil];
                            if (![removeCommentScanner scanUpToString:@"\"" intoString:nil]) {
                                break;
                            }
                        }
                        [removeCommentScanner scanString:@"\"" intoString:nil];
                        [noCommentCode appendString:@"\"\""];
                    }
                    else if([removeCommentScanner scanString:@"#" intoString:nil]) {
                        [removeCommentScanner scanUpToString:@"\n" intoString:nil];
                        [removeCommentScanner scanString:@"\n" intoString:nil];
                    }
                    else{
                        if ([removeCommentScanner scanString:@"/" intoString:nil]) {
                            [noCommentCode appendString:@"/"];
                        }
                    }
                    
                }
                codeText = noCommentCode;
                
               
                if ([codeText length]) {
                    {
                        NSScanner *scaner = [NSScanner scannerWithString:codeText];
                        while (![scaner isAtEnd]) {
                            [scaner scanUpToString:@"@interface" intoString:nil];
                            NSString *interfaceCode = nil;
                            if ([scaner scanUpToString:@"@end" intoString:&interfaceCode]) {
                                OCInterfceScanner *interfaceScan = [[OCInterfceScanner alloc] initWithCodeText:[interfaceCode stringByAppendingString:@"\n@end\n"]];
                                if([interfaceScan.scanItem.name length]) [ocitems addObject:interfaceScan.scanItem];
                                [interfaceScan release];
                            }
                        }
                    }
                    if(!isHeaderFile){
                        NSScanner *scaner = [NSScanner scannerWithString:codeText];
                        while (![scaner isAtEnd]) {
                            [scaner scanUpToString:@"@implementation" intoString:nil];
                            NSString *interfaceCode = nil;
                            if ([scaner scanUpToString:@"@end" intoString:&interfaceCode]) {
                                OCImplementationScanner *implementScan = [[OCImplementationScanner alloc] initWithCodeText:[interfaceCode stringByAppendingString:@"\n@end\n"]];
                                if([implementScan.scanItem.name length]) [ocitems addObject:implementScan.scanItem];
                                [implementScan release];
                            }
                        }
                    }
                }
            }
        }
    }
    return self;
}

- (void)dealloc{
    [ocitems release];
    [super dealloc];
}
@end
