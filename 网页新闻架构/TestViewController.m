//
//  TestViewController.m
//  网页新闻架构
//
//  Created by gzz on 2019/4/30.
//  Copyright © 2019 gzz. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *colorBg = [UIColor colorWithRed:getRandomNumber()/255.f green:getRandomNumber()/255.f blue:getRandomNumber()/255.f alpha:1.0];
    self.view.backgroundColor = colorBg;
    
}
int getRandomNumber(){
    
    return arc4random()%256;
}


@end
