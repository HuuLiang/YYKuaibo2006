//
//  YYKPhotoUrlModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPhotoUrlModel.h"

@interface YYKPhotoUrlResponse : QBURLResponse
@property (nonatomic,retain) NSArray<YYKProgramUrl *> *programUrlList;
@end

@implementation YYKPhotoUrlResponse
SynthesizeContainerPropertyElementClassMethod(programUrlList, YYKProgramUrl)
@end

@implementation YYKPhotoUrlModel

+ (Class)responseClass {
    return [YYKPhotoUrlResponse class];
}

- (BOOL)fetchUrlListWithProgramId:(NSNumber *)programId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(QBCompletionHandler)handler
{
    @weakify(self);
    
    NSDictionary *params = @{@"programId":programId, @"urlPage":@(pageNo), @"urlPageSize":@(pageSize)};
    
    BOOL ret = [self requestURLPath:YYK_PHOTO_PROGRAM_URL
                     standbyURLPath:[YYKUtil getStandByUrlPathWithOriginalUrl:YYK_PHOTO_PROGRAM_URL params:@[programId,@(pageNo),@(pageSize)]]
                         withParams:params
                    responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage) {
                        @strongify(self);
                        if (!self) {
                            return ;
                        }
                        
                        NSArray *urls;
                        if (respStatus == QBURLResponseSuccess) {
                            YYKPhotoUrlResponse *resp = self.response;
                            urls = resp.programUrlList;
                            self->_fetchedUrls = urls;
                        }
                        
                        SafelyCallBlock(handler, respStatus == QBURLResponseSuccess, urls);
                     }];
    
        return ret;
}
@end
