//
//  DetectorController.m
//  QRCode
//
//  Created by xiaomage on 16/6/11.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "DetectorController.h"
#import <CoreImage/CoreImage.h>
#import "QRCodeManager.h"

@interface DetectorController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DetectorController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
     NSArray *resultArray = [[QRCodeManager shareInstance] detectorQRCodeWithQRCodeImage:self.imageView.image];
    
    for (NSString *resulStr in resultArray) {
        NSLog(@"%@", resulStr);
    }
}

#pragma mark - 选择照片
- (IBAction)selectPhotoPic:(UIButton *)sender {
    // 1.判断点的哪一个按钮
    UIImagePickerControllerSourceType sourceType = sender.tag == 1 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    
    // 2.判断数据源是否可用
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSLog(@"数据源不可用");
        return;
    }
    
    // 3.创建照片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    
    // 4.设置数据源
    ipc.sourceType = sourceType;
    
    // 5.设置代理
    ipc.delegate = self;
    
    // 6.弹出控制器
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - 实现UIImagePickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 1.获取选中的图片
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    
    // 2.将照片显示在imageView中
    self.imageView.image = selectedImage;
    
    // 3.退出控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
