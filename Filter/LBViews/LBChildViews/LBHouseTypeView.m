//
//  LBHouseTypeView.m
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/19.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import "LBHouseTypeView.h"
#import "LBHouseTypeModel.h"

typedef void(^LBResetBlock)(void);
typedef void(^LBHouseTypeTouchBGViewBlock)(void);
typedef void(^LBSureBlock)(NSMutableArray* selectedArray);

@interface LBHouseTypeFootView()

@property(nonatomic, strong)UIView* topLine;
@property(nonatomic, strong)UIButton* resetBtn;
@property(nonatomic, strong)UIButton* sureBtn;

@end

@implementation LBHouseTypeFootView

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
        make.height.mas_equalTo(LBFit(ButtonHeight));
        make.width.mas_equalTo((LBScreenW-LBFit(45))/2);
    }];
    
    [self.sureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.top.mas_equalTo(self.resetBtn);
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

@interface LBHouseTypeCell()

@property(nonatomic, strong)UILabel* title;
@property(nonatomic, strong)LBTypesModel* model;
@end

@implementation LBHouseTypeCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)setModel:(LBTypesModel *)model {
    _model = model;
    
    self.title.backgroundColor = model.isSelected==YES?LBUIColorWithRGB(0x4CB371, .9):LBUIColorWithRGB(0xE8E8E8, 1);
    self.title.text = model.title;
}

- (void)createUI {
    [self.contentView addSubview:self.title];
    
    [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
}

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = [UIColor blackColor];
        _title.font = [UIFont systemFontOfSize:14];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.backgroundColor = LBUIColorWithRGB(0xE8E8E8, 1);
        _title.layer.cornerRadius = 8;
        _title.clipsToBounds = YES;
    }
    return _title;
}

@end

@interface LBHouseTypeView() <UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic, strong)NSMutableArray* dataSource;
@property(nonatomic, copy)LBResetBlock resetBlock;
@property(nonatomic, copy)LBHouseTypeTouchBGViewBlock touchBGViewBlock;
@property(nonatomic, strong)UICollectionView* collectionView;
@property(nonatomic, strong)UIButton* sureBtn;
@property(nonatomic, strong)UIButton* resetBtn;
@property(nonatomic, copy)LBSureBlock sureCallbackBlock;
@property(nonatomic, strong)NSMutableArray* selectedArray;
@property(nonatomic, assign)BOOL isSureAction;
@property(nonatomic, strong)UIView* currentView;
@property(nonatomic, strong)LBHouseTypeFootView* footView;

@end

@implementation LBHouseTypeView

//显示
+ (LBHouseTypeView*)showHouseTypeIn:(UIView*)view dataSource:(NSMutableArray*)dataSource sureCallback:(void(^)(NSMutableArray* selectedArray))sureCallback touchUpBgView:(void(^)(void))touchBGView resetAction:(void(^)(void))resetAction {
    [self hideIn:view];
    LBHouseTypeView *hud = [[LBHouseTypeView alloc] initWithFrame:view.bounds];
    hud.userInteractionEnabled = YES;
    hud.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.05f];
    hud.dataSource = dataSource;
    hud.sureCallbackBlock = sureCallback;
    hud.touchBGViewBlock = touchBGView;
    hud.resetBlock = resetAction;
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
+ (LBHouseTypeView *)hideIn:(UIView *)view {
    LBHouseTypeView *hud = nil;
    for (LBHouseTypeView *subView in view.subviews) {
        if ([subView isKindOfClass:[LBHouseTypeView class]]) {
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
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UICollectionReusableView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UICollectionView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UIView"]) {//判断如果点击的是tableView的cell，就把手势给关闭了 return NO;//关闭手势 }//否则手势存在 return YES;
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
    [self addSubview:self.collectionView];
    [self addSubview:self.footView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(LBScreenW);
    }];
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom);
        make.left.right.height.offset(0);
    }];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    LBHouseTypeModel * dict = [self.dataSource objectAtIndex:section];
    return dict.houseTypeList.count> 0 ?dict.houseTypeList.count:0;
}

#pragma mark - item宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((LBScreenW-LBFit(50))/4, LBFit(40));
}
#pragma mark - head宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(LBScreenW,LBFit(50));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBHouseTypeCell * collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HouseTypeCell" forIndexPath:indexPath];
    
    LBHouseTypeModel* houseTypeModel =[self.dataSource objectAtIndex:indexPath.section];
    collectionCell.model = houseTypeModel.houseTypeList[indexPath.item];
    
    return collectionCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    //如果是头视图
     if (kind == UICollectionElementKindSectionHeader) {
         UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeadView" forIndexPath:indexPath];
         UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(LBFit(10), LBFit(10), LBScreenW, LBFit(30))];
         LBHouseTypeModel * dict = [self.dataSource objectAtIndex:indexPath.section];
         title.textColor = LBUIColorWithRGB(0x333333, 1.0);
         title.font = LBFontNameSize(Font_Bold, 18);
         title.text = dict.dictKey;
         [headView addSubview:title];
         
         return headView;
     }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    LBHouseTypeCell * selectCell = (LBHouseTypeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    LBHouseTypeModel* houseTypeModel = [self.dataSource objectAtIndex:indexPath.section];
    LBTypesModel* typesModel = houseTypeModel.houseTypeList[indexPath.item];
    typesModel.isSelected = !typesModel.isSelected;
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects: indexPath, nil]];
    [self.selectedArray addObject:typesModel];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    LBHouseTypeCell * deselectCell = (LBHouseTypeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    LBHouseTypeModel* houseTypeModel = [self.dataSource objectAtIndex:indexPath.section];
    LBTypesModel* typesModel = houseTypeModel.houseTypeList[indexPath.item];
    typesModel.isSelected = !typesModel.isSelected;
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects: indexPath, nil]];
    [self.selectedArray removeObject:typesModel];
}
// 点击背景
- (void)touchUpbgView {
    [self resetSelected];
    
    if (self.touchBGViewBlock) {
        self.touchBGViewBlock();
    }
    [LBHouseTypeView hideIn:self.currentView];
}

// footCallback
- (void)footViewCallback {
    WeakSelf(weakSelf);
    // 重置
    self.footView.resetBlock = ^{
        StrongSelf(strongSelf);
        __block NSInteger indexSection = 0;
        [strongSelf.dataSource enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            LBHouseTypeModel* houseTypeModel = object;
            indexSection = idx;
            [houseTypeModel.houseTypeList enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                LBTypesModel *typesModel = object;
                typesModel.isSelected = NO;
                [UIView performWithoutAnimation:^{
                    NSIndexPath* index = [NSIndexPath indexPathForRow:idx inSection:indexSection];
                    [strongSelf.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects: index, nil]];
                }];
            }];
        }];
        [strongSelf.selectedArray removeAllObjects];
        if (strongSelf.resetBlock) {
            strongSelf.resetBlock();
        }
    };
    // 确定
    self.footView.sureBlock = ^{
        StrongSelf(strongSelf);
        strongSelf.isSureAction = YES;
        if (strongSelf.sureCallbackBlock) {
            strongSelf.sureCallbackBlock(strongSelf.dataSource);
        }
        [LBHouseTypeView hideIn:strongSelf.currentView];
    };
}
    
- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = @[].mutableCopy;
    }
    return _selectedArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置布局方向为垂直流布局
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        // 行间距
        layout.minimumLineSpacing = LBFit(10);
        layout.minimumInteritemSpacing = LBFit(10);
        layout.sectionInset = UIEdgeInsetsMake(LBFit(10), LBFit(10), LBFit(20), LBFit(10)); //设置距离上 左 下 右
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
         [_collectionView registerClass:[LBHouseTypeCell class] forCellWithReuseIdentifier:@"HouseTypeCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeadView"];
        _collectionView.backgroundColor = LBUIColorWithRGB(0xFFFFFF, 1.0);
        _collectionView.allowsMultipleSelection = YES;
    }
    return _collectionView;
}

- (LBHouseTypeFootView *)footView {
    if (!_footView) {
        _footView = [LBHouseTypeFootView new];
        _footView.backgroundColor = LBUIColorWithRGB(0xFFFFFF, 1);
    }
    return _footView;
}
    
/* 显示提示框的动画 */
- (void)shakeToShow {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LBFit(250));
            }];
            [self.footView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(LBFit(75));
            }];
            [self.footView.superview layoutIfNeeded];
            [self.collectionView.superview layoutIfNeeded];//强制绘制
        }];
    });
}

- (void)resetSelected {
    [self.selectedArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        LBTypesModel *typesModel = object;
        typesModel.isSelected = !typesModel.isSelected;
    }];
    [self.selectedArray removeAllObjects];
}

- (void)dealloc {
    if (self.isSureAction == NO) {
        [self resetSelected];
        self.isSureAction = YES;
    }
}

@end
