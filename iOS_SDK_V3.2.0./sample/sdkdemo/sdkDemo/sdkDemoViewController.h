//
//  sdkDemoViewController.h
//  sdkDemo
//
//  Created by xiaolongzhang on 13-3-29.
//  Copyright (c) 2013年 xiaolongzhang. All rights reserved.
//  Update by BilsonChen 2016-06-01

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface sdkDemoViewController : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, retain)NSString *albumId;

@end
