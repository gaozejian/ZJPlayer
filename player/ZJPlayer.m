//
//  ZJPlayer.m
//  player
//
//  Created by 郜泽建 on 2017/12/5.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ZJPlayer.h"
#import <AVFoundation/AVFoundation.h>
@interface ZJPlayer()
@property(nonatomic,strong)AVPlayer * player;
@end
@implementation ZJPlayer
-(instancetype)init{
    if (self = [super init]) {
        [self initPlayer];
    }
    return self;
}

-(void)initPlayer{
    self.player = [[AVPlayer alloc]initWithPlayerItem:nil];
    self.player.automaticallyWaitsToMinimizeStalling = NO;
}
-(void)playInitData:(NSURL*)url{
    AVPlayerItem  *itme = [[AVPlayerItem alloc]initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:itme];
}
-(void)play{
    [self.player play];
}
-(void)pause{
    [self.player pause];
}
@end
