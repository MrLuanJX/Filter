//
//  LBFilterView.h
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/27.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBFilterCell: UICollectionViewCell

@end

@interface LBFilterView : UIView

+ (LBFilterView*)showFilterWithView:(UIView*)view dataSource:(NSMutableArray*)dataSource sureCallback:(void(^)(NSMutableArray* selectedArray))sureCallback touchUpBgView:(void(^)(void))touchBGView resetAction:(void(^)(void))resetAction;
+ (LBFilterView *)hideIn:(UIView *)view;

@end


