//
//  ViewController.m
//  Filter
//
//  Created by 理享学 on 2021/8/31.
//

#import "ViewController.h"
#import "LBSegementView.h"

@interface ViewController ()

@property(nonatomic, strong)LBSegementView* segementView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
}

- (void)createUI {
    CGFloat top = 0;
    if (@available(iOS 11.0, *)) {
        if (LBkWindow.safeAreaInsets.top>0) {
            top = 88;
        } else
            top = 64;
    } else {
        top = 64;
    }
    
    [self.view addSubview:self.segementView];
    [self.segementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.offset(top);
    }];
}

- (LBSegementView *)segementView{
    if (!_segementView) {
        _segementView = [LBSegementView new];
    }
    return _segementView;
}
@end
