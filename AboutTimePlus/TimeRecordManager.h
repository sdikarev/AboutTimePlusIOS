//
//  TimeRecordManager.h
//  iFieldClock
//
//  Created by Bartimeus on 06.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TimeRecording;
@class TimeRecordingBackup;
@class Customer;
@class Employee;
@class Company;
@class SyncCenter;
@interface TimeRecordManager : NSObject {
	SyncCenter *sc;
}
@property (nonatomic, retain) SyncCenter *sc;
-(TimeRecording *)getLastTimeRec:(NSInteger)companyId empId:(NSInteger)empId jobId:(NSInteger)jobId timeRecords:(NSArray *)timeRecords;
-(BOOL)isTimeRecordExists:(TimeRecordingBackup *)tr timeRecords:(NSMutableArray *)timeRecords;
-(BOOL)isTimeRecordBackupExists:(TimeRecordingBackup *)tr timeRecords:(NSMutableArray *)timeRecords;
-(TimeRecording *)roundMinutes:(NSInteger)roundMinutesTo timeRec:(TimeRecording *)timeRec;
-(void)isTimeRecordWithEmployeeExists:(TimeRecording *)tr timeRecords:(NSMutableArray *)timeRecords;
-(void)setCorrectDate:(TimeRecording *)tr;
@end
