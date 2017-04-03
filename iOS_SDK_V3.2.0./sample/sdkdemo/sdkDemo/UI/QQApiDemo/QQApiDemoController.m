//
//  ViewController.m
//  QQApiInterfaceDemo
//
//  Created by Random Zhang on 12-5-16.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//  Update by BilsonChen 2016-06-02

#import "QQApiDemoController.h"
#import "TCApiObjectEditController.h"
#import "TCQRCodeGenerator.h"
#import "TencentRequest.h"

#define TCSafeRelease(__tcObj) { [__tcObj release]; __tcObj = nil; }

#define kTenpayID @"kTenpayID"

@interface QQApiDemoController () <TencentRequestDelegate>

@property (nonatomic, strong) UITableView *operationTable;
@property (nonatomic, strong) NSArray *operationList;

@property (nonatomic, strong) NSString *tenpayID;
@property (nonatomic, strong) TencentRequest *requestQRStr;
@property (nonatomic, strong) UIControl *qrcodePanel;
@property (nonatomic, strong) UIImageView *qrcodeImgView;

- (void)showQRCode:(NSString *)qrcode;
- (void)onQRCodePanelClick:(id)sender;

#if BUILD_QQAPIDEMO
- (void)handleSendResult:(QQApiSendResultCode)sendResult;
#endif

@end

@implementation QQApiDemoController

@synthesize operationTable = _operationTable;
@synthesize operationList = _operationList;

@synthesize requestQRStr = _requestQRStr;

-(void)dealloc
{
    self.requestQRStr.delegate = nil;
    [self.requestQRStr cancel];
    self.requestQRStr = nil;
    
    self.operationTable = nil;
    self.operationList = nil;
    self.qrcodePanel = nil;
    self.qrcodeImgView = nil;
    self.tenpayID = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect frame = [[self view] bounds];
    
    self.operationList = [NSArray arrayWithObjects:
                          @"分享文本消息",
                          @"分享图片消息",
                          @"分享新闻链接消息(网络图片缩略图)",
                          @"分享新闻链接消息(本地图片缩略图)",
                          @"分享音乐链接消息(本地图片缩略图)",
                          @"分享视频链接消息(本地图片缩略图)",
                          @"手Q支付接口",
                          @"发送链接到QQ收藏(网络图片缩略图)",
                          @"发送图片到我的电脑(本地图片)",
                          @"打开WPA临时会话",
                          @"打开指定群会话",
                          nil];
    
    self.operationTable = [[[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped] autorelease];
    self.operationTable.backgroundColor = [UIColor colorWithRed:(214.f/255.f) green:(214.f/255.f) blue:(214.f/255.f) alpha:1];
    self.operationTable.scrollEnabled = YES;
    self.operationTable.dataSource = self;
    self.operationTable.delegate = self;
    [self.view addSubview:self.operationTable];
    
    self.qrcodePanel = [[[UIControl alloc] initWithFrame:frame] autorelease];
    self.qrcodePanel.hidden = YES;
    self.qrcodePanel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    [self.qrcodePanel addTarget:self action:@selector(onQRCodePanelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.qrcodePanel];
    
    CGRect panelFrame = [self.qrcodePanel bounds];
    CGFloat minSize = MIN(panelFrame.size.width, panelFrame.size.height) * 0.9f;
    self.qrcodeImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, minSize, minSize)] autorelease];
    self.qrcodeImgView.center = CGPointMake(CGRectGetMidX(panelFrame), CGRectGetMidY(panelFrame));
    [self.qrcodePanel addSubview:self.qrcodeImgView];
    
    self.tenpayID = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.operationTable = nil;
}

- (ShareDestType)getShareType
{
    BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkSwitchFlag"] boolValue];
    return flag? ShareDestTypeTIM :ShareDestTypeQQ;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

// Override to allow orientations other than the default portrait orientation ios6.0
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"QQ定向分享";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.operationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = [self.operationTable dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.operationList objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    if(section == 0)
    {
        switch (row)
        {
            case 0:
                [self sendTextMessage];
                break;
            case 1:
                [self sendImageMessage];
                break;
            case 2:
                [self sendNewsMessageWithNetworkImage];
                break;
            case 3:
                [self sendNewsMessageWithLocalImage];
                break;
            case 4:
                [self sendAudioMessage];
                break;
            case 5:
                [self sendVideoMessage];
                break;
            case 6:
                [self PayFromIphoneQQ];
                break;
            case 7:
                [self shareToQQFavorite];
                break;
            case 8:
                [self shareToDataLine];
                break;
            case 9:
                [self sendToQQWPA];
                break;
            case 10:
                [self sendToQQGroupChat];
                break;
                
            default:
                NSLog(@"No event handling for row %d",row);
                break;
        }
    }
    
    [_operationTable deselectRowAtIndexPath:indexPath animated:YES];
}

#if BUILD_QQAPIDEMO
- (void)onReq:(QQBaseReq *)req
{
    switch (req.type)
    {
        case EGETMESSAGEFROMQQREQTYPE:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}
#endif

#if BUILD_QQAPIDEMO
- (void)onResp:(QQBaseResp *)resp
{
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:sendResp.result message:sendResp.errorDescription delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            break;
        }
        default:
        {
            break;
        }
    }
}
#endif

- (void) sendTextMessage
{
#if BUILD_QQAPIDEMO
    
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objTitle.hidden = YES;
    apiObjEditCtrl.objDesc.hidden = YES;
    apiObjEditCtrl.objUrl.hidden = YES;
    apiObjEditCtrl.objText.text = @"马化腾指出，过去两年移动互联网有很多开放平台非常成功。事实上到现在来看，发展到现在一年多，最关键的开放平台是能不能真正从用户和经济回报中打造生态链。";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         QQApiTextObject* txtObj = [QQApiTextObject objectWithText:editCtrl.objText.text];
         txtObj.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
              cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
    
#endif
}

- (void) sendImageMessage
{
#if BUILD_QQAPIDEMO
    
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objText.hidden = YES;
    apiObjEditCtrl.objUrl.hidden = YES;
    apiObjEditCtrl.objTitle.text = @"测试分享图 sdkDemo/UI/QQApiDemo/img.jpg";
    apiObjEditCtrl.objDesc.text = @"图片描述（注意：目前手Q用这个接口分享图片，不会出现描述）";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img.jpg"];
         NSData* data = [NSData dataWithContentsOfFile:path];
         
         QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:data title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text];
         img.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
              cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
    
#endif
}

- (void) sendNewsMessageWithNetworkImage
{
#if BUILD_QQAPIDEMO
    
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objText.hidden = YES;
    apiObjEditCtrl.objTitle.text = @"天公作美伦敦奥运圣火点燃成功 火炬传递开启";
    apiObjEditCtrl.objDesc.text = @"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。";
    apiObjEditCtrl.objUrl.text = @"http://sports.qq.com/a/20120510/000650.htm";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         NSURL *previewURL = [NSURL URLWithString:@"http://img1.gtimg.com/sports/pics/hv1/87/16/1037/67435092.jpg"];
         NSURL* url = [NSURL URLWithString:apiObjEditCtrl.objUrl.text];
         
         QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text previewImageURL:previewURL];
         img.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
    cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
#endif
}

- (void) sendNewsMessageWithLocalImage
{
#if BUILD_QQAPIDEMO
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objText.hidden = YES;
    apiObjEditCtrl.objTitle.text = @"天公作美伦敦奥运圣火点燃成功 火炬传递开启";
    apiObjEditCtrl.objDesc.text = @"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。";
    apiObjEditCtrl.objUrl.text = @"http://sports.qq.com/a/20120510/000650.htm";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"news.jpg"];
         NSData* data = [NSData dataWithContentsOfFile:path];
         NSURL* url = [NSURL URLWithString:apiObjEditCtrl.objUrl.text];
         
         QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text previewImageData:data];
         img.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
    cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
    
#endif
}

- (void) sendAudioMessage
{
#if BUILD_QQAPIDEMO
    
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objText.hidden = YES;
    apiObjEditCtrl.objTitle.text = @"Wish You Were Here";
    apiObjEditCtrl.objDesc.text = @"Avril Lavigne";
    apiObjEditCtrl.objUrl.text = @"http://i.y.qq.com/v8/playsong.html?hostuin=0&songid=&songmid=002x5Jje3eUkXT&_wv=1&source=qq&appshare=iphone&media_mid=002x5Jje3eUkXT";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"audio.jpg"];
         NSData* data = [NSData dataWithContentsOfFile:path];
         NSURL* url = [NSURL URLWithString:apiObjEditCtrl.objUrl.text];
         
         QQApiAudioObject* img = [QQApiAudioObject objectWithURL:url title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text previewImageData:data];
         img.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
              cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
    
#endif
}

- (void) sendVideoMessage
{
#if BUILD_QQAPIDEMO
    
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objText.hidden = YES;
    apiObjEditCtrl.objTitle.text = @"腾讯暗黑风动作新游《天刹》国服视频曝光";
    apiObjEditCtrl.objDesc.text = @"你觉得正在玩的动作游戏的打击感不够好？战斗不够真实缺乏技巧？PVP索然无味完全是比谁装备好？那么现在有款新游戏或许能满足你的胃口！ 《天刹》是由韩国nse公司开发，腾讯全球代理中国首发的3D锁视角动作游戏，是一款有着暗黑写实风格、东方奇幻题材的游戏，具备打击感十足的动作体验、策略多变的战斗方式，游戏操作不难但有足够的深度，在动作游戏领域首次引入了手动格挡格斗机制，构建快速攻防转换体系。 官方网站：tian.qq.com 官方微博：http://t.qq.com/tiancha001";
    apiObjEditCtrl.objUrl.text = @"http://www.tudou.com/programs/view/_cVM3aAp270/";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"video.jpg"];
         NSData* data = [NSData dataWithContentsOfFile:path];
         NSURL* url = [NSURL URLWithString:apiObjEditCtrl.objUrl.text];
         
         /*
          * QQApiVideoObject类型的分享，目前在android和PC上接收消息时，展现有问题，待手Q版本以后更新支持
          * 目前如果要分享视频请使用 QQApiNewsObject 类型，URL填视频所在的H5地址
          
          QQApiVideoObject* img = [QQApiVideoObject objectWithURL:url title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text previewImageData:data];
          */
         
         QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text previewImageData:data];
         img.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
              cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
    
#endif
}

- (void)PayFromIphoneQQ
{
#if BUILD_QQAPIDEMO
    
    //设置一个有效的订单号
    self.tenpayID = @"d8cce911de40b2719be0a40a8e85d5fb";
    
    NSString * tenpayAppInfo = [NSString stringWithFormat:@"appid#test1|bargainor_id#test2|channel#test3"];
    
    if ([self.tenpayID length] == 0) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"设置一个有效的订单号" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        [msgbox release];
        return;
    }
    
    QQApiPayObject *payObj = [QQApiPayObject objectWithOrderNo:self.tenpayID AppInfo:tenpayAppInfo];
    payObj.shareDestType = [self getShareType];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:payObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
#endif
}

- (void)shareToQQFavorite
{
#if BUILD_QQAPIDEMO
    
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objText.hidden = YES;
    apiObjEditCtrl.objTitle.text = @"天公作美伦敦奥运圣火点燃成功 火炬传递开启";
    apiObjEditCtrl.objDesc.text = @"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。";
    apiObjEditCtrl.objUrl.text = @"http://sports.qq.com/a/20120510/000650.htm";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         NSURL *previewURL = [NSURL URLWithString:@"http://img1.gtimg.com/sports/pics/hv1/87/16/1037/67435092.jpg"];
         NSURL* url = [NSURL URLWithString:apiObjEditCtrl.objUrl.text];
         
         QQApiNewsObject* imgObj = [QQApiNewsObject objectWithURL:url title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text previewImageURL:previewURL];
         
         [imgObj setCflag:kQQAPICtrlFlagQQShareFavorites];
         imgObj.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:imgObj];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
              cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
#endif
}

- (void)shareToDataLine
{
#if BUILD_QQAPIDEMO
    
    TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
    apiObjEditCtrl.objText.hidden = YES;
    apiObjEditCtrl.objUrl.hidden = YES;
    apiObjEditCtrl.objTitle.text = @"默认分享图";
    
    [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
     {
         NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img.jpg"];
         NSData* data = [NSData dataWithContentsOfFile:path];
         
         QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:data title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text];
         
         [img setCflag:kQQAPICtrlFlagQQShareDataline];
         img.shareDestType = [self getShareType];
         SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
         
         QQApiSendResultCode sent = [QQApiInterface sendReq:req];
         [self handleSendResult:sent];
     }
              cancelHandler:NULL animated:YES];
    TCSafeRelease(apiObjEditCtrl)
#endif
}

- (void)sendToQQWPA
{
    //设置一个有效的号码
    NSString * qqNum = @"79796356";
    
    if ([qqNum length] == 0) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"在demo代码里设置一个有效号码" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        [msgbox release];
        return;
    }
    
    QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:qqNum];
    wpaObj.shareDestType = [self getShareType];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)sendToQQGroupChat
{
    //设置一个有效的群号，且你是那个群的成员
    NSString * qqGroupNum = @"";
    
    if ([qqGroupNum length] == 0) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"在demo代码里设置一个有效的群号，且你是那个群的成员" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        [msgbox release];
        return;
    }
    
    QQApiGroupChatObject *wpaObj = [QQApiGroupChatObject objectWithGroup:qqGroupNum];
    wpaObj.shareDestType = [self getShareType];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}


#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
#if BUILD_QQAPIDEMO
    if (nil != picker)
    {
        NSURL *picUrl = (NSURL *)[info objectForKey:UIImagePickerControllerReferenceURL];
        [self dismissModalViewControllerAnimated:NO];
        
        TCApiObjectEditController *apiObjEditCtrl = [[TCApiObjectEditController alloc] initWithNibName:nil bundle:nil];
        apiObjEditCtrl.objText.hidden = YES;
        apiObjEditCtrl.objTitle.text = @"天公作美伦敦奥运圣火点燃成功 火炬传递开启";
        apiObjEditCtrl.objDesc.text = @"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。";
        apiObjEditCtrl.objUrl.text = @"http://sports.qq.com/a/20120510/000650.htm";
        
        [apiObjEditCtrl modalIn:self withDoneHandler:^(TCApiObjectEditController *editCtrl)
         {
             NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"news.jpg"];
             //NSData* data = [NSData dataWithContentsOfFile:path];
             NSURL* url = [NSURL URLWithString:apiObjEditCtrl.objUrl.text];
             
             QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:apiObjEditCtrl.objTitle.text description:apiObjEditCtrl.objDesc.text previewImageURL:picUrl];
             SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
             
             QQApiSendResultCode sent = [QQApiInterface sendReq:req];
             [self handleSendResult:sent];
         }
                  cancelHandler:NULL animated:YES];
        TCSafeRelease(apiObjEditCtrl)
        
    }
    
#endif
}


#if BUILD_QQAPIDEMO
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPITIMNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装TIM" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        case EQQAPITIMNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前QQ版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case ETIMAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前QQ版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}
#endif

- (void)showQRCode:(NSString *)qrcode
{
    CGFloat size = self.qrcodeImgView.bounds.size.width;
    UIImage *qrcodeImg = [TCQRCodeGenerator qrImageForString:qrcode imageSize:size];
    
    [self.qrcodeImgView setImage:qrcodeImg];
    [self.qrcodePanel setHidden:NO];
}

- (void)onQRCodePanelClick:(id)sender
{
    if (sender == self.qrcodePanel)
    {
        [sender setHidden:YES];
    }
}

#pragma mark -
#pragma mark TencentRequestDelegate
- (void)request:(TencentRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"TenpayQR获取失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [msgbox show];
    [msgbox release];
}

- (void)request:(TencentRequest *)request didLoad:(id)result dat:(NSData *)data
{
    NSString *tenpayUrl = [result objectForKey:@"url"];
    if (tenpayUrl)
    {
        [self showQRCode:tenpayUrl];
    }
    else
    {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"TenpayQR解析失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        [msgbox release];
    }
}

@end
