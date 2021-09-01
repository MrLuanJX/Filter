//
//  LBAddressModel.h
//  LearnBorrow
//
//  Created by 栾金鑫 on 2020/4/21.
//  Copyright © 2020 LearnBorrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBAddressModel : NSObject

@property(nonatomic, strong) NSArray *cityList;
@property(nonatomic, strong) NSArray *areaList;
/// 市
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *code;

/// 字典转模型的对象方法
/// @param dict 字典
- (instancetype)initWithDict:(NSDictionary *)dict;

/// 字典转模型的类方法
/// @param dict 字典
+(instancetype)cityWithDict:(NSDictionary *)dict;

@end


