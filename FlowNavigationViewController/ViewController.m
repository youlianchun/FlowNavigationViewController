//
//  ViewController.m
//  FlowNavigationViewController
//
//  Created by YLCHUN on 2017/4/26.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import "FlowNavigationViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"ViewController";
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    but.backgroundColor = [UIColor redColor];
    [but addTarget:self action:@selector(butAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)butAction {
    ViewController *vc = [[ViewController alloc] init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentFlowViewController:vc animated:YES];
    }
}

@end
