//
//  EmployeeCostCode.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EmployeeCostCode : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * CostCodeId;
@property (nonatomic, retain) NSNumber * EmployeeId;

@end
