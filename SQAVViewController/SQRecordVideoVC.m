
//
//  SQRecordVideoVC.m
//  SQAVDemo
//
//  Created by tgjr-Hzz on 2017/8/8.
//  Copyright © 2017年 Hzz. All rights reserved.
//

#import "SQRecordVideoVC.h"
#import "SQRecordEngine.h"
#import "SQRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"
#import "UIViewExt.h"
#import "SQRecordProgressView/SQRecordProgressView.h"
#import "SQPlayVideoVC.h"

typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    VideoRecord = 0,
    VideoLocation,
};

@interface SQRecordVideoVC () <SQRecordEngineDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *flashLightBT;
@property (weak, nonatomic) IBOutlet UIButton *changeCameraBT;
@property (weak, nonatomic) IBOutlet UIButton *recordNextBT;
@property (weak, nonatomic) IBOutlet UIButton *recordBt;
@property (weak, nonatomic) IBOutlet UIButton *locationVideoBT;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTop;
@property (weak, nonatomic) IBOutlet SQRecordProgressView *progressView;
@property (strong, nonatomic) SQRecordEngine         *recordEngine;
@property (assign, nonatomic) BOOL                    allowRecord;//允许录制
@property (assign, nonatomic) UploadVieoStyle         videoStyle;//视频的类型
@property (strong, nonatomic) UIImagePickerController *moviePicker;//视频选择器
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;

//UI
//@property (strong, nonatomic) UIView *playbgView;


@end

@implementation SQRecordVideoVC

- (void)dealloc {
    _recordEngine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:[_playerVC moviePlayer]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recordEngine shutdown];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
    [self makeView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.allowRecord = YES;
   
}

#pragma mark - ****************创建视图
- (void)makeView
{
    
    UIView *navBgView = [[UIView alloc] init];
    navBgView.backgroundColor = [UIColor redColor];
    navBgView.frame = CGRectMake(0, 20, self.view.frame.size.width, 55);
    [self.view addSubview:navBgView];
    
    //取消录像
    UIImage *backImage = [UIImage imageNamed:@"closeVideo"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:backImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(15, 10, 40, 35);
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [navBgView addSubview:backButton];
    
    //闪光灯
    UIButton *flashLightBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashLightBT setImage:[UIImage imageNamed:@"flashlightOff"] forState:UIControlStateNormal];
    flashLightBT.frame = CGRectMake(backButton.right+80, 10, 40, 35);
    [flashLightBT addTarget:self action:@selector(flashLightAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBgView addSubview:flashLightBT];
    self.flashLightBT = flashLightBT;

    //变换摄像头
    UIButton *changeCameraBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeCameraBT setImage:[UIImage imageNamed:@"changeCamera"] forState:UIControlStateNormal];
    changeCameraBT.frame = CGRectMake(flashLightBT.right+80, 10, 40, 35);
    [changeCameraBT addTarget:self action:@selector(changeCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBgView addSubview:changeCameraBT];
    self.changeCameraBT = changeCameraBT;
    
    //下一步
    UIButton *recordNextBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordNextBT setImage:[UIImage imageNamed:@"videoNext"] forState:UIControlStateNormal];
    recordNextBT.frame = CGRectMake(changeCameraBT.right+80, 10, 40, 35);
    [recordNextBT addTarget:self action:@selector(recordNextAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBgView addSubview:recordNextBT];
    self.recordNextBT = recordNextBT;

    
    UIView *playbgView = [[UIView alloc] init];
    playbgView.backgroundColor = [UIColor clearColor];
    playbgView.frame = CGRectMake(0, self.view.frame.size.height-245, self.view.frame.size.width, 245);
//    self.playbgView = playbgView;
    [self.view addSubview:playbgView];
    
    UIButton *recordBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBt setImage:[UIImage imageNamed:@"videoRecord"] forState:UIControlStateNormal];
    recordBt.frame = CGRectMake((self.view.frame.size.width-80)/2, playbgView.height-120, 80, 80);
    [recordBt addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    [playbgView addSubview:recordBt];
    self.recordBt = recordBt;

    SQRecordProgressView *progressView = [[SQRecordProgressView alloc] init];
    progressView.frame = CGRectMake(0, self.recordBt.top-10, self.view.frame.size.width, 5);
    progressView.progress = 0;
    progressView.progressBgColor = [UIColor orangeColor];
    progressView.progressColor = [UIColor redColor];
    progressView.loadProgress = self.view.frame.size.width;
    progressView.loadProgressColor = [UIColor yellowColor];
    [playbgView addSubview:progressView];
    self.progressView = progressView;
    
    UIButton *locationVideoBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationVideoBT setTitle:@"本地视频" forState:UIControlStateNormal];
    locationVideoBT.frame = CGRectMake((self.view.frame.size.width-80)/2+100, playbgView.height-120, 80, 80);
    [locationVideoBT addTarget:self action:@selector(locationVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    [playbgView addSubview:locationVideoBT];
    self.locationVideoBT = locationVideoBT;

    
    [self.view updateConstraintsIfNeeded];
}

- (void) backButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - **************** 跳转布局
- (void)updateViewConstraints
{
    [super updateViewConstraints];
   
//    [self.playbgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.view.frame.size.height-99);
//        make.right.equalTo(self.view);
//        make.height.mas_equalTo(@146);
//        make.width.mas_equalTo(@(self.view.frame.size.width));
//    }];

}

//- (UIView *)playbgView
//{
//    if (_playbgView == nil) {
//        _playbgView = [[UIView alloc] init];
//        _playbgView.backgroundColor = [UIColor redColor];
//    }
//    return _playbgView;
//}


//根据状态调整view的展示情况
- (void)adjustViewFrame {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.recordBt.selected) {
            self.topViewTop.constant = -64;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }else {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            self.topViewTop.constant = 0;
        }
        if (self.videoStyle == VideoRecord) {
            self.locationVideoBT.alpha = 0;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - set、get方法
- (SQRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[SQRecordEngine alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

- (UIImagePickerController *)moviePicker {
    if (_moviePicker == nil) {
        _moviePicker = [[UIImagePickerController alloc] init];
        _moviePicker.delegate = self;
        _moviePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _moviePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    return _moviePicker;
}

#pragma mark - Apple相册选择代理
//选择了某个照片的回调函数/代理回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        //获取视频的名称
        NSString * videoPath=[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
        NSRange range =[videoPath rangeOfString:@"trim."];//匹配得到的下标
        NSString *content=[videoPath substringFromIndex:range.location+5];
        //视频的后缀
        NSRange rangeSuffix=[content rangeOfString:@"."];
        NSString * suffixName=[content substringFromIndex:rangeSuffix.location+1];
        //如果视频是mov格式的则转为MP4的
        if ([suffixName isEqualToString:@"MOV"]) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            __weak typeof(self) weakSelf = self;
            [self.recordEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
                [weakSelf.moviePicker dismissViewControllerAnimated:YES completion:^{
//                    weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
//                    [[weakSelf.playerVC moviePlayer] prepareToPlay];
//                    
//                    [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
//                    [[weakSelf.playerVC moviePlayer] play];
                        SQPlayVideoVC *vc = [[SQPlayVideoVC alloc] init];
                        vc.videoPath = _recordEngine.videoPath;
                        [self presentViewController:vc animated:YES completion:nil];
                        

                }];
            }];
        }
    }
}

#pragma mark - WCLRecordEngineDelegate
- (void)recordProgress:(CGFloat)progress {
    if (progress >= 1) {
        [self recordAction:self.recordBt];
        self.allowRecord = NO;
    }
    self.progressView.progress = progress;
}

#pragma mark - 各种点击事件
//返回点击事件
- (void)dismissAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//开关闪光灯
- (void)flashLightAction:(id)sender {
    if (self.changeCameraBT.selected == NO) {
        self.flashLightBT.selected = !self.flashLightBT.selected;
        if (self.flashLightBT.selected == YES) {
            [self.recordEngine openFlashLight];
            [self.flashLightBT setImage:[UIImage imageNamed:@"flashlightOn"] forState:UIControlStateNormal];
        }else {
            [self.recordEngine closeFlashLight];
            [self.flashLightBT setImage:[UIImage imageNamed:@"flashlightOff"] forState:UIControlStateNormal];
        }
    }
}

//切换前后摄像头
- (void)changeCameraAction:(id)sender {
    self.changeCameraBT.selected = !self.changeCameraBT.selected;
    if (self.changeCameraBT.selected == YES) {
        //前置摄像头
        [self.recordEngine closeFlashLight];
        self.flashLightBT.selected = NO;
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}

//录制下一步点击事件
- (void)recordNextAction:(id)sender {
    if (_recordEngine.videoPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
//            weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
//            [[weakSelf.playerVC moviePlayer] prepareToPlay];
//            
//            [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
//            [[weakSelf.playerVC moviePlayer] play];
            
            SQPlayVideoVC *vc = [[SQPlayVideoVC alloc] init];
            vc.videoPath = _recordEngine.videoPath;
            [self presentViewController:vc animated:YES completion:nil];

        }];
    }else {
        NSLog(@"请先录制视频~");
    }
}

//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerVC dismissMoviePlayerViewControllerAnimated];
    self.playerVC = nil;
}

//本地视频点击视频
- (void)locationVideoAction:(id)sender {
    self.videoStyle = VideoLocation;
    [self.recordEngine shutdown];
    [self presentViewController:self.moviePicker animated:YES completion:nil];
}

//开始和暂停录制事件
- (void)recordAction:(UIButton *)sender {
    if (self.allowRecord) {
        self.videoStyle = VideoRecord;
        self.recordBt.selected = !self.recordBt.selected;
        if (self.recordBt.selected) {
            if (self.recordEngine.isCapturing) {
                [self.recordEngine resumeCapture];
                [self.recordBt setImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateNormal];
            }else {
                [self.recordEngine startCapture];
                [self.recordBt setImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateNormal];
            }
        }else {
            [self.recordEngine pauseCapture];
            [self.recordBt setImage:[UIImage imageNamed:@"videoRecord"] forState:UIControlStateNormal];
        }
        [self adjustViewFrame];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
