//
//  ZJPlayer.m
//  player
//
//  Created by 郜泽建 on 2017/12/5.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ZJPlayer.h"
#import <AVFoundation/AVFoundation.h>
@interface ZJPlayer(){
    id _playTimeObserver;
}
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
    AVURLAsset * asset = [[AVURLAsset alloc]initWithURL:url options:nil];
    AVPlayerItem  *itme = [[AVPlayerItem alloc]initWithAsset:asset];
   // self.itme = itme;
    [self addObserver:itme];
    [self.player replaceCurrentItemWithPlayerItem:itme];
}
-(void)play{
    [self.player play];
}
-(void)pause{
    [self.player pause];
}
-(void)addObserver:(AVPlayerItem *)itme{
    [itme addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [itme addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //AVPlayerItemNewErrorLogEntryNotification
    [self monitoringPlayback:itme];
}
-(void)removeObserver:(AVPlayerItem *)itme{
    [itme removeObserver:self forKeyPath:@"status"];
     [itme removeObserver:self forKeyPath:@"error"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object

                        change:(NSDictionary *)change context:(void *)context {
    
    if (object ==self.self.player.currentItem && [keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        if (status ==AVPlayerStatusFailed) {
            NSLog(@"====AVPlayerStatusFailed");
        }else if (status ==AVPlayerStatusReadyToPlay){
             NSLog(@"====AVPlayerStatusReadyToPlay");
        }else{
             NSLog(@"====AVPlayerStatusUnknown");
        }
       // NSLog(@"====%ld",status);
    }else if (object ==self.player.currentItem && [keyPath isEqualToString:@"error"]){
        NSError * error = [change objectForKey:NSKeyValueChangeNewKey];
        NSLog(@"===%@",error);
    }
    
}

- (void)monitoringPlayback:(AVPlayerItem *)item {
   // __weak typeof(self)WeakSelf = self;
    
    // 播放进度, 每秒执行30次， CMTime 为30分之一秒
    _playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        double floatcurrent = CMTimeGetSeconds(time);
        
        //总时间
        double floattotal = CMTimeGetSeconds(item.duration);
        
        NSLog(@"%f  %f",floatcurrent,floattotal);
    }];
}
-(void)playbackFinished:(NSNotification*)Notification{
    NSLog(@"结束");
}
@end
