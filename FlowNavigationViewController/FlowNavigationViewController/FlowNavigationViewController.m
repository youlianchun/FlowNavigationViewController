//
//  FlowNavigationViewController.m
//  UPBOX
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 PPSPORTS Cultural Development Co., Ltd. All rights reserved.
//

#import "FlowNavigationViewController.h"
#import "UIViewController+FullScreen.h"

@interface FlowNavigationViewController ()<UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL initFlag;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, copy) void(^flowEndEventAtRoot)();
@property (nonatomic, copy) void(^dismisCompletion)();

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
    self.navigationBar.tintColor = [UIColor whiteColor];
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

-(void)pushViewController:(UIViewController *)viewController beforePop:(NSUInteger)popCount animated:(BOOL)animated {
    NSUInteger count = MIN(popCount, self.viewControllers.count-1);
    [super pushViewController:viewController animated:YES];
    NSMutableArray *arr = [self.viewControllers mutableCopy];
    for (int i = 0; i<count; i++) {
        [arr removeObjectAtIndex:arr.count-2];
    }
    self.viewControllers = arr;
}

-(void)closeFlowWithAnimated:(BOOL)flag {
    [super popToRootViewControllerAnimated:flag];
}

#pragma mark - Navigation

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count == 1 && !self.initFlag) {
        [super dismissViewControllerAnimated:NO completion:^{
            if (self.flowEndEventAtRoot) {
                self.flowEndEventAtRoot();
            }
            if ([self respondsToSelector:@selector(flowEndEvent)]) {
                [(FlowNavigationViewController<FlowNavigationProtocol>*)self flowEndEvent];
            }
            if (self.dismisCompletion) {
                self.dismisCompletion();
            }
        }];
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
    [self dismisFlowViewControllerWithAnimated:flag completion:nil];
}

-(void)dismisFlowViewControllerWithAnimated:(BOOL)flag completion: (void (^)(void))completion {
    FlowNavigationViewController * fnvc;
    if ([self isKindOfClass:[FlowNavigationViewController class]]) {
        fnvc = (FlowNavigationViewController*)self;
    }
    if ([self.navigationController isKindOfClass:[FlowNavigationViewController class]]) {
        fnvc = (FlowNavigationViewController*)self.navigationController;
    }
    if (fnvc) {
        fnvc.dismisCompletion = completion;
        [fnvc popToRootViewControllerAnimated:flag];
    }
}

@end
