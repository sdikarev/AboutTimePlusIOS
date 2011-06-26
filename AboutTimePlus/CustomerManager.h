//
//  CustomerManager.h
//  iFieldClock
//
//  Created by Bartimeus on 01.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Customer;

@interface CustomerManager : NSObject {
	NSMutableArray *customers;
	NSMutableArray *result;
}
@property (nonatomic, retain) NSMutableArray *customers;
@property (nonatomic, retain) NSMutableArray *result;

-(NSMutableArray *)getCustomers:(NSInteger)parentId companyId:(NSInteger)companyId array:(NSMutableArray *)array;
-(Customer *)getCustomerById:(NSInteger)customerId array:(NSMutableArray *)array;
-(NSMutableArray *)getCustomersByKeyword:(NSString *)key parentId:(NSInteger)parentId companyId:(NSInteger)companyId array:(NSMutableArray *)array;
@end
