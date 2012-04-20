//
//  OCInterfceScanner.h
//  objcheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCClassItem.h"

@interface OCInterfceScanner : NSObject{
    OCClassItem *scanItem;
}

- (id)initWithCodeText:(NSString*)codeText;
@property(nonatomic, readonly) OCClassItem *scanItem;
@end
