//
//  SQPlayVideoVC.m
//  SQAVDemo
//
//  Created by tgjr-Hzz on 2017/8/10.
//  Copyright © 2017年 Hzz. All rights reserved.
//

#import "SQPlayVideoVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"
#import "UIViewExt.h"
#import "SQRecordEngine.h"
#import "SQRecordEncoder.h"
#import "SBPlayer.h"
#import "SQUpdateVideoVC.h"

@interface SQPlayVideoVC ()<SQRecordEngineDelegate>

@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (strong, nonatomic) SQRecordEngine         *recordEngine;
@property (nonatomic,strong) SBPlayer *player;
@property (nonatomic,strong) UIButton *updateButton;

@end

@implementation SQPlayVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *url1 = [NSURL fileURLWithPath:_videoPath];
    self.player = [[SBPlayer alloc]initWithUrl:url1];
    //设置标题
//    [self.player setTitle:@"这是一个标题"];
    //设置播放器背景颜色
    self.player.backgroundColor = [UIColor blackColor];
    //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
    self.player.mode = SBLayerVideoGravityResizeAspectFill;
    //添加播放器到视图
    [self.view addSubview:self.player];
    //约束，也可以使用Frame
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(@(self.view.frame.size.height-49));
    }];
    
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

    
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateButton.frame = CGRectMake(0, 10, 40, 35);
    [updateButton setTitle:@"上传" forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    updateButton.backgroundColor = [UIColor blueColor];
    [updateButton addTarget:self action:@selector(updateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateButton];
    self.updateButton = updateButton;
    [self.updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.player.mas_bottom);
        make.height.mas_equalTo(@49);
    }];

}

- (void) backButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateButtonAction
{
    SQUpdateVideoVC *vc = [[SQUpdateVideoVC alloc] init];
    vc.videoPath = _recordEngine.videoPath;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
