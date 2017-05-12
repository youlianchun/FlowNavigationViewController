////
////  UIViewController+FullScreen.m
////  ViewControllerFullScreen
////
////  Created by YLCHUN on 16/10/28.
////  Copyright © 2016年 ylchun. All rights reserved.
////
//
//#import "UIViewController+FullScreen.h"
//#import <objc/runtime.h>
//
//#pragma mark - swizzleClassMethod
//#define fs_swizzleMethod(originalSelector, swizzledSelector)  fs_swizzleClassMethod([self class], @selector(originalSelector), @selector(swizzledSelector))
//BOOL fs_swizzleClassMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//    if (success) {
//        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//    return success;
//}
//
//#pragma mark - UIViewController
//@implementation UIViewController (FullScreen)
//
//+ (void)load {
//    [super load];
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        fs_swizzleMethod(viewWillAppear:, fs_viewWillAppear:);
//    });
//}
//
//-(void)fs_viewWillAppear:(BOOL)animated {
//    [self fs_viewWillAppear:animated];
//    if ([self.navigationController.viewControllers containsObject:self]) {
//        [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:animated];
//    }
//}
//
//-(BOOL)navigationBarHidden {
//    return [objc_getAssociatedObject(self, @selector(navigationBarHidden)) boolValue];
//}
//
//-(void)setNavigationBarHidden:(BOOL)navigationBarHidden {
//    objc_setAssociatedObject(self, @selector(navigationBarHidden), @(navigationBarHidden), OBJC_ASSOCIATION_RETAIN);
//}
//
//-(BOOL)backPanEnabled {
//    id backPanEnabled = objc_getAssociatedObject(self, @selector(backPanEnabled));
//    if (backPanEnabled) {
//        return [backPanEnabled boolValue];
//    }else{
//        return YES;
//    }
//}
//
//-(void)setBackPanEnabled:(BOOL)backPanEnabled {
//    objc_setAssociatedObject(self, @selector(backPanEnabled), @(backPanEnabled), OBJC_ASSOCIATION_RETAIN);
//}
//
//@end
//
//
//#pragma mark - _FullScreenPopGestureRecognizer
//@interface _FullScreenPopGestureRecognizer : UIScreenEdgePanGestureRecognizer
//{
//    __weak id<UIGestureRecognizerDelegate> _receiverDelegate;
//}
//@property (nonatomic, readwrite, weak) UINavigationController* navigationController;
//@end
//
//@implementation _FullScreenPopGestureRecognizer
//-(instancetype)init {
//    self = [super init];
//    if (self) {
//        self.edges = UIRectEdgeLeft;
//    }
//    return self;
//}
//
//-(void)setDelegate:(id<UIGestureRecognizerDelegate>)delegate {
//    if (_receiverDelegate != delegate) {
//        id<UIGestureRecognizerDelegate> delegateSelf = (id<UIGestureRecognizerDelegate>)self;
//        _receiverDelegate = (delegateSelf != delegate ? delegate : nil);
//        [super setDelegate:delegateSelf];
//    }
//}
//
//-(id<UIGestureRecognizerDelegate>)delegate {
//    return _receiverDelegate;
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    UIViewController *viewController = self.navigationController.topViewController;
//    if (!viewController.backPanEnabled) {
//        return NO;
//    }
//    if ([self.delegate respondsToSelector:_cmd]) {
//        return [self.delegate gestureRecognizerShouldBegin:gestureRecognizer];
//    }
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//
////- (id)forwardingTargetForSelector:(SEL)aSelector {
////    id i = [super forwardingTargetForSelector:aSelector];
////    if (!i && [self.delegate respondsToSelector:aSelector]) {
////        i = self.delegate;
////    }
////    return i;
////}
////
////- (BOOL)respondsToSelector:(SEL)aSelector {
////    BOOL b = [super respondsToSelector:aSelector];
////    if (!b) {
////        b = [self.delegate respondsToSelector:aSelector];
////    }
////    return b;
////}
//@end
//
//#pragma mark - UINavigationController
//@interface UINavigationController ()
//@property (nonatomic, retain) _FullScreenPopGestureRecognizer *fs_popGestureRecognizer;
//@end
//
//@implementation UINavigationController (FullScreen)
//
//+ (void)load {
//    [super load];
//    if (kFullScreen_popEnabled) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            fs_swizzleMethod(viewDidLoad, fs_viewDidLoad);
//        });
//    }
//}
//
//-(void)fs_viewDidLoad {
//    [self createPopGestureRecognizer];
//    [self fs_viewDidLoad];
//}
//
//-(void)createPopGestureRecognizer {
//    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.fs_popGestureRecognizer]) {
//        self.fs_popGestureRecognizer = [[_FullScreenPopGestureRecognizer alloc] init];
//        self.fs_popGestureRecognizer.navigationController = self;
//        self.fs_popGestureRecognizer.delegate = self.interactivePopGestureRecognizer.delegate;
//        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
//        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
//        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
//        [self.fs_popGestureRecognizer addTarget:internalTarget action:internalAction];
//        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.fs_popGestureRecognizer];
//        self.interactivePopGestureRecognizer.enabled = NO;
//    }
//}
//
//-(_FullScreenPopGestureRecognizer *)fs_popGestureRecognizer {
//    return objc_getAssociatedObject(self, @selector(fs_popGestureRecognizer));
//}
//
//-(void)setFs_popGestureRecognizer:(_FullScreenPopGestureRecognizer *)fs_popGestureRecognizer {
//    objc_setAssociatedObject(self, @selector(fs_popGestureRecognizer), fs_popGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
//}
//
//@end
//
