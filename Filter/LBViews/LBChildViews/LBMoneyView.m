//
//  LBMoneyView.m
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/19.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import "LBMoneyView.h"

#define dealocInfo NSLog(@"%@ 释放了",[self class])
#define baseColor [UIColor colorWithRed:0.389 green:0.670 blue:0.265 alpha:1.000]

static NSInteger tableH = 50;
typedef void(^LBTouchBGViewBlock)(NSString* selectTitle);
typedef void(^LBResetBlock)(NSString* selectTitle); // 确定

@interface LBRangeSliderItem ()

@end

@implementation LBRangeSliderItem

-(id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
       //添加手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

-(void)pan:(UIPanGestureRecognizer *)pan {
    if (self.pan) {
        if (self.pan) {
            self.pan(pan,_itemStyle,self);
        }
    }
}

-(void)dealloc {
    dealocInfo;
}

@end

@interface LBRangeSlider ()

@property(nonatomic, strong)NSMutableArray* titleLabelArray;
@property(nonatomic, assign)int mixValue;
@property(nonatomic, assign)int maxValue;
@property(nonatomic, strong)UIImageView* bottomView;
@property(nonatomic, strong)UIImageView* upView;

@end

@implementation LBRangeSlider

- (id)initWithFrame:(CGRect)frame {
    if (self  = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        //init data
        self.titleLabelArray = [[NSMutableArray alloc] initWithCapacity:0];
        //init config
        self.titleHeight = 0;
        self.titleColor = [UIColor grayColor];
        self.titleFont = [UIFont systemFontOfSize:12.0f];
                
        self.upViewHeight = 5;
        self.bottomViewHeight = 5;
        self.bottomColor = [UIColor colorWithWhite:0.788 alpha:1.000];
        self.upColor = baseColor;
        self.sliderItemSize = 20;
        self.maxValue = 0;
        self.mixValue = 0;
        
        [self refreshView];
    }
    return self;
}

-(void)setTitleHeight:(CGFloat )titleHeight {
    _titleHeight = titleHeight;
    [self refreshView];
}

-(void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    if(_maxValue == 0)
        _maxValue = (int)titleArray.count - 1;
    [self refreshView];
}
-(void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [self refreshView];
}
-(void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [self refreshView];
}

//滑块
-(void)setBottomColor:(UIColor *)bottomColor {
    _bottomColor = bottomColor;
    [self refreshView];
}

-(void)setUpColor:(UIColor *)upColor {
    _upColor = upColor;
    [self refreshView];
}

-(void)setSliderItemSize:(CGFloat)sliderItemSize {
    _sliderItemSize = sliderItemSize;
    [self refreshView];
}

-(void)setBottomViewHeight:(CGFloat)bottomViewHeight {
    _bottomViewHeight = bottomViewHeight;
    [self refreshView];
}

-(void)setUpViewHeight:(CGFloat)upViewHeight {
    _upViewHeight = upViewHeight;
    [self refreshView];
}

-(void)refreshView {
   //清空之前的title
    while (self.titleLabelArray.count > 0) {
        [self.titleLabelArray.lastObject removeFromSuperview];
        [self.titleLabelArray removeLastObject];
    }
    
    //重新加载新标题
    CGFloat width = self.titleArray == nil ? 0 : self.frame.size.width/self.titleArray.count;
    for (int i = 0; i < self.titleArray.count; i++) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{i*width,0},{width,self.titleHeight}}];
        titleLabel.textColor = self.titleColor;
        titleLabel.font = self.titleFont;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        if (0 == i) {
            titleLabel.textAlignment = NSTextAlignmentLeft;
        } else if (self.titleArray.count - 1 == i) {
            titleLabel.textAlignment = NSTextAlignmentRight;
        }
        [self addSubview:titleLabel];
        titleLabel.text = [self.titleArray objectAtIndex:i];
        [self.titleLabelArray addObject:titleLabel];
    }

#pragma mark 加载滑块
    //加底部线
    [self.bottomView removeFromSuperview];
    if (self.bottomView == nil) {
        self.bottomView = [[UIImageView alloc] init];
    }
    self.bottomView.frame = CGRectMake(0,self.titleHeight + 10 + self.sliderItemSize/2 - self.bottomViewHeight/2, self.frame.size.width, self.bottomViewHeight);
    _bottomView.backgroundColor = self.bottomColor;
    [self addSubview:self.bottomView];
    //加上部线
    [self.upView removeFromSuperview];
    if (self.upView == nil) {
        self.upView = [[UIImageView alloc] init];
    }
    CGFloat mixX = self.mixValue == 0 ? self.sliderItemSize/2 :(self.mixValue*width + width/2);
    CGFloat maxX = self.maxValue == 0 || self.maxValue == self.titleArray.count - 1 ? (self.frame.size.width - self.sliderItemSize/2) : self.maxValue*width + width/2;
    _upView.frame = CGRectMake(mixX,self.titleHeight + 10 + self.sliderItemSize/2 - self.upViewHeight/2,maxX - mixX, self.upViewHeight);
    _upView.backgroundColor = _upColor;
    [self addSubview:_upView];
    //加滑块
    [self.leftItem removeFromSuperview];
    if (self.leftItem == nil) {
        self.leftItem = [[LBRangeSliderItem alloc] init];
    }
    self.leftItem.frame = CGRectMake(0, 0, self.sliderItemSize, self.sliderItemSize);
    self.leftItem.layer.cornerRadius = self.sliderItemSize/2;
    self.leftItem.backgroundColor = self.upColor;
    self.leftItem.itemStyle = 0;
    self.leftItem.center = CGPointMake(mixX, self.upView.center.y);
    [self addSubview:self.leftItem];
    
    [self.rightItem removeFromSuperview];
    if (self.rightItem == nil) {
        self.rightItem = [[LBRangeSliderItem alloc] init];
    }
    self.rightItem.frame = CGRectMake(0, 0, self.sliderItemSize, self.sliderItemSize);
    self.rightItem.layer.cornerRadius = self.sliderItemSize/2;
    self.rightItem.backgroundColor = self.upColor;
    self.rightItem.itemStyle = 1;
    self.rightItem.range = (int)self.titleArray.count - 1;
    self.rightItem.center = CGPointMake(maxX, self.upView.center.y);
    [self addSubview:_rightItem];
    
    //滑块的滑动block
    WeakSelf(weakSelf);
    void (^pan)(UIPanGestureRecognizer * pan,int itemStyle ,LBRangeSliderItem * item) = ^(UIPanGestureRecognizer * pan,int itemStyle,LBRangeSliderItem * item) {
        StrongSelf(strongSelf);
        if (strongSelf) {
            if (pan.state == UIGestureRecognizerStateBegan) {}
            if (pan.state == UIGestureRecognizerStateChanged) {
                CGPoint point = [pan locationInView:strongSelf];
                CGFloat x = point.x;
                if(0 == itemStyle){ //左滑块
                    if (x < strongSelf.sliderItemSize/2){ //最左边
                        x = strongSelf.sliderItemSize/2;
                    }
                    if(x > strongSelf.rightItem.center.x - strongSelf.sliderItemSize) { //不能超过右边
                        x = strongSelf.rightItem.center.x - strongSelf.sliderItemSize;
                    }
                    item.center = CGPointMake(x, item.center.y);
                }
                else if (1 == itemStyle) {//右滑块
                    if (x > (strongSelf.frame.size.width - strongSelf.sliderItemSize/2)) {
                        x = strongSelf.frame.size.width - strongSelf.sliderItemSize/2;
                    }
                    if(x < strongSelf.leftItem.center.x + strongSelf.sliderItemSize) {
                        x = strongSelf.leftItem.center.x + strongSelf.sliderItemSize;
                    }
                    item.center = CGPointMake(x, item.center.y);
                }
                //跳整上面的浮动
                CGFloat width = self.rightItem.center.x - self.leftItem.center.x;
                strongSelf.upView.frame = CGRectMake(0 == itemStyle ? x + strongSelf.sliderItemSize/2 : strongSelf.leftItem.center.x + strongSelf.sliderItemSize/2, strongSelf.upView.frame.origin.y,width,strongSelf.upViewHeight);
            }
            
            if (pan.state == UIGestureRecognizerStateEnded) {
                [strongSelf adjustSliderItem];
            }
        }
    };
    self.leftItem.pan = pan;
    self.rightItem.pan = pan;
}

//调整滑块到正确的结点
-(void)adjustSliderItem {
    WeakSelf(weakSelf);
    CGFloat width = self.titleArray == nil ? 0 : self.frame.size.width/self.titleArray.count;
    //左边
    int range = self.leftItem.center.x/width;
    if (range == self.titleArray.count - 1) {
        range--;
    }
    if (range == 0) {
        if (self.leftItem.center.x > width/2) {
            range++;
        }
    }
    if (self.rightItem.center.x == range*width + width/2) {
        range--;
    }
    CGPoint center =  CGPointMake(range == 0 ? self.sliderItemSize/2 : range*width + width/2, self.leftItem.center.y);
    [UIView animateWithDuration:0.2 animations:^{
        StrongSelf(strongSelf);
        strongSelf.leftItem.center = center;
        strongSelf.upView.frame = CGRectMake(center.x, strongSelf.upView.frame.origin.y, strongSelf.rightItem.center.x - center.x, strongSelf.upView.frame.size.height);
    } completion:^(BOOL finished){
        StrongSelf(strongSelf);
        strongSelf.leftItem.range = range;
        strongSelf.mixValue = range;
        if (strongSelf.leftItemCallback) {
            strongSelf.leftItemCallback(strongSelf.mixValue);
        }
         //此处加值变化通知
        [strongSelf sendActionsForControlEvents:UIControlEventValueChanged];
    }];
    //右边
    range = self.rightItem.center.x/width;
    if (range == self.titleArray.count - 1) {
        if (self.rightItem.center.x < self.frame.size.width -  width/2) {
            range--;
        }
    }
    if (range == 0) {
        range = 1;
    }
    if (self.leftItem.center.x == range*width + width/2) {
        range++;
    }
    center =  CGPointMake(range == self.titleArray.count - 1 ? self.frame.size.width - self.sliderItemSize/2 : range*width + width/2, self.rightItem.center.y);
    [UIView animateWithDuration:0.2 animations:^{
        StrongSelf(strongSelf);
        strongSelf.rightItem.center = center;
        strongSelf.upView.frame = CGRectMake(strongSelf.upView.frame.origin.x, strongSelf.upView.frame.origin.y, strongSelf.rightItem.center.x - strongSelf.leftItem.center.x, strongSelf.upView.frame.size.height);
    } completion:^(BOOL finished){
        StrongSelf(strongSelf);
        strongSelf.rightItem.range = range;
        strongSelf.maxValue = range;
        if (strongSelf.rightItemCallback) {
            strongSelf.rightItemCallback(strongSelf.maxValue);
        }
        //此处加值变化通知
        [strongSelf sendActionsForControlEvents:UIControlEventValueChanged];
    }];
}

-(void)dealloc {
    dealocInfo;
}
@end

@interface LBSliderView() <UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIView* bgView;
@property(nonatomic, strong)LBRangeSlider* slider;
@property(nonatomic, copy)NSString* selectString;
@property(nonatomic, strong)NSMutableArray* dataSource;
@property(nonatomic, copy)void(^minCallback)(NSString* minString);
@property(nonatomic, copy)void(^maxCallback)(NSString* maxString);

@end

@implementation LBSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
        
        UITapGestureRecognizer*pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpbgView)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark-手势代理，解决和tableview点击发生的冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"LBSliderView"]) {//判断如果点击的是tableView的cell，就把手势给关闭了 return NO;//关闭手势 }//否则手势存在 return YES;
        return NO;
    }
    return YES;
}

- (void)createUI {
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.slider];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.offset(0);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(LBFit(20));
        make.right.bottom.offset(-LBFit(20));
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.slider.backgroundColor = [UIColor clearColor];
        self.slider.titleArray = self.dataSource;
        self.slider.titleHeight = 30;
        self.slider.titleFont = [UIFont systemFontOfSize:13];
        self.slider.sliderItemSize = 25;
    });
    WeakSelf(weakSelf);
    self.slider.leftItemCallback = ^(int minIndex) {
        StrongSelf(strongSelf);
        if (strongSelf.minCallback) {
            strongSelf.minCallback(strongSelf.dataSource[minIndex]);
        }
    };
    
    self.slider.rightItemCallback = ^(int maxIndex) {
        StrongSelf(strongSelf);
        if (strongSelf.maxCallback) {
            strongSelf.maxCallback(strongSelf.dataSource[maxIndex]);
        }
    };
}

- (void)setSelectString:(NSString *)selectString {
    _selectString = selectString;
    CGFloat min = 0;
    CGFloat max = 0;
    if ([selectString isEqualToString:@"不限"]) {
        min = 0;
        max = 8;
    } else if ([selectString containsString:@"<="]) {
        min = 0;
        max = 1;
    } else if ([selectString containsString:@">="]) {
        min = 7;
        max = 8;
    } else {
        NSArray *array = [selectString componentsSeparatedByString:@"~"];
        for (int i=0; i<self.dataSource.count; i++) {
            if ([self.dataSource[i] isEqualToString:array.firstObject]) {
                min = i;
            }
            if ([self.dataSource[i] isEqualToString:array.lastObject]) {
                max = i;
            }
        }
    }
    [self.slider setValue:@(min) forKey:@"mixValue"];
    [self.slider setValue:@(max) forKey:@"maxValue"];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
    }
    return _bgView;
}

- (LBRangeSlider *)slider {
    if (!_slider) {
        _slider = [LBRangeSlider new];
        //因为Slider是继承的UIControl,所以可以注册信息
        [_slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
        for(int i=0;i<8;i++) {
            [_dataSource addObject:[NSString stringWithFormat:@"%d",i*1000]];
        }
        [_dataSource addObject:@"不限"];
    }
    return _dataSource;
}

- (void)valueChange:(id)sender {}
- (void)touchUpbgView{}
@end

@interface LBMoneyFootView() <UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIButton* resetBtn;
@property(nonatomic, strong)UIView* topLine;
@property(nonatomic, strong)LBSliderView* sliderView;
@property(nonatomic, copy)NSString* selectString;
@property(nonatomic, copy)NSString* sliderMinString;
@property(nonatomic, copy)NSString* sliderMaxString;
@property(nonatomic, copy)void(^footCallback)(NSString* selectedString);

@end

@implementation LBMoneyFootView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
        
        [self sliderCallback];
    }
    return self;
}

- (void)createUI {
    [self addSubview:self.resetBtn];
    [self addSubview:self.topLine];
    [self addSubview:self.sliderView];
    
    [self.topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.mas_equalTo(1);
    }];
    
    [self.sliderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.mas_equalTo(LBFit(100));
    }];
    
    [self.resetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(LBFit(110));
        make.left.offset(LBFit(15));
        make.right.offset(-LBFit(15));
        make.height.mas_equalTo(LBFit(ButtonHeight));
    }];
    
    [self.resetBtn setBackgroundImage:[UIImage lb_createImageWithSize:CGSizeMake(self.width - (LBFit(40)), LBFit(ButtonHeight)) gradientColors:@[LBUIColorWithRGB(0x3CB371, 1.0),LBUIColorWithRGB(0x64AB44, 1.0)] percentage:@[@0.0,@1.0] gradientType:LBImageGradientFromTopToBottom] forState:UIControlStateNormal];
    self.resetBtn.layer.cornerRadius = 5;
    self.resetBtn.clipsToBounds = YES;
}

- (void)sliderCallback {
    WeakSelf(weakSelf);
    self.sliderView.minCallback = ^(NSString *minString) {
        StrongSelf(strongSelf);
        strongSelf.sliderMinString = LBNULLString(minString)?@"":minString;
    };
    self.sliderView.maxCallback = ^(NSString *maxString) {
        StrongSelf(strongSelf);
        strongSelf.sliderMaxString = LBNULLString(maxString)?@"":maxString;
    };
}

- (LBSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [LBSliderView new];
    }
    return _sliderView;
}

- (void)setSelectString:(NSString *)selectString {
    _selectString = selectString;
    
    self.sliderView.selectString = selectString;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [UIButton new];
        _resetBtn.titleLabel.font = LBFontNameSize(Font_Regular, 15);
        [_resetBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_resetBtn setTitleColor:LBUIColorWithRGB(0xFFFFFF, 1.0) forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = LBUIColorWithRGB(0xCFCFCF, 1);
    }
    return _topLine;
}

- (void)resetAction {
    if (self.footCallback) {
        self.footCallback([NSString stringWithFormat:@"%@~%@",LBNULLString(self.sliderMinString)?@"":self.sliderMinString,LBNULLString(self.sliderMaxString)?@"":self.sliderMaxString]);
    }
}

@end

@interface LBMoneyView() <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic, strong)UITableView* childtableView;
@property(nonatomic, copy)NSArray* dataSource;
@property(nonatomic, copy)LBTouchBGViewBlock touchBGViewBlock;
@property(nonatomic, strong)LBMoneyFootView* footView;
@property(nonatomic, copy)NSString* selectedItem;
@property(nonatomic, strong)NSIndexPath* lastIndex;
@property(nonatomic, strong)UIView* currentView;
@property(nonatomic, copy)void(^footCallback)(NSString* selectedString);

@end

@implementation LBMoneyView

//显示
+ (LBMoneyView*)showIn:(UIView*)view dataSource:(NSArray*)dataSource selectedItem:(NSString *)selectedItem touchUpBgView:(void(^)(NSString* selectTitle))touchBGView resetAction:(void(^)(NSString* selectTitle))reset {
    [self hideIn:view];
    LBMoneyView *hud = [[LBMoneyView alloc] initWithFrame:view.bounds];
    hud.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.05f];
    hud.dataSource = dataSource;
    hud.touchBGViewBlock = touchBGView;
    hud.footCallback = reset;
    hud.selectedItem = selectedItem;
    hud.currentView = view;
    [hud shakeToShow];
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
+ (LBMoneyView *)hideIn:(UIView *)view {
    LBMoneyView *hud = nil;
    for (LBMoneyView *subView in view.subviews) {
        if ([subView isKindOfClass:[LBMoneyView class]]) {
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
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {//判断如果点击的是tableView的cell，就把手势给关闭了 return NO;//关闭手势 }//否则手势存在 return YES;
        return NO;
    }
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubView];
        
        [self footViewCallback];
    }
    return self;
}

- (void)createSubView {
    [self addSubview:self.childtableView];
    [self addSubview:self.footView];
    
    [self.childtableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(LBScreenW);
    }];
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.childtableView.mas_bottom);
        make.height.left.mas_equalTo(0);
        make.width.mas_equalTo(LBScreenW);
    }];
}
    
- (void)touchUpbgView {
    if (self.touchBGViewBlock) {
        self.touchBGViewBlock(self.selectedItem);
    }
    [LBMoneyView hideIn:self.currentView];
}

- (void)footViewCallback {
    WeakSelf(weakSelf);
    self.footView.footCallback = ^(NSString *selectedString) {
        StrongSelf(strongSelf);
        NSArray *array = [selectedString componentsSeparatedByString:@"~"];
        if (strongSelf.footCallback) {
            strongSelf.footCallback(LBNULLString(array.lastObject)?strongSelf.selectedItem:[array.firstObject isEqualToString:@"0"]&&[array.lastObject isEqualToString:@"不限"]?@"":selectedString);
        }
        [LBMoneyView hideIn:strongSelf.currentView];
    };
}

#pragma mark -  tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource?self.dataSource.count:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LBFit(tableH);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellsId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.textColor = [self.selectedItem isEqualToString:self.dataSource[indexPath.item]]&& ![self.selectedItem isEqualToString:@"不限"]? LBUIColorWithRGB(0x4CB371, 1):LBUIColorWithRGB(0x666666, 1);
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    if ([self.selectedItem isEqualToString:self.dataSource[indexPath.row]] && ![self.selectedItem isEqualToString:@"不限"]) {
        self.lastIndex = indexPath;
    }
    
    self.footView.selectString = self.selectedItem;
    
    return cell;
}

// 设置距离左右各15的距离
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // 设置cell分割线位置
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"点击了第%ld行",indexPath.row);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = LBUIColorWithRGB(0x4CB371, 1);
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:self.lastIndex];
    lastCell.textLabel.textColor = LBUIColorWithRGB(0x666666, 1);
    
    //    刷新某一行
    //    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:0];
    //    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.touchBGViewBlock) {
        self.touchBGViewBlock(self.dataSource[indexPath.row]);
    }
    
    [LBMoneyView hideIn:self.currentView];
}

- (UITableView *)childtableView {
    if (!_childtableView) {
        _childtableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _childtableView.delegate = self;
        _childtableView.dataSource = self;
        _childtableView.userInteractionEnabled = YES;
        _childtableView.backgroundColor = [UIColor whiteColor];
        if (@available(iOS 11.0, *)) {
            _childtableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _childtableView;
}

- (LBMoneyFootView *)footView {
    if (!_footView) {
        _footView = [[LBMoneyFootView alloc] initWithFrame:CGRectMake(0, 0, LBScreenW, LBFit(85))];
        _footView.backgroundColor = [UIColor whiteColor];
    }
    return _footView;
}

/* 显示提示框的动画 */
- (void)shakeToShow {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.childtableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LBFit(tableH)*self.dataSource.count);
            }];
            [self.footView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LBFit(175));
            }];
            [self.footView.superview layoutIfNeeded];
            [self.childtableView.superview layoutIfNeeded];//强制绘制
        }];
    });
}

@end
