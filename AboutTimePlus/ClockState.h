//
//  ClockState.h
//  iFieldClock
//
//  Created by Bartimeus on 30.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Employee;

@interface ClockState : NSObject {
	NSInteger CAMERA_READ_BARCODE;
    NSInteger CAMERA_JOB_PICTURE;
        
    NSInteger companyId;
	NSString *companyName;
    NSInteger clockId;
    NSString *clockName;
    NSInteger batteryStatus;
    NSInteger EmployeeId;
    NSDate *currentDateTime;
    NSInteger customerId;
    NSString *customerName;
    NSInteger costCodeId;
    NSInteger equipmentId;
    NSInteger cameraState;
    NSMutableData *lastSignature;
    NSInteger numPinKeys;
	NSMutableArray *lastEmployees;
	
}
@property (nonatomic, retain) NSString *clockName;
@property (nonatomic, retain) NSDate *currentDateTime;
@property (nonatomic, retain) NSString *customerName;
@property (nonatomic, retain) NSMutableData *lastSignature;
@property (nonatomic, retain) NSMutableArray *lastEmployees;
@property (nonatomic) NSInteger EmployeeId;
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic) NSInteger CAMERA_READ_BARCODE;
@property (nonatomic) NSInteger CAMERA_JOB_PICTURE;
@property (nonatomic) NSInteger companyId;
@property (nonatomic) NSInteger clockId;
@property (nonatomic) NSInteger batteryStatus;
@property (nonatomic) NSInteger customerId;
@property (nonatomic) NSInteger costCodeId;
@property (nonatomic) NSInteger equipmentId;
@property (nonatomic) NSInteger cameraState;
@property (nonatomic) NSInteger numPinKeys;
@end
