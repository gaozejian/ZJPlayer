//
//  ZJPlayerManger.h
//  player
//
//  Created by 郜泽建 on 2017/12/5.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJPlayerManger : NSObject
+(instancetype)sharePlayerManger;

-(void)playData:(NSURL*)url;
-(void)play;
-(void)pause;
// 外部调用将产生编译错误
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharePlayerManger instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharePlayerManger instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharePlayerManger instead")));
+(instancetype)allocWithZone __attribute__((unavailable("new not available, call sharePlayerManger instead")));
@end
