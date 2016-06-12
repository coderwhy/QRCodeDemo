//
//  QRCodeManager.h
//  QRCode
//
//  Created by xiaomage on 16/6/11.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeManager : NSObject

+ (instancetype)shareInstance;

/**
 *  生成二维码
 *
 *  @param inputMsg 二维码保存的信息
 *  @param fgImage  前景图片
 *
 *  @return 返回的二维码图片
 */
- (UIImage *)generateQRCodeWithMsg:(NSString *)inputMsg fgImage:(UIImage *)fgImage;


/**
 *  识别二维码图片
 *
 *  @param qrCodeImage 二维码的图片
 *
 *  @return 结果的数组
 */
- (NSArray *)detectorQRCodeWithQRCodeImage:(UIImage *)qrCodeImage;

/**
 *  开始扫描
 *
 *  @param inView 图层添加到哪一个View中
 *  @param scanView 扫描区域的View
 */
- (void)startScanningQRCodeWithInView:(UIView *)inView  scanView:(UIView *)scanView resultCallback:(void(^)(NSArray *results))callback;

@end
