//
//  ViewController.m
//  AudioPlayerDemo
//
//  Created by TangTieshan on 15/7/14.
//  Copyright (c) 2015年 TangTieshan. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ColorToImage.h"
#import <AVFoundation/AVFoundation.h>
#import "SecViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 60, 280, 35);
    button.center = CGPointMake(self.view.frame.size.width * 0.5f, button.center.y);
    button.layer.cornerRadius = button.frame.size.height * 0.5f;
    button.layer.masksToBounds = YES;
    [button setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [button setTitle:@"播放音效(不带震动)" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton * secButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secButton.frame = CGRectMake(20, 120, 280, 35);
    secButton.center = CGPointMake(self.view.frame.size.width * 0.5f, secButton.center.y);
    secButton.layer.cornerRadius = button.frame.size.height * 0.5f;
    secButton.layer.masksToBounds = YES;
    [secButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [secButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [secButton setTitle:@"播放音效(带震动)" forState:UIControlStateNormal];
    [secButton addTarget:self action:@selector(secButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:secButton];
    
    UIButton * thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(20, 180, 280, 35);
    thirdButton.center = CGPointMake(self.view.frame.size.width * 0.5f, thirdButton.center.y);
    thirdButton.layer.cornerRadius = button.frame.size.height * 0.5f;
    thirdButton.layer.masksToBounds = YES;
    [thirdButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.12 green:0.23 blue:0.23f alpha:1.0f]] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:0.16 green:0.27 blue:0.3f alpha:1.0f]] forState:UIControlStateHighlighted];
    [thirdButton setTitle:@"播放音频" forState:UIControlStateNormal];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:thirdButton];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UIButton Target Action
- (void)buttonClicked
{
    [self playSoundEffect:@"background.caf" andIsShake:NO];
}

- (void)secButtonClicked
{
    [self playSoundEffect:@"background.caf" andIsShake:YES];
}

- (void)thirdButtonClicked
{
    SecViewController * secVc = [[SecViewController alloc] init];
    [self presentViewController:secVc animated:YES completion:^{}];
    [secVc release];
}

#pragma mark -
#pragma mark - 音效播放完成的回调方法
void soundCompleteCallback(SystemSoundID soundID, void * clientData)
{
    NSLog(@"soundCompleteCallback");
}

#pragma mark -
#pragma mark - 播放音效
- (void)playSoundEffect:(NSString *)fileName andIsShake:(BOOL)isShake
{
    NSString * audioFile = [[NSBundle mainBundle] pathForResource:fileName ofType:Nil];
    
    NSURL * fileUrl = [NSURL URLWithString:audioFile];
    
    //获得系统声音ID
    SystemSoundID soundID = 0;
    
    /**
     *  inFileUrl:音频文件url
     *  outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    //如果需要播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    if (isShake) {      //播放音效带震动
        AudioServicesPlayAlertSound(soundID);
    }
    else                //播放音效不带震动
    {
        AudioServicesPlaySystemSound(soundID);
    }
}

@end
