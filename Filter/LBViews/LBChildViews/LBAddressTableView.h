//
//  LBAddressTableView.h
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/19.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBAddressModel.h"

@interface LBAddressFootView : UIView

@property(nonatomic, copy)void(^sureBlock)(void);
@property(nonatomic, copy)void(^resetBlock)(void);

@end

@class LBAddressModel;
typedef void(^LBAddressCallback)(LBAddressModel * province, LBAddressModel * city, NSMutableArray * areaArray);

@interface LBAddressTableView : UIView

+ (LBAddressTableView*)showAddressTableIn:(UIView*)view dataSource:(NSMutableArray*)dataSource province:(LBAddressModel*)province city:(LBAddressModel*)city area:(NSMutableArray*)area addressBlock:(LBAddressCallback)addressBlock touchBGView:(void(^)(void))touchBGView resetCallback:(void(^)(void))resetCallback;
+ (LBAddressTableView *)hideIn:(UIView *)view;

@end

