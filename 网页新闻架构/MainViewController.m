//
//  MainViewController.m
//  网页新闻架构
//
//  Created by gzz on 2019/4/30.
//  Copyright © 2019 gzz. All rights reserved.
//

#import "MainViewController.h"
#import "TestViewController.h"
/*屏幕的宽高*/
#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

/*标题栏高度*/
#define TITLE_SCROLLVIEW_HEIGHT 44

static int const number = 4;

static CGFloat const radio = 1.3;
@interface MainViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView * titleScrollView;
@property (nonatomic,strong) UIScrollView * mainScrollView;

@property (nonatomic,strong) NSArray <NSString *> * titleArray;
@property (nonatomic,strong) NSMutableArray <UILabel *> * labelArray;

@property (nonatomic,strong) UILabel * selectedLabel;

@property (nonatomic,strong) NSMutableArray <UIViewController *> *viewControllers;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     网易新闻实现步骤:
     1.搭建结构(导航控制器)
     * 自定义导航控制器根控制器NewsViewController
     * 搭建NewsViewController界面(上下滚动条)
     * 确定NewsViewController有多少个子控制器,添加子控制器
     2.设置上面滚动条标题
     * 遍历所有子控制器
     3.监听滚动条标题点击
     * 3.1 让标题选中,文字变为红色
     * 3.2 滚动到对应的位置
     * 3.3 在对应的位置添加子控制器view
     4.监听滚动完成时候
     * 4.1 在对应的位置添加子控制器view
     * 4.2 选中子控制器对应的标题
     */

    [self.navigationItem setTitle:@"网页新闻"];
    [self.view addSubview:self.titleScrollView];
    [self.view addSubview:self.mainScrollView];
    //添加子控制器
    [self addChildViewControllers];
    //添加标题
    [self addTitleLable];
    // iOS7会给导航控制器下所有的UIScrollView顶部添加额外滚动区域
    // 不想要添加
    self.automaticallyAdjustsScrollViewInsets = NO;
}

//添加标题
- (void)addTitleLable
{
    NSInteger count = self.titleArray.count;
    CGFloat labelW = kScreenW/number;
    CGFloat labelH = TITLE_SCROLLVIEW_HEIGHT;
    for (int i= 0; i<count; i++) {
        UILabel *label = [[UILabel alloc]init];
        [self.labelArray addObject:label];
        label.text = self.titleArray[i];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:15.0];
        label.userInteractionEnabled = YES;
        label.tag = i;
        label.textAlignment =  NSTextAlignmentCenter;
        label.highlightedTextColor = [UIColor redColor];
        label.frame = CGRectMake(labelW*i, 0, labelW, labelH);
        //添加s手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAddClick:)];
        
         [label addGestureRecognizer:tap];
        // 默认选中第0个label
        if (i == 0) {
            [self labelAddClick:tap];
        }
        
       
        [self.titleScrollView addSubview:label];
    }

}

- (void)labelAddClick:(UITapGestureRecognizer *)tap
{
    UILabel * selectedLabel = (UILabel *)tap.view;
    
    [self selectedLabel:selectedLabel];

    //滚动到相应位置
    NSInteger index = selectedLabel.tag;
    CGFloat ofSetX = index* kScreenW;
    self.mainScrollView.contentOffset = CGPointMake(ofSetX, 0);
     // 3.给对应位置添加对应子控制器
    [self showVC:index];
    //选中标题居中
    [self setUpTitleCenter:selectedLabel];
    
    

}
#pragma mark - UIScrollViewDelegate
//滚动就会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat currentPage = scrollView.contentOffset.x/scrollView.bounds.size.width;
    
    
    //左边label角标
    NSInteger leftLabelIndex =  currentPage;
    
    //右边label角标
    NSInteger rightLabelIndex = leftLabelIndex +1;
    
    //获取左边的label
    UILabel * leftLabel = self.labelArray[leftLabelIndex];
    
    //获取右边的label
    UILabel * rightLabel;
    if (rightLabelIndex< self.labelArray.count) {
        rightLabel  = self.labelArray[rightLabelIndex];
    }
    
    // 计算右边缩放比例
    CGFloat rightScale = currentPage - leftLabelIndex;
    
    // 计算左边缩放比例
    CGFloat leftScale = 1 - rightScale;
    
    // 0 ~ 1
    // 1 ~ 2
    // 左边缩放
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale * 0.3+ 1);
    
    // 右边缩放
    rightLabel.transform = CGAffineTransformMakeScale(rightScale * 0.3 + 1, rightScale * 0.3+ 1);
    // 设置文字颜色渐变
    /*
     R G B
     黑色 0 0 0
     红色 1 0 0
     */
    leftLabel.textColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
    rightLabel.textColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //计算滚动到哪一页
    NSInteger page = scrollView.contentOffset.x/scrollView.bounds.size.width;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 1.添加子控制器view
    [self showVC:page];
    
    // 2.把对应的标题选中
    UILabel *selLabel = self.labelArray[page];
    
    [self selectedLabel:selLabel];
    //选中标题居中
    [self setUpTitleCenter:selLabel];
}
- (void)showVC:(NSInteger)index
{
    CGFloat offsetX = index * kScreenW;
    UIViewController *vc = self.viewControllers[index];
    
    // 判断控制器的view有没有加载过,如果已经加载过,就不需要加载
    if (vc.isViewLoaded) return;
    
    vc.view.frame = CGRectMake(offsetX, 0, kScreenW, kScreenH-44-64);
    
    [self.mainScrollView addSubview:vc.view];
    
}

- (void)selectedLabel:(UILabel *)label
{
    _selectedLabel.highlighted = NO;
    _selectedLabel.transform = CGAffineTransformIdentity;
    label.highlighted = YES;
     label.transform = CGAffineTransformMakeScale(radio, radio);
    _selectedLabel = label;
    
    
}
//设置标题居中
- (void)setUpTitleCenter:(UILabel *)centerLabel{
    //计算偏移量
    //
    CGFloat offsetX = centerLabel.center.x - kScreenW*0.5;
    //最小移动范围
    if (offsetX < 0) {
        offsetX = 0;
    }
    // 获取d最大移动范围
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width-kScreenW;
    if (offsetX >maxOffsetX) {
        offsetX = maxOffsetX;
    }
    // 滚动标题滚动条
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

//添加子控制器
-(void)addChildViewControllers{
    
    for (int i= 0; i<self.titleArray.count; i++) {
        TestViewController * testCtl = [[TestViewController alloc]init];
        testCtl.titleName = self.titleArray[i];
        [self.viewControllers addObject:testCtl];
    }
    NSLog(@"%@",self.childViewControllers);
}
- (UIScrollView *)titleScrollView
{
    if (!_titleScrollView) {
        UIScrollView * titleScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, kScreenW, TITLE_SCROLLVIEW_HEIGHT)];
        titleScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        titleScrollView.contentSize = CGSizeMake(kScreenW/number*self.titleArray.count, 0);
        titleScrollView.showsHorizontalScrollIndicator = NO;
        titleScrollView.pagingEnabled = NO;
        _titleScrollView = titleScrollView;
    }
    return _titleScrollView;
}
- (UIScrollView *)mainScrollView
{
    if (!_mainScrollView) {
        UIScrollView * mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+TITLE_SCROLLVIEW_HEIGHT, kScreenW, kScreenH-64-TITLE_SCROLLVIEW_HEIGHT)];
        mainScrollView.backgroundColor = [UIColor blueColor];
        mainScrollView.contentSize = CGSizeMake(kScreenW*self.titleArray.count, 0);
        mainScrollView.showsHorizontalScrollIndicator = NO;
        mainScrollView.pagingEnabled = YES;
        mainScrollView.delegate = self;
        _mainScrollView = mainScrollView;
    }
    return _mainScrollView;
}
- (NSArray <NSString *> *)titleArray
{
    if (!_titleArray) {
        _titleArray = [NSArray arrayWithObjects:@"头条",@"热点",@"视频",@"图片",@"新闻",@"科技", nil];
    }
    return _titleArray;
}
- (NSMutableArray<UILabel *> *)labelArray
{
    if (_labelArray == nil) {
        _labelArray = [NSMutableArray new];
    }
    return _labelArray;
}


- (NSMutableArray <UIViewController *>*)viewControllers{
    if (_viewControllers == nil) {
        _viewControllers = [NSMutableArray new];
    }
    return _viewControllers;
}

@end
