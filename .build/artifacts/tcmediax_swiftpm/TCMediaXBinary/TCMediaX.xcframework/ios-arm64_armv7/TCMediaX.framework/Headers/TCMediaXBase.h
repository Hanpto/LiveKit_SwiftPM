//  Copyright © 2023年 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCMediaXBaseDelegate;
@interface TCMediaXBase : NSObject

/**
 @brief 创建TCMediaXBase对象
 @discussion 创建TCMediaXBase对象
 @return 返回创建的TCMediaXBase对象
*/
+ (instancetype)getInstance;

/**
 @brief 设置Delegate
 @param  delegate  设置的Delegate
*/
- (void)setDelegate:(id<TCMediaXBaseDelegate>)delegate;

/**
 @brief 设置Licence
 @param url  设置Licence的URL地址
 @param key  设置Licence的对应的Key
*/
- (void)setLicenceURL:(NSString *)url key:(NSString *)key;

/**
 @brief 设置Log是否允许
 @param enabled   YES 允许  NO 不允许。默认为YES
*/
- (void)setLogEnable:(BOOL)enabled;

/**
 @brief Get the SDK version info.
 */
- (NSString *)getSdkVersion;

@end

NS_ASSUME_NONNULL_END
