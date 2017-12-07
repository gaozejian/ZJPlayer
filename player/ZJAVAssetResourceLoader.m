//
//  ZJAVAssetResourceLoader.m
//  player
//
//  Created by 郜泽建 on 2017/12/7.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ZJAVAssetResourceLoader.h"

@implementation ZJAVAssetResourceLoader

-(instancetype)init{
    if (self = [super init]) {
    
    }
    return self;
}
#pragma mark AVAssetResourceLoader代理方法
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    return YES;
}
@end
