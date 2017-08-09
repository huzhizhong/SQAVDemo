//
//  SQViewController.m
//  SQAVDemo
//
//  Created by tgjr-Hzz on 2017/8/8.
//  Copyright © 2017年 Hzz. All rights reserved.
//

#import "SQViewController.h"
#import "SQRecordVideoVC.h"

@interface SQViewController ()

@end

@implementation SQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(200, 300, 80, 40);
    [button setTitle:@"录制视频" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(videoClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void) videoClicked
{
    SQRecordVideoVC *vc = [[SQRecordVideoVC alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
