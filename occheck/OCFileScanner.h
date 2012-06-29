//
//  OCScanner.h
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCClassItem.h"

@interface OCFileScanner : NSObject{
    BOOL isHeaderFile;
    NSMutableArray *ocitems;
    BOOL isObjcFile;
}

- (id)initWithFile:(NSString*)file;
@property(nonatomic,readonly) NSMutableArray *ocitems;
@end
