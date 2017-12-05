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
    [self.player playInitData:url];
}
-(void)play{
    [self.player play];
}
-(void)pause{
    [self.player pause];
}
@end
