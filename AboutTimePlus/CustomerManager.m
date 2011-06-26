//
//  CustomerManager.m
//  iFieldClock
//
//  Created by Bartimeus on 01.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomerManager.h"
#import "Customer.h"

@implementation CustomerManager
@synthesize customers, result;
NSInteger CompanyId;

-(id)init:(NSInteger)_CompanyId
{
	self = [super init];
	result = [[NSMutableArray alloc] init];
	CompanyId = _CompanyId;
	return self;

}
/*
-(void)getJobTree:(NSMutableArray *)array parentId:(NSInteger)parentId parentNodeId:(NSInteger)parentNodeId
{
	for(Customer *c in array)
	{
		if(c.CustomerId == parentId && c.CompanyId == CompanyId)
		{
		
		}
	
	}

}
*/

-(NSMutableArray *)getCustomers:(NSInteger)parentId companyId:(NSInteger)companyId array:(NSMutableArray *)array
{
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for(Customer *c in array)
	{
	
		NSInteger i = [c.CompanyId integerValue];
		if([c.ParentId integerValue] == parentId && i == companyId)
		{
			[res addObject:c];
	
		}
	}
	return [res autorelease];
}

-(NSMutableArray *)getCustomersByKeyword:(NSString *)key parentId:(NSInteger)parentId companyId:(NSInteger)companyId array:(NSMutableArray *)array
{
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for(Customer *c in array)
	{
        
		NSInteger i = [c.CompanyId integerValue];
		if([c.ParentId integerValue] == parentId && i == companyId)
		{
            if([c.Name rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [res addObject:c];
            }
		}
	}
	return [res autorelease];
}


-(Customer *)getCustomerById:(NSInteger)customerId array:(NSMutableArray *)array
{

		for(Customer *c in array)
		{
			if([c.CustomerId integerValue] == customerId)
			{
				return c;
			}
		}
		return nil;


}


- (void)dealloc {
	//[result release];
	[customers release];
    [super dealloc];
}
@end
