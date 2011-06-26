//
//  CustomerEmployee.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomerEmployee : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * CustomerId;
@property (nonatomic, retain) NSNumber * EmployeeId;

@end
