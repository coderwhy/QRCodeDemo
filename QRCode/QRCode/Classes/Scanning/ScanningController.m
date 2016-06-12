//
//  ScanningController.m
//  QRCode
//
//  Created by xiaomage on 16/6/11.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "ScanningController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeManager.h"

@interface ScanningController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanViewBottomCons;
@property (nonatomic, strong) AVCaptureSession *session;
@property (weak, nonatomic) IBOutlet UIView *scanView;

@end

@implementation ScanningController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // 1.添加扫描动画
    [self addScanningAnimation];
    
    // 2.开始扫描信息
    [self startScanning];
}

#pragma mark - 添加扫描动画
- (void)addScanningAnimation {
    // 1.修改控件的约束
    self.scanViewBottomCons.constant = -240;
    
    // 2.执行动画
    [UIView animateWithDuration:2.0 animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - 开始扫描内容
- (void)startScanning {
    [[QRCodeManager shareInstance] startScanningQRCodeWithInView:self.view scanView:self.scanView resultCallback:^(NSArray *results) {
        NSLog(@"%@", results);
    }];
}



@end
