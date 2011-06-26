//
//  EmployeeCostCode.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EmployeeCostCode : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * CostCodeId;
@property (nonatomic, retain) NSNumber * EmployeeId;

@end
