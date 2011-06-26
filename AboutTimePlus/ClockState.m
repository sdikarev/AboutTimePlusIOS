//
//  ClockState.m
//  iFieldClock
//
//  Created by Bartimeus on 30.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClockState.h"
#import "Employee.h"

@implementation ClockState
@synthesize CAMERA_READ_BARCODE;
@synthesize CAMERA_JOB_PICTURE;

@synthesize companyId;
@synthesize companyName;
@synthesize clockId;
@synthesize clockName;
@synthesize batteryStatus;
@synthesize EmployeeId;
@synthesize currentDateTime;
@synthesize customerId;
@synthesize customerName;
@synthesize costCodeId;
@synthesize equipmentId;
@synthesize cameraState;
@synthesize lastSignature;
@synthesize numPinKeys;
@synthesize lastEmployees;

-(id)init
{
	self = [super init];
	CAMERA_JOB_PICTURE = 2;
	CAMERA_READ_BARCODE = 1;
	cameraState = -1;
	companyId = -1;
	companyName = @"";
	customerId = -1;
	return self;
}

- (id) initWithCoder:(NSCoder *)coder {
	currentDateTime = [[coder decodeObjectForKey:@"currentDateTime"] retain];
	clockName = [[coder decodeObjectForKey:@"clockName"] retain];
	customerName = [[coder decodeObjectForKey:@"customerName"] retain];
	lastSignature = [[coder decodeObjectForKey:@"lastSignature"] retain];
	lastEmployees = [[coder decodeObjectForKey:@"lastEmployees"] retain];
	EmployeeId = [coder decodeIntegerForKey:@"EmployeeId"];
	companyName = [[coder decodeObjectForKey:@"companyName"] retain];
	CAMERA_READ_BARCODE = [coder decodeIntegerForKey:@"CAMERA_READ_BARCODE"];
	CAMERA_JOB_PICTURE =[coder decodeIntegerForKey:@"CAMERA_JOB_PICTURE"];
	companyId = [coder decodeIntegerForKey:@"companyId"];
	clockId = [coder decodeIntegerForKey:@"clockId"];
	batteryStatus = [coder decodeIntegerForKey:@"batteryStatus"];
	customerId = [coder decodeIntegerForKey:@"customerId"];
	costCodeId = [coder decodeIntegerForKey:@"costCodeId"];
	equipmentId = [coder decodeIntegerForKey:@"equipmentId"];
	cameraState = [coder decodeIntegerForKey:@"cameraState"];
	numPinKeys = [coder decodeIntegerForKey:@"numPinKeys"];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:currentDateTime forKey:@"currentDateTime"];
	[encoder encodeObject:clockName forKey:@"clockName"];
	[encoder encodeObject:customerName forKey:@"customerName"];
	[encoder encodeObject:lastSignature forKey:@"lastSignature"];
	[encoder encodeObject:lastEmployees forKey:@"lastEmployees"];
	[encoder encodeInteger:EmployeeId forKey:@"EmployeeId"];
	[encoder encodeObject:companyName forKey:@"companyName"];
	[encoder encodeInteger:CAMERA_READ_BARCODE forKey:@"CAMERA_READ_BARCODE"];
	[encoder encodeInteger:CAMERA_JOB_PICTURE forKey:@"CAMERA_JOB_PICTURE"];
	[encoder encodeInteger:companyId forKey:@"companyId"];
	[encoder encodeInteger:clockId forKey:@"clockId"];
	[encoder encodeInteger:batteryStatus forKey:@"batteryStatus"];
	[encoder encodeInteger:customerId forKey:@"customerId"];
	[encoder encodeInteger:costCodeId forKey:@"costCodeId"];
	[encoder encodeInteger:equipmentId forKey:@"equipmentId"];
	[encoder encodeInteger:cameraState forKey:@"cameraState"];
	[encoder encodeInteger:numPinKeys forKey:@"numPinKeys"];
	

}

- (void)dealloc {
	[clockName release];
	[currentDateTime release];
	[customerName release];
	[lastSignature release];
	[companyName release];
	[lastEmployees release];
    [super dealloc];
}
@end
