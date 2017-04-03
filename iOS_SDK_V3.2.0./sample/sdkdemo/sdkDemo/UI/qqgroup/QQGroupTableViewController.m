//
//  QQGroupTableViewController.m
//
//  BilsonChen 2016-06-02

#import "QQGroupTableViewController.h"
#import "cellInfo.h"
#import "sdkCall.h"
#import "QQGroupAPIDemoViewController.h"

@interface QQGroupTableViewController ()

@end

@implementation QQGroupTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        NSMutableArray *cellvip = [NSMutableArray array];
        [cellvip addObject:[cellInfo info:@"一键加群" target:self Sel:@selector(joinGroup) viewController:nil]];
        [[self sectionName] addObject:@"QQ群接口"];
        [[self sectionRow] addObject:cellvip];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)joinGroup {
    QQGroupAPIDemoViewController *controller = [[QQGroupAPIDemoViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
