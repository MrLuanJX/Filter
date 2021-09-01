//
//  LBHouseTypeView.h
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/19.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBHouseTypeFootView : UIView

@property(nonatomic, copy)void(^sureBlock)(void);
@property(nonatomic, copy)void(^resetBlock)(void);

@end

@interface LBHouseTypeCell: UICollectionViewCell

@end

@interface LBHouseTypeView : UIView

+ (LBHouseTypeView*)showHouseTypeIn:(UIView*)view dataSource:(NSMutableArray*)dataSource sureCallback:(void(^)(NSMutableArray* selectedArray))sureCallback touchUpBgView:(void(^)(void))touchBGView resetAction:(void(^)(void))resetAction;
+ (LBHouseTypeView *)hideIn:(UIView *)view;

@end

