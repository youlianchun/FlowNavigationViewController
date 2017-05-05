//
//  FlowNavigationViewController.m
//  UPBOX
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 PPSPORTS Cultural Development Co., Ltd. All rights reserved.
//
#import "UIViewController+FullScreen.h"
#import "FlowNavigationViewController.h"

@interface FlowNavigationViewController ()<UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL initFlag;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, copy) void(^flowEndEventAtRoot)();
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
        self.closeFlag = YES;
    }
    return self;
}

-(void)setViewController:(UIViewController *)viewController {
    _viewController = viewController;
    self.flowEndEventAtRoot = nil;
    if ([viewController conformsToProtocol:@protocol(FlowNavigationProtocol)] || [viewController respondsToSelector:@selector(flowEndEventAtRoot)]) {
        self.flowEndEventAtRoot = [(UIViewController<FlowNavigationProtocol>*)viewController flowEndEventAtRoot];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.initFlag = YES;
    [self performSelector:@selector(showWebVC) withObject:nil afterDelay:0];
    // Do any additional setup after loading the view.
}

-(void)showWebVC{
    [self pushViewController:self.viewController animated:self.animated];
    _viewController = nil;
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
    if (navigationController.viewControllers.count == 1 && !self.initFlag && self.closeFlag) {
        [super dismissViewControllerAnimated:NO completion:^{
            if (self.flowEndEventAtRoot) {
                self.flowEndEventAtRoot();
            }
            if ([self respondsToSelector:@selector(flowEndEvent)]) {
                [(FlowNavigationViewController<FlowNavigationProtocol>*)self flowEndEvent];
            }
        }];
    }
    self.initFlag = NO;
}

-(void)unCloseWithJump:(void(^)())code {
    if (code) {
        self.closeFlag = NO;
        code();
        self.closeFlag = YES;
    }
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
