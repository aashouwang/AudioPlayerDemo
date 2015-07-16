//
//  ThirdViewController.m
//  AudioPlayerDemo
//
//  Created by tieshan on 15/7/16.
//  Copyright (c) 2015年 TangTieshan. All rights reserved.
//

#import "ThirdViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage+ColorToImage.h"

@interface ThirdViewController ()<MPMediaPickerControllerDelegate>
@property (nonatomic, retain)MPMediaPickerController * mediaPicker;         //媒体选择控制器
@property (nonatomic, retain)MPMusicPlayerController * musicPlayer;         //音乐播放器
@property (nonatomic, retain)UILabel * songTitleLabel;
@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.musicPlayer endGeneratingPlaybackNotifications];
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MPMusicPlayerController *)musicPlayer
{
    if (!_musicPlayer) {
        //applicationMusicPlayer        获取应用播放器，注意此类播放器无法在后台播放
        //systemMusicPlayer             获取系统播放器，支持后台播放
        _musicPlayer = [MPMusicPlayerController systemMusicPlayer];
        [_musicPlayer beginGeneratingPlaybackNotifications];    //开启通知，否则监控不到MPMusicPlayerController的通知
//        _musicPlayer.repeatMode = MPMusicRepeatModeAll;
        [self addNotification];                                 //添加通知
        //如果不使用MPMediaPickerController可以使用如下方法获得音乐库媒体队列
//        [_musicPlayer setQueueWithItemCollection:[self getLocalMediaItemCollection]];
    }
    return _musicPlayer;
}

- (MPMediaPickerController *)mediaPicker
{
    if (!_mediaPicker) {
        //初始化媒体选择器，这里设置媒体类型为音乐，其实这里也可以选择视频、广播等
        _mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        _mediaPicker.allowsPickingMultipleItems = YES;      //允许多选
        _mediaPicker.prompt = @"请选择要播放的音乐";
        _mediaPicker.delegate = self;                       //设置选择器代理
        
    }
    return _mediaPicker;
}

/**
 *	@brief	取得媒体队列
 *
 *	@return	媒体队列
 */
- (MPMediaQuery *)getLocalMediaQuery
{
    MPMediaQuery * mediaQueue = [MPMediaQuery songsQuery];
    for (MPMediaItem * item in mediaQueue.items) {
        NSLog(@"标题：%@, %@", item.title, item.albumTitle);
    }
    return mediaQueue;
}

/**
 *	@brief	获取媒体集合
 *
 *	@return	媒体集合
 */
- (MPMediaItemCollection *)getLocalMediaItemCollection
{
    MPMediaQuery * mediaQueue = [MPMediaQuery songsQuery];
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    for (MPMediaItem * item in mediaQueue.items) {
        [array addObject:item];
        NSLog(@"标题：%@, %@", item.title, item.albumTitle);
    }
    MPMediaItemCollection * mediaItemCollection = [[MPMediaItemCollection alloc] initWithItems:array];
    NSLog(@"array = %@", array);
    [array release];
    
    return [mediaItemCollection autorelease];
}

#pragma mark - 
#pragma mark - Private Action
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChange:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.musicPlayer];
}

- (void)addView
{
    //设置背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加背景图片
    UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = [UIImage imageNamed:@"1.jpg"];
    [self.view addSubview:bgImageView];
    
    UIView * topBgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    topBgview.backgroundColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:0.8f];
    [self.view addSubview:topBgview];
    [topBgview release];
    
    //添加标题
    _songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, topBgview.frame.size.width, 44)];
    _songTitleLabel.textColor = [UIColor whiteColor];
    _songTitleLabel.textAlignment = NSTextAlignmentCenter;
    _songTitleLabel.backgroundColor = [UIColor clearColor];
    _songTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    [topBgview addSubview:_songTitleLabel];
    [_songTitleLabel release];
    
    //返回按钮
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, 20, 30, 30);
    backButton.center = CGPointMake(backButton.center.x, _songTitleLabel.center.y);
    [backButton setTitle:@"<<" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [topBgview addSubview:backButton];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 80, 280, 35);
    button.center = CGPointMake(self.view.frame.size.width * 0.5f, button.center.y);
    button.layer.cornerRadius = button.frame.size.height * 0.5f;
    button.layer.masksToBounds = YES;
    [button setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [button setTitle:@"选择歌曲" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton * secButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secButton.frame = CGRectMake(20, 140, 280, 35);
    secButton.center = CGPointMake(self.view.frame.size.width * 0.5f, secButton.center.y);
    secButton.layer.cornerRadius = button.frame.size.height * 0.5f;
    secButton.layer.masksToBounds = YES;
    [secButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [secButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [secButton setTitle:@"播放" forState:UIControlStateNormal];
    [secButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:secButton];
    
    UIButton * thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(20, 200, 280, 35);
    thirdButton.center = CGPointMake(self.view.frame.size.width * 0.5f, thirdButton.center.y);
    thirdButton.layer.cornerRadius = button.frame.size.height * 0.5f;
    thirdButton.layer.masksToBounds = YES;
    [thirdButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [thirdButton setTitle:@"暂停" forState:UIControlStateNormal];
    [thirdButton addTarget:self action:@selector(pauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:thirdButton];
    
    UIButton * fourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthButton.frame = CGRectMake(20, 260, 280, 35);
    fourthButton.center = CGPointMake(self.view.frame.size.width * 0.5f, fourthButton.center.y);
    fourthButton.layer.cornerRadius = button.frame.size.height * 0.5f;
    fourthButton.layer.masksToBounds = YES;
    [fourthButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [fourthButton setTitle:@"上一曲" forState:UIControlStateNormal];
    [fourthButton addTarget:self action:@selector(previousButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fourthButton];
    
    UIButton * fifthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fifthButton.frame = CGRectMake(20, 320, 280, 35);
    fifthButton.center = CGPointMake(self.view.frame.size.width * 0.5f, fifthButton.center.y);
    fifthButton.layer.cornerRadius = button.frame.size.height * 0.5f;
    fifthButton.layer.masksToBounds = YES;
    [fifthButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [fifthButton setTitle:@"下一曲" forState:UIControlStateNormal];
    [fifthButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fifthButton];
    
    UIButton * sixthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sixthButton.frame = CGRectMake(20, 380, 280, 35);
    sixthButton.center = CGPointMake(self.view.frame.size.width * 0.5f, sixthButton.center.y);
    sixthButton.layer.cornerRadius = button.frame.size.height * 0.5f;
    sixthButton.layer.masksToBounds = YES;
    [sixthButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [sixthButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [sixthButton setTitle:@"停止" forState:UIControlStateNormal];
    [sixthButton addTarget:self action:@selector(stopButtonCicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sixthButton];
    
    UISlider * musicSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 440, 280, 20)];
    musicSlider.center = CGPointMake(sixthButton.center.x, musicSlider.center.y);
    musicSlider.minimumValue = 0;
    musicSlider.maximumValue = 100;
    musicSlider.value = 12;
//    musicSlider.minimumTrackTintColor = [UIColor redColor];
//    musicSlider.maximumTrackTintColor = [UIColor yellowColor];
//    musicSlider.thumbTintColor = [UIColor greenColor];
    [musicSlider setMinimumTrackImage:[UIImage createImageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
    [musicSlider setMaximumTrackImage:[UIImage createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [musicSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    [musicSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateHighlighted];
    [self.view addSubview:musicSlider];
    [musicSlider release];
}

#pragma mark -
#pragma mark - MPMediaPickerController代理方法
//选择完成
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    for (MPMediaItem * mediaItem in mediaItemCollection.items) {
        NSLog(@"标题：%@,表演者：%@, 专辑:%@", mediaItem.title, mediaItem.artist, mediaItem.albumTitle);
        
    }
//    MPMediaItem * mediaItem = [mediaItemCollection.items firstObject];      //第一个播放音乐
    
    [self.musicPlayer setQueueWithItemCollection:mediaItemCollection];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//取消选择
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - 通知
- (void)playbackStateChange:(NSNotification *)notify
{
    NSLog(@"self.musicPlayer.playbackState = %ld", (long)self.musicPlayer.playbackState);
    switch (self.musicPlayer.playbackState) {
        case MPMusicPlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMusicPlaybackStatePaused:
            NSLog(@"播放暂定...");
            break;
        case MPMusicPlaybackStateStopped:
            NSLog(@"播放停止...");
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - 按钮点击事件
- (void)selectButtonClicked:(UIButton *)sender
{
    [self presentViewController:self.mediaPicker animated:YES completion:nil];
}

- (void)playButtonClicked:(UIButton *)playButton
{
    [self.musicPlayer play];
}

- (void)pauseButtonClicked:(UIButton *)pauseButton
{
    [self.musicPlayer pause];
}

- (void)stopButtonCicked:(UIButton *)stopButton
{
    [self.musicPlayer stop];
}

- (void)nextButtonClicked:(UIButton *)nextButton
{
    [self.musicPlayer skipToNextItem];
}

- (void)previousButtonClicked:(UIButton *)prevButton
{
    [self.musicPlayer skipToPreviousItem];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
