//
//  VideoViewController.h
//  PiptureFoundations
//
//  Created by  on 24.10.11.
//  Copyright 2011 Thumbtack Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>


@interface VideoViewController : UIViewController
{
    @private 
    MPMoviePlayerController* player;
    NSTimer* playbackTimer;
    UIView *_playbackControls;
}

@property (nonatomic, retain) IBOutlet UIView *playbackControls;
@property(nonatomic,retain) IBOutlet UIButton* playButton;
@property(nonatomic,retain) IBOutlet UIButton* pauseButton;
@property(nonatomic,retain) IBOutlet UIView* videoContainer;
@property(nonatomic,retain) IBOutlet UILabel* subtitlesLabel;


- (IBAction)playClick:(id)sender;
- (IBAction)pauseClick:(id)sender;

- (void)playbackStateChangedCallback:(NSNotification*)aNotification; 
- (void)playbackTimerCallback:(NSTimer*)theTimer;
- (void)renderSubtitles;


@end
