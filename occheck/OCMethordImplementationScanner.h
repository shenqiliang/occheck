//
//  OCMessageScanner.h
//  occheck
//
//  Created by 启亮 谌 on 12-3-1.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCMethordImplementationScanner : NSObject{
    BOOL isClassMessage;
}
- (id)initWithCodeText:(NSString*)codeText andClassItem:(OCClassItem*)item;
@end
