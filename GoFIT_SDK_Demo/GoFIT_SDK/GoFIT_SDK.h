//
//  GoFIT_SDK.h
//  GoFIT_SDK
//
//  Created by Rik Tsai on 2018/5/31.
//  Copyright © 2018年 GOLiFE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Handler+Object.h"

@interface GoFIT_SDK : NSObject

@property (nonatomic,weak) FindMyPhoneHandler findMyPhoneHandler;

+ (GoFIT_SDK*)shareInstance;

- (void)instantiate:(NSString*)certificate
         andLicense:(NSString*)license
            success:(void (^)(ResponseInfo *resp))success
            failure:(void (^)(ResponseInfo *resp))failure;

- (void)doScanDevice:(void (^)(NSDictionary* device))success
          completion:(void (^)(ResponseInfo *resp))completion
             failure:(void (^)(ResponseInfo *resp))failure;

- (void)doNewPairing:(NSString*)uuidStr
        andProductID:(NSString*)productID
             success:(void (^)(ResponseInfo *resp))success
             failure:(void (^)(ResponseInfo *resp))failure;

- (void)confirmPairingCode:(NSString*)pairingCode
            andPairingTime:(NSString*)pairingTime
              andProductID:(NSString*)productID
                   success:(void (^)(ResponseInfo *resp))success
                   failure:(void (^)(ResponseInfo *resp))failure;

- (void)doBondingANCS:(void (^)(ResponseInfo *resp))success
              failure:(void (^)(ResponseInfo *resp))failure;

- (void)doConnectDevice:(NSString*)uuidStr
           andProductID:(NSString*)productID
         andPairingCode:(NSString*)pairingCode
         andPairingTime:(NSString*)pairingTime
                success:(void (^)(ResponseInfo *resp))success
                failure:(void (^)(ResponseInfo *resp))failure;

- (void)doSyncFitnessData:(void (^)(int progressValue))progress
                  success:(void (^)(ResponseInfo *resp))success
                  failure:(void (^)(ResponseInfo *resp))failure;

- (void)doSetSetting:(NSArray*)settings
             success:(void (^)(ResponseInfo *resp))success
             failure:(void (^)(ResponseInfo *resp))failure;

- (void)doClearDeviceData:(void (^)(ResponseInfo *resp))success
                  failure:(void (^)(ResponseInfo *resp))failure;

- (void)doInitialDevice:(void (^)(ResponseInfo *resp))success
                failure:(void (^)(ResponseInfo *resp))failure;

- (void)doDFU:(void (^)(int progressValue))progress
      success:(void (^)(ResponseInfo *resp))success
      failure:(void (^)(ResponseInfo *resp))failure;

- (void)doFindMyCare:(NSInteger)vibrationCount
             success:(void (^)(ResponseInfo *resp))success
             failure:(void (^)(ResponseInfo *resp))failure;

- (void)doDisconnectDevice;

- (BOOL)isBLEConnect;

- (NSInteger)getDeviceBatteryValue;

- (NSString*)getDeviceSN;

- (NSString*)getDeviceMAC;

- (NSString*)getDeviceFWVersion;

- (void)reInitInstance;

@end
