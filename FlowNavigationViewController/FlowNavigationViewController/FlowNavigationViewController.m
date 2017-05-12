//
//  FlowNavigationViewController.m
//  UPBOX
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 PPSPORTS Cultural Development Co., Ltd. All rights reserved.
//

#import "FlowNavigationViewController.h"

@interface UIBorderViewController : UIViewController
@property (nonatomic, retain) UIImageView *imageView;
@end
@implementation UIBorderViewController
-(void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.imageView];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
@end

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
    UIBorderViewController *rootVC = [[UIBorderViewController alloc] init];
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
    UIView *transitionView = self.view.subviews[0];
    transitionView.backgroundColor = [UIColor clearColor];
    self.initFlag = YES;
    [self performSelector:@selector(showViewController) withObject:nil afterDelay:0];
    // Do any additional setup after loading the view.
}

-(void)showViewController{
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
    UIBorderViewController *borderVC = [[UIBorderViewController alloc] init];
    UIView *view =  self.presentingViewController.view;
    CGSize s = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    borderVC.imageView.image = image;
    [self pushViewController:borderVC animated:flag];
//    [super popToRootViewControllerAnimated:flag];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:false completion:^{
        if (self.flowEndEventAtRoot) {
            self.flowEndEventAtRoot();
        }
        if ([self respondsToSelector:@selector(flowEndEvent)]) {
            [(FlowNavigationViewController<FlowNavigationProtocol>*)self flowEndEvent];
        }
        if (self.dismisCompletion) {
            self.dismisCompletion();
        }
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Navigation

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ((navigationController.viewControllers.count == 1  || [self.topViewController isKindOfClass:[UIBorderViewController class]]) && !self.initFlag) {
        [super dismissViewControllerAnimated:NO completion:nil];
    }
    self.initFlag = NO;
}
//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
//    return nil;
//    
//}
//
//- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                            animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                         fromViewController:(UIViewController *)fromVC
//                                                           toViewController:(UIViewController *)toVC{
//    
//    return nil;
//}
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
        [fnvc closeFlowWithAnimated:flag];
    }
}

@end
