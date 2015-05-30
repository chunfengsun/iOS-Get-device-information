//
//  ViewController.m
//  获取设备信息
//
//  Created by chunfeng on 15/5/30.
//  Copyright (c) 2015年 chunfeng. All rights reserved.
//

#import "ViewController.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <dlfcn.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIColor *tintColor = [UIColor colorWithRed:80/255.0f green:219/255.0f blue:140/255.0f alpha:0.1f];
    self.navigationController.navigationBar.barTintColor = tintColor;
    // Do any additional setup after loading the view from its nib.
    
    /*
     
     获取手机信息
     
     应用程序的名称和版本号等信息都保存在mainBundle的一个字典中，用下面代码可以取出来
     
     */
    
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    
    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
    
    NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
    
    NSString*text =[NSString stringWithFormat:@"%@ %@",appName,versionNum];
    
    
    NSString * strModel = [UIDevice currentDevice].model ;
    
    NSLog(@"%@",strModel);
    
    //手机别名： 用户定义的名称
    
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    
    NSLog(@"手机别名: %@", userPhoneName);
    
    //设备名称
    
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    
    NSLog(@"设备名称: %@",deviceName );
    
    //手机系统版本
    
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    NSLog(@"手机系统版本: %@", phoneVersion);
    
    //手机型号
    
    NSString* phoneModel = [[UIDevice currentDevice] model];
    
    NSLog(@"手机型号: %@",phoneModel );
    
    //地方型号 （国际化区域名称）
    
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    
    NSLog(@"国际化区域名称: %@",localPhoneModel );
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    // 当前应用名称
    
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    NSLog(@"当前应用名称：%@",appCurName);
    
    // 当前应用软件版本 比如：1.0.1
    
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSLog(@"当前应用软件版本:%@",appCurVersion);
    
    // 当前应用版本号码 int类型
    
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    // app build版本
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
                           
    NSLog(@"当前应用版本号码：%@  build版本: %@",appCurVersionNum, app_build);
    
    
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"获取设备的唯一标示符：%@",identifier);
    
    
    NSLog(@"为系统创建一个随机的标示符：%@",[self createUUID]);
    
    [self dangqianfenbianlv];
    
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mCarrier = [NSString stringWithFormat:@"%@",[carrier carrierName]];
    
    NSString *mConnectType = [[NSString alloc] initWithFormat:@"%@",info.currentRadioAccessTechnology];
    
    NSLog(@"获取运行商的名称: %@ 获取当前网络的类型: %@",mCarrier, mConnectType);
    
    NSLog(@"获取当前信号的强弱: %d",[self getSignalLevel]);
    
}
//CTRadioAccessTechnologyGPRS         //介于2G和3G之间，也叫2.5G ,过度技术
//CTRadioAccessTechnologyEdge         //EDGE为GPRS到第三代移动通信的过渡，EDGE俗称2.75G
//CTRadioAccessTechnologyWCDMA
//CTRadioAccessTechnologyHSDPA            //亦称为3.5G(3?G)
//CTRadioAccessTechnologyHSUPA            //3G到4G的过度技术
//CTRadioAccessTechnologyCDMA1x       //3G
//CTRadioAccessTechnologyCDMAEVDORev0    //3G标准
//CTRadioAccessTechnologyCDMAEVDORevA
//CTRadioAccessTechnologyCDMAEVDORevB
//CTRadioAccessTechnologyeHRPD        //电信使用的一种3G到4G的演进技术， 3.75G
//CTRadioAccessTechnologyLTE          //接近4G

//这个貌似没有给出官方的api，但是网上有人说可以用私有的api实现，但是通不过appStore的审核
- (int)getSignalLevel
{
    void *libHandle = dlopen("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony",RTLD_LAZY);//获取库句柄
    int (*CTGetSignalStrength)(); //定义一个与将要获取的函数匹配的函数指针
    CTGetSignalStrength = (int(*)())dlsym(libHandle,"CTGetSignalStrength"); //获取指定名称的函数
    
    if(CTGetSignalStrength == NULL)
        return -1;
    else{
        int level = CTGetSignalStrength();
        dlclose(libHandle); //切记关闭库
        return level;
    }
}

- (NSString*)createUUID
{
    NSString *id = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]; 	//获取标识为"UUID"的值
    if(id == nil)
    {
        if([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0)
        {
            NSString *identifierNumber = [[NSUUID UUID] UUIDString]; 				//ios 6.0 之后可以使用的api
            [[NSUserDefaults standardUserDefaults] setObject:identifierNumber forKey:@"UUID"];	//保存为UUID
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);      				//ios6.0之前使用的api
            NSString *identifierNumber = [NSString stringWithFormat:@"%@", uuidString];
            [[NSUserDefaults standardUserDefaults] setObject:identifierNumber forKey:@"UUID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            CFRelease(uuidString);
            CFRelease(uuid);
        }
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    }
    return id;
}

//获取当前屏幕分辨率的信息
- (void)dangqianfenbianlv{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = rect.size.width * scale;
    CGFloat height = rect.size.height * scale;
    
    NSLog(@"获取当前屏幕分辨率的信息: %@--%f--%f", NSStringFromCGRect(rect),width, height);
    
    [self wanzhengxinghao];
}



- (void)wanzhengxinghao{
    ///=====  设备型号：方法一  ========
    NSString * strModel  = [UIDevice currentDevice].model;
    NSLog(@"model:%@",strModel);
    NSLog(@"localizedModel: %@", [[UIDevice currentDevice] localizedModel]);
    
    //=====   设备型号：方法二 =========
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSLog(@"systemInfo.machine:%@",deviceString);
    
    //===== 设备型号：方法三 (model)=========
    size_t size;
    sysctlbyname ("hw.machine" , NULL , &size ,NULL ,0);
    char *model = (char *)malloc(size);
    sysctlbyname ("hw.machine" , model , &size ,NULL ,0);
    NSString * strModel3 = [NSString stringWithCString: model encoding:NSUTF8StringEncoding];
    free(model);
    NSLog(@"hw.machine-model:%@",strModel3);
    
    //===== 设备型号：方法三 (machine)=========
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    NSLog(@"hw.machine-platform:%@",platform);
    
    
    NSLog(@"--getDeviceVersion: %@-\n-----%@",[self getDeviceVersion], [self platformString]);
    
    //app信息
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    //CFShow(infoDictionary);
    NSLog(@"app信息:-%@", infoDictionary);
    
    
}

- (NSString*)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self getDeviceVersion];
    
//    1.IOS 获取最新设备型号方法
//    列表最新对照表：http://theiphonewiki.com/wiki/Models
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return@"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])   return@"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return@"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return@"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return@"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return@"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM/WCDMA)";
    if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])   return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])   return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])   return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])   return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,2"])   return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])   return @"iPhone Plus";


    
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return@"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])     return@"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])     return@"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])     return@"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])     return@"iPod Touch 5G";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return@"iPad";
    if ([platform isEqualToString:@"iPad2,1"])     return@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])     return@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return@"iPad 2 New";
    if ([platform isEqualToString:@"iPad2,5"])     return@"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad3,1"])     return@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])     return@"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])     return@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])        return@"Simulator";
    
    return platform;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
