//
//  PlayerView.m
//  Pipture
//
//  Created by Vladimir Kubyshev on 05.12.11.
//  Copyright (c) 2011 Thumbtack Technology Inc. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    AVPlayerLayer * layer = (AVPlayerLayer *)[self layer];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [layer setPlayer:player];
}
@end
