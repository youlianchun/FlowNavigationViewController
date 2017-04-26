//
//  FlowNavigationViewController.m
//  FlowNavigationViewController
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 PPSPORTS Cultural Development Co., Ltd. All rights reserved.
//

#import "FlowNavigationViewController.h"
#import "UIViewController+FullScreen.h"

@interface FlowNavigationViewController ()<UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL initFlag;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, assign) BOOL animated;
-(instancetype)initWithRootViewController_self:(UIViewController *)rootViewController;
@end

@implementation FlowNavigationViewController

+(instancetype)flowNavigationWithViewController:(UIViewController*)viewController {
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.navigationBarHidden = YES;
    FlowNavigationViewController * fnvc = [[FlowNavigationViewController alloc] initWithRootViewController_self:rootVC];
    fnvc.viewController = viewController;
    return fnvc;
}

-(instancetype)initWithRootViewController_self:(UIViewController *)rootViewController  {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.initFlag = YES;
    [self performSelector:@selector(showWebVC) withObject:nil afterDelay:0.001];
    // Do any additional setup after loading the view.
}

-(void)showWebVC{
    [self pushViewController:self.viewController animated:self.animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)popToStartViewControllerWithAnimated:(BOOL)flag {
    if(self.viewControllers.count>1) {
        UIViewController *viewController = self.viewControllers[1];
        [super popToViewController:viewController animated:flag];
    }
}

-(void)closeFlowWithAnimated:(BOOL)flag {
    [super popToRootViewControllerAnimated:flag];
}

#pragma mark - Navigation

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count == 1 && !self.initFlag ) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    self.initFlag = NO;
}

@end

@implementation UIViewController(Flow)

-(FlowNavigationViewController*)presentFlowViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag {
    FlowNavigationViewController *fnvc;
    if ([viewControllerToPresent isKindOfClass:[FlowNavigationViewController class]]) {
        fnvc = (FlowNavigationViewController*)viewControllerToPresent;
        if ([fnvc.viewControllers[0] class] != [UIViewController class] || !fnvc.viewController) {
            NSAssert(NO, @"FlowNavigationViewController 格式错误");
            return nil;
        }
    }else {
        fnvc = [FlowNavigationViewController flowNavigationWithViewController:viewControllerToPresent];
    }
    fnvc.animated = flag;
    [self presentViewController:fnvc animated:NO completion:nil];
    return fnvc;
}

-(void)dismisFlowViewControllerWithAnimated:(BOOL)flag {
    if ([self isKindOfClass:[FlowNavigationViewController class]]) {
        [((UINavigationController*)self) popToRootViewControllerAnimated:flag];
        return;
    }
    if ([self.navigationController isKindOfClass:[FlowNavigationViewController class]]) {
        [self.navigationController popToRootViewControllerAnimated:flag];
        return;
    }
}

@end
