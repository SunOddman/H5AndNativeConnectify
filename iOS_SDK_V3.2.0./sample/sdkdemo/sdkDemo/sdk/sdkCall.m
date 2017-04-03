//
//  sdkCall.m
//  sdkDemo
//
//  Created by xiaolongzhang on 13-3-29.
//  Copyright (c) 2013年 xiaolongzhang. All rights reserved.
//

#import "sdkCall.h"
#import "sdkDef.h"
#import <TencentOpenAPI/TencentMessageObject.h>
#import "RequestContentViewController.h"

static sdkCall *g_instance = nil;
@interface sdkCall()
@property (nonatomic, retain)NSArray* permissons;
@property (nonatomic, retain)RequestContentViewController *requestViewController;
@end

@implementation sdkCall

@synthesize oauth = _oauth;
@synthesize permissons = _permissons;
@synthesize photos = _photos;
@synthesize thumbPhotos = _thumbPhotos;
@synthesize requestViewController = _requestViewController;

+ (sdkCall *)getinstance
{
    @synchronized(self)
    {
        if (nil == g_instance)
        {
            g_instance = [[super allocWithZone:nil] init];
            [g_instance setPhotos:[NSMutableArray arrayWithCapacity:1]];
            [g_instance setThumbPhotos:[NSMutableArray arrayWithCapacity:1]];
        }
    }

    return g_instance;
}

- (id)init
{
    //注意： 初始化授权 开发者需要在这里填入自己申请到的 AppID
    _oauth = [[TencentOAuth alloc] initWithAppId:__TencentDemoAppid__ andDelegate:self];
    
    return self;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [[self getinstance] retain];
}

+ (void)showInvalidTokenOrOpenIDMessage
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"api调用失败" message:@"可能授权已过期，请重新获取" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (void)resetSDK
{
    g_instance = nil;
}

- (void)tencentDidLogin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessed object:self];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginCancelled object:self];
}

- (void)tencentDidNotNetWork
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailed object:self];
}

- (NSArray *)getAuthorizedPermissions:(NSArray *)permissions withExtraParams:(NSDictionary *)extraParams
{
    return nil;
}

- (void)tencentDidLogout
{

}


- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions
{
    return YES;
}


- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth
{
    return YES;
}

- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth
{
}


- (void)tencentFailedUpdate:(UpdateFailType)reason
{
}


- (void)getUserInfoResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserInfoResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}


- (void)getListAlbumResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetListAlbumResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}


- (void)getListPhotoResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetListPhotoResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}   


- (void)checkPageFansResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheckPageFansResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}


- (void)addShareResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddShareResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}


- (void)addAlbumResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddAlbumResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}

- (void)uploadPicResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUploadPicResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}

- (void)addOneBlogResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddOneBlogResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}

- (void)addTopicResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddTopicResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}


- (void)setUserHeadpicResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSetUserHeadPicResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}


- (void)getVipInfoResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetVipInfoResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}


- (void)getVipRichInfoResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetVipRichInfoResponse object:self  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}

- (void)sendStoryResponse:(APIResponse*) response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSendStoryResponse object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, kResponse, nil]];
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite userData:(id)userData
{
    
}


- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:tencentOAuth, kTencentOAuth,
                                                                        viewController, kUIViewController, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseWnd object:self  userInfo:userInfo];
}

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery
{
    return [[self photos] count];
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeLocal;
}

- (UIImage*)photoGallery:(FGalleryViewController*)gallery imageForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    if (index >= [[self photos] count])
    {
        return nil;
    }
    
    if (FGalleryPhotoSizeFullsize == size)
    {
        return [[self photos] objectAtIndex:index];
    }
    else if (FGalleryPhotoSizeThumbnail == size)
    {
        return [[self thumbPhotos] objectAtIndex:index];
    }
    
    return nil;
}

- (BOOL)onTencentReq:(TencentApiReq *)req
{
    if (_requestViewController)
    {
        if (([[[UIDevice currentDevice] systemVersion] floatValue] > 5.0))
        {
            [_requestViewController dismissViewControllerAnimated:NO completion:nil];
        }
        else
        {
            [_requestViewController dismissModalViewControllerAnimated:YES];
        }
        
        _requestViewController = nil;
    }
    
    _requestViewController = [[RequestContentViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [_requestViewController setDataSource:[req arrMessage]];
    [_requestViewController setReq:req];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_requestViewController];
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:navController animated:YES];
    
    return YES;
}

@end
