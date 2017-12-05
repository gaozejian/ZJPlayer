//
//  ViewController.m
//  player
//
//  Created by 郜泽建 on 2017/12/5.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZJPlayerManger.h"
@interface ViewController ()
@property (nonatomic,strong) AVPlayer * player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.player= [[AVPlayer alloc]initWithURL:[NSURL URLWithString:@"http://huayuncpv.china.com/WJSL_YFMD/WJSL_YFMD/54c6f9582a80fc1e70ff5575/B3158D1E60284DD585702F0ADD5B4246.mp3"]];
//    self.player.automaticallyWaitsToMinimizeStalling = NO;
 
    [ [ZJPlayerManger sharePlayerManger] playData:[NSURL URLWithString:@"http://huayuncpv.china.com/WJSL_YFMD/WJSL_YFMD/54c6f9582a80fc1e70ff5575/B3158D1E60284DD585702F0ADD5B4246.mp3"]];

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //[self.player play];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender {
    [[ZJPlayerManger sharePlayerManger] play];
}
- (IBAction)zanting:(id)sender {
    [[ZJPlayerManger sharePlayerManger] pause];
}

@end
