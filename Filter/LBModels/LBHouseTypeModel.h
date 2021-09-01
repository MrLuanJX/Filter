//
//  LBHouseTypeModel.h
//  LearnBorrow
//
//  Created by 理享学 on 2021/8/20.
//  Copyright © 2021 LearnBorrow. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LBTypesModel : NSObject

@property(nonatomic, assign)BOOL isSelected;
@property(nonatomic, copy)NSString* title;

@end

@interface LBHouseTypeModel : NSObject

@property(nonatomic, copy)NSString* dictKey;
@property(nonatomic, strong)NSArray<LBTypesModel *>* houseTypeList;

@end


