//
//  LBFilterModel.h
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/27.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBFilterListModel : NSObject

@property(nonatomic, assign)BOOL isSelected;
@property(nonatomic, copy)NSString* title;

@end

@interface LBFilterModel : NSObject

@property(nonatomic, copy)NSString* dictKey;
@property(nonatomic, strong)NSArray<LBFilterListModel *>* filterList;


@end

