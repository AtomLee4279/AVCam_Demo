//
//  ViewController.m
//  AVCam_Demo
//
//  Created by 李一贤 on 2021/7/19.
//demo：使用后置的三个摄像头（广角、超广角、长焦）同时独立拍摄图片

#import "ViewController.h"
#import "KYCamPreviewView.h"
#import "Tool.h"
@import AVFoundation;
@import Photos;

@interface ViewController ()<AVCapturePhotoCaptureDelegate>

@property (weak, nonatomic) IBOutlet KYCamPreviewView *wideAnglePreview;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *wideAnglePreviewLayer;

@property (weak, nonatomic) IBOutlet KYCamPreviewView *ultraWideAnglePreview;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *ultraWideAnglePreviewLayer;

@property (weak, nonatomic) IBOutlet KYCamPreviewView *telephotoPreview;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *telephotoPreviewLayer;

@property (weak, nonatomic) IBOutlet UIButton *shootBtn;

@property (strong,nonatomic) AVCaptureMultiCamSession *session;

//后置广角相机
@property (strong, nonatomic) AVCaptureDevice* backWideAngleCamera;

//后置超广角相机
@property (strong, nonatomic) AVCaptureDevice* backUltraWideAngleCamera;

//后置长焦相机
@property (strong, nonatomic) AVCaptureDevice* backTelephotoCamera;

//后置广角相机输入对象
@property (strong,nonatomic) AVCaptureDeviceInput *backWideAngleCameraDeviceInput;

//后置广角相机输出对象
@property (strong,nonatomic) AVCapturePhotoOutput *backWideAngleCameraOutput;

//后置超广角相机输入对象
@property (strong,nonatomic) AVCaptureDeviceInput *backUltraWideAngleCameraDeviceInput;

//后置超广角相机输出对象
@property (strong,nonatomic) AVCapturePhotoOutput *backUltraWideAngleCameraOutput;

//后置长焦相机输入对象
@property (strong,nonatomic) AVCaptureDeviceInput *backTelephotoCameraDeviceInput;

//后置长焦相机输出对象
@property (strong,nonatomic) AVCapturePhotoOutput *backTelephotoCameraOutput;

//一个串行队列，该队列用于session之间的交流
@property (nonatomic) dispatch_queue_t sessionQueue;

@property (nonatomic) NSData* photoData;

//currentSettings用于区分每一轮拍照
@property (strong,nonatomic) AVCapturePhotoSettings* currentSettings;

@property (copy,nonatomic) NSString* currentItemName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置预览广角相机画面layer
    [self.wideAnglePreview.videoPreviewLayer setSessionWithNoConnection:self.session];
    self.wideAnglePreviewLayer = self.wideAnglePreview.videoPreviewLayer;
    
    //设置预览超广角相机画面layer
    [self.ultraWideAnglePreview.videoPreviewLayer setSessionWithNoConnection:self.session];
    self.ultraWideAnglePreviewLayer = self.ultraWideAnglePreview.videoPreviewLayer;
    
    //设置预览长焦相机画面layer
    [self.telephotoPreview.videoPreviewLayer setSessionWithNoConnection:self.session];
    self.telephotoPreviewLayer = self.telephotoPreview.videoPreviewLayer;
    dispatch_async(self.sessionQueue, ^{
        self.currentSettings = [self fetchNewPhotoSettings];
    });
    dispatch_async(self.sessionQueue, ^{
        [self configSession];
    });
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
    });
}

#pragma mark - Custom Methods -

//配置session
-(void)configSession{
    
    //开始设置session
    [self.session beginConfiguration];
    
    //配置广角相机
//    [self configBackWideAngleCamera];
    //配置超广角相机
    [self configUltraWideAngleCamera];
//    //配置长焦相机
    [self configTelephotoCamera];
    //.提交session设置
    [self.session commitConfiguration];
}

//配置（后置）广角相机
-(BOOL)configBackWideAngleCamera{
    
    //1.获取后置广角相机设备
    AVCaptureDevice* backWideAngleCamera = self.backWideAngleCamera;
    if (!backWideAngleCamera) {
        NSLog(@"无法找到后置广角相机");
        return NO;
    }
    //2.将后置广角相机封装装进AVCaptureDeviceInput对象中
    NSError *error = nil;
    self.backWideAngleCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backWideAngleCamera error:&error];
    if (error) {
        NSLog(@"无法创建AVCaptureDeviceInput：backWideAngleCameraDeviceInput");
        return NO;
    }
    //添加AVCaptureDeviceInput进sessin
    //判读是否可以添加进去
    if (![self.session canAddInput:self.backWideAngleCameraDeviceInput]) {
        NSLog(@"无法将AVCaptureDeviceInput：backWideAngleCameraDeviceInput添加进session里");
        return NO;
    }
    [self.session addInputWithNoConnections:self.backWideAngleCameraDeviceInput];
    //3.利用AVCaptureDeviceInput对象,创建 后置广角相机的视频输入管线对象
    AVCaptureInputPort* backWideAngleInputPort = [self.backWideAngleCameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:backWideAngleCamera.deviceType sourceDevicePosition:AVCaptureDevicePositionBack].firstObject;
    //4.将AVCapturePhotoOutput对象添加进session：
    //检查AVCapturePhotoOutput对象能否添加进session
    if (![self.session canAddOutput:self.backWideAngleCameraOutput]) {
        NSLog(@"session无法添加AVCapturePhotoOutput");
        return NO;
    }
    [self.session addOutputWithNoConnections:self.backWideAngleCameraOutput];
    //5.利用输入管线 和 output对象， 创建一个AVCaptureConnection对象
    AVCaptureConnection* wideAngleCameraConnection = [AVCaptureConnection connectionWithInputPorts:@[backWideAngleInputPort] output:self.backWideAngleCameraOutput];
    //6.将AVCaptureConnection对象添加进session
    //检查是否能添加进去
    if (![self.session canAddConnection:wideAngleCameraConnection]) {
        NSLog(@"session无法添加wideAngleCameraConnection");
        return NO;
    }
    wideAngleCameraConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.session addConnection:wideAngleCameraConnection];
    //7.创建一个提供预览layer的AVCaptureConnection
    AVCaptureConnection* backWideAngleCameraPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:backWideAngleInputPort videoPreviewLayer:self.wideAnglePreviewLayer];
    //8.检查是否能添加进session
    if (![self.session canAddConnection:backWideAngleCameraPreviewLayerConnection]) {
        NSLog(@"无法添加带预览layer的AVCaptureConnection：backWideAngleCameraPreviewLayerConnection");
        return NO;
    }
    [self.session addConnection:backWideAngleCameraPreviewLayerConnection];
    return YES;
}

//配置超广角相机
-(BOOL)configUltraWideAngleCamera{
    
    //1.获取后置超广角相机设备
    AVCaptureDevice* backUltraWideAngleCamera = self.backUltraWideAngleCamera;
    if (!backUltraWideAngleCamera) {
        NSLog(@"无法找到后置超广角相机");
        return NO;
    }
    //2.将后置超广角相机封装装进AVCaptureDeviceInput对象中
    NSError *error = nil;
    self.backUltraWideAngleCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backUltraWideAngleCamera error:&error];
    if (error) {
        NSLog(@"无法创建AVCaptureDeviceInput：backUltraWideAngleCameraDeviceInput");
        return NO;
    }
    //添加AVCaptureDeviceInput进sessin
    //判读是否可以添加进去
    if (![self.session canAddInput:self.backUltraWideAngleCameraDeviceInput]) {
        NSLog(@"无法将AVCaptureDeviceInput：backUltraWideAngleCameraDeviceInput添加进session里");
        return NO;
    }
    [self.session addInputWithNoConnections:self.backUltraWideAngleCameraDeviceInput];
    //3.利用AVCaptureDeviceInput对象,创建 后置超广角相机的视频输入管线对象
    AVCaptureInputPort* backUltraWideAngleInputPort = [self.backUltraWideAngleCameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:backUltraWideAngleCamera.deviceType sourceDevicePosition:AVCaptureDevicePositionBack].firstObject;
    //4.将AVCapturePhotoOutput对象添加进session：
    //检查AVCapturePhotoOutput对象能否添加进session
    if (![self.session canAddOutput:self.backUltraWideAngleCameraOutput]) {
        NSLog(@"session无法添加AVCapturePhotoOutput");
        return NO;
    }
    [self.session addOutputWithNoConnections:self.backUltraWideAngleCameraOutput];
    //5.利用输入管线 和 output对象， 创建一个AVCaptureConnection对象
    AVCaptureConnection* ultraWideAngleCameraConnection = [AVCaptureConnection connectionWithInputPorts:@[backUltraWideAngleInputPort] output:self.backUltraWideAngleCameraOutput];
    //6.将AVCaptureConnection对象添加进session
    //检查是否能添加进去
    if (![self.session canAddConnection:ultraWideAngleCameraConnection]) {
        NSLog(@"session无法添加wideAngleCameraConnection");
        return NO;
    }
    ultraWideAngleCameraConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.session addConnection:ultraWideAngleCameraConnection];
    //7.创建一个提供预览layer的AVCaptureConnection
    AVCaptureConnection* backUltraWideAngleCameraPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:backUltraWideAngleInputPort videoPreviewLayer:self.ultraWideAnglePreviewLayer];
    //8.检查是否能添加进session
    if (![self.session canAddConnection:backUltraWideAngleCameraPreviewLayerConnection]) {
        NSLog(@"无法添加带预览layer的AVCaptureConnection：backWideAngleCameraPreviewLayerConnection");
        return NO;
    }
    [self.session addConnection:backUltraWideAngleCameraPreviewLayerConnection];
    return YES;
    
}

//配置长焦相机
-(BOOL)configTelephotoCamera{
    
    //1.获取后置长焦相机设备
    AVCaptureDevice* backTelephotoCamera = self.backTelephotoCamera;
    if (!backTelephotoCamera) {
        NSLog(@"无法找到后置长焦相机");
        return NO;
    }
    //2.将后置超广角相机封装装进AVCaptureDeviceInput对象中
    NSError *error = nil;
    self.backTelephotoCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backTelephotoCamera error:&error];
    if (error) {
        NSLog(@"无法创建AVCaptureDeviceInput：backTelephotoCameraDeviceInput");
        return NO;
    }
    //添加AVCaptureDeviceInput进sessin
    //判读是否可以添加进去
    if (![self.session canAddInput:self.backTelephotoCameraDeviceInput]) {
        NSLog(@"无法将AVCaptureDeviceInput：backTelephotoCameraDeviceInput添加进session里");
        return NO;
    }
    [self.session addInputWithNoConnections:self.backTelephotoCameraDeviceInput];
    //3.利用AVCaptureDeviceInput对象,创建 后置超广角相机的视频输入管线对象
    AVCaptureInputPort* backTelephotoInputPort = [self.backTelephotoCameraDeviceInput portsWithMediaType:AVMediaTypeVideo sourceDeviceType:backTelephotoCamera.deviceType sourceDevicePosition:AVCaptureDevicePositionBack].firstObject;
    //4.将AVCapturePhotoOutput对象添加进session：
    //检查AVCapturePhotoOutput对象能否添加进session
    if (![self.session canAddOutput:self.backTelephotoCameraOutput]) {
        NSLog(@"session无法添加AVCapturePhotoOutput");
        return NO;
    }
    [self.session addOutputWithNoConnections:self.backTelephotoCameraOutput];
    //5.利用输入管线 和 output对象， 创建一个AVCaptureConnection对象
    AVCaptureConnection* telephotoCameraConnection = [AVCaptureConnection connectionWithInputPorts:@[backTelephotoInputPort] output:self.backTelephotoCameraOutput];
    //6.将AVCaptureConnection对象添加进session
    //检查是否能添加进去
    if (![self.session canAddConnection:telephotoCameraConnection]) {
        NSLog(@"session无法添加telephotoCameraConnection");
        return NO;
    }
    telephotoCameraConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.session addConnection:telephotoCameraConnection];
    //7.创建一个提供预览layer的AVCaptureConnection
    AVCaptureConnection* backTelephotoCameraPreviewLayerConnection = [AVCaptureConnection connectionWithInputPort:backTelephotoInputPort videoPreviewLayer:self.telephotoPreviewLayer];
    //8.检查是否能添加进session
    if (![self.session canAddConnection:backTelephotoCameraPreviewLayerConnection]) {
        NSLog(@"无法添加带预览layer的AVCaptureConnection：backTelephotoCameraPreviewLayerConnection");
        return NO;
    }
    [self.session addConnection:backTelephotoCameraPreviewLayerConnection];
    return YES;
    
}

-(NSString*)createDocumentName{

    NSDate *date = [NSDate date];
    NSString *itemName = [Tool dateChangeUTC:date];
    return itemName;
}

//-[AVCapturePhotoOutput capturePhotoWithSettings:delegate:]时，
//都必须使用新的AVCapturePhotoSettings对象
- (AVCapturePhotoSettings *)fetchNewPhotoSettings{
    
    AVCapturePhotoSettings *photoSettings = nil;
    //当支持拍摄HEIF图片时，设置自动闪光灯以及高质量图片拍摄
    // Capture HEIF photos when supported, with the flash set to enable auto- and high-resolution photos.
//    if ([self.backWideAngleCameraOutput.availablePhotoCodecTypes containsObject:AVVideoCodecTypeHEVC]) {
//        _photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{ AVVideoCodecKey : AVVideoCodecTypeHEVC }];
//    }
//    else {
//        _photoSettings = [AVCapturePhotoSettings photoSettings];
//    }
    photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{ AVVideoCodecKey : AVVideoCodecTypeJPEG }];
    //自动闪光灯
//    if (self.backWideAngleCameraDeviceInput.device.isFlashAvailable) {
//        _photoSettings.flashMode = AVCaptureFlashModeAuto;
//    }
    photoSettings.highResolutionPhotoEnabled = YES;
    //设置previewPhotoFormat
    if (photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0) {
        photoSettings.previewPhotoFormat = @{ (NSString*)kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.firstObject };
    }
    photoSettings.photoQualityPrioritization = AVCapturePhotoQualityPrioritizationBalanced;
    photoSettings.cameraCalibrationDataDeliveryEnabled = self.backWideAngleCameraOutput.cameraCalibrationDataDeliverySupported;
    return photoSettings;
}

#pragma mark - Button Actions -
- (IBAction)actShootPhotoBtnDidClicked:(id)sender {
    
    //即将开始拍照片，展示屏幕画面闪一下的动画
    dispatch_async(dispatch_get_main_queue(), ^{
        self.wideAnglePreview.videoPreviewLayer.opacity = 0.0;
        self.ultraWideAnglePreview.videoPreviewLayer.opacity = 0.0;
        self.telephotoPreview.videoPreviewLayer.opacity = 0.0;
        [UIView animateWithDuration:0.25 animations:^{
            self.wideAnglePreview.videoPreviewLayer.opacity = 1.0;
            self.ultraWideAnglePreview.videoPreviewLayer.opacity = 1.0;
            self.telephotoPreview.videoPreviewLayer.opacity = 1.0;
        }];
    });
    //在session队列里处理拍照采集
    dispatch_async(self.sessionQueue, ^{
        
        self.currentItemName = [self createDocumentName];
//        [self.backWideAngleCameraOutput capturePhotoWithSettings:self.currentSettings delegate:self];
        [self.backUltraWideAngleCameraOutput capturePhotoWithSettings:self.currentSettings delegate:self];
        [self.backTelephotoCameraOutput capturePhotoWithSettings:self.currentSettings delegate:self];
    });
    
}

#pragma mark - AVCapturePhotoCaptureDelegate -

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishProcessingPhoto:(AVCapturePhoto*)photo error:(nullable NSError*)error{
    
    //缓存拍照处理完成后的图片数据
    self.photoData = [photo fileDataRepresentation];
    photo.cameraCalibrationData.intrinsicMatrix;
}

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings error:(NSError*)error
{
    //若出错
    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        return;
    }
    //若拍摄图片数据为空
    if ( self.photoData == nil ) {
        NSLog( @"No photo data resource" );
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@",self.currentItemName];
    path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    //若：该文件夹目录不存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //创建资源所在的目录
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (self.backUltraWideAngleCameraOutput == captureOutput) {
        NSLog(@"是后置超广角相机拍摄的图片,uniqueID:%lld",resolvedSettings.uniqueID);
        path = [path stringByAppendingPathComponent:@"3.jpg"];
    }
    
    if (self.backWideAngleCameraOutput == captureOutput) {
        NSLog(@"是后置广角相机拍摄的图片,uniqueID:%lld",resolvedSettings.uniqueID);
        path = [path stringByAppendingPathComponent:@"1.jpg"];
        
    }
    
    if (self.backTelephotoCameraOutput == captureOutput) {
        NSLog(@"是后置长焦相机拍摄的图片,uniqueID:%lld",resolvedSettings.uniqueID);
        path = [path stringByAppendingPathComponent:@"2.jpg"];
    }
    [self.photoData writeToFile:path atomically:YES];

    //保存到本地相册
//    [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
//        if ( status == PHAuthorizationStatusAuthorized ) {
//            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                PHAssetCreationRequest* creationRequest = [PHAssetCreationRequest creationRequestForAsset];
//                [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:self.photoData options:nil];
//
//            } completionHandler:^( BOOL success, NSError* _Nullable error ) {
//                if ( ! success ) {
//                    NSLog( @"保存图片出错: %@", error );
//                }
//            }];
//        }
//        else {
//            NSLog( @"未授权保存图片的权限");
//        }
//    }];
}

#pragma mark - Getter && Setter -

- (AVCaptureMultiCamSession *)session{
    
    if (!_session) {
        _session = [[AVCaptureMultiCamSession alloc] init];
    }
    return _session;
}

- (AVCaptureDevice *)backWideAngleCamera{
    
    if (!_backWideAngleCamera) {
        _backWideAngleCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if ([_backWideAngleCamera lockForConfiguration:nil]) {
            //设置曝光锁定
    //        [_backWideAngleCamera setExposureMode:AVCaptureExposureModeLocked];
            //设置对焦锁定
    //        _backWideAngleCamera.focusMode = AVCaptureFocusModeLocked;
//            if ([_backWideAngleCamera isExposureModeSupported:AVCaptureExposureModeCustom]) {
//                [_backWideAngleCamera setExposureMode:AVCaptureExposureModeCustom];
//                [_backWideAngleCamera setExposureModeCustomWithDuration:_backWideAngleCamera.exposureDuration ISO:AVCaptureISOCurrent completionHandler:^(CMTime syncTime) {
//
//                }];
//            }
            
            [_backWideAngleCamera unlockForConfiguration];
        }
    }
    return _backWideAngleCamera;
}

- (AVCaptureDevice *)backUltraWideAngleCamera{
    
    if (!_backUltraWideAngleCamera) {
        _backUltraWideAngleCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInUltraWideCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if ([_backUltraWideAngleCamera lockForConfiguration:nil]) {
            if ([_backUltraWideAngleCamera isExposureModeSupported:AVCaptureExposureModeCustom]) {
                [_backUltraWideAngleCamera setExposureMode:AVCaptureExposureModeCustom];
                CGFloat minISO = _backUltraWideAngleCamera.activeFormat.minISO;
                CGFloat maxISO = _backUltraWideAngleCamera.activeFormat.maxISO;
                CGFloat currentISO = (maxISO - minISO) * 0.7 + minISO;
                [_backUltraWideAngleCamera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:AVCaptureISOCurrent completionHandler:^(CMTime syncTime) {
                                
                }];
            }
            
            [_backUltraWideAngleCamera unlockForConfiguration];
        }
        
    }
    return  _backUltraWideAngleCamera;
}

- (AVCaptureDevice *)backTelephotoCamera{
    
    if (!_backTelephotoCamera) {
        _backTelephotoCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInTelephotoCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if ([_backTelephotoCamera lockForConfiguration:nil]) {
            if ([_backTelephotoCamera isExposureModeSupported:AVCaptureExposureModeCustom]) {
                [_backTelephotoCamera setExposureMode:AVCaptureExposureModeCustom];
                [_backTelephotoCamera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:AVCaptureISOCurrent completionHandler:^(CMTime syncTime) {
                                
                }];
            }
            [_backTelephotoCamera unlockForConfiguration];
        }
    }
    return _backTelephotoCamera;
}

-(dispatch_queue_t)sessionQueue{
    
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}

- (AVCapturePhotoOutput *)backWideAngleCameraOutput{
    
    if (!_backWideAngleCameraOutput) {
        _backWideAngleCameraOutput = [[AVCapturePhotoOutput alloc] init];
        _backWideAngleCameraOutput.highResolutionCaptureEnabled = YES;
        _backWideAngleCameraOutput.maxPhotoQualityPrioritization = AVCapturePhotoQualityPrioritizationQuality;
    }
    return _backWideAngleCameraOutput;
}

- (AVCapturePhotoOutput *)backUltraWideAngleCameraOutput{
    
    if (!_backUltraWideAngleCameraOutput) {
        _backUltraWideAngleCameraOutput = [[AVCapturePhotoOutput alloc] init];
        _backUltraWideAngleCameraOutput.highResolutionCaptureEnabled = YES;
        _backUltraWideAngleCameraOutput.maxPhotoQualityPrioritization = AVCapturePhotoQualityPrioritizationQuality;
    }
    return _backUltraWideAngleCameraOutput;
}

- (AVCapturePhotoOutput *)backTelephotoCameraOutput{
    
    if (!_backTelephotoCameraOutput) {
        _backTelephotoCameraOutput = [[AVCapturePhotoOutput alloc] init];
        _backTelephotoCameraOutput.highResolutionCaptureEnabled = YES;
        _backTelephotoCameraOutput.maxPhotoQualityPrioritization = AVCapturePhotoQualityPrioritizationQuality;
    }
    return _backTelephotoCameraOutput;
    
}



@end
