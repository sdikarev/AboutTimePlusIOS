//
//  MealExpenseBackup.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MealExpenseBackup : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * ApproveDate;
@property (nonatomic, retain) NSNumber * ApprovedById;
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSNumber * EmployeeId;

@end
