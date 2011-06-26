//
//  CustomerCostCode.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomerCostCode : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * AccruedHours;
@property (nonatomic, retain) NSNumber * AccruedUnits;
@property (nonatomic, retain) NSNumber * BudgetedHours;
@property (nonatomic, retain) NSNumber * BudgetedUnits;
@property (nonatomic, retain) NSNumber * CostCodeId;
@property (nonatomic, retain) NSNumber * CustomerId;

@end
