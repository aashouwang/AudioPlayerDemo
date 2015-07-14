//
//  SecViewController.m
//  AudioPlayerDemo
//
//  Created by TangTieshan on 15/7/14.
//  Copyright (c) 2015年 TangTieshan. All rights reserved.
//

#import "SecViewController.h"


#define kMusicFile          @"陈奕迅 - 红玫瑰.mp3"
#define kMusicSinger        @"陈奕迅"
#define KMusicTitle         @"红玫瑰"

@interface SecViewController ()
@property (nonatomic, retain)UILabel * songTitleLabel;
@property (nonatomic, retain)UILabel * singerLabel;
@property (nonatomic, retain)UIProgressView * playProgress;
@property (nonatomic, retain)UIButton * playOrPause;
@property (nonatomic, retain)AVAudioPlayer * audioPlayer;
@property (nonatomic, retain)NSTimer * timer;
@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addView];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark - Private Action
- (void)addView
{
    self.view.backgroundColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:0.8f];
    
    //背景图片
    UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = [UIImage imageNamed:@"1.jpg"];
    [self.view addSubview:bgImageView];
    [bgImageView release];
    
    //标题
    UIView * titleBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    titleBgView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:titleBgView];
    
    //添加标题
    _songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, titleBgView.frame.size.width, 44)];
    _songTitleLabel.textColor = [UIColor whiteColor];
    _songTitleLabel.textAlignment = NSTextAlignmentCenter;
    _songTitleLabel.backgroundColor = [UIColor clearColor];
    _songTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    [titleBgView addSubview:_songTitleLabel];
    [_songTitleLabel release];
    
        //返回按钮
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, 20, 30, 30);
    backButton.center = CGPointMake(backButton.center.x, _songTitleLabel.center.y);
    [backButton setTitle:@"<<" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [titleBgView addSubview:backButton];
    
    
    //底部背景
    UIView * bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150)];
    bottomBgView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:bottomBgView];
    [bottomBgView release];
    
    //添加演唱者名字
    _singerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, bottomBgView.frame.size.width - 20, 50)];
    _singerLabel.backgroundColor = [UIColor clearColor];
    _singerLabel.textColor = [UIColor whiteColor];
    _singerLabel.textAlignment = NSTextAlignmentLeft;
    _singerLabel.font = [UIFont systemFontOfSize:18];
    [bottomBgView addSubview:_singerLabel];
    [_singerLabel release];
    
    //添加进度条
    _playProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 60, bottomBgView.frame.size.width, 10)];
    _playProgress.progress = 0;
    _playProgress.progressTintColor = [UIColor blueColor];
    _playProgress.trackTintColor = [UIColor whiteColor];
    [bottomBgView addSubview:_playProgress];
    [_playProgress release];
    
    //暂定和播放按钮
    _playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
    _playOrPause.frame = CGRectMake(0, 75, 60, 60);
    _playOrPause.center = CGPointMake(bottomBgView.frame.size.width * 0.5f, _playOrPause.center.y);
    [_playOrPause setBackgroundImage:[UIImage imageNamed:@"efun_pf_EX_normal"] forState:UIControlStateNormal];
    [_playOrPause setBackgroundImage:[UIImage imageNamed:@"efun_pf_goon_normal"] forState:UIControlStateSelected];
    [_playOrPause addTarget:self action:@selector(playOrPauseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [bottomBgView addSubview:_playOrPause];
}

- (void)setupUI
{
    self.songTitleLabel.text = KMusicTitle;
    self.singerLabel.text = kMusicSinger;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
}

//创建播放音频
- (AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSString * urlStr = [[NSBundle mainBundle] pathForResource:kMusicFile ofType:Nil];
        NSURL * url = [NSURL fileURLWithPath:urlStr];
        
        NSError * error = nil;
        //初始化播放器，注意这里的url参数智能是文件路径，不支持HTTP Url
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        
        _audioPlayer.numberOfLoops = 0;         //设置为0不循环
        
        _audioPlayer.delegate = self;
        
        [_audioPlayer prepareToPlay];           //加载音频文件到缓存
        if (error) {
            NSLog(@"初始化播放器过程发生错误，错误信息：%@", error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  更新播放进度
 */
-(void)updateProgress{
    float progress= self.audioPlayer.currentTime /self.audioPlayer.duration;
    [self.playProgress setProgress:progress animated:true];
}

- (void)play
{
    if (![self.audioPlayer isPlaying]) {
        NSLog(@"play");
        [self.audioPlayer play];
        self.timer.fireDate = [NSDate distantPast];
    }
}

- (void)pause
{
    if ([self.audioPlayer isPlaying]) {
        NSLog(@"pause");
        [self.audioPlayer pause];
        self.timer.fireDate = [NSDate distantFuture];
    }
}

#pragma mark -
#pragma mark - UIButton Target Action
- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)playOrPauseButtonClicked
{
    if (!_playOrPause.selected) {
        [self play];
    }
    else
    {
        [self pause];
    }
    _playOrPause.selected = !_playOrPause.selected;
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
    [self playOrPauseButtonClicked];
}

@end
