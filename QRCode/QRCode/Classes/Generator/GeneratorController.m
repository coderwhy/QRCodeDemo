//
//  GeneratorController.m
//  QRCode
//
//  Created by xiaomage on 16/6/11.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "GeneratorController.h"
#import <CoreImage/CoreImage.h>
#import "QRCodeManager.h"

@interface GeneratorController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@end

@implementation GeneratorController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 生成二维码
- (IBAction)generate {
    // 1.获取输入框中输入的内容
    NSString *inputMsg = self.textField.text;
    if (inputMsg.length == 0) {
        NSLog(@"请输入的内容");
        return;
    }
    
    // 2.生成二维码图片
    UIImage *fgImage = [UIImage imageNamed:@"erha"];
    self.qrCodeImageView.image = [[QRCodeManager shareInstance] generateQRCodeWithMsg:inputMsg fgImage:fgImage];
}

@end












