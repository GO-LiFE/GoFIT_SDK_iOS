//
//  ViewController.m
//  GoFIT_SDK_Demo
//
//  Created by Rik Tsai on 2018/6/12.
//  Copyright © 2018年 GOLiFE. All rights reserved.
//

#import "ViewController.h"
#import "GoFIT_SDK.h"
#import <AudioToolbox/AudioServices.h>
#import <UserNotifications/UserNotifications.h>

enum TAG_ALERT
{
    TAG_ALERT_SETTING_SELECTOR = 200,
    TAG_ALERT_SET_STEP_TARGET,
    TAG_ALERT_SET_UNIT,
    TAG_ALERT_SET_TIME_FORMAT,
    TAG_ALERT_SET_AUTO_SHOW_SCREEN,
    TAG_ALERT_SET_SIT_REMINDER,
    TAG_ALERT_SET_BLE_DISCONNECT_NOTIFICATION,
    TAG_ALERT_SET_HANDEDNESS,
    TAG_ALERT_SET_NEW_ALARM_CLOCK,
    TAG_ALERT_SET_HR_TIMIG_MEASURE,
    TAG_ALERT_SET_LANGUAGE,
    TAG_ALERT_SET_DND,
    TAG_ALERT_SET_SCREEN_LOCK,
    TAG_ALERT_SET_HR_WARNING,

    TAG_ALERT_CHOOSE_DEVICE,
    TAG_ALERT_PAIR_WITH_CODE
};

enum ENGINEER_MODE
{
    E_DO_SCAN = 0,
    E_DO_NEW_PAIRING,
    E_DO_BONDING_ANCS,
    E_DO_CONNECT,
    E_DO_SET_SETTING,
    E_DO_FULLY_SYNC,
    E_DO_CLEAR_FITNESS_DATA,
    E_DO_INIT_DEVICE,
    E_DO_DFU,
    E_DO_FIND_MY_PHONE,
    E_DO_FIND_MY_CARE,
    E_DO_DISCONNECT
};

enum DEVICE_STATUS
{
    E_UUID,
    E_GET_CONNECT_STATUS,
    E_GET_BATTERY_VALUE,
    E_GET_MAC,
    E_GET_SN,
    E_GET_FW_VERSION
};

enum SETTING_SELECTOR
{
    E_SET_STEP_GOAL = 1,
    E_SET_SYSTEM_UNIT,
    E_SET_TIME_FORMAT,
    E_SET_AUTO_LIGHTUP,
    E_SET_IDLE_ALERT,
    E_SET_BLE_DISCONNECT_ALERT,
    E_SET_HANDEDNESS,
    E_SET_NEW_ALARM_CLOCK,
    E_SET_HR_TIMING_MEASURE,
    E_SET_LANGUAGE,
    E_SET_DND,
    E_SET_SCREEN_LOCK,
    E_SET_HR_WARNING
};

#define Care_BLE_FUNCTION_ARRAY [NSArray arrayWithObjects :\
 @"1. Scan Device"\
,@"2. New Pairing"\
,@"3. Bonding ANCS"\
,@"4. Connect Device"\
,@"5. Device Setting"\
,@"6. Get Fitness Data"\
,@"7. Clear Data"\
,@"8. Device Data Initialization"\
,@"9. Device Firmware Update"\
,@"10. Enable Find My Phone"\
,@"11. Find My Care"\
,@"12. Device Disconnect"\
,nil]

#define DEVICE_STATUS_ARRAY [NSArray arrayWithObjects :\
@"UUID"\
,@"Connect Status"\
,@"Battery"\
,@"MAC Address"\
,@"SN"\
,@"FW Version"\
,nil]

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *m_tableView;
    __weak IBOutlet UIActivityIndicatorView *m_spinner;
    
    NSMutableString *deviceUUID;
    NSMutableString *currentProductID;
    NSMutableString *targetPairingCode;
    NSMutableString *targetPairingTime;
    NSMutableString *sdkLicense;
    NSMutableArray *candidateDevice;
    BOOL isSDKAAAOK;
    
    NSMutableString *alertMessage;
    NSMutableArray *settingArray;
    NSInteger progressDFU;
    NSInteger progressSync;
    
    GoFIT_SDK *SDK_Instance;
}

@property (nonatomic, strong) FindMyPhoneHandler findMyPhoneHandler;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    SDK_Instance = [GoFIT_SDK shareInstance];
    
    deviceUUID = [[NSMutableString alloc] init];
    currentProductID = [[NSMutableString alloc] init];
    targetPairingCode = [[NSMutableString alloc] init];
    targetPairingTime = [[NSMutableString alloc] init];
    sdkLicense = [[NSMutableString alloc] init];
    candidateDevice = [[NSMutableArray alloc] init];
    
    alertMessage = [NSMutableString string];
    settingArray = [NSMutableArray array];
    
    SDK_Instance.findMyPhoneHandler = self.findMyPhoneHandler;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"SDK";
            break;
            
        case 1:
            return @"BLE FUNCTION";
            break;
            
        case 2:
            return @"DEVICE STATUS";
            break;
            
        default:
            return @"";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
            
        case 1:
            return [Care_BLE_FUNCTION_ARRAY count];
            break;
            
        case 2:
            return [DEVICE_STATUS_ARRAY count];
            break;
            
        default:
            return 1;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section])
    {
        case 0:
            return 44;
            break;
            
        case 1:
            return 44;
            break;
            
        case 2:
            return 44;
            break;
            
        default:
            return 44;
            break;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    switch (section)
    {
        case 0:
        {
            NSString *CellIdentifier = [[NSString alloc] initWithFormat:@"SettingCell%ld%ld", (long)section, (long)row];
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
            }
            
            if (isSDKAAAOK)
            {
                cell.textLabel.text = @"SDK Authentication is OK";
            }
            else
            {
                cell.textLabel.text = @"SDK init";
            }
            
            return cell;
        }
            break;
            
        case 1:
        {
            NSString *CellIdentifier = [[NSString alloc] initWithFormat:@"SettingCell%ld%ld", (long)section, (long)row];
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = [NSString stringWithString:[Care_BLE_FUNCTION_ARRAY objectAtIndex:row]];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
            }
            
            if (row == E_DO_SCAN)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)[candidateDevice count]];
            }
            else if (row == E_DO_FULLY_SYNC)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)progressSync];
            }
            else if (row == E_DO_DFU)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%%", (int)progressDFU];
            }
            else if (row == E_DO_CONNECT)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", targetPairingCode];
            }
            
            return cell;
        }
            break;
            
        case 2:
        {
            NSString *CellIdentifier = [[NSString alloc] initWithFormat:@"SettingCell%ld%ld", (long)section, (long)row];
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = [NSString stringWithString:[DEVICE_STATUS_ARRAY objectAtIndex:row]];
                cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            }
            
            if (row == E_UUID)
            {
                cell.detailTextLabel.text = deviceUUID;
            }
            else if (row == E_GET_CONNECT_STATUS)
            {
                cell.detailTextLabel.text = [SDK_Instance isBLEConnect] ? @"Connected" : @"Disconnected";
            }
            else if (row == E_GET_BATTERY_VALUE)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)[SDK_Instance getDeviceBatteryValue]];
            }
            else if (row == E_GET_MAC)
            {
                cell.detailTextLabel.text = [SDK_Instance getDeviceMAC];
            }
            else if (row == E_GET_SN)
            {
                cell.detailTextLabel.text = [SDK_Instance getDeviceSN];
            }
            else if (row == E_GET_FW_VERSION)
            {
                cell.detailTextLabel.text = [SDK_Instance getDeviceFWVersion];
            }
            
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    // empty cell
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    switch (section)
    {
        case 0:
        {
            [self restoreDeviceInformation];
            
            // read SDK certificate from file
            NSString *crt = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client_cert" ofType:@"crt"] encoding:NSUTF8StringEncoding error:nil];
            
            __weak typeof (self) weakSelf = self;
            [SDK_Instance instantiate:crt
                           andLicense:sdkLicense
                              success:^(ResponseInfo *resp) {
                                  // TODO : Save the received license
                                  NSString *receivedLicense = resp.responseObject;
                                  NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, receivedLicense];
                                  [[NSUserDefaults standardUserDefaults] setValue:receivedLicense forKey:[NSString stringWithFormat:@"License+GoFITSDK_Demo"]];
                                  self->isSDKAAAOK = YES;
                                  [weakSelf messageShow:message];
                              }
                              failure:^(ResponseInfo *resp) {
                                  NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                                  self->isSDKAAAOK = NO;
                                  [weakSelf messageShow:message];
                              }
             ];
            
            [SDK_Instance reInitInstance];
        }
            break;
            
        case 1:
        {
            switch (row)
            {
                case E_DO_SCAN:
                {
                    [m_spinner startAnimating];
                    
                    __weak typeof (m_spinner) weakSpinner = m_spinner;
                    __weak typeof (candidateDevice) weakCandidateDevice = candidateDevice;
                    
                    [SDK_Instance doScanDevice:^(NSDictionary *device) {
                        NSLog(@"%@", device);
                    } completion:^(ResponseInfo *resp) {
                        [weakSpinner stopAnimating];
                        NSArray *devices = (NSArray*)resp.responseObject;
                        NSMutableString *message = [NSMutableString string];
                        
                        [weakCandidateDevice removeAllObjects];
                        [message appendString:@"Below devices recommended to connect:\n"];
                        [message appendString:@"-----\n"];
                        for (NSDictionary *dict in devices) {
                            NSNumber *RSSI = [dict objectForKey:@"RSSI"];
                            NSString *UUID = [dict objectForKey:@"UUID"];
                            NSString *productID = [dict objectForKey:@"productID"];
                            CBPeripheral *peri = [dict objectForKey:@"peripheral"];
                            if (RSSI.integerValue >= -85 && UUID.length > 0 && productID.length > 0) {
                                [weakCandidateDevice addObject:dict];
                                [message appendString:[NSString stringWithFormat:@"Name :「%@」\n", peri.name]];
                                [message appendString:[NSString stringWithFormat:@"UUID :「%@」\n", UUID]];
                                [message appendString:[NSString stringWithFormat:@"ProductID :「%@」\n", productID]];
                                [message appendString:[NSString stringWithFormat:@"RSSI : %@\n", RSSI]];
                                [message appendString:@"-----\n"];
                            }
                        }
                        
                        [self messageShow:message];
                    } failure:^(ResponseInfo *resp) {
                        [weakSpinner stopAnimating];
                        NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                        [self messageShow:message];
                    }];
                }
                    break;
                
                case E_DO_NEW_PAIRING:
                {
                    if ([candidateDevice count] > 0)
                    {
                        NSMutableString *message = [NSMutableString string];
                        int deviceIndex = 1;
                        [message appendString:@"-----\n"];
                        for (NSDictionary *dict in candidateDevice) {
                            NSNumber *RSSI = [dict objectForKey:@"RSSI"];
                            NSString *UUID = [dict objectForKey:@"UUID"];
                            NSString *productID = [dict objectForKey:@"productID"];
                            CBPeripheral *peri = [dict objectForKey:@"peripheral"];
                            if (RSSI.integerValue >= -70 && UUID.length > 0 && productID.length > 0) {
                                [message appendString:[NSString stringWithFormat:@"[%d]\n", deviceIndex]];
                                [message appendString:[NSString stringWithFormat:@"Name :「%@」\n", peri.name]];
                                [message appendString:[NSString stringWithFormat:@"UUID :「%@」\n", UUID]];
                                [message appendString:[NSString stringWithFormat:@"ProductID :「%@」\n", productID]];
                                [message appendString:[NSString stringWithFormat:@"RSSI : %@\n", RSSI]];
                                [message appendString:@"-----\n"];
                                deviceIndex++;
                            }
                        }
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose the `index` of devices to do new pairing"
                                                                        message:message
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        
                        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [alert setTag:TAG_ALERT_CHOOSE_DEVICE];
                        [alert show];
                    }
                    else
                    {
                        [self messageShow:@"`Scan Device` first"];
                    }
                }
                    break;
                
                case E_DO_BONDING_ANCS:
                {
                    [SDK_Instance
                     doBondingANCS:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }
                     failure:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }];
                }
                    break;
                    
                case E_DO_CONNECT:
                {
                    if ([currentProductID length] != 0)
                    {
                        [m_spinner startAnimating];
                        __weak typeof (m_spinner) weakSpinner = m_spinner;
                        
                        if ([deviceUUID length] == 0)
                        {
                            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deviceUUID+GoFITSDK_Demo"] != nil)
                            {
                                [deviceUUID setString:[[NSUserDefaults standardUserDefaults] valueForKey:@"deviceUUID+GoFITSDK_Demo"]];
                            }
                        }
                        
                        [SDK_Instance
                         doConnectDevice:deviceUUID
                         andProductID:currentProductID
                         andPairingCode:targetPairingCode
                         andPairingTime:targetPairingTime
                         success:^(ResponseInfo *resp) {
                             [weakSpinner stopAnimating];
                             NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                             [self messageShow:message];
                         }
                         failure:^(ResponseInfo *resp) {
                             [weakSpinner stopAnimating];
                             NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                             [self messageShow:message];
                         }];
                    }
                    else
                    {
                        [self messageShow:@"`New Pairing` first"];
                    }
                }
                    break;
                    
                case E_DO_SET_SETTING:
                {
                    if ([currentProductID length] != 0)
                    {
                        if ([SDK_Instance isBLEConnect])
                        {
                            [settingArray removeAllObjects];
                            
                            [alertMessage setString:@"** `GoWatch series` only support [Step Target] setting **\n\n1 : Step Target\n2 : Unit\n3 : Time Format\n4 : Auto Show Screen\n5 : Sit Reminder\n6 : BLE Disconnect Notification\n7 : Handedness\n8 : Alarm Clock\n9 : HR Timing Measure\n10 : Language\n11 : Do Not Disturb\n12 : Screen Lock\n13 : HR Warning\n\n999 : Set setting to device"];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                            message:alertMessage
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            
                            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                            [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                            [alert show];
                        }
                        else
                        {
                            [self messageShow:@"`Connect Device` first"];
                        }
                    }
                    else
                    {
                        [self messageShow:@"`New Pairing` first"];
                    }
                }
                    break;
                    
                case E_DO_FULLY_SYNC:
                {
                    progressSync = 0;
                    [m_tableView reloadData];
                    
                    [m_spinner startAnimating];
                    __weak typeof (self) weakSelf = self;
                    __weak typeof (m_spinner) weakSpinner = m_spinner;
                    
                    [SDK_Instance
                        doSyncFitnessData:^(int progressValue) {
                            [weakSelf updateSyncProgress:progressValue];
                        }
                        success:^(ResponseInfo *resp) {
                            [weakSpinner stopAnimating];
                            NSDictionary *dict = (NSDictionary*)resp.responseObject;
                            if ([dict objectForKey:@"GoWatchSeries"] == NULL)
                            {
                                NSArray *stepArray = [dict objectForKey:@"stepArray"];
                                NSArray *sleepArray = [dict objectForKey:@"sleepArray"];
                                NSArray *hrArray = [dict objectForKey:@"hrArray"];
                                NSArray *spo2Array = [dict objectForKey:@"spO2Array"];

                                NSMutableString *message = [NSMutableString string];
                                for (FitnessStep *step in stepArray)
                                {
                                    [message appendString:[NSString stringWithFormat:@"Step Record : {\n"]];
                                    [message appendString:[NSString stringWithFormat:@"   timestamp : %@\n", step.timestamp]];
                                    [message appendString:[NSString stringWithFormat:@"   steps : %@\n", step.steps]];
                                    [message appendString:[NSString stringWithFormat:@"   distance : %@\n", step.distance]];
                                    [message appendString:[NSString stringWithFormat:@"   kCal : %@\n", step.calories]];
                                    [message appendString:[NSString stringWithFormat:@"}\n"]];
                                }

                                for (FitnessSleep *sleep in sleepArray)
                                {
                                    [message appendString:[NSString stringWithFormat:@"Sleep Record : {\n"]];
                                    [message appendString:[NSString stringWithFormat:@"   timestamp : %@\n", sleep.timestamp]];
                                    [message appendString:[NSString stringWithFormat:@"   score : %@\n", sleep.score]];
                                    [message appendString:[NSString stringWithFormat:@"}\n"]];
                                }

                                for (FitnessHR *hr in hrArray)
                                {
                                    [message appendString:[NSString stringWithFormat:@"HR Record : {\n"]];
                                    [message appendString:[NSString stringWithFormat:@"   timestamp : %@\n", hr.timestamp]];
                                    [message appendString:[NSString stringWithFormat:@"   pulse : %@\n", hr.pulse]];
                                    [message appendString:[NSString stringWithFormat:@"}\n"]];
                                }
                                
                                for (FitnessSpO2 *spo2 in spo2Array)
                                {
                                    [message appendString:[NSString stringWithFormat:@"SpO2 Record : {\n"]];
                                    [message appendString:[NSString stringWithFormat:@"   timestamp : %@\n", spo2.timestamp]];
                                    [message appendString:[NSString stringWithFormat:@"   SpO2 : %@\n", spo2.spo2]];
                                    [message appendString:[NSString stringWithFormat:@"}\n"]];
                                }

                                NSLog(@"%@", message);
                                [self messageShow:message];
                            }
                            else
                            {
                                NSArray *recordArray = [dict objectForKey:@"recordArray"];
                                NSMutableString *message = [NSMutableString string];
                                int i = 0;
                                for (FitnessActivity *record in recordArray)
                                {
                                    [message appendString:[NSString stringWithFormat:@"Activity Record (%d) : {\n", i]];
                                    [message appendString:[NSString stringWithFormat:@"   timestamp : %@\n", record.startRecordTime]];
                                    [message appendString:[NSString stringWithFormat:@"   typeID : %@\n", record.typeID]];
                                    [message appendString:[NSString stringWithFormat:@"   stats : %@\n", record.stats]];
                                    [message appendString:[NSString stringWithFormat:@"}\n"]];
                                    
                                    NSLog(@"%@", message);
                                    
                                    NSArray *gpsData = record.gpsData;
                                    int j = 0;
                                    for (NSDictionary *item in gpsData)
                                    {
                                        NSLog(@"GPS Data (%d)(%d) : %@", i, j, item);
                                        j++;
                                    }
                                    
                                    j = 0;
                                    NSArray *lapStatsData = record.lapStatsData;
                                    for (NSDictionary *item in lapStatsData)
                                    {
                                        NSLog(@"Lap Data (%d)(%d) : %@", i, j, item);
                                        j++;
                                    }
                                    
                                    [message appendString:[NSString stringWithFormat:@"-----\n"]];                                    
                                    i++;
                                }
                                
                                [message appendString:[NSString stringWithFormat:@"* Detail GPS & Lap data please check in NSLog\n"]];
                                [self messageShow:message];
                            }
                        }
                        failure:^(ResponseInfo *resp) {
                            [weakSpinner stopAnimating];
                            NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                            [self messageShow:message];
                        }
                    ];
                }
                    break;
                
                case E_DO_CLEAR_FITNESS_DATA:
                {
                    [SDK_Instance
                     doClearDeviceData:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }
                     failure:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }];
                }
                    break;
                    
                case E_DO_INIT_DEVICE:
                {
                    [SDK_Instance
                     doInitialDevice:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }
                     failure:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }];
                }
                    break;
                    
                case E_DO_DFU:
                {
                    progressDFU = 0;
                    [m_tableView reloadData];
                    
                    __weak typeof (self) weakSelf = self;
                    [SDK_Instance
                     doDFU:^(int progressValue) {
                         [weakSelf updateDFUProgress:progressValue];
                     }
                     success:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }
                     failure:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }];
                }
                    break;
                
                case E_DO_FIND_MY_PHONE:
                {
                    // 本地推播隱私權
                    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                        
                        NSString *message = @"Switch your Care smart band to `Find my phone` view.\n\nIf notification doesn't work, please check Desktop > `Settings` > `Notifications` > `GoFIT_SDK_Demo` > `Allow Notifications` ";
                        [self messageShow:message];
                    }
                    
                }
                    break;
                
                case E_DO_FIND_MY_CARE:
                {
                    NSInteger vibrationCount = 5;
                    
                    [SDK_Instance
                     doFindMyCare:vibrationCount
                     success:^(ResponseInfo *resp) {
                         
                     }
                     failure:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }];
                }
                    break;
                    
                case E_DO_DISCONNECT:
                {
                    [deviceUUID setString:@""];
                    [SDK_Instance doDisconnectDevice];
                    [m_tableView reloadData];
                }
                    break;
                
                default:
                    break;
            }
        }
            break;
            
        case 2:
        {
            switch (row)
            {                    
                case E_GET_CONNECT_STATUS:
                case E_GET_BATTERY_VALUE:
                {
                    [m_tableView reloadData];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    [m_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (FindMyPhoneHandler)findMyPhoneHandler
{
    if (_findMyPhoneHandler == nil)
    {
        _findMyPhoneHandler = ^() {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
            {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
                {
                    UNUserNotificationCenter * notifCenter = [UNUserNotificationCenter currentNotificationCenter];
                    
                    // Content
                    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                    content.title = @"";
                    content.body = [NSString stringWithFormat:NSLocalizedString(@"Find My Phone", @"")];
                    content.sound = [UNNotificationSound defaultSound];
                    
                    // Trigger
                    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
                    
                    // Identifier
                    NSString *identifier = @"GoFIT_SDK_Notification";
                    
                    UNNotificationRequest *terminateRequest = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
                    
                    [notifCenter addNotificationRequest:terminateRequest withCompletionHandler:^(NSError * _Nullable error) {
                        if (error != nil) {
                            NSLog(@"Error %@: %@", identifier,error);
                        }
                    }];
                }
                else
                {
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertAction = @"Show";
                    notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Find My Phone", @"")];
                    notification.hasAction = NO;
                    notification.timeZone = [NSTimeZone localTimeZone];
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    notification.fireDate = [NSDate date];
                    NSMutableArray *alarms = [NSMutableArray array];
                    [alarms addObject:notification];
                    [[UIApplication sharedApplication] setScheduledLocalNotifications:alarms];
                }
            }
            else
            {
                AudioServicesPlaySystemSound(1331);
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        };
    }
    
    return _findMyPhoneHandler;
}

#pragma mark -
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_CHOOSE_DEVICE)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            if ([strInput rangeOfCharacterFromSet:notDigits].location == NSNotFound && strInput.length > 0)
            {
                NSInteger index = strInput.integerValue;
                if (index <= [candidateDevice count])
                {
                    NSDictionary *dict = [candidateDevice objectAtIndex:index-1];
                    NSString *theUUID = [dict objectForKey:@"UUID"];
                    NSString *theProductID = [dict objectForKey:@"productID"];
                    [deviceUUID setString:theUUID];
                    [currentProductID setString:theProductID];
                    
                    __weak typeof (targetPairingCode) weakTargetPairingCode = targetPairingCode;
                    __weak typeof (targetPairingTime) weakTargetPairingTime = targetPairingTime;
                    __weak typeof (deviceUUID) weakDeviceUUID = deviceUUID;
                    __weak typeof (currentProductID) weakCurrentProductID = currentProductID;
                    
                     [SDK_Instance
                     doNewPairing:theUUID
                     andProductID:theProductID
                     success:^(ResponseInfo *resp) {
                         NSDictionary *dict = (NSDictionary*)resp;
                         if ([dict objectForKey:@"pairingCode"] != NULL) {
                             [weakTargetPairingCode setString:[dict objectForKey:@"pairingCode"]];
                             [weakTargetPairingTime setString:[dict objectForKey:@"pairingTime"]];
                             
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                             message:@"Input Pairing Code:"
                             delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
                         
                             alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                             [alert setTag:TAG_ALERT_PAIR_WITH_CODE];
                             [alert show];
                         }
                         else {
                             [[NSUserDefaults standardUserDefaults] setValue:weakDeviceUUID forKey:[NSString stringWithFormat:@"deviceUUID+GoFITSDK_Demo"]];
                             [[NSUserDefaults standardUserDefaults] setValue:weakCurrentProductID forKey:[NSString stringWithFormat:@"currentProductID+GoFITSDK_Demo"]];
                             NSString *message = [NSString stringWithFormat:@"message = %@", resp];
                             [self messageShow:message];
                         }
                     }
                     failure:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }];
                }
                else
                {
                    NSString *message = @"Input index is out of range!";
                    [self messageShow:message];
                }
            }
            else
            {
                NSString *message = @"Input is not number format!";
                [self messageShow:message];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_PAIR_WITH_CODE)
    {
        if (buttonIndex == 0)
        {
            __weak typeof (deviceUUID) weakDeviceUUID = deviceUUID;
            __weak typeof (currentProductID) weakCurrentProductID = currentProductID;
            __weak typeof (targetPairingTime) weakTargetPairingTime = targetPairingTime;
            
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            [SDK_Instance
             confirmPairingCode:strInput
             andPairingTime:targetPairingTime
             andProductID:currentProductID
             success:^(ResponseInfo *resp) {
                 
                 [[NSUserDefaults standardUserDefaults] setValue:strInput forKey:[NSString stringWithFormat:@"PairingCode+GoFITSDK_Demo"]];
                 [[NSUserDefaults standardUserDefaults] setValue:weakTargetPairingTime forKey:[NSString stringWithFormat:@"PairingTime+GoFITSDK_Demo"]];
                 [[NSUserDefaults standardUserDefaults] setValue:weakDeviceUUID forKey:[NSString stringWithFormat:@"deviceUUID+GoFITSDK_Demo"]];
                 [[NSUserDefaults standardUserDefaults] setValue:weakCurrentProductID forKey:[NSString stringWithFormat:@"currentProductID+GoFITSDK_Demo"]];
                 
                 NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                 [self messageShow:message];
             }
             failure:^(ResponseInfo *resp) {
                 NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                 [self messageShow:message];
             }];
        }
    }
    else if (alertView.tag == TAG_ALERT_SETTING_SELECTOR)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSInteger selector = [strInput integerValue];
            switch (selector)
            {
                case E_SET_STEP_GOAL:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [Target Steps]\ne.g : 8000"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_STEP_TARGET];
                    [alert show];
                }
                    break;
                    
                case E_SET_SYSTEM_UNIT:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [\"imperial\"/\"metric\"]\ne.g : imperial"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_UNIT];
                    [alert show];
                }
                    break;
                    
                case E_SET_TIME_FORMAT:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [\"12\"/\"24\"]\ne.g : 12"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_TIME_FORMAT];
                    [alert show];
                }
                    break;
                    
                case E_SET_AUTO_LIGHTUP:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [0:off/1:on]\ne.g : 1"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_AUTO_SHOW_SCREEN];
                    [alert show];
                }
                    break;
                    
                case E_SET_IDLE_ALERT:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [on/off], [repeatDays(0~127 bit operator)], [HH:mm(startTime)], [HH:mm(endTime)], [IntervalMin]\ne.g : on,127,09:30,18:30,15"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_SIT_REMINDER];
                    [alert show];
                }
                    break;
                    
                case E_SET_BLE_DISCONNECT_ALERT:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [0:off/1:on]\ne.g : 1"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_BLE_DISCONNECT_NOTIFICATION];
                    [alert show];
                }
                    break;
                    
                case E_SET_HANDEDNESS:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [\"left\"/\"right\"]\ne.g : left"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_HANDEDNESS];
                    [alert show];
                }
                    break;
                    
                case E_SET_NEW_ALARM_CLOCK:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [clockID(0~29)], [on/off], [repeatDays(0~127 bit operator)], [HH:mm], [Category]\ne.g : 2,on,0,07:30,0"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_NEW_ALARM_CLOCK];
                    [alert show];
                }
                    break;
                    
                case E_SET_HR_TIMING_MEASURE:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [on/off], [HH:mm(startTime)], [HH:mm(endTime)], [IntervalMin]\ne.g : on,00:00,23:59,15"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_HR_TIMIG_MEASURE];
                    [alert show];
                }
                    break;
                    
                case E_SET_LANGUAGE:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [0:TW/1:CN/2:EN/3:JP]\ne.g : 2"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_LANGUAGE];
                    [alert show];
                }
                    break;
                    
                case E_SET_DND:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [0:off/1:on]\ne.g : 1"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_DND];
                    [alert show];
                }
                    break;
                    
                case E_SET_SCREEN_LOCK:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [0:off/1:on]\ne.g : 1"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_SCREEN_LOCK];
                    [alert show];
                }
                    break;
                    
                case E_SET_HR_WARNING:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"format : [on/off], [max warning], [min warning]\ne.g : on,170,50 (max value must larger than min value)"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert setTag:TAG_ALERT_SET_HR_WARNING];
                    [alert show];
                }
                    break;
                    
                case 999:
                {
                    [SDK_Instance
                     doSetSetting:settingArray
                     success:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }
                     failure:^(ResponseInfo *resp) {
                         NSString *message = [NSString stringWithFormat:@"code = %@\n message = %@", resp.responseCode, resp.message];
                         [self messageShow:message];
                     }];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_STEP_TARGET)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            DeviceSettingStepGoal *stepGoal = [[DeviceSettingStepGoal alloc] init];
            stepGoal.stepGoal = [strInput integerValue];
            [settingArray addObject:stepGoal];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert setTag:TAG_ALERT_SETTING_SELECTOR];
            [alert show];
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_UNIT)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            DeviceSettingSystemUnit *unit = [[DeviceSettingSystemUnit alloc] init];
            unit.systemUnit = strInput;
            [settingArray addObject:unit];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert setTag:TAG_ALERT_SETTING_SELECTOR];
            [alert show];
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_TIME_FORMAT)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            DeviceSettingTimeFormat *format = [[DeviceSettingTimeFormat alloc] init];
            format.timeFormat = strInput;
            [settingArray addObject:format];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert setTag:TAG_ALERT_SETTING_SELECTOR];
            [alert show];
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_AUTO_SHOW_SCREEN)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSInteger setting = [strInput integerValue];
            if (setting == 0 || setting == 1)
            {
                DeviceSettingAutoLightUp *autoLight = [[DeviceSettingAutoLightUp alloc] init];
                autoLight.enable = setting;
                [settingArray addObject:autoLight];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
            }
            else
            {
                NSString *message = @"format error!";
                [self messageShow:message];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_SIT_REMINDER)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSArray *items = [strInput componentsSeparatedByString:@","];
            if ([items count] == 5)
            {
                DeviceSettingIdleAlert *idle = [[DeviceSettingIdleAlert alloc] init];
                
                NSString *strOnOff = [items objectAtIndex:0];
                NSInteger sitReminderOnOff = [strOnOff isEqualToString:@"on"] ? 1 : 0;
                NSInteger repeatDay = [[items objectAtIndex:1] integerValue];
                NSInteger intervalMin = [[items objectAtIndex:4] integerValue];
                
                for(int i=2;i<4;i++)
                {
                    NSString *timeHHmm = [items objectAtIndex:i];
                    
                    if(i==2)
                        idle.startTimeHHMM = timeHHmm;
                    else if(i==3)
                        idle.endTimeHHMM = timeHHmm;
                }
                
                idle.enable = sitReminderOnOff;
                idle.repeatDays = repeatDay;
                idle.intervalMin = intervalMin;
                [settingArray addObject:idle];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
            }
            else
            {
                NSString *message = @"format error!";
                [self messageShow:message];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_BLE_DISCONNECT_NOTIFICATION)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSInteger setting = [strInput integerValue];
            if (setting == 0 || setting == 1)
            {
                DeviceSettingDisconnectAlert *disconnectAlert = [[DeviceSettingDisconnectAlert alloc] init];
                disconnectAlert.enable = setting;
                [settingArray addObject:disconnectAlert];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
            }
            else
            {
                NSString *message = @"format error!";
                [self messageShow:message];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_HANDEDNESS)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            DeviceSettingHandedness *hand = [[DeviceSettingHandedness alloc] init];
            hand.handedness = strInput;
            [settingArray addObject:hand];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert setTag:TAG_ALERT_SETTING_SELECTOR];
            [alert show];
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_NEW_ALARM_CLOCK)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSArray *items = [strInput componentsSeparatedByString:@","];
            if ([items count] == 5)
            {
                NSInteger clockID = [[items objectAtIndex:0] integerValue];
                NSString *strOnOff = [items objectAtIndex:1];
                NSInteger repeatDay = [[items objectAtIndex:2] integerValue];
                NSString *timeHHmm = [items objectAtIndex:3];
                NSInteger category = [[items objectAtIndex:4] integerValue];
                NSInteger alarmOnOff = [strOnOff isEqualToString:@"on"] ? 1 : 0;
                
                DeviceSettingAlarms *alarm = [[DeviceSettingAlarms alloc] init];
                alarm.enable = alarmOnOff;
                alarm.clockID = clockID;
                alarm.repeatDays = repeatDay;
                alarm.alarmTimeHHMM = timeHHmm;
                alarm.category = category;
                alarm.isActive = YES;
                [settingArray addObject:alarm];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
                
            }
            else
            {
                NSString *message = @"format error!";
                [self messageShow:message];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_HR_TIMIG_MEASURE)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSArray *items = [strInput componentsSeparatedByString:@","];
            if ([items count] == 4)
            {
                DeviceSettingTimingDetectHR *measure = [[DeviceSettingTimingDetectHR alloc] init];
                
                BOOL enable = [[items objectAtIndex:0] isEqualToString:@"on"] ? YES : NO;
                NSInteger intervalMin = [[items objectAtIndex:3] integerValue];
                
                for(int i=1;i<3;i++)
                {
                    NSString *timeHHmm = [items objectAtIndex:i];
                    
                    if(i==1)
                        measure.startTimeHHMM = timeHHmm;
                    else if(i==2)
                        measure.endTimeHHMM = timeHHmm;
                }
                
                measure.enable = enable;
                measure.intervalMin = intervalMin;
                measure.repeatDays = 127;
                [settingArray addObject:measure];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"format error!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_LANGUAGE)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSInteger setting = [strInput integerValue];
            if (setting >= 0 && setting <= 3)
            {
                DeviceSettingLanguage *lang = [[DeviceSettingLanguage alloc] init];
                lang.language = setting;
                [settingArray addObject:lang];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"format error!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_DND)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSInteger setting = [strInput integerValue];
            if (setting == 0 || setting == 1)
            {
                DeviceSettingDND *dnd = [[DeviceSettingDND alloc] init];
                dnd.enable = (setting == 1) ? YES : NO;
                dnd.startTimeHHMM = @"22:00";
                dnd.endTimeHHMM = @"07:30";
                dnd.repeatDays = 127;
                
                [settingArray addObject:dnd];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"format error!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_SCREEN_LOCK)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSInteger setting = [strInput integerValue];
            if (setting == 0 || setting == 1)
            {
                DeviceSettingHorizontalUnlock *screenLock = [[DeviceSettingHorizontalUnlock alloc] init];
                screenLock.enable = (setting == 1) ? YES : NO;
                
                [settingArray addObject:screenLock];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"format error!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    
    else if (alertView.tag == TAG_ALERT_SET_HR_WARNING)
    {
        if (buttonIndex == 0)
        {
            NSString *strInput = [alertView textFieldAtIndex:0].text;
            NSArray *items = [strInput componentsSeparatedByString:@","];
            if ([items count] == 3)
            {
                BOOL enable = [[items objectAtIndex:0] isEqualToString:@"on"] ? YES : NO;
                NSInteger maxWarning = [[items objectAtIndex:1] integerValue];
                NSInteger minWarning = [[items objectAtIndex:2] integerValue];
                
                DeviceSettingHRWarning *warning = [[DeviceSettingHRWarning alloc] init];
                warning.enable = enable;
                warning.maxValue = maxWarning;
                warning.minValue = minWarning;
                [settingArray addObject:warning];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert setTag:TAG_ALERT_SETTING_SELECTOR];
                [alert show];
                
            }
            else
            {
                NSString *message = @"format error!";
                [self messageShow:message];
            }
        }
    }
}

#pragma mark -
#pragma mark Other Function

-(void)restoreDeviceInformation
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PairingCode+GoFITSDK_Demo"] != nil)
    {
        [targetPairingCode setString:[[NSUserDefaults standardUserDefaults] valueForKey:@"PairingCode+GoFITSDK_Demo"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PairingTime+GoFITSDK_Demo"] != nil)
    {
        [targetPairingTime setString:[[NSUserDefaults standardUserDefaults] valueForKey:@"PairingTime+GoFITSDK_Demo"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deviceUUID+GoFITSDK_Demo"] != nil)
    {
        [deviceUUID setString:[[NSUserDefaults standardUserDefaults] valueForKey:@"deviceUUID+GoFITSDK_Demo"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"currentProductID+GoFITSDK_Demo"] != nil)
    {
        [currentProductID setString:[[NSUserDefaults standardUserDefaults] valueForKey:@"currentProductID+GoFITSDK_Demo"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"License+GoFITSDK_Demo"] != nil)
    {
        [sdkLicense setString:[[NSUserDefaults standardUserDefaults] valueForKey:@"License+GoFITSDK_Demo"]];
    }
}

-(void)messageShow:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [m_tableView reloadData];
}

-(void)updateSyncProgress:(NSInteger)progress
{
    progressSync = progress;
    [m_tableView reloadData];
}

-(void)updateDFUProgress:(NSInteger)progress
{
    progressDFU = progress;
    [m_tableView reloadData];
}

@end
