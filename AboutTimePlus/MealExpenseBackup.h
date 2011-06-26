//
//  MealExpenseBackup.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
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
