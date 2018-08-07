/**
 * Project : GoFIT SDK
 * 
 * Demo App for GoFIT SDK.
 *
 * @author Rik Tsai <rik.tsai@goyourlife.com>
 * @link http://www.goyourlife.com
 * @copyright Copyright &copy; 2018 GOYOURLIFE INC.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, E_RESPONSE_CODE)
{
    // Reserverd
    HTTP_REQUEST_FAIL = 0,                        // Http request fail
    SDK_OK = 1,
    
    // BLE
    BLE_CMD_OK = 10,                              // BLE command OK
    BLE_NOT_ENABLE,                               // BLE not enable
    BLE_CONNECT_FAIL,                             // BLE connect fail
    DEVICE_DISCONNECT,                            // Device disconnect
    DEVICE_PAIRING_FAIL,                          // Pairing fail
    DEVICE_PAIRING_CODE_NOT_FOUND,                // Pairing code not found, do new pairing first
    DEVICE_ALREADY_PAIRED,                        // Device already paired, forget device first
    DEVICE_RELEASE_PAIR_FAIL,                     // Release pair fail
    BLE_SETTING_FORMAT_ERROR,                     // Setting format error
    DEVICE_NOT_SUPPORT_JUMP_BOOTLOADER,           // Device is not support jumping to bootloader
    DFU_APP_MODE_ERROR,                           // DFU with App mode error
    MESSAGE_TYPE_NON_EXISTENT_OR_NOT_IMPLEMENTED, // Message type non existent or not implemented
    PAIRING_NEEDED,                               // Pairing needed
    AUTHORIZATION_NEEDED,                         // Authorization needed
    ANCS_BONDING_FAIL,                            // ANCS bonding fail
    START_TRANSMISSION_FAIL,                      // GoWatch Start transmission fail
    GET_ACTIVITY_SUMMARY_FAIL,                    // GoWatch Get activity summary fail
    GET_NMEA_FAIL,                                // GoWatch Get NMEA fail
    DEVICE_NOT_FOUND,
    WRITE_COMMAND_TO_DEVICE_TIMEOUT,
    PAIRING_CODE_MISMATCH,
    DEVICE_FIRMWARE_UPDATE_FAILED,
    DEVICE_FIRMWARE_UPDATE_PROGRESSING,
    OTHER_DEVICE_SYNCING,
    
    // Cloud
    GOLiFE_RESULT_OK = 200,
    GOLiFE_RESULT_REDIRECTION_FOUND = 302,
    GOLiFE_RESULT_BAD_REQUEST = 400,
    GOLiFE_RESULT_UNAUTHORIZED = 401,
    GOLiFE_RESULT_FORBIDDEN = 403,
    GOLiFE_RESULT_NOT_FOUND = 404,
    GOLiFE_RESULT_CONFLICT = 409,
    GOLiFE_RESULT_SERVER_ERROR = 500,
    GOLiFE_RESULT_CONNECTION_ERROR = 520,
    
    // App
    USER_CANCEL = 600,                            // User operation cancelled
    DEVICE_NETWORK_NOT_ENABLE,                    // Device network is not enable
    DEVICE_NETWORK_SUPPORT_ONLY_WIFI,             // Only support WiFi enviorment
    EMAIL_NOT_VALID,                              // Email format is not valid
    PASSWORD_NOT_ENOUGH,                          // Password less than 8 characters
    REGISTER_ACCOUNT_ALREADY_EXIST,               // Register account already exist
    LOGIN_ACCOUNT_OR_PASSWORD_ERROR,              // Login account or password error
    THIRD_PARTY_TYPE_ERROR,                       // Third party type error
    COMPONENT_INITIAL_ERROR,                      // Component initial error
    PARSER_DATA_ERROR,                            // Parsing data error
    GET_EXCEPTION,                                // Get exception
    WECHAT_APP_DO_NOT_EXIST,                      // Wechat App not exist
    SOURCE_TYPE_ERROR,                            // data source type error
    PASSWORD_NOT_THE_SAME,                        // Password is not the same
    DEVICE_API_NOT_SUPPORT,                       // Device API is not supported
    API_PARAMETER_ERROR,                          // API parameter error
    DATABASE_NO_AFFECT,
    SHARE_TO_QQ_NOT_SUPPORT_IMAGE_OBJECT,
    CANNOT_REGISTER_RECEIVER,
    WRITE_DATABASE_FAILED,
    SYNC_IS_ALREADY_START,
    SDK_AUTHENTICATION_FAIL,
    SDK_AUTHENTICATION_EXPIRED
};

typedef void (^CompletionHandler)(E_RESPONSE_CODE, id);

@interface ResponseInfo : NSObject

@property (nonatomic, retain) NSNumber * responseCode;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) id responseObject;

@end

@interface NSDateFormatter(Locale)

- (id)initWithSafeLocale;

@end

#pragma mark -
#pragma mark Raw Data Format

@interface FitnessStep : NSObject

@property (nonatomic, retain) NSNumber * timestamp;   // Unix Time, i.e., number of seconds that have elapsed since 00:00:00 UTC time, 1 January 1970
@property (nonatomic, retain) NSNumber * distance;    // distance, unit : m
@property (nonatomic, retain) NSNumber * calories;    // unit : 大卡
@property (nonatomic, retain) NSNumber * steps;       // step counts

@end

@interface FitnessSleep : NSObject

@property (nonatomic, retain) NSNumber * timestamp;   // Unix Time, i.e., number of seconds that have elapsed since 00:00:00 UTC time, 1 January 1970
@property (nonatomic, retain) NSNumber * score;       // 睡眠分數：0~5，0為深眠，5為淺眠

@end

@interface FitnessHR : NSObject

@property (nonatomic, retain) NSNumber * timestamp;   // Unix Time, i.e., number of seconds that have elapsed since 00:00:00 UTC time, 1 January 1970
@property (nonatomic, retain) NSNumber * pulse;       // Heart Rate counts

@end

#pragma mark -
#pragma mark BLE Device Setting

@interface DeviceSettingUserProfile : NSObject

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat weight;
@property (nonatomic) NSUInteger age;
@property (nonatomic) CGFloat footLength;
@property (nonatomic, retain) NSString * birthday;  // yyyy-MM-dd
@property (nonatomic) NSUInteger gender;            // 0 : male, 1 :female

@end

@interface DeviceSettingStepGoal : NSObject

@property (nonatomic) NSUInteger stepGoal;

@end

@interface DeviceSettingSystemUnit : NSObject

@property (nonatomic, retain) NSString * systemUnit;

@end

@interface DeviceSettingTimeFormat : NSObject

@property (nonatomic, retain) NSString * timeFormat;

@end

@interface DeviceSettingHandedness : NSObject

@property (nonatomic, retain) NSString * handedness;

@end

@interface DeviceSettingAutoLightUp : NSObject

@property (nonatomic) BOOL enable;

@end

@interface DeviceSettingDisconnectAlert : NSObject

@property (nonatomic) BOOL enable;

@end

@interface DeviceSettingANTPlus : NSObject

@property (nonatomic) BOOL enable;

@end

@interface DeviceSettingANCSReminder : NSObject

@property (nonatomic) BOOL enable;

@end

@interface DeviceSettingANCSSwitch : NSObject

@property (nonatomic) BOOL enable_IncomingCall;
@property (nonatomic) BOOL enable_SMS;
@property (nonatomic) BOOL enable_GMAIL;
@property (nonatomic) BOOL enable_Hangout;
@property (nonatomic) BOOL enable_Calendar;
@property (nonatomic) BOOL enable_Facebook;
@property (nonatomic) BOOL enable_LINE;
@property (nonatomic) BOOL enable_QQ;
@property (nonatomic) BOOL enable_WhatsApp;
@property (nonatomic) BOOL enable_WeChat;
@property (nonatomic) BOOL enable_Common;   // other else app

@end

@interface DeviceSettingHRDetect : NSObject

@property (nonatomic) BOOL enable;

@end

@interface DeviceSettingIdleAlert : NSObject

@property (nonatomic) BOOL enable;

@property (nonatomic) NSInteger repeatDays;
// bit0 : Sun
// bit1 : Mon
// bit2 : Tue
// bit3 : Wed
// bit4 : Thu
// bit5 : Fri
// bit6 : Sat

@property (nonatomic, retain) NSString * startTimeHHMM;
@property (nonatomic, retain) NSString * endTimeHHMM;
@property (nonatomic) NSInteger intervalMin;

@end

@interface DeviceSettingAlarms : NSObject

@property (nonatomic) BOOL enable;
@property (nonatomic) NSInteger clockID;
@property (nonatomic) NSInteger category;

@property (nonatomic) NSInteger repeatDays;
// bit0 : Sun
// bit1 : Mon
// bit2 : Tue
// bit3 : Wed
// bit4 : Thu
// bit5 : Fri
// bit6 : Sat

@property (nonatomic, retain) NSString * alarmEnableDate;  // YYYY-MM-dd
@property (nonatomic, retain) NSString * alarmTimeHHMM;    // HH:mm
@property (nonatomic) BOOL isActive;
@property (nonatomic, retain) NSString * alarmText;

@end

@interface DeviceSettingTimingDetectHR : NSObject

@property (nonatomic) BOOL enable;
@property (nonatomic, retain) NSString * startTimeHHMM;
@property (nonatomic, retain) NSString * endTimeHHMM;
@property (nonatomic) NSInteger intervalMin;
@property (nonatomic) NSInteger repeatDays;

@end

@interface DeviceSettingDND : NSObject

@property (nonatomic) BOOL enable;
@property (nonatomic, retain) NSString * startTimeHHMM;
@property (nonatomic, retain) NSString * endTimeHHMM;
@property (nonatomic) NSInteger repeatDays;

@end

@interface DeviceSettingLanguage : NSObject

@property (nonatomic) NSUInteger language;
// 0 : TW
// 1 : CN
// 2 : EN
// 3 : JP

@end

@interface DeviceSettingFindMyCare : NSObject

@property (nonatomic) BOOL vibrationOnOff;
@property (nonatomic) NSInteger vibrationSecond;
@property (nonatomic) BOOL vibrationRepeat;

@end

@interface DeviceSettingFindMyPhone : NSObject

@property (nonatomic) BOOL enable;
@property (nonatomic) NSInteger vibrationTime;
@property (nonatomic) BOOL soundOnOff;

@end

@interface DeviceSettingHRWarning : NSObject

@property (nonatomic) BOOL enable;
@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger minValue;

@end

@interface DeviceSettingHorizontalUnlock : NSObject

@property (nonatomic) BOOL enable;

@end
