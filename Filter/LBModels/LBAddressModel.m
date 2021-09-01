//
//  LBAddressModel.m
//  LearnBorrow
//
//  Created by 栾金鑫 on 2020/4/21.
//  Copyright © 2020 LearnBorrow. All rights reserved.
//

#import "LBAddressModel.h"

@implementation LBAddressModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)cityWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

- (NSArray *)cityList {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < _cityList.count; i++) {
        LBAddressModel *model = [LBAddressModel cityWithDict:_cityList[i]];
        [arrayM addObject:model];
    }
    return arrayM;
}

- (NSArray *)areaList {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < _areaList.count; i++) {
        LBAddressModel *model = [LBAddressModel cityWithDict:_areaList[i]];
        [arrayM addObject:model];
    }
    return arrayM;
}

@end
