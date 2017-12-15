//
//  ZJAVAssetResourceLoader.h
//  player
//
//  Created by 郜泽建 on 2017/12/7.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<AVFoundation/AVFoundation.h>
@protocol ZJDownloadTaskDelegate <NSObject>
-(void)downLoading:(NSString*)path;
@end
@interface
ZJAVAssetResourceLoader :NSObject<AVAssetResourceLoaderDelegate>
/*注释:<#name#> */
@property (nonatomic, weak) id <ZJDownloadTaskDelegate> delegate;
-(instancetype)init;
-(void)cancelTask;
@end
