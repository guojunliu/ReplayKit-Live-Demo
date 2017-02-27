//
//  ViewController.m
//  ReplayKit
//
//  Created by steve on 2017/2/24.
//  Copyright © 2017年 liuguojun. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>

static NSString *StartRecord = @"开始";
static NSString *StopRecord = @"结束";

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

#define AnimationDuration (0.3)


@interface ViewController () <RPPreviewViewControllerDelegate>
{
    
}
@property (nonatomic, strong)UIButton *btnStart;
@property (nonatomic, strong)UIButton *btnStop;
@property (nonatomic, strong)NSTimer *progressTimer;
@property (nonatomic, strong)UIProgressView *progressView;
@property (nonatomic, strong)UIActivityIndicatorView *activity;
@property (nonatomic, strong)UIView *tipView;
@property (nonatomic, strong)UILabel *lbTip;
@property (nonatomic, strong)UILabel *lbTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"苹果ReplayKit Demo";
    
    BOOL isVersionOk = [self isSystemVersionOk];
    
    if (!isVersionOk) {
        NSLog(@"系统版本需要是iOS9.0及以上才支持ReplayKit");
        return;
    }
    if (SIMULATOR) {
        [self showSimulatorWarning];
        return;
    }
    
    //创建按钮
    self.btnStart = [self createButtonWithTitle:StartRecord andCenter:CGPointMake(self.view.frame.size.width/4, 150)];
    [self.view addSubview:self.btnStart];
    
    self.btnStop = [self createButtonWithTitle:StopRecord andCenter:CGPointMake(self.view.frame.size.width/4*3, 150)];
    [self.view addSubview:self.btnStop];
    [self setButton:self.btnStop enabled:NO];
    
    //loading指示
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = 8.0f;
    view.center = CGPointMake(self.view.frame.size.width/2, 300);
    self.activity.center = CGPointMake(30, view.frame.size.height/2);
    [view addSubview:self.activity];
    [self.activity startAnimating];
    
    self.lbTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
    self.lbTip.font = [UIFont boldSystemFontOfSize:20];
    self.lbTip.backgroundColor = [UIColor clearColor];
    self.lbTip.textColor = [UIColor blackColor];
    self.lbTip.layer.cornerRadius = 4.0;
    self.lbTip.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.lbTip];
    
    self.tipView = view;
    [self hideTip];
    
    
    //显示时间（用于看录制结果时能知道时间）
    self.lbTime = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 50*2, 40)];
    self.lbTime.font = [UIFont boldSystemFontOfSize:20];
    self.lbTime.backgroundColor = [UIColor orangeColor];
    self.lbTime.textColor = [UIColor whiteColor];
    self.lbTime.layer.cornerRadius = 4.0;
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init] ;
    [dateFormat setDateFormat: @"HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    self.lbTime.text =  dateString;
    self.lbTime.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 100);
    self.lbTime.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lbTime];
    
    //进度条 （显示动画，不然看不出画面的变化）
    UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*0.8, 10)];
    progress.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 150);
    progress.progressViewStyle = UIProgressViewStyleDefault;
    progress.progress = 0.0;
    [self.view addSubview:progress];
    self.progressView = progress;
    
    //计时器
    //更新时间
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(updateTimeString)
                                   userInfo:nil
                                    repeats:YES];

    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

#pragma mark - UI控件
//显示 提示信息
- (void)showTipWithText:(NSString *)tip activity:(BOOL)activity{
    [self.activity startAnimating];
    self.lbTip.text = tip;
    self.tipView.hidden = NO;
    if (activity) {
        self.activity.hidden = NO;
        [self.activity startAnimating];
    } else {
        [self.activity stopAnimating];
        self.activity.hidden = YES;
    }
}
//隐藏 提示信息
- (void)hideTip {
    self.tipView.hidden = YES;
    [self.activity stopAnimating];
}

//创建按钮
- (UIButton *)createButtonWithTitle:(NSString *)title andCenter:(CGPoint)center {
    
    CGRect rect = CGRectMake(0, 0, 100, 30);
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    btn.layer.cornerRadius = 5.0;
    btn.layer.borderWidth = 2.0;
    btn.layer.borderColor = [[UIColor blackColor] CGColor];
    btn.backgroundColor = [UIColor lightGrayColor];
    btn.center = center;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBtnPressed:) forControlEvents:UIControlEventTouchDown];
    return btn;
    
}

//设置按钮是否可点击
- (void)setButton:(UIButton *)button enabled:(BOOL)enabled {
    if (enabled) {
        button.alpha = 1.0;
    } else {
        button.alpha = 0.2;
    }
    button.enabled = enabled;
}

//提示不支持模拟器
- (void)showSimulatorWarning {
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ReplayKit不支持模拟器" message:@"请使用真机运行这个Demo工程" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:actionCancel];
    [alert addAction:actionOK];
    
    [self presentViewController:alert animated:NO completion:nil];
}

//显示弹框提示
- (void)showAlert:(NSString *)title andMessage:(NSString *)message {
    if (!title) {
        title = @"";
    }
    if (!message) {
        message = @"";
    }
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:NO completion:nil];
}

//显示视频预览页面，animation=是否要动画显示
- (void)showVideoPreviewController:(RPPreviewViewController *)previewController withAnimation:(BOOL)animation {
    
    __weak ViewController *weakSelf = self;
    
    //UI需要放到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect rect = [UIScreen mainScreen].bounds;
        
        if (animation) {
            
            rect.origin.x += rect.size.width;
            previewController.view.frame = rect;
            rect.origin.x -= rect.size.width;
            [UIView animateWithDuration:AnimationDuration animations:^(){
                previewController.view.frame = rect;
            } completion:^(BOOL finished){
                
            }];
            
        } else {
            previewController.view.frame = rect;
        }
        
        [weakSelf.view addSubview:previewController.view];
        [weakSelf addChildViewController:previewController];
        
        
    });
    
}

//关闭视频预览页面，animation=是否要动画显示
- (void)hideVideoPreviewController:(RPPreviewViewController *)previewController withAnimation:(BOOL)animation {
    
    //UI需要放到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect rect = previewController.view.frame;
        
        if (animation) {
            
            rect.origin.x += rect.size.width;
            [UIView animateWithDuration:AnimationDuration animations:^(){
                previewController.view.frame = rect;
            } completion:^(BOOL finished){
                //移除页面
                [previewController.view removeFromSuperview];
                [previewController removeFromParentViewController];
            }];
            
        } else {
            //移除页面
            [previewController.view removeFromSuperview];
            [previewController removeFromParentViewController];
        }
    });
}

#pragma mark - 按钮 回调
//按钮事件
- (void)onBtnPressed:(UIButton *)sender {
    
    //点击效果
    sender.transform = CGAffineTransformMakeScale(0.8, 0.8);
    float duration = 0.3;
    [UIView animateWithDuration:duration
                     animations:^{
                         sender.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }completion:^(BOOL finish){
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              sender.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                          }completion:^(BOOL finish){ }];
                     }];
    
    NSString *function = sender.titleLabel.text;
    if ([function isEqualToString:StartRecord]) {
        [self startRecord];
    }
    else if ([function isEqualToString:StopRecord]) {
        [self stopRecord];
    }
}


- (void)startRecord {
    
    //    [self setButton:self.btnStart enabled:NO];
    
    NSLog(@"ReplayKit只支持真机录屏，支持游戏录屏，不支持录avplayer播放的视频");
    NSLog(@"检查机器和版本是否支持ReplayKit录制...");
    if ([[RPScreenRecorder sharedRecorder] isAvailable]) {
        NSLog(@"支持ReplayKit录制");
    } else {
        NSLog(@"!!不支持支持ReplayKit录制!!");
        return;
    }
    
    __weak ViewController *weakSelf = self;
    
    NSLog(@"%@ 录制", StartRecord);
    [self showTipWithText:@"录制初始化" activity:YES];
    
    
    [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError *error){
        NSLog(@"录制开始...");
        [weakSelf hideTip];
        if (error) {
            NSLog(@"错误信息 %@", error);
            [weakSelf showTipWithText:error.description activity:NO];
        } else {
            //其他处理
            [weakSelf setButton:self.btnStop enabled:YES];
            [weakSelf setButton:self.btnStart enabled:NO];
            
            [weakSelf showTipWithText:@"正在录制" activity:NO];
            //更新进度条
            weakSelf.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                                      target:self
                                                                    selector:@selector(changeProgressValue)
                                                                    userInfo:nil
                                                                     repeats:YES];
        }
    }];
    
}

- (void)stopRecord {
    NSLog(@"%@ 录制", StopRecord);
    
    [self setButton:self.btnStart enabled:YES];
    [self setButton:self.btnStop enabled:NO];
    
    __weak ViewController *weakSelf = self;
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController *previewViewController, NSError *  error){
        
        
        if (error) {
            NSLog(@"失败消息:%@", error);
            [weakSelf showTipWithText:error.description activity:NO];
        } else {
            
            [weakSelf showTipWithText:@"录制完成" activity:NO];
            
            //显示录制到的视频的预览页
            NSLog(@"显示预览页面");
            previewViewController.previewControllerDelegate = weakSelf;
            
            //去除计时器
            [weakSelf.progressTimer invalidate];
            weakSelf.progressTimer = nil;
            
            [self showVideoPreviewController:previewViewController withAnimation:YES];
        }
    }];
}

#pragma mark - 视频预览页面 回调
//关闭的回调
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    [self hideVideoPreviewController:previewController withAnimation:YES];
}

//选择了某些功能的回调（如分享和保存）
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes {
    
    __weak ViewController *weakSelf = self;
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.SaveToCameraRoll"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlert:@"保存成功" andMessage:@"已经保存到系统相册"];
        });
    }
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.CopyToPasteboard"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlert:@"复制成功" andMessage:@"已经复制到粘贴板"];
        });
    }
}

#pragma mark - 计时器 回调

//改变进度条的显示的进度
- (void)changeProgressValue {
    float progress = self.progressView.progress + 0.01;
    [self.progressView setProgress:progress animated:NO];
    if (progress >= 1.0) {
        self.progressView.progress = 0.0;
    }
}

//更新显示的时间
- (void)updateTimeString {
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init] ;
    [dateFormat setDateFormat: @"HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    self.lbTime.text =  dateString;
}

#pragma mark - 其他
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//判断对应系统版本是否支持ReplayKit
- (BOOL)isSystemVersionOk {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
        return NO;
    } else {
        return YES;
    }
}

@end
