//
//  QRCodeManager.m
//  QRCode
//
//  Created by xiaomage on 16/6/11.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "QRCodeManager.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeManager () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic ,copy) void(^resultCallBack)(NSArray *results);

@end

@implementation QRCodeManager

static QRCodeManager *_instance;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}


#pragma mark - 生成二维码代码
- (UIImage *)generateQRCodeWithMsg:(NSString *)inputMsg fgImage:(UIImage *)fgImage {
    // 1.将内容生成二维码
    // 1.1.创建滤镜(name = "CIQRCodeGenerator")
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 1.1.1.恢复默认设置
    [filter setDefaults];
    
    // 1.2.2.设置生成的二维码的容错率
    // key = inputCorrectionLevel value = @"L/M/Q/H"
    [filter setValue:@"H" forKeyPath:@"inputCorrectionLevel"];
    
    // 2.设置输入的内容(KVC)
    // 注意:key = inputMessage, value必须是NSData类型
    NSData *inputData = [inputMsg dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:inputData forKeyPath:@"inputMessage"];
    
    // 3.获取输出的图片
    CIImage *outImage = [filter outputImage];
    
    // 4.获取高清图片
    UIImage *hdImage = [self createHDImageWithOriginalImage:outImage];
    
    // 5.判断是否有前景图片
    if (fgImage == nil) {
        return hdImage;
    }
    
    // 6.获取有前景图片的二维码图像
    return [self createResultImageWithHDImage:hdImage fgImage:fgImage];
}

- (UIImage *)createHDImageWithOriginalImage:(CIImage *)ciImage {
    // 1.创建Transform
    CGAffineTransform transform = CGAffineTransformMakeScale(10, 10);
    
    // 2.放大图片
    ciImage = [ciImage imageByApplyingTransform:transform];
    
    return [UIImage imageWithCIImage:ciImage];
}

- (UIImage *)createResultImageWithHDImage:(UIImage *)hdImage fgImage:(UIImage *)fgImage {
    // 0.获取高清图的Size
    CGSize size = hdImage.size;
    
    // 1.开启图形上下文
    UIGraphicsBeginImageContext(size);
    
    // 2.将高清图片画到上下文中
    [hdImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 3.将前景图片画到上下文中
    CGFloat w = 80;
    CGFloat h = 80;
    CGFloat x = (size.width - w) * 0.5;
    CGFloat y = (size.height - h) * 0.5;
    [fgImage drawInRect:CGRectMake(x, y, w, h)];
    
    // 4.获取上下文中图片
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.关闭上下文
    UIGraphicsEndImageContext();
    
    return resultImage;
}


#pragma mark - 识别二维码代码
- (NSArray *)detectorQRCodeWithQRCodeImage:(UIImage *)qrCodeImage {
    // 1.创建过滤器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    
    // 2.获取CIIImage对象
    CIImage *ciImage = [[CIImage alloc] initWithImage:qrCodeImage];
    
    // 3.识别图片中的二维码
    NSArray *features = [detector featuresInImage:ciImage];
    
    // 4.遍历数组,拿到二维码信息
    NSMutableArray *resultArray = [NSMutableArray array];
    for (CIQRCodeFeature *f in features) {
        [resultArray addObject:f.messageString];
    }
    
    return resultArray;
}


#pragma mark - 扫描二维码
#pragma mark 开始扫描
- (void)startScanningQRCodeWithInView:(UIView *)inView scanView:(UIView *)scanView resultCallback:(void(^)(NSArray *results))callback {
    // 0.保存block
    self.resultCallBack = callback;
    
    // 1.创建输入
    // 1.1.定义错误
    NSError *error = nil;
    
    // 1.2.获取摄像头
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 1.3.创建输入
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error != nil) {
        return;
    }
    
    // 2.创建输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 3.创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session addInput:input];
    [session addOutput:output];
    
    // 4.设置输入的内容类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 5.添加预览图层(让用户看到扫描的界面)
    // 5.1.创建图层
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    // 5.2.设置的layer的frame
    previewLayer.frame = inView.bounds;
    
    // 5.3.将图层添加到其它图层中
    [inView.layer insertSublayer:previewLayer below:scanView.layer];
    
    // 6.设置扫描区域
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat x = scanView.frame.origin.y / screenSize.height;
    CGFloat y = scanView.frame.origin.x / screenSize.width;
    CGFloat w = scanView.frame.size.height / screenSize.height;
    CGFloat h = scanView.frame.size.width / screenSize.width;
    output.rectOfInterest = CGRectMake(x, y, w, h);
    
    // 7.开始扫描
    [session startRunning];
}

#pragma mark - 实现AVCaptureMetadataOutput代理方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 1.遍历结果
    NSMutableArray *resultArray = [NSMutableArray array];
    for (AVMetadataMachineReadableCodeObject *result in metadataObjects) {
        [resultArray addObject:result.stringValue];
    }
    
    // 2.将结果回调出去
    self.resultCallBack(resultArray);
}


@end
