//
//  ZJPlayer.h
//  player
//
//  Created by 郜泽建 on 2017/12/5.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJPlayer : NSObject
-(instancetype)init;
-(void)playInitData:(NSURL*)url;
-(void)play;
-(void)pause;
@end
