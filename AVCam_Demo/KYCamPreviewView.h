//
//  KYCamPreviewView.h
//  AVCam_Demo
//
//  Created by 李一贤 on 2021/7/19.
//

@import UIKit;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface KYCamPreviewView : UIView

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

NS_ASSUME_NONNULL_END
