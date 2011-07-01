//
//  CustomerEmployee.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomerEmployee : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * CustomerId;
@property (nonatomic, retain) NSNumber * EmployeeId;

@end
