//
//  OCManager.h
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCManager : NSObject{
    NSMutableDictionary *classItems;
}

- (id)initWithDirectory:(NSString*)directory;
- (BOOL)checkError;
@end
