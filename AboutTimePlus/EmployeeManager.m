//
//  EmployeeManager.m
//  iFieldClock
//
//  Created by Bartimeus on 30.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EmployeeManager.h"
#import "Employee.h"
#import "CustomerEmployee.h"

@implementation EmployeeManager

-(Employee *)getEmployeeByPin:(NSString *)pin employees:(NSArray *)employees
{
	for(Employee *e in employees)
	{
		NSString *p = e.Pin;
	
		if([p isEqualToString:pin])
		{
			return e;
		}
	}
	return nil;
}

-(Employee *)getEmployeeById:(NSInteger)code employees:(NSArray *)employees
{
	for(Employee *e in employees)
	{
		if([e.EmployeeId integerValue] == code)
		{
			return e;
		}
	}
	return nil;
}

-(BOOL)employeeHasRestrictions:(NSInteger)empId custEmployeeList:(NSArray *)custEmployeeList {
	BOOL hasRestrictions = NO;
	if ([custEmployeeList count] > 0){
		for(NSInteger indx = 0; indx < [custEmployeeList count]; indx++){
			CustomerEmployee *custEmployee = [custEmployeeList objectAtIndex:indx];
			if (custEmployee != nil && [custEmployee.EmployeeId integerValue] == empId){
				return YES;
			}
		}
	}
	return hasRestrictions;
}

-(BOOL)empAuthorizedForJob:(NSInteger)empId jobId:(NSInteger)jobId custEmployeeList:(NSArray *)custEmployeeList
{
	BOOL jobAuthorized = NO;
	if ([custEmployeeList count] > 0){
		for(CustomerEmployee *custEmployee in custEmployeeList)
		{
			if (custEmployee != nil && [custEmployee.EmployeeId integerValue] == empId && [custEmployee.CustomerId integerValue] == jobId){
				return YES;
			}
		}
	}
	return jobAuthorized;
}


- (void)dealloc {
    [super dealloc];
}
@end
