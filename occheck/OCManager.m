//
//  OCManager.m
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "OCManager.h"
#import "OCFileScanner.h"
@implementation OCManager

- (id)initWithDirectory:(NSString*)directory{
    self = [super init];
    if (self) {
        classItems = [[NSMutableDictionary alloc] init];
        NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:directory error:nil];
        for (NSString *path in files) {
            if ([path hasPrefix:@"."]||!([path hasSuffix:@".h"]||[path hasSuffix:@".m"]||[path hasSuffix:@".mm"])) {
                continue;
            }
            path = [directory stringByAppendingPathComponent:path];
            OCFileScanner *scanner = [[OCFileScanner alloc] initWithFile:path];
            for (OCClassItem *item in [scanner ocitems]) {
                if ([item.name length]) {
                    OCClassItem *scannedItem = [classItems objectForKey:item.name];
                    if (scannedItem==nil) {
                        scannedItem = item;
                        [classItems setObject:scannedItem forKey:scannedItem.name];
                    }
                    else{
                        [scannedItem mergeWithOCClassItem:item];
                    }
                }
            }
            [scanner release];
        }
    }
    return self;
}

- (BOOL)checkError{
    BOOL ret = NO;
    for(OCClassItem *item in [classItems allValues]){
        if ([item checkError]) {
            ret = YES;
        }
    }
    return ret;
}

- (void)dealloc{
    [classItems release];
    [super dealloc];
}

@end
