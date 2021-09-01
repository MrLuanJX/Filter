//
//  LBSegementView.m
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/16.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import "LBSegementView.h"
#import "LBHouseTypeModel.h"
#import "LBFilterModel.h"
#import "LBAddressModel.h"

@interface LBSegementCell()

@property(nonatomic, copy)NSArray* dataSource;
@property(nonatomic, strong)UILabel* title;
@property(nonatomic, copy)NSString * text;

@property (nonatomic, assign) BOOL clicked; // 是否选中
@end

@implementation LBSegementCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)setClicked:(BOOL)clicked {
    _clicked = clicked;
    self.title.textColor = clicked == YES ? LBUIColorWithRGB(0x4CB371, 1):LBUIColorWithRGB(0x333333, 1);//[UIColor redColor]: [UIColor blackColor];
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.title.text = text;
}

- (void)createUI {
    [self addSubview:self.title];
    [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.mas_equalTo(LBFit(30));
        make.centerY.offset(0);
    }];
}

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = [UIColor blackColor];
        _title.font = [UIFont boldSystemFontOfSize:14];
        _title.textAlignment = NSTextAlignmentCenter;
    }
    return _title;
}

@end

@interface LBSegementBtns()<UICollectionViewDelegate,UICollectionViewDataSource>

/* 一个item项点击回调*/
@property(nonatomic,copy)void(^ChooseItem)(UICollectionView* collectionView,LBSegementCell* cell,NSIndexPath* index,BOOL isClicked);
@property(nonatomic, strong)UICollectionView* collectionView;
@property(nonatomic, copy)NSArray* dataSource;
@property(nonatomic, assign)NSInteger seletedTag;
@property(nonatomic, strong)NSIndexPath* index;

@end

@implementation LBSegementBtns

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    [self addSubview:self.collectionView];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.offset(0);
        make.height.mas_equalTo(LBFit(60));
    }];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count>0 ?self.dataSource.count : 0;
}

#pragma mark - item宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((LBScreenW - self.dataSource.count + 1)/self.dataSource.count, LBFit(60));
    
    // 核心代码 动态宽度计算
    //  LL_ScreenWidth -74 （文本最大宽度）最大就是一行放置一个
//     CGRect itemFrame = [self.dataSource[indexPath.item] boundingRectWithSize:CGSizeMake(LBScreenW-self.dataSource.count+1, 14) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
//    //  item的宽度 文本宽度+左右间距合计24
//     CGFloat width = itemFrame.size.width + 24;
//     //  item的size
//     return CGSizeMake(width, LBFit(60));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBSegementCell * collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"segementCell" forIndexPath:indexPath];
    [collectionCell setValue:self.dataSource[indexPath.item] forKey:@"text"];
    return collectionCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LBSegementCell * cell = (LBSegementCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if (self.ChooseItem) {
        self.ChooseItem(collectionView, cell, indexPath, cell.clicked);
    }
}

//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    LBSegementCell * cell = (LBSegementCell *)[collectionView cellForItemAtIndexPath:indexPath];
//}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置布局方向为垂直流布局
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // 行间距
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //设置距离上 左 下 右
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
         [_collectionView registerClass:[LBSegementCell class] forCellWithReuseIdentifier:@"segementCell"];
        _collectionView.backgroundColor = LBUIColorWithRGB(0xCDCDCD, 1.0);
//        _collectionView.allowsMultipleSelection = YES;
    }
    return _collectionView;
}

@end

@interface LBSegementView() <UIScrollViewDelegate>

@property(nonatomic, strong)LBSegementBtns* btnsView;
@property(nonatomic, copy)NSArray* dataSource;

@property(nonatomic, strong)NSIndexPath* currentIndexPath;
@property(nonatomic, copy)NSString* moneySelectedItem;
@property(nonatomic, strong)NSMutableArray* selectedArray;
@property(nonatomic, strong)NSMutableArray* houseAllSelected;
@property(nonatomic, strong)NSMutableArray* houseJoinSelected;

@property(nonatomic, strong)NSMutableArray* addressArray;
@property(nonatomic, strong)LBAddressModel* provinceSelected;
@property(nonatomic, strong)LBAddressModel* citySelected;
@property(nonatomic, strong)NSMutableArray* areaSelecteds;
@property(nonatomic, strong)NSMutableArray* fliterSelecteds;

@property(nonatomic, assign)BOOL isShow;
@property(nonatomic, assign)BOOL houseIsShow;
@property(nonatomic, assign)BOOL addressIsShow;
@property(nonatomic, assign)BOOL filterIsShow;

// filter
@property(nonatomic, strong)NSMutableArray* filterArray;

@end

@implementation LBSegementView 

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
                
        [self createUI];
        
        [self loadAddress];
    }
    return self;
}

- (void)createUI {
    [self addSubview:self.btnsView];

    [self.btnsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.mas_equalTo(0);
        make.height.mas_equalTo(LBFit(60));
    }];
    
    WeakSelf(weakSelf);
    self.btnsView.ChooseItem = ^(UICollectionView* collectionView,LBSegementCell* cell,NSIndexPath* index,BOOL isClicked) {
        StrongSelf(strongSelf);
        
        if (strongSelf.currentIndexPath.item == index.item) {
            if (index.item == 0) {
                if (strongSelf.isShow == YES) {
                    [LBMoneyView hideIn:strongSelf];
                    strongSelf.isShow = NO;
                    cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]? NO: YES;;
                } else {
                    [strongSelf selectedMoneyWithIndex:index cell:cell];
                    strongSelf.isShow = YES;
                    cell.clicked = YES;
                }
            }
            if (index.item == 1) {
                if (strongSelf.houseIsShow == YES) {
                    [LBHouseTypeView hideIn:strongSelf];
                    strongSelf.houseIsShow = NO;
                    cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]? NO: YES;;
                } else {
                    [strongSelf selectedHouseTypeWithIndex:index cell:cell];
                    strongSelf.houseIsShow = YES;
                    cell.clicked = YES;
                }
            }
            if (index.item == 2) {
                if (strongSelf.addressIsShow == YES) {
                    [LBAddressTableView hideIn:strongSelf];
                    strongSelf.addressIsShow = NO;
                    cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]? NO: YES;;
                } else {
                    [strongSelf selectedAddressWithIndex:index cell:cell];
                    strongSelf.addressIsShow = YES;
                    cell.clicked = YES;
                }
            }
            if (index.item == 3) {
                if (strongSelf.filterIsShow == YES) {
                    [LBFilterView hideIn:strongSelf];
                    strongSelf.filterIsShow = NO;
                    cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]? NO: YES;;
                } else {
                    [strongSelf selectedFilterWithIndex:index cell:cell];
                    strongSelf.filterIsShow = YES;
                    cell.clicked = YES;
                }
            }
           
            strongSelf.currentIndexPath = index;
        } else {
            strongSelf.houseIsShow = YES;
            strongSelf.isShow = YES;
            strongSelf.addressIsShow = YES;
            strongSelf.filterIsShow = YES;
            
            [LBMoneyView hideIn:strongSelf];
            [LBHouseTypeView hideIn:strongSelf];
            [LBAddressTableView hideIn:strongSelf];
            [LBFilterView hideIn:strongSelf];
            
            LBSegementCell * lastCell = (LBSegementCell *)[collectionView cellForItemAtIndexPath:strongSelf.currentIndexPath];
            lastCell.clicked = [lastCell.title.text isEqualToString:strongSelf.dataSource[strongSelf.currentIndexPath.item]]? NO: YES;
            
            strongSelf.currentIndexPath = index;
            cell.clicked = YES;
            
            if (index.item == 0) {
                [strongSelf selectedMoneyWithIndex:index cell:cell];
            }
            if (index.item == 1) {
                [strongSelf selectedHouseTypeWithIndex:index cell:cell];
            }
            if (index.item == 2) {
                [strongSelf selectedAddressWithIndex:index cell:cell];
            }
            if (index.item == 3) {
                [strongSelf selectedFilterWithIndex:index cell:cell];
            }
        }
    };
}
// moneyViewShow
- (void)selectedMoneyWithIndex:(NSIndexPath*)index cell:(LBSegementCell*)cell  {
    WeakSelf(weakSelf);
    [LBMoneyView showIn:self dataSource:@[@"不限",@"<=1000",@"1000~2000",@"2000~3000",@"3000~5000",@"5000~7000",@">=7000"] selectedItem:self.moneySelectedItem touchUpBgView:^(NSString *selectTitle) {
        StrongSelf(strongSelf);
        // 点击背景/选中
        cell.title.text = LBNULLString(selectTitle)||[selectTitle isEqualToString:@"不限"]?strongSelf.dataSource[index.item]:selectTitle;
        strongSelf.moneySelectedItem = LBNULLString(selectTitle)?strongSelf.dataSource[index.item]:selectTitle;
        cell.clicked = LBNULLString(selectTitle)||[selectTitle isEqualToString:@"不限"]||[selectTitle isEqualToString:strongSelf.dataSource[index.item]]?NO:YES;
        strongSelf.isShow = NO;
    } resetAction:^(NSString *selectTitle) {    // 确定
        StrongSelf(strongSelf);
        NSLog(@"selectTitle: %@",selectTitle);
        cell.title.text = LBNULLString(selectTitle)||[selectTitle isEqualToString:@"不限"]?strongSelf.dataSource[index.item]:selectTitle;
        strongSelf.moneySelectedItem = LBNULLString(selectTitle)||[selectTitle isEqualToString:@"不限"]?strongSelf.dataSource[index.item]:selectTitle;
        strongSelf.isShow = NO;
        cell.clicked = LBNULLString(selectTitle)||[selectTitle isEqualToString:@"不限"]||[selectTitle isEqualToString:strongSelf.dataSource[index.item]]?NO:YES;
    }];
}
// houseTypeViewShow
- (void)selectedHouseTypeWithIndex:(NSIndexPath*)index cell:(LBSegementCell*)cell {
    WeakSelf(weakSelf);
    [LBHouseTypeView showHouseTypeIn:self dataSource:self.selectedArray sureCallback:^(NSMutableArray *selectedArray) {
        StrongSelf(strongSelf);
        // 确定
        strongSelf.selectedArray = selectedArray;
        __block NSString* cellTitle = @"";
        [strongSelf.houseAllSelected removeAllObjects];
        [strongSelf.houseJoinSelected removeAllObjects];
        
        [selectedArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            LBHouseTypeModel* houseTypeModel = object;
            if ([houseTypeModel.dictKey isEqualToString:@"整租"]) {
                [strongSelf enumArrayWithModel:houseTypeModel title:houseTypeModel.dictKey];
            }
            if ([houseTypeModel.dictKey isEqualToString:@"合租"]) {
                [strongSelf enumArrayWithModel:houseTypeModel title:houseTypeModel.dictKey];
            }
        }];
        
        if (strongSelf.houseAllSelected.count > 0) {
            cellTitle = [cellTitle stringByAppendingFormat:@"整租"];
        }
        if (strongSelf.houseJoinSelected.count > 0) {
            cellTitle = [cellTitle stringByAppendingFormat:@"合租"];
        }
        
        cell.title.text = LBNULLString(cellTitle)?self.dataSource[index.item]:cellTitle;
        cell.clicked = LBNULLString(cellTitle)?NO:YES;
        strongSelf.houseIsShow = NO;
    } touchUpBgView:^{  // 点击背景
        StrongSelf(strongSelf);
        // 点击背景
        cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]?NO:YES;
        strongSelf.houseIsShow = NO;
    } resetAction:^{ // 重置
        StrongSelf(strongSelf);
        cell.title.text = strongSelf.dataSource[index.item];
    }];
}
// addressAction
- (void)selectedAddressWithIndex:(NSIndexPath*)index cell:(LBSegementCell*)cell {
    WeakSelf(weakSelf);
    [LBAddressTableView showAddressTableIn:self dataSource:self.addressArray province:self.provinceSelected city:self.citySelected area:self.areaSelecteds addressBlock:^(LBAddressModel *province, LBAddressModel *city, NSMutableArray* areaArray) {
        StrongSelf(strongSelf);
        strongSelf.provinceSelected = province;
        strongSelf.citySelected = city;
        strongSelf.areaSelecteds = areaArray;
        if (areaArray.count > 1) {
            cell.title.text = @"多选";
        } else if (areaArray.count == 1) {
            cell.title.text = ((LBAddressModel*)areaArray.firstObject).name;
        } else
            cell.title.text = strongSelf.dataSource[index.item];
        cell.clicked = YES;
        strongSelf.addressIsShow = NO;
    } touchBGView:^{    // 点击背景
        StrongSelf(strongSelf);
        strongSelf.addressIsShow = NO;
        cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]? NO: YES;
    } resetCallback:^{  // 重置
        StrongSelf(strongSelf);
        strongSelf.provinceSelected = nil;
        strongSelf.citySelected = nil;
        [strongSelf.areaSelecteds removeAllObjects];
        cell.title.text = strongSelf.dataSource[index.item];
    }];
}
// filterAction
- (void)selectedFilterWithIndex:(NSIndexPath*)index cell:(LBSegementCell*)cell {
    WeakSelf(weakSelf);
    [LBFilterView showFilterWithView:self dataSource:self.filterArray sureCallback:^(NSMutableArray *selectedArray) {
        // 确定
        StrongSelf(strongSelf);
        [strongSelf.fliterSelecteds removeAllObjects];
        
        [selectedArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            LBFilterModel* filterModel = object;
            
            [filterModel.filterList enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                LBFilterListModel* listModel = object;
                NSLog(@"isSelected: %d",listModel.isSelected);
                
                if (listModel.isSelected == 1) {
                    [strongSelf.fliterSelecteds addObject:listModel];
                }
            }];
        }];
        
        if (strongSelf.fliterSelecteds.count==0) {
            cell.title.text = strongSelf.dataSource[index.item];
            cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]?NO:YES;
        } else if (strongSelf.fliterSelecteds.count==1) {
            LBFilterListModel* listModel = strongSelf.fliterSelecteds.firstObject;
            cell.title.text = listModel.title;
        } else if (strongSelf.fliterSelecteds.count>1) {
            cell.title.text = @"多选";
        }

        strongSelf.filterArray = selectedArray;
        strongSelf.filterIsShow = NO;
    } touchUpBgView:^{  // 点击背景
        StrongSelf(strongSelf);
        cell.clicked = [cell.title.text isEqualToString:strongSelf.dataSource[index.item]]?NO:YES;
        strongSelf.filterIsShow = NO;
    } resetAction:^{ // 重置
        StrongSelf(strongSelf);
        cell.title.text = strongSelf.dataSource[index.item];
        [strongSelf.fliterSelecteds removeAllObjects];
    }];
}

- (void)enumArrayWithModel:(LBHouseTypeModel*)houseTypeModel title:(NSString*)title {
    [houseTypeModel.houseTypeList enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        LBTypesModel* typesModel = object;
        if (typesModel.isSelected == YES) {
            [title isEqualToString:@"合租"]?[self.houseJoinSelected addObject:typesModel]:[self.houseAllSelected addObject:typesModel];
        }
    }];
}

- (LBSegementBtns*)btnsView{
    if (!_btnsView) {
        _btnsView = [LBSegementBtns new];
        _btnsView.dataSource = self.dataSource;
    }
    return _btnsView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"租金",@"户型",@"位置",@"筛选"];
    }
    return _dataSource;
}
    
- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = @[].mutableCopy;
        NSArray* keyArr = @[@"整租",@"合租"];
        NSArray* arr = @[@"一居",@"两居",@"三居",@"四居及以上"];
        NSArray* array = @[@"一居",@"两居",@"三居",@"四居及以上"];

        NSMutableArray* tempArr = @[].mutableCopy;
        NSMutableArray* tempArray = @[].mutableCopy;
        for (int j = 0; j < arr.count; j++) {
            LBTypesModel* typeModel = [LBTypesModel new];
            typeModel.isSelected = NO;
            typeModel.title = arr[j];
            [tempArr addObject:typeModel];
        }
        for (int j = 0; j < array.count; j++) {
            LBTypesModel* typeModel = [LBTypesModel new];
            typeModel.isSelected = NO;
            typeModel.title = array[j];
            [tempArray addObject:typeModel];
        }
        for (int i= 0; i< keyArr.count; i++) {
            LBHouseTypeModel* model = [LBHouseTypeModel new];
            model.dictKey = keyArr[i];
            model.houseTypeList = i==0 ?tempArr:tempArray;
            [_selectedArray addObject:model];
        }
    }
    return _selectedArray;
}

- (NSMutableArray *)houseAllSelected {
    if (!_houseAllSelected) {
        _houseAllSelected = @[].mutableCopy;
    }
    return _houseAllSelected;
}

- (NSMutableArray *)houseJoinSelected {
    if (!_houseJoinSelected) {
        _houseJoinSelected = @[].mutableCopy;
    }
    return _houseJoinSelected;
}

- (NSMutableArray *)addressArray {
    if (!_addressArray) {
        _addressArray = @[].mutableCopy;
    }
    return _addressArray;
}

- (NSMutableArray *)fliterSelecteds {
    if (!_fliterSelecteds) {
        _fliterSelecteds = @[].mutableCopy;
    }
    return _fliterSelecteds;
}

- (NSMutableArray *)filterArray {
    if (!_filterArray) {
        _filterArray = @[].mutableCopy;
        NSArray* brightArr = @[@"必看好房",@"近地铁",@"集中供暖",@"押一付一",@"新上",@"认证公寓",@"随时看房",@"VR房源",@"业主自荐"];
        NSArray* orienArr = @[@"东",@"南",@"西",@"北",@"南北"];
        NSArray* deadLineArr = @[@"月租",@"年租",@"一个月起租",@"1～3个月",@"4～6个月"];
        NSArray* elevatorArr = @[@"无电梯",@"有电梯"];
        NSArray* liveInDateArr = @[@"近5天内",@"近10天内",@"近15天内",@"近20天内",@"近30天内"];
        NSArray* floorArr = @[@"低楼层",@"中楼层",@"高楼层"];
        NSArray* fitmentArr = @[@"精装修",@"普通装修"];
        NSArray* keyArr = @[@{@"key":@"房源亮点",@"value":brightArr},@{@"key":@"朝向",@"value":orienArr},@{@"key":@"租期",@"value":deadLineArr},@{@"key":@"电梯",@"value":elevatorArr},@{@"key":@"入住时间",@"value":liveInDateArr},@{@"key":@"楼层",@"value":floorArr},@{@"key":@"装修情况",@"value":fitmentArr}];
                
        for (int i = 0; i< keyArr.count; i++) {
            NSMutableArray* tempArr = @[].mutableCopy;
            NSArray* array = keyArr[i][@"value"];
            LBFilterModel* filterModel = [LBFilterModel new];
            for (int j = 0; j < array.count; j++) {
                LBFilterListModel* typeModel = [LBFilterListModel new];
                typeModel.isSelected = NO;
                typeModel.title = array[j];
                [tempArr addObject:typeModel];
            }
            filterModel.dictKey = keyArr[i][@"key"];
            filterModel.filterList = tempArr;
            [_filterArray addObject:filterModel];
        }
    }
    return _filterArray;
}

#pragma mark 加载地址数据
- (void)loadAddress {
    // 1.获取沙盒路径
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [docDir stringByAppendingPathComponent:@"cityList.plist"];
    
    // 2.加载 data
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    // 3.判断沙盒中是否存在 cityList.plist 文件，存在则不需要从网络上获取，否则，发送请求。
    if (data == nil) {
        // 4.从网络上加载'全国地址大全信息'
        NSString *jsonPath = [NSBundle.mainBundle pathForResource:@"cityList.json" ofType:nil];
        data = [NSData dataWithContentsOfFile:jsonPath];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        // 获取沙盒路径
        NSString *docDir1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *plistPath = [docDir1 stringByAppendingPathComponent:@"cityList.plist"];
        
        // 5.将'全国地址大全信息'存到沙盒中。
        [array writeToFile:plistPath atomically:YES];
    }
    
    // 6.字典转模型
    // 反序列化成数组
    NSArray *cityArr = [NSArray arrayWithContentsOfFile:filePath];
    // 字典数组转模型数组
    for (int i = 0; i < cityArr.count; i++) {
        LBAddressModel *model = [LBAddressModel cityWithDict:cityArr[i]];
        [self.addressArray addObject:model];
    }
}

@end
