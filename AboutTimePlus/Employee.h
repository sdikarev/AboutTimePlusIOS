//
//  Employee.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * AddEmplyees;
@property (nonatomic, retain) NSNumber * AddFieldNotes;
@property (nonatomic, retain) NSNumber * AddJobs;
@property (nonatomic, retain) NSString * Address;
@property (nonatomic, retain) NSNumber * AllocateTime;
@property (nonatomic, retain) NSString * BarCodeScannerId;
@property (nonatomic, retain) NSString * Cell;
@property (nonatomic, retain) NSString * City;
@property (nonatomic, retain) NSNumber * ClockInOthers;
@property (nonatomic, retain) NSString * Country;
@property (nonatomic, retain) NSNumber * EditTime;
@property (nonatomic, retain) NSString * EmpCode;
@property (nonatomic, retain) NSNumber * EmployeeId;
@property (nonatomic, retain) NSString * FirstName;
@property (nonatomic, retain) NSNumber * IgnoreRestrictions;
@property (nonatomic, retain) NSNumber * LanguageVal;
@property (nonatomic, retain) NSString * LastName;
@property (nonatomic, retain) NSNumber * Manager;
@property (nonatomic, retain) NSString * MiddleName;
@property (nonatomic, retain) NSString * Phone;
@property (nonatomic, retain) NSString * Pin;
@property (nonatomic, retain) NSNumber * SetCostCodes;
@property (nonatomic, retain) NSNumber * SetJobs;
@property (nonatomic, retain) NSString * State;
@property (nonatomic, retain) NSNumber * TrackEquipment;
@property (nonatomic, retain) NSNumber * ViewTimeStamps;
@property (nonatomic, retain) NSString * Zip;

@end
