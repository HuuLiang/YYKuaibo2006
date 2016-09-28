//
//  YYKPhotoBrowser.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface YYKPhotoBrowser : MWPhotoBrowser

@property (nonatomic,retain,readonly) YYKProgram *program;

- (instancetype)initWithPhotoProgram:(YYKProgram *)program;

@end
