//
//  EmployeeManager.h
//  iFieldClock
//
//  Created by Bartimeus on 30.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Employee;

@interface EmployeeManager : NSObject {

}
-(Employee *)getEmployeeByPin:(NSString *)pin employees:(NSArray *)employees;
-(Employee *)getEmployeeById:(NSInteger)code employees:(NSArray *)employees;
-(BOOL)employeeHasRestrictions:(NSInteger)empId custEmployeeList:(NSArray *)custEmployeeList;
-(BOOL)empAuthorizedForJob:(NSInteger)empId jobId:(NSInteger)jobId custEmployeeList:(NSArray *)custEmployeeList;
@end
