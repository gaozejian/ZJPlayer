//
//  ZJPlayerManger.m
//  player
//
//  Created by 郜泽建 on 2017/12/5.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ZJPlayerManger.h"
#import "ZJPlayer.h"
@interface ZJPlayerManger()
@property(nonatomic,strong)ZJPlayer * player;
@end
@implementation ZJPlayerManger
+(instancetype)sharePlayerManger{
    static ZJPlayerManger * manger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[super alloc]initInstace];
    });
    return manger;
}
-(instancetype)initInstace{
    [self initPlayer];
     return [super init];
}
-(void)initPlayer{
    self.player = [[ZJPlayer alloc]init];
}
-(void)playData:(NSURL*)url{
    
    [self.player playInitData:[self getSchemeVideoURL:url]];
}
-(void)play{
    [self.player play];
}
-(void)pause{
    [self.player pause];
}
- (NSURL *)getSchemeVideoURL:(NSURL *)url
{/**
  注解:需要将URL的scheme修改,并且在plist中 URLtypes 添加
  否则AVAssetResourceLoaderDelegate 代理方法不会执行 巨坑
  **/
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"ezfm";
    return [components URL];
   //return  url;
}
@end
