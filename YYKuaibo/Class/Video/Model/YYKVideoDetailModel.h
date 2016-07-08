//
//  YYKVideoDetailModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

@interface YYKVideoDetail : YYKURLResponse
@property (nonatomic) NSArray<YYKProgram *> *hotProgramList;
@property (nonatomic) YYKProgram *program;
@property (nonatomic) NSArray<YYKProgram *> *spreadAppList;

@property (nonatomic) YYKProgram *spreadApp;
@end

@interface YYKVideoDetailModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKVideoDetail *fetchedDetail;

- (BOOL)fetchDetailOfVideo:(YYKProgram *)video
                 inChannel:(YYKChannel *)channel
     withCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
