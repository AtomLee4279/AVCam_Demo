//
//  Tool.h
//  churchsapp
//
//  Created by Phoenix on 16/3/20.
//  Copyright © 2016年 The Technology Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, CompareTime) {
    compareTimeIsBefore = 0,
    bothTimesIsSave,
    compareTimeIsAfter
};

typedef NS_ENUM(NSInteger, LocalDeviceType) {
    IS_IPHONE_4 = 0,
    IS_IPHONE_5,
    IS_IPHONE_6,
    IS_IPHONE_6P,
    IS_IPHONE_X,
    IS_UNKNOWN_DEVICE
};

/*
 所用功能目录：
 UIImage:
 1、图片缩放
 2、获取UIImageView中Image的位置
 3、颜色转图片
 4、生成一张水印图片
 5、两张图片的合并
 
 NSDate:
 6、时间转字符串
 7、字符串转时间
 8、时间转时间戳
 9、时间戳转时间
 10、比较时间先后
 11、计算指定时间与当前的时间差
 
 判断和验证
 12、判断字符串是否为空
 13、验证货币数字
 14、验证email
 15、验证zipCode
 16、验证手机号
 17、验证用户密码（6-18位数字和字母组合）
 
 加密解密
 18、MD5加密
 19、图片转Base64
 20、字符串转Base64
 21、base64字符串解码
 22、AES加密
 23、AES解密

 NSArray
 24、数组排序
 25、数组过滤
 
 杂项
 26、创建document文件路径
 27、生成唯一字符串
 28、hexColor转UIColor
 29、获取设备类型
 */

@interface Tool : NSObject
// 1、图片缩放
+(UIImage *)scaleImage:(UIImage *)imageSrc withSizeBounds:(CGSize)bounds;
// 2、获取UIImageView中Image的位置
+(CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView;
// 3、颜色转图片
+(UIImage*)createImageWithColor:(UIColor*) color;
// 4、生成一张水印图片
+(UIImage *)createWatermarkWithImage:(UIImage *)image title:(NSString *)title;
// 5、两张图片的合并 scale为icon缩放的倍数，如3倍
+(UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withScale:(CGFloat)scale;
// 6、时间转字符串 默认为 @"MM/dd/YYYY"
+(NSString *)stringFromDate:(NSDate *)date dateFormatter:(NSString *)dateFormatterStr;
// 7、字符串转时间 默认为 @"MM/dd/YYYY"
+(NSDate *)dateFromString:(NSString *)dateStr dateFormatter:(NSString *)dateFormatterStr;
// 8、时间转时间戳
+(NSString *)dateChangeUTC:(NSDate *)date;
// 9、时间戳转时间
+(NSDate *)UTCchangeDate:(NSString *)utcStr;
// 10、比较时间先后 @return 1 oneDay后于 anotherDay; 返回-1表示oneDay前于anotherDay；返回0表示相等
+(CompareTime)compareWithCompareTime:(NSDate *)compareTime withAnotherTime:(NSDate *)anotherTime;
// 11、计算指定时间与当前的时间差 比如，3天前、10分钟前
+(NSString *)compareCurrentTime:(NSDate*) compareDate;
// 12、判断字符串是否为空
+(BOOL)isBlankString:(NSString *)string;
// 13、验证货币数字
+(BOOL)validateMoney:(NSString *)money;
// 14、验证email
+(BOOL)isValidateEmail:(NSString *)email;
// 15、验证zipCode
+(BOOL)isValidateZipCode:(NSString *)zipCode;
// 16、验证手机号
+(BOOL)isValidatePhoneNumber:(NSString *)phoneNumber;
// 17、 验证用户密码（6-18位数字和字母组合）
+(BOOL)isValidatePassword:(NSString *)password;
// 18、MD5加密 , 不可逆，经常用于登录密码的加密
+(NSString *)MD5HexDigest:(NSString *)str;
// 19、转换图片的方法Base64 ,base64加密是可逆的，一般是为了不能肉眼看出加密前的内容，比如把图片转成一个base64字符串传给后台，而不是直接传一个png
+(NSString *)UIImageToBase64Str:(UIImage *)image;
// 20、把字符串转成Base64编码
+(NSString *)base64EncodeString:(NSString *)string;
// 21、base64字符串解码
+(NSString *)stringEncodeBase64:(NSString *)base64;
// 22、AES加密 ， 可逆，经常用于请求参数的加密 key为跟后台约定的一个字符串 ，这里用的是128位bits
+(NSData *)encryptWithAES:(NSData *)data key:(NSString *)key error:(NSError **)error;
// 23、AES解密 key为跟后台约定的一个字符串
+(NSData *)decryptWithAES:(NSData *)data key:(NSString *)key error:(NSError **)error;
// 24、数组排序 array里面放的是entity key是entity的一个property 如displayOrder ascend == YES为升序
+(NSArray *)sortedArray:(NSArray *)array bySortDescriptorKey:(NSString *)key ascending:(BOOL)ascend;
// 25、数组过滤 array里面放的是entity format是过滤的条件，类似sql语句 如：active = 1，这个active是entity的一个property
+(NSArray *)filteredArray:(NSArray *)array byPredicateFormat:(NSString *)format;
// 26、创建document文件路径 如FileName: userInfo extension:plist
+(NSString *)documentPathForFileName:(NSString *)fileName extension:(NSString *)extensionName;
// 27、生成一个唯一的字符串
+(NSString *)createGeneralId;
// 28、通过hexColor得到一个UIColor hexColor @example #FFFFFF或者FFFFFF或者0XFFFFFF
+(UIColor*)colorWithHexadecimalColor:(NSString *)color;

//29.获取设备类型
+(LocalDeviceType)deviceType;

+ (NSString *)getWifiName;

+(NSString *)getMacAddress;
@end
