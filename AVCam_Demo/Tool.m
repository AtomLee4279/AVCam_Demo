//
//  Tool.m
//  churchsapp
//
//  Created by Phoenix on 16/3/20.
//  Copyright © 2016年 The Technology Studios. All rights reserved.
//


#import "Tool.h"
#import <CommonCrypto/CommonCrypto.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation Tool
+(UIImage *)scaleImage:(UIImage *)imageSrc withSizeBounds:(CGSize)bounds{
    CGSize newSize, srcSize;
    float rate;
    UIImage *imageScale;
    srcSize = imageSrc.size;
    rate = MIN(bounds.width/srcSize.width, bounds.height/srcSize.height);
    newSize = CGSizeMake(srcSize.width *rate, srcSize.height *rate);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    [imageSrc drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    imageScale = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageScale;
}
// 获取UIImageView中Image的位置
+(CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView{
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    float factor = fmax(hfactor, vfactor);
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}
// 颜色转图片
+(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(NSString *)stringFromDate:(NSDate *)date dateFormatter:(NSString *)dateFormatterStr{
    NSString *s = dateFormatterStr;
    if (dateFormatterStr.length == 0) {
        s = @"MM/dd/YYYY";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatterStr];
    return [dateFormatter stringFromDate:date];
}
+(NSDate *)dateFromString:(NSString *)dateStr dateFormatter:(NSString *)dateFormatterStr{
    NSString *s = dateFormatterStr;
    if (dateFormatterStr.length == 0) {
        s = @"MM/dd/YYYY";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatterStr];
    return [dateFormatter dateFromString:dateStr];
}
+(NSString *)dateChangeUTC:(NSDate *)date{
    // *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    return timeSp;
}
+(NSDate *)UTCchangeDate:(NSString *)utcStr{
    NSTimeInterval time = [utcStr doubleValue];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
    return date;
}
+(BOOL)validateMoney:(NSString *)money{
    NSString *reg1 = @"^[0-9]+\\.[0-9]{0,2}$";
    NSPredicate *pre1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg1];
    NSString *reg2 = @"^\\d+$";
    NSPredicate *pre2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg2];
    NSString *reg3 = @"^0{2,}$";
    NSPredicate *pre3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg3];
    if (([pre1 evaluateWithObject:money] || [pre2 evaluateWithObject:money]) && (![pre3 evaluateWithObject:money])) {
        return YES;
    }else{
        return NO;
    }
}
// 判断字符串是否为空
+(BOOL)isBlankString:(NSString *)string{
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(BOOL)isValidateZipCode:(NSString *)zipCode{
    NSString *zipRegex = @"[0-9]{5}";
    NSPredicate *zipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipRegex];
    return [zipTest evaluateWithObject:zipCode];
}
+(BOOL)isValidatePhoneNumber:(NSString *)phoneNumber{
    NSString *pattern = @"^1+[3456789]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    return isMatch;
}
+(BOOL)isValidatePassword:(NSString *)password{
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,18}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}
+(NSString *)MD5HexDigest:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}
//转换图片的方法Base64
+(NSString *)UIImageToBase64Str:(UIImage *)image{
    NSData *data = UIImagePNGRepresentation(image);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}
//把字符串转成Base64编码
+(NSString *)base64EncodeString:(NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}
//base64字符串解码
+(NSString *)stringEncodeBase64:(NSString *)base64{
    NSData *nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:base64 options:0];
    NSString *base64Decoded = [[NSString alloc]initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    return base64Decoded;
}
+ (NSData *)encryptWithAES:(NSData *)data key:(NSString *)key error:(NSError **)error{
    NSData *theKey = [key dataUsingEncoding:NSASCIIStringEncoding];
    NSParameterAssert(data != nil);
    NSParameterAssert(theKey != nil);
    NSParameterAssert(theKey.length == kCCKeySizeAES128);
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t cryptBytes = 0;
    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt,
                                       kCCAlgorithmAES,
                                       kCCOptionECBMode|kCCOptionPKCS7Padding,
                                       theKey.bytes, kCCKeySizeAES128,
                                       nil,
                                       data.bytes, data.length,
                                       buffer,
                                       bufferSize,
                                       &cryptBytes);
    if (ccStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:cryptBytes];
    }else {
        free(buffer);
        if (error) {
            *error = [NSError errorWithDomain:@"CryptoAssist" code:ccStatus userInfo:nil];
        }
        return nil;
    }
}
+(NSData *)decryptWithAES:(NSData *)data key:(NSString *)key error:(NSError **)error{
    NSData *theKey = [key dataUsingEncoding:NSASCIIStringEncoding];
    NSParameterAssert(data != nil);
    NSParameterAssert(theKey != nil);
    NSParameterAssert(theKey.length == kCCKeySizeAES128);
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t cryptBytes = 0;
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                                       kCCAlgorithmAES,
                                       kCCOptionECBMode|kCCOptionPKCS7Padding,
                                       theKey.bytes, kCCKeySizeAES128,
                                       nil,
                                       data.bytes, data.length,
                                       buffer,
                                       bufferSize,
                                       &cryptBytes);
    if (ccStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:cryptBytes];
    }else {
        free(buffer);
        if (error) {
            *error = [NSError errorWithDomain:@"CryptoAssist" code:ccStatus userInfo:nil];
        }
        return nil;
    }
}
+(NSString *) compareCurrentTime:(NSDate*) compareDate{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分前",temp];
    }else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小前",temp];
    }else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    return  result;
}

+(UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withScale:(CGFloat)scale {
    //通过两张图片进行位置和大小的绘制，实现两张图片的合并；其实此原理做法也可以用于多张图片的合并
    CGFloat widthOfImage = image.size.width;
    CGFloat heightOfImage = image.size.height;
    CGFloat widthOfIcon = widthOfImage/scale;
    CGFloat heightOfIcon = heightOfImage/scale;
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, widthOfImage, heightOfImage)];
    [icon drawInRect:CGRectMake((widthOfImage-widthOfIcon)/2, (heightOfImage-heightOfIcon)/2,
                                widthOfIcon, heightOfIcon)];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
+(UIImage *)createWatermarkWithImage:(UIImage *)image title:(NSString *)title{
    /*
    实现水印效果的思路:
    1.开启一个和原始图片一样的位图上下文.
    2.把原始图片先绘制到位图上下文.
    3.再把要添加的水印(文字,logo)等绘制到位图上下文.
    4.最后从上下文中取出一张图片.
    5.关闭位图上下文.
     */
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
    [image drawAtPoint:CGPointZero];
    [title drawAtPoint:CGPointMake(50, 100) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20], NSForegroundColorAttributeName : [UIColor orangeColor]}];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
+(NSString *)documentPathForFileName:(NSString *)fileName extension:(NSString *)extensionName{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:fileName];
    NSString *fileFullName = [path stringByAppendingPathExtension:extensionName];
    path = [path stringByAppendingPathComponent:fileFullName];
    NSString *dirPath = path.stringByDeletingLastPathComponent;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
+(NSArray *)sortedArray:(NSArray *)array bySortDescriptorKey:(NSString *)key ascending:(BOOL)ascend{
    NSArray *newArray = [array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascend]]];
    return newArray;
}
+(NSArray *)filteredArray:(NSArray *)array byPredicateFormat:(NSString *)format{
    NSArray *newArray = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:format]];
    return newArray;
}
+(NSString *)createGeneralId{
    NSString *ID;
    char rand[5];
    for (int i = 0; i < 4; i++) {
        rand[i] = 'A' + (arc4random() % 26);
    }
    rand[4] = '\0';
    ID = [NSString stringWithFormat:@"%.f%s", [[NSDate date]timeIntervalSince1970] * 1000, rand];
    return ID;
}
// 比较时间先后
+(CompareTime)compareWithCompareTime:(NSDate *)compareTime withAnotherTime:(NSDate *)anotherTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSString *oneDayStr = [dateFormatter stringFromDate:compareTime];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherTime];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", compareTime, anotherTime);
    if (result == NSOrderedDescending) {
        //NSLog(@"oneDay  is in the future");
        return compareTimeIsAfter;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"oneDay is in the past");
        return compareTimeIsBefore;
    }
    //NSLog(@"Both dates are the same");
    return bothTimesIsSave;
}
+ (UIColor*)colorWithHexadecimalColor:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6) {
        NSLog(@"输入的16进制有误，不足6位！");
        return [UIColor clearColor];
    }
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+(LocalDeviceType)deviceType{
    NSString *stringSize = NSStringFromCGSize([UIScreen mainScreen].bounds.size);
    if ([stringSize isEqualToString:@"{320, 480}"]) { // iphone 4/4s
        return IS_IPHONE_4;
    } else if ([stringSize isEqualToString:@"{320, 568}"]) { // iphone 5/5c/5s/SE
        return IS_IPHONE_5;
    } else if ([stringSize isEqualToString:@"{375, 667}"]) { // iphone 6/6s/7/8
        return IS_IPHONE_6;
    } else if ([stringSize isEqualToString:@"{414, 736}"]) { // iphone 6p/6sp/7p/8p
        return IS_IPHONE_6P;
    } else if ([stringSize isEqualToString:@"{375, 812}"] || [stringSize isEqualToString:@"{414, 896}"]) {
        // iphone X iphone X_max iphone_XR
        return IS_IPHONE_X;
    }else {
        return IS_UNKNOWN_DEVICE;
    }
}

#pragma mark Get WiFi Name
+ (NSString *)getWifiName
{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            //            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

+(NSString *)getMacAddress
{
//    通过如下方法获取wifi名称和wifi macAddress，ssid代表wifi名称，bssid表示wifi macAddress。
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dic = (NSDictionary *)info;
    NSString *ssid = [[dic objectForKey:@"SSID"] lowercaseString];
    NSString *bssid = [dic objectForKey:@"BSSID"];
    NSLog(@"ssid:%@ \nssid:%@",ssid,bssid);
    return bssid;
}
@end
