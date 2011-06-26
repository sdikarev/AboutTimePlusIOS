//
//  TimeRecording.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeRecording : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * AddedEmpFName;
@property (nonatomic, retain) NSString * AddedEmpLName;
@property (nonatomic, retain) NSString * AddedEmpMName;
@property (nonatomic, retain) NSString * AddedJobName;
@property (nonatomic, retain) NSNumber * ClockAddedRecord;
@property (nonatomic, retain) NSNumber * ClockId;
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSNumber * CostCodeId;
@property (nonatomic, retain) NSNumber * CustomerId;
@property (nonatomic, retain) NSNumber * CustomList1Id;
@property (nonatomic, retain) NSNumber * CustomList2Id;
@property (nonatomic, retain) NSNumber * CustomList3Id;
@property (nonatomic, retain) NSNumber * EditedByEmpId;
@property (nonatomic, retain) NSNumber * EmployeeId;
@property (nonatomic, retain) NSNumber * EmployeeSignOffId;
@property (nonatomic, retain) NSDate * EmpSignOffDate;
@property (nonatomic, retain) NSNumber * EquipmentId;
@property (nonatomic, retain) NSString * Latitude;
@property (nonatomic, retain) NSString * Longitude;
@property (nonatomic, retain) NSNumber * ManagerSignOffId;
@property (nonatomic, retain) NSDate * mgrSignOffDate;
@property (nonatomic, retain) NSDate * trDate;
@property (nonatomic, retain) NSString * Units;

@end
