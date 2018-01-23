//
//  YYKAppSpreadModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//


//@interface YYKAppSpreadResponse : YYKURLResponse
//@property (nonatomic,retain) NSArray<YYKProgram *> *programList;
//@end

@interface YYKAppSpreadModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKChannel *fetchedSpreadChannel;

- (BOOL)fetchAppSpreadWithCompletionHandler:(YYKCompletionHandler)handler;

@end
