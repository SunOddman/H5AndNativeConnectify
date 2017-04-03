//
//  sdkDemoViewController.m
//  sdkDemo
//
//  Created by xiaolongzhang on 13-3-29.
//  Copyright (c) 2013年 xiaolongzhang. All rights reserved.
//  Update by BilsonChen 2016-06-01

#import "sdkDemoViewController.h"
#import "sdkCall.h"
#import "cellInfo.h"
#import "QZoneTableViewController.h"
#import "QQVipTableViewController.h"
#import "QQGroupTableViewController.h"
#import "QQApiDemoController.h"
#import <time.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CommonCrypto/CommonDigest.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "QuickDemoViewController.h"


@interface sdkDemoViewController ()
{
    FGalleryViewController  *_localGallery;
    NSInteger               _currentTableViewTag;
    BOOL _isLogined;
}

@property (nonatomic, retain)NSMutableArray *sectionName;
@property (nonatomic, retain)NSMutableArray *sectionRow;

@end

@implementation sdkDemoViewController

@synthesize sectionName = _sectionName;
@synthesize sectionRow = _sectionRow;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.sectionName = [NSMutableArray arrayWithCapacity:1];
        self.sectionRow = [NSMutableArray arrayWithCapacity:1];
        [self loadData];
        _isLogined = NO;
        _currentTableViewTag = 0;
    }

    return self;
}

- (void)loadData
{
    NSString *title = [NSString stringWithFormat:@"QQ Open SDK's demo (%@)", [TencentOAuth sdkVersion]];
    [self setTitle:title];
    
    NSMutableArray *shareFlag = [NSMutableArray arrayWithCapacity:1];
    [shareFlag addObject:[cellInfo info:@"打开TIMSDK开关。默认使用QQ。" target:self Sel:@selector(switchSdkSupport) viewController:nil]];
    [_sectionName addObject:@"SDK类型"];
    [_sectionRow addObject:shareFlag];
    
    NSMutableArray *cellLogin = [NSMutableArray arrayWithCapacity:1];
    [cellLogin addObject:[cellInfo info:@"第三方登录" target:self Sel:@selector(login) viewController:nil]];
    [[self sectionName] addObject:@"登录"];
    [[self sectionRow] addObject:cellLogin];
    
    NSMutableArray *cellApiInfo = [NSMutableArray arrayWithCapacity:3];
    [cellApiInfo addObject:[cellInfo info:@"QQ定向分享" target:self Sel:@selector(pushSelectViewController:) viewController:nil userInfo:[NSNumber numberWithInteger:kApiQQ]]];
    [cellApiInfo addObject:[cellInfo info:@"QQ空间"    target:self Sel:@selector(pushSelectViewController:) viewController:nil userInfo:[NSNumber numberWithInteger:kApiQZone]]];
    [cellApiInfo addObject:[cellInfo info:@"QQ会员"    target:self Sel:@selector(pushSelectViewController:) viewController:nil userInfo:[NSNumber numberWithInteger:kApiQQVip]]];
    [cellApiInfo addObject:[cellInfo info:@"QQ群"     target:self Sel:@selector(pushSelectViewController:) viewController:nil userInfo:[NSNumber numberWithInteger:kApiQQqun]]];
    
    [[self sectionName] addObject:@"api"];
    [[self sectionRow] addObject:cellApiInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessed) name:kLoginSuccessed object:[sdkCall getinstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed)    name:kLoginFailed    object:[sdkCall getinstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCancelled) name:kLoginCancelled object:[sdkCall getinstance]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    __SUPER_DEALLOC;
}

- (void)switchSdkSupport
{
    NSNumber *flag = [[NSUserDefaults standardUserDefaults] objectForKey:@"sdkSwitchFlag"];
    if (flag) {
        BOOL b = [flag boolValue];
        [[NSUserDefaults standardUserDefaults] setObject:@(!b) forKey:@"sdkSwitchFlag"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"sdkSwitchFlag"];
    }
    [self.tableView reloadData];
}

#pragma mark UIMessage
- (void)loginSuccessed
{
    if (NO == _isLogined)
    {
        _isLogined = YES;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结果" message:@"登录成功" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
}

- (void)loginFailed
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结果" message:@"登录失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
}

- (void) loginCancelled
{
    NSLog(@"Login Canceled !");
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionName count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sectionRow objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:CellIdentifier];
    }
    
    NSString *title = nil;
    NSMutableArray *array = [[self sectionRow] objectAtIndex:section];
    if ([array isKindOfClass:[NSMutableArray class]])
    {
        title = [[array objectAtIndex:row] title];
    }
    
    if (nil == title)
    {
        title = @"未知";
    }
    
    [[cell textLabel] setText:title];
    [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
    if (indexPath.section == 0) {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkSwitchFlag"] boolValue];
        UISwitch *s = [cell viewWithTag:10000];
        if (!s) {
            s = [[UISwitch alloc] init];
            s.tag = 10000;
            [s addTarget:self action:@selector(switchSdkSupport) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = s;
        }
        s.on = flag;
    }
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionName objectAtIndex:section];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    NSArray *array = [[self sectionRow] objectAtIndex:section];
    if ([array isKindOfClass:[NSMutableArray class]])
    {
        cellInfo *info = (cellInfo *)[array objectAtIndex:row];
        if ([self respondsToSelector:[info sel]])
        {
            if (nil == [info userInfo])
            {
                [self performSelector:[info sel]];
            }
            else
            {
                [self performSelector:[info sel] withObject:[info userInfo]];
            }
        }
    }
    
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:NO];
}

#pragma mark - 第三方授权登陆操作示例
- (TencentAuthShareType)getAuthType
{
    BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkSwitchFlag"] boolValue];
    return flag? AuthShareType_TIM :AuthShareType_QQ;
}
- (void)login
{
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            nil];
    
    [[[sdkCall getinstance] oauth] setAuthShareType:[self getAuthType]];
    [[[sdkCall getinstance] oauth] authorize:permissions inSafari:NO];
    
    //授权前是必须要注册appId的，这个demo吧这个操作封装在 [sdkCall getinstance]里了
    //开发者不要忘记调用 [[TencentOAuth alloc] initWithAppId:你的APPID andDelegate:self]; 哦~
}

#pragma mark - 各种API操作示例
- (void)pushSelectViewController:(NSNumber *)apiType
{
    UIViewController *rootViewController = nil;
    switch ([apiType unsignedIntegerValue]) {
        case kApiQQ: //QQ定向分享API
            rootViewController = [[QQApiDemoController alloc] init];
            break;
        case kApiQZone: //QQ空间API
            rootViewController = [[QZoneTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            break;
        case kApiQQVip: //QQ会员API
            rootViewController = [[QQVipTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            break;
        case kApiQQqun: //QQ群API
            rootViewController = [[QQGroupTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            break;
        default:
            break;
    }
    [[self navigationController] pushViewController:rootViewController animated:YES];
    __RELEASE(rootViewController);
}

@end
