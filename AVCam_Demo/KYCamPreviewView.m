//
//  KYCamPreviewView.m
//  AVCam_Demo
//
//  Created by 李一贤 on 2021/7/19.
//

#import "KYCamPreviewView.h"

@implementation KYCamPreviewView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(Class)layerClass{
    
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer*) videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}


@end
