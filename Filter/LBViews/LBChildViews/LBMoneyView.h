//
//  LBMoneyView.h
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/19.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBRangeSliderItem : UIImageView

@property(nonatomic,copy)void (^pan)(UIPanGestureRecognizer * pan ,int itemStyle,LBRangeSliderItem * item);
@property(nonatomic,assign)int itemStyle;//0为左边，1为右边

@property(nonatomic,assign)int range;

@end

@interface LBRangeSlider : UIControl

@property(nonatomic, copy)void(^leftItemCallback)(int minIndex);
@property(nonatomic, copy)void(^rightItemCallback)(int maxIndex);

@property(nonatomic,assign)CGFloat  titleHeight;
@property(nonatomic,strong)NSArray * titleArray;
@property(nonatomic,strong)UIColor * titleColor;
@property(nonatomic,strong)UIFont  * titleFont;

//滑动块
@property(nonatomic,strong)LBRangeSliderItem * leftItem;
@property(nonatomic,strong)LBRangeSliderItem * rightItem;

//滑动条
@property(nonatomic,strong)UIColor * bottomColor;
@property(nonatomic,strong)UIColor * upColor;
@property(nonatomic,assign)CGFloat sliderItemSize;
@property(nonatomic,assign)CGFloat bottomViewHeight;
@property(nonatomic,assign)CGFloat upViewHeight;

@end

@interface LBSliderView: UIView

@end

@interface LBMoneyFootView: UIView

@end

@interface LBMoneyView : UIView

+ (LBMoneyView*)showIn:(UIView*)view dataSource:(NSArray*)dataSource selectedItem:(NSString *)selectedItem touchUpBgView:(void(^)(NSString* selectTitle))touchBGView resetAction:(void(^)(NSString* selectTitle))reset;
+ (LBMoneyView *)hideIn:(UIView *)view;

@end

