//
//  YYKPhotoUrlModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <QBEncryptedURLRequest.h>

@interface YYKPhotoUrlModel : QBEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<YYKProgramUrl *> *fetchedUrls;

- (BOOL)fetchUrlListWithProgramId:(NSNumber *)programId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(QBCompletionHandler)handler;

@end
