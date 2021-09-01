//
//  LBAddressTableView.m
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/19.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import "LBAddressTableView.h"

typedef void(^LBTouchBGViewBlock)(void);
typedef void(^LBResetCallback)(void);

@interface LBAddressFootView()

@property(nonatomic, strong)UIView* topLine;
@property(nonatomic, strong)UIButton* resetBtn;
@property(nonatomic, strong)UIButton* sureBtn;

@end

@implementation LBAddressFootView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        [self configUI];
    }
    return self;
}

- (void)configUI {
    [self addSubview:self.topLine];
    [self addSubview:self.resetBtn];
    [self addSubview:self.sureBtn];
    
    [self.topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.mas_equalTo(1);
    }];
    
    [self.resetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(LBFit(15));
        make.width.height.mas_equalTo(LBFit(ButtonHeight));
    }];
    
    [self.sureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.top.mas_equalTo(self.resetBtn);
        make.left.mas_equalTo(self.resetBtn.mas_right).offset(LBFit(15));
        make.right.offset(-LBFit(15));
    }];
    
    [self.sureBtn setBackgroundImage:[UIImage lb_createImageWithSize:CGSizeMake(LBScreenW - (LBFit(100)), LBFit(ButtonHeight)) gradientColors:@[LBUIColorWithRGB(0x3CB371, 1.0),LBUIColorWithRGB(0x64AB44, 1.0)] percentage:@[@0.0,@1.0] gradientType:LBImageGradientFromTopToBottom] forState:UIControlStateNormal];
    self.sureBtn.layer.cornerRadius = 5;
    self.sureBtn.clipsToBounds = YES;
}

- (void)resetAction {
    if (self.resetBlock) {
        self.resetBlock();
    }
}

- (void)sureAction {
    if (self.sureBlock) {
        self.sureBlock();
    }
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = LBUIColorWithRGB(0xCFCFCF, 1);
    }
    return _topLine;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [UIButton new];
        _resetBtn.backgroundColor = [UIColor whiteColor];
        _resetBtn.layer.cornerRadius = 5;
        _resetBtn.clipsToBounds = YES;
        _resetBtn.layer.borderWidth = 1;
        _resetBtn.layer.borderColor = LBUIColorWithRGB(0x130202, 1).CGColor;
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn setTitleColor:LBUIColorWithRGB(0x130202, 1) forState:UIControlStateNormal];
        _resetBtn.titleLabel.font = LBFontNameSize(Font_Regular, 14);
        [_resetBtn addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton new];
        _sureBtn.backgroundColor = [UIColor whiteColor];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:LBUIColorWithRGB(0xFFFFFF, 1) forState:UIControlStateNormal];
        _sureBtn.titleLabel.font = LBFontNameSize(Font_Regular, 15);
        [_sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

@end

@interface LBAddressTableView() <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic, strong)NSMutableArray *provinceArr;
@property(nonatomic, strong)NSMutableArray *cityArr;
@property(nonatomic, strong)NSMutableArray *zoneArr;
@property(nonatomic, strong)UITableView *provinceTableView;
@property(nonatomic, strong)UITableView *cityTableView;
@property(nonatomic, strong)UITableView *zoneTableView;
/// 选完地址后的回调
@property(nonatomic, copy)LBTouchBGViewBlock touchBGView;
@property(nonatomic, copy)LBAddressCallback addressCallback;

@property(nonatomic, copy)LBResetCallback resetCallback;
@property(nonatomic, strong)LBAddressModel *provinceModel;
@property(nonatomic, strong)LBAddressModel *cityModel;
@property(nonatomic, strong)LBAddressModel *areaModel;
@property(nonatomic, strong)LBAddressFootView *footView;

@property(nonatomic, strong)UIView* currentView;
@property(nonatomic, strong)NSMutableArray* nowSelectObjectArr;
@end

@implementation LBAddressTableView

//显示
+ (LBAddressTableView*)showAddressTableIn:(UIView*)view dataSource:(NSMutableArray*)dataSource province:(LBAddressModel*)province city:(LBAddressModel*)city area:(NSMutableArray*)area addressBlock:(LBAddressCallback)addressBlock touchBGView:(void(^)(void))touchBGView resetCallback:(void(^)(void))resetCallback {
    [self hideIn:view];
    LBAddressTableView *hud = [[LBAddressTableView alloc] initWithFrame:view.bounds];
    hud.userInteractionEnabled = YES;
    hud.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.05f];
    hud.addressCallback = addressBlock;
    hud.provinceArr = dataSource;
    hud.currentView = view;
    hud.touchBGView = touchBGView;
    hud.resetCallback = resetCallback;
    hud.provinceModel = province;
    hud.cityModel = city;
    [hud.nowSelectObjectArr addObjectsFromArray:area];
    
    if (province) {
        [hud selectedToshow:province city:city areaArr:area];
    } else {
        NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        [hud tableView:hud.provinceTableView didSelectRowAtIndexPath:currentIndex];
        [hud shakeToShow];
    }
    [view addSubview:hud];
    
    UITapGestureRecognizer*pan = [[UITapGestureRecognizer alloc] initWithTarget:hud action:@selector(touchUpbgView)];
    pan.delegate = hud;
    [hud addGestureRecognizer:pan];
    
    [hud mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(LBFit(60));
        make.left.right.bottom.offset(0);
    }];
    return hud;
}

//隐藏
+ (LBAddressTableView *)hideIn:(UIView *)view {
    LBAddressTableView *hud = nil;
    for (LBAddressTableView *subView in view.subviews) {
        if ([subView isKindOfClass:[LBAddressTableView class]]) {
            [UIView animateWithDuration:0.2 animations:^{
                subView.alpha = 0;
            } completion:^(BOOL finished) {
                [subView removeFromSuperview];
            }];
           hud = subView;
        }
    }
    return hud;
}

#pragma mark-手势代理，解决和tableview点击发生的冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableView"]) {//判断如果点击的是tableView的cell，就把手势给关闭了 return NO;//关闭手势 }//否则手势存在 return YES;
        return NO;
    }
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubView];
        [self footViewBtnsCallback];
    }
    return self;
}

- (void)createSubView {
    [self addSubview:self.provinceTableView];
    [self addSubview:self.cityTableView];
    [self addSubview:self.zoneTableView];
    [self addSubview:self.footView];

    [self.provinceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(LBScreenW);
    }];
    [self.cityTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.mas_equalTo(self.provinceTableView.mas_right);
        make.height.mas_equalTo(self.provinceTableView.mas_height);
        make.width.mas_equalTo(0);
    }];
    [self.zoneTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.width.mas_equalTo(0);
        make.left.mas_equalTo(self.cityTableView.mas_right);
        make.height.mas_equalTo(self.provinceTableView.mas_height);
    }];
    
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.provinceTableView.mas_bottom);
        make.width.mas_equalTo(LBScreenW);
        make.left.offset(0);
        make.height.mas_equalTo(0);
    }];
//    NSLog(@"dataSource: %ld",self.dataSource.count);
//    [self.dataSource enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
//        LBAddressModel *provinceModel = object;
//        NSLog(@"provinceName: %@",provinceModel.name);
//        [provinceModel.cityList enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
//            LBAddressModel *cityModel = object;
//            NSLog(@"cityName: %@",cityModel.name);
//            [cityModel.areaList enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
//                LBAddressModel *areaModel = object;
//                NSLog(@"areaName: %@",areaModel.name);
//            }];
//        }];
//    }];
}

- (void)touchUpbgView {
    if (self.touchBGView) {
        self.touchBGView();
    }
    
    [LBAddressTableView hideIn:self.currentView];
}

- (void)setProvinceArr:(NSMutableArray *)provinceArr {
    _provinceArr = provinceArr;
}

- (void)setCityArr:(NSMutableArray *)cityArr {
    _cityArr = cityArr;
}

- (void)setZoneArr:(NSMutableArray *)zoneArr {
    _zoneArr = zoneArr;
}

#pragma mark - 数据源
//返回指定组的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.provinceTableView == tableView) {
        return self.provinceArr.count;
    } else if (self.cityTableView == tableView) {
        return self.cityArr.count;
    } else
        return self.zoneArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.provinceTableView == tableView) {
        static NSString *cellId = @"provinceCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        LBAddressModel * addressModel = self.provinceArr[indexPath.row];
        cell.textLabel.text = addressModel.name;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = self.provinceModel == self.provinceArr[indexPath.row] ? LBUIColorWithRGB(0x4CB371, .9) : LBUIColorWithRGB(0xDCDCDC, 1);
        return cell;
    } else if (self.cityTableView == tableView) {
        static NSString *cellId = @"cityCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        LBAddressModel * cityModel = self.cityArr[indexPath.row];
        cell.textLabel.text = cityModel.name;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = self.cityModel == self.cityArr[indexPath.row] ? LBUIColorWithRGB(0x4CB371, .9) : LBUIColorWithRGB(0xE8E8E8, 1);
        return cell;
    } else if (self.zoneTableView == tableView) {
        static NSString *cellId = @"zoneCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.backgroundColor = [self.nowSelectObjectArr containsObject:self.zoneArr[indexPath.row]]?LBUIColorWithRGB(0x4CB371, .9):LBUIColorWithRGB(0xF5F5F5, 1);
        
        LBAddressModel * zoneModel = self.zoneArr[indexPath.row];
        cell.textLabel.text = zoneModel.name;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;

        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - 点击右侧 cell 的代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:0];

    // 点击省出现市
    if (tableView == self.provinceTableView) {
        LBAddressModel* model = self.provinceArr[currentIndex.row];
        [self showTableWithIndex:indexPath type:@"city" model:model];
        
    } else if (tableView == self.cityTableView) {
        LBAddressModel* model = self.cityArr[currentIndex.row];
        [self showTableWithIndex:indexPath type:@"zone" model:model];
       
    } else if (tableView == self.zoneTableView) {
        LBAddressModel* model = self.zoneArr[currentIndex.row];
        [self showTableWithIndex:indexPath type:@"done" model:model];
    }
}

- (void)showTableWithIndex:(NSIndexPath*)indexPath type:(NSString*)type model:(LBAddressModel*)model {
    // 把省对应的市的数组给属性赋值
    if ([type isEqualToString:@"city"]) {   // 点击省
        self.cityArr = [NSMutableArray arrayWithArray:model.cityList];
        self.provinceModel = model;
        [self.provinceTableView reloadData];
        [self.cityTableView reloadData];
        [self changeFrameWithType:@"city"];
    } else if ([type isEqualToString:@"zone"]) {    // 点击市
        self.zoneArr = [NSMutableArray arrayWithArray:model.areaList];
        [self.cityTableView reloadData];
        [self.zoneTableView reloadData];
        self.cityModel = model;
        [self changeFrameWithType:@"zone"];
        [self.nowSelectObjectArr removeAllObjects];
    } else if ([type isEqualToString:@"done"]) {    // 点击区
        NSLog(@"nowSelectObjectArr: %@",self.nowSelectObjectArr);
        if ([self.nowSelectObjectArr containsObject:self.zoneArr[indexPath.row]]) {
            [self.nowSelectObjectArr removeObject:self.zoneArr[indexPath.row]];
        }else{
            [self.nowSelectObjectArr addObject:self.zoneArr[indexPath.row]];
        }
        [self.zoneTableView reloadData];
    }
}

- (void)changeFrameWithType:(NSString*)type {
    UITableView *tableView = [type isEqualToString:@"city"]?self.provinceTableView:self.cityTableView;
    UITableView* childView = [type isEqualToString:@"city"]?self.cityTableView:self.zoneTableView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([type isEqualToString:@"city"]?LBScreenW/4:(LBScreenW/4*3)/5*2);
            }];
            [tableView.superview layoutIfNeeded];//强制绘制
            [childView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([type isEqualToString:@"city"]?LBScreenW/4*3:(LBScreenW/4*3)/5*3);
            }];
            [childView.superview layoutIfNeeded];//强制绘制
        }];
    });
}

- (void)footViewBtnsCallback {
    WeakSelf(weakSelf);
    // 重置
    self.footView.resetBlock = ^{
        StrongSelf(strongSelf);
        NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        [strongSelf tableView:strongSelf.provinceTableView didSelectRowAtIndexPath:currentIndex];
//        strongSelf.provinceModel = nil;
        strongSelf.cityModel = nil;
        [strongSelf.nowSelectObjectArr removeAllObjects];
        [strongSelf.provinceTableView reloadData];
        [strongSelf.cityTableView reloadData];
        [strongSelf.zoneTableView reloadData];
        if (strongSelf.resetCallback) {
            strongSelf.resetCallback();
        }
    };
    
    // 确定
    self.footView.sureBlock = ^{
        StrongSelf(strongSelf);
        if (strongSelf.nowSelectObjectArr.count > 0) {
            if (strongSelf.addressCallback) {
                strongSelf.addressCallback(strongSelf.provinceModel,strongSelf.cityModel,strongSelf.nowSelectObjectArr);
            }
            [strongSelf touchUpbgView];
        } else {
            [strongSelf footViewBtnsCallback];
            [strongSelf touchUpbgView];
        }
    };
}

- (UITableView *)provinceTableView {
    if (!_provinceTableView) {
        _provinceTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _provinceTableView.delegate = self;
        _provinceTableView.dataSource = self;
        _provinceTableView.backgroundColor = [UIColor whiteColor];
        _provinceTableView.tableFooterView = [UIView new];
        _provinceTableView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _provinceTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _provinceTableView;
}
    
- (UITableView *)cityTableView {
    if (!_cityTableView) {
        _cityTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _cityTableView.delegate = self;
        _cityTableView.dataSource = self;
        _cityTableView.backgroundColor = [UIColor whiteColor];
        _cityTableView.tableFooterView = [UIView new];
        _cityTableView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _cityTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _cityTableView;
}
    
- (UITableView *)zoneTableView {
    if (!_zoneTableView) {
        _zoneTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _zoneTableView.delegate = self;
        _zoneTableView.dataSource = self;
        _zoneTableView.tableFooterView = [UIView new];
        _zoneTableView.backgroundColor = [UIColor whiteColor];
        _zoneTableView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _zoneTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _zoneTableView;
}

- (NSMutableArray *)nowSelectObjectArr {
    if (!_nowSelectObjectArr) {
        _nowSelectObjectArr = @[].mutableCopy;
    }
    return _nowSelectObjectArr;
}

- (LBAddressFootView *)footView {
    if (!_footView) {
        _footView = [LBAddressFootView new];
        _footView.backgroundColor = LBUIColorWithRGB(0xFFFFFF, 1);
    }
    return _footView;
}

/* 显示提示框的动画 */
- (void)shakeToShow {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.provinceTableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LBFit(420));
            }];
            [self.provinceTableView.superview layoutIfNeeded];//强制绘制
        }];
        [self.footView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(LBFit(70));
        }];
        [self.footView.superview layoutIfNeeded];//强制绘制
    });
}
// 复选方法
- (void)selectedToshow:(LBAddressModel*)province city:(LBAddressModel*)city areaArr:(NSMutableArray*)areaArr {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.provinceTableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LBFit(420));
                make.width.mas_equalTo(LBScreenW/4);
            }];
            [self.cityTableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.top.mas_equalTo(self.provinceTableView);
                make.left.mas_equalTo(self.provinceTableView.mas_right);
                make.width.mas_equalTo((LBScreenW/4*3)/5*2);
            }];
            [self.footView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LBFit(70));
            }];
            [self.footView.superview layoutIfNeeded];//强制绘制
            [self.cityTableView.superview layoutIfNeeded];//强制绘制
            [self.provinceTableView.superview layoutIfNeeded];//强制绘制
        }];
    });
    [self.provinceArr enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        LBAddressModel* provinceModel = object;
        if ([provinceModel.name isEqualToString:province.name]) {
            NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:idx inSection:0];
            [self showTableWithIndex:currentIndex type:@"city" model:provinceModel];
        }
    }];
    [self.cityArr enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        LBAddressModel* cityModel = object;
        if ([cityModel.name isEqualToString:city.name]) {
            NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:idx inSection:0];
            [self showTableWithIndex:currentIndex type:@"zone" model:cityModel];
        }
    }];
    [self.zoneArr enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        LBAddressModel* zoneModel = object;
        NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:idx inSection:0];
        [areaArr enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            LBAddressModel* areaModel = object;
            if ([areaModel.name isEqualToString:zoneModel.name]) {
                [self showTableWithIndex:currentIndex type:@"done" model:zoneModel];
            }
        }];
    }];
    
}

@end
