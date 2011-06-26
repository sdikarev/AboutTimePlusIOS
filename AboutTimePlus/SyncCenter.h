//
//  SyncCenter.h
//  FieldClock
//
//  Created by Bartimeus on 18.07.10.
//  Copyright 2010 Incoding.biz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AsyncSocket;
@class CommandHeader;
@class myNetWorking;
@class AppSettings;
@class ClockState;
@class TimeRecording;
@interface SyncCenter : NSObject {
	NSMutableArray *connectedSockets;
	NSString *dataFilePath;
	NSManagedObjectContext *managedObjectContext;

	myNetWorking *nett;
	
}
@property (nonatomic, retain) NSString *dataFilePath;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) myNetWorking *nett;

-(void)registerDevice:(NSString *)accountName command:(short)command readTo:(BOOL)readTo;
- (id)initSyncCenter;
-(void)SaveSettings:(NSString *)accountNumber cName:(NSString *)clName lastEmpIDList:(NSInteger)lastEmpIDList clockId:(NSInteger)clockId gpsEnabled:(BOOL)gpsEnabled myServer:(NSString *)myServer myPort:(NSString *)myPort;
-(AppSettings *)LoadSettings;
-(void)getEmployeeDataFromCoreData;
-(void)SyncAllData:(UIProgressView *)progr;
-(NSMutableArray *)createRequest:(NSString *)entityForName initWithKey:(NSString *)key asc:(BOOL)asc;
-(NSMutableArray *)createRequestWithKey:(NSString *)entityForName predicate:(NSPredicate *)predicate initWithKey:(NSString *)key asc:(BOOL)asc;
-(ClockState *)LoadClockState;
-(void)SaveClockState:(ClockState *)state;
-(void)Connect:(NSString*)host port:(NSInteger)port;
-(void)sendClockInfo;
-(void)Disconnect;

-(void)sendClockInfo;

-(void)sendTimeRecordsToSyncCenter;

-(void)sendFieldNotesToSyncCenter;

-(void)sendPerDiemToSyncCenter;

-(void)sendFeedbackToSyncCenter;

-(void)sendJobPhotosToSyncCenter;

-(void)getSystemDataFromSyncCenter;


-(void)getCompanyDataFromSyncCenter;


-(void)getEmployeeDataFromSyncCenter;


-(void)getEmployeeCostCodeDataFromSyncCenter;


-(void)getJobDataFromSyncCenter;


-(void)getCostCodeDataFromSyncCenter;


-(void)getJobCostCodeDataFromSyncCenter;


-(void)getJobEmployeeDataFromSyncCenter;


-(void)getFBQuestionDataFromSyncCenter;


-(void)getEquipmentDataFromSyncCenter;

-(void)getCustomListDataFromSyncCenter;

-(int)sendSignatureFile:(NSInteger)empId image:(NSMutableData *)image;
-(int)syncJobPhotos;
-(void)makeNiceButton:(UIButton *)btn;
-(NSDate *)getCurrentDate;
-(NSDate *)getDate:(NSDate *)d;
- (NSDate *)dateToGMT:(NSDate *)sourceDate;
-(NSInteger)getYearFromDate:(NSDate *)date;

-(NSInteger)getMonthFromDate:(NSDate *)date;

-(NSInteger)getDayFromDate:(NSDate *)date;
-(NSInteger)getHourFromDate:(NSDate *)date;
-(NSInteger)getMinuteFromDate:(NSDate *)date;
-(NSInteger)getSecondFromDate:(NSDate *)date;
-(void)sendTimeRecordsArrayToSyncCenter:(NSMutableArray *)array;
-(void)sendTimeRecordToSyncCenter:(TimeRecording *)tr;
-(void)deleteAllRecords;
@end
