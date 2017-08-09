//
//  SQRecordProgressView.h
//  SQAVDemo
//
//  Created by tgjr-Hzz on 2017/8/8.
//  Copyright © 2017年 Hzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQRecordProgressView : UIView

@property (assign, nonatomic) CGFloat progress;//当前进度
@property (strong, nonatomic) UIColor *progressBgColor;//进度条背景颜色
@property (strong, nonatomic) UIColor *progressColor;//进度条颜色
@property (assign, nonatomic) CGFloat loadProgress;//加载好的进度
@property (strong, nonatomic) UIColor *loadProgressColor;//已经加载好的进度颜色

@end
