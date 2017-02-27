//
//  TestViewController.m
//  ReplayKit
//
//  Created by steve on 2017/2/24.
//  Copyright © 2017年 liuguojun. All rights reserved.
//

#import "TestViewController.h"
#import <ReplayKit/ReplayKit.h>

@interface TestViewController () <RPBroadcastActivityViewControllerDelegate>
{
    UILabel *_timeLabel;
    UIButton *_liveButton;
    UIButton *_pauseButton;
    UIButton *_resumeButton;
    UIButton *_finishButton;
}
@property (nonatomic) RPBroadcastActivityViewController *broadcastAVC;
@property (nonatomic) RPBroadcastController *broadcastController;

@end

@implementation TestViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"直播";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _liveButton.frame = CGRectMake(self.view.frame.size.width/2 - 100/2, 50, 100, 30);
    _liveButton.layer.cornerRadius = 5.0;
    _liveButton.layer.borderWidth = 2.0;
    _liveButton.layer.borderColor = [[UIColor blackColor] CGColor];
    _liveButton.backgroundColor = [UIColor lightGrayColor];
    [_liveButton setTitle:@"直播" forState:UIControlStateNormal];
    [_liveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_liveButton addTarget:self action:@selector(live) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_liveButton];
    
    _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _pauseButton.frame = CGRectMake(self.view.frame.size.width/2 - 100/2, 100, 100, 30);
    _pauseButton.layer.cornerRadius = 5.0;
    _pauseButton.layer.borderWidth = 2.0;
    _pauseButton.layer.borderColor = [[UIColor blackColor] CGColor];
    _pauseButton.backgroundColor = [UIColor lightGrayColor];
    [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [_pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_pauseButton];
    
    _resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _resumeButton.frame = CGRectMake(self.view.frame.size.width/2 - 100/2, 150, 100, 30);
    _resumeButton.layer.cornerRadius = 5.0;
    _resumeButton.layer.borderWidth = 2.0;
    _resumeButton.layer.borderColor = [[UIColor blackColor] CGColor];
    _resumeButton.backgroundColor = [UIColor lightGrayColor];
    [_resumeButton setTitle:@"恢复" forState:UIControlStateNormal];
    [_resumeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_resumeButton addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_resumeButton];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = CGRectMake(self.view.frame.size.width/2 - 100/2, 200, 100, 30);
    _finishButton.layer.cornerRadius = 5.0;
    _finishButton.layer.borderWidth = 2.0;
    _finishButton.layer.borderColor = [[UIColor blackColor] CGColor];
    _finishButton.backgroundColor = [UIColor lightGrayColor];
    [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [_finishButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_finishButton];
    
    _liveButton.hidden = NO;
    _pauseButton.hidden = YES;
    _resumeButton.hidden = YES;
    _finishButton.hidden = YES;
    
    //显示时间（用于看录制结果时能知道时间）
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 50*2, 40)];
    _timeLabel.font = [UIFont boldSystemFontOfSize:20];
    _timeLabel.backgroundColor = [UIColor orangeColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.layer.cornerRadius = 4.0;
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init] ;
    [dateFormat setDateFormat: @"HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    _timeLabel.text =  dateString;
    _timeLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 100);
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    
    //计时器
    //更新时间
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(updateTimeString)
                                   userInfo:nil
                                    repeats:YES];
}

//更新显示的时间
- (void)updateTimeString {
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init] ;
    [dateFormat setDateFormat: @"HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    _timeLabel.text =  dateString;
}

//创建直播
- (void)live
{
    NSLog(@"点击了直播按钮");
    [_liveButton setTitle:@"直播中" forState:UIControlStateNormal];
    
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        
        self.broadcastAVC = broadcastActivityViewController;
        self.broadcastAVC.delegate = self;
        [self presentViewController:self.broadcastAVC animated:YES completion:nil];
        
        NSLog(@"弹出了直播平台选择框");
        
    }];
}

- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error
{
    [self.broadcastAVC dismissViewControllerAnimated:YES completion:nil];
    
    self.broadcastController = broadcastController;
    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"开始直播");
            
            _liveButton.hidden = YES;
            _pauseButton.hidden = NO;
            _resumeButton.hidden = YES;
            _finishButton.hidden = NO;
            
        } else {
            NSLog(@"startBroadcastWithHandler error: %@", error);
        }
    }];
}

//暂停直播
- (void)pause
{
    [self.broadcastController pauseBroadcast];
    
    _liveButton.hidden = YES;
    _pauseButton.hidden = YES;
    _resumeButton.hidden = NO;
    _finishButton.hidden = NO;
    
    NSLog(@"暂停直播");
}

//恢复直播
- (void)resume
{
    _liveButton.hidden = YES;
    _pauseButton.hidden = NO;
    _resumeButton.hidden = YES;
    _finishButton.hidden = NO;
    
    [self.broadcastController resumeBroadcast];
    
    NSLog(@"恢复直播");
}

//完成直播
- (void)finish
{
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"完成直播失败");
        }
        else
        {
            NSLog(@"完成直播成功");
            
            _liveButton.hidden = NO;
            _pauseButton.hidden = YES;
            _resumeButton.hidden = YES;
            _finishButton.hidden = YES;
        }
    }];
}

@end
