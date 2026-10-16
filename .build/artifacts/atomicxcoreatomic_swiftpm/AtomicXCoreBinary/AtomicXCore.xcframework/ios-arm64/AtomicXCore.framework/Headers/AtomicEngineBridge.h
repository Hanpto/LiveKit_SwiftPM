// Copyright (c) 2026 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol AtomicEngineEventDelegate <NSObject>
- (void)onCall:(NSString *)eventName id:(NSString *)scopeId jsonData:(NSString *)jsonData;
- (NSString *)onQuery:(NSString *)eventName id:(NSString *)scopeId jsonData:(NSString *)jsonData;
@end

@interface AtomicEngineBridge : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, weak, nullable) id<AtomicEngineEventDelegate> delegate;

- (void)initEngine;
- (void)uninitEngine;

- (void)callAPI:(NSString *)apiName
             id:(NSString *)scopeId
      jsonParam:(NSString *)jsonParam
       callback:
           (void (^_Nullable)(int errorCode, NSString *errorMessage, NSString *jsonData))callback;

- (NSString *)queryAPI:(NSString *)apiName id:(NSString *)scopeId jsonParam:(NSString *)jsonParam;

@end

NS_ASSUME_NONNULL_END
