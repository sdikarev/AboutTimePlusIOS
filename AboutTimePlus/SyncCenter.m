//
//  SyncCenter.m
//  FieldClock
//
//  Created by Bartimeus on 18.07.10.
//  Copyright 2010 Incoding.biz. All rights reserved.
//

#import "SyncCenter.h"
#import "CommandHeader.h"
#import "AppSettings.h"
#import "TimeRecording.h"
#import "TimeRecordingBackup.h"
#import "Employee.h"
#import "CostCode.h"
#import "Company.h"
#import "Customer.h"
#import "Clock.h"
#import "networking.h"
#import "FieldNote.h"
#import "FieldNoteBackup.h"
#import "MealExpense.h"
#import "MealExpenseBackup.h"
#import "FeedbackAnswer.h"
#import "FeedbackAnswerBackup.h"
#import "JobPhoto.h"
#import "SystemData.h"
#import "EmployeeCostCode.h"
#import "CustomerCostCode.h"
#import "Equipment.h"
#import "FeedbackQuestion.h"
#import "CustomerEmployee.h"
#import "ClockState.h"
#import "TimeRecordManager.h"
#import "STDeviceDetection.h"
#import "CustomList.h"

@implementation SyncCenter
//@synthesize asyncSocket;
@synthesize dataFilePath, managedObjectContext, nett;
BOOL regDevice = NO;
BOOL sendTimeRecords = NO;
BOOL syncAll = NO;
BOOL success = NO;
BOOL connect = NO;

- (id)initSyncCenter
{
	
	self = [super init];
	/*
	NSError *err = nil;
	asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
	if(![asyncSocket connectToHost:host onPort:port error:&err])
	{
		NSLog(@"Error: %@", err);
	}
	*/

	    
	//settings = [[AppSettings alloc] init];
	
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//NSString *crew = [defaults objectForKey:@"crewclock_preference"];
	//NSString *account = [defaults objectForKey:@"account_preference"];
	
	//NSString *temp  = dataFilePath;
	
	//[self SaveSettings:account cName:crew lastEmpIDList:-1 clockId:40 gpsEnabled:YES];
	
	//UIDevice *device = [UIDevice currentDevice];
	//[device setBatteryMonitoringEnabled:YES];
	//float f = [device batteryLevel];
	
	
	//NSString *s  = device.batteryState == UIDeviceBatteryStateUnknown ? @"Unknown" : [NSString stringWithFormat:@"%i%%", (int)(device.batteryLevel * 100)];	
	//unsigned short i = 0;
		
	
	return self;
}

-(void)Connect:(NSString*)host port:(NSInteger)port
{
	self.nett = [[[myNetWorking alloc] init] autorelease]; 
	[self.nett connectToServerUsingStream:host portNo:port];
}

-(void)makeNiceButton:(UIButton *)btn
{
	CALayer * layer = [btn layer];
	[layer setMasksToBounds:YES];
	[layer setCornerRadius:8];
	[layer setBorderWidth:1.0];
	UIColor *c = [[UIColor alloc] initWithRed:0.2 green:0.3 blue:0.5 alpha:1.0];
	[btn setTitleColor:c forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[btn setBackgroundImage:[UIImage imageNamed:@"GlossBG_Silver.png"] forState:UIControlStateNormal];
	[layer setBorderColor:[c CGColor]];
	[c release];
}

-(void)registerDevice:(NSString *)accountName command:(short)command readTo:(BOOL)readTo
{
	CommandHeader *header = [[CommandHeader alloc] init];
	NSMutableData *h = [header createHeader:command accountNum:accountName clockType:5 majorVersionNum:3 minorVersionNum:1 buildVersionNum:1 revisionVersionNum:24];

	NSInteger l = [h length];
	
	[nett.oStream write:[h bytes] maxLength:l]; 
    [header release];
    
	NSLog(@"write to server  register");
		
	if(readTo)
	{
		[self sendClockInfo];
	}
	
}



-(void)sendClockInfo
{
	NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
	//register device
	UIDevice *device = [UIDevice currentDevice];
	//NSLog(@"%@", [device model]);
	NSMutableString *uniqueIdentifier = [[[NSMutableString alloc] init] autorelease];
	//if([[device model] isEqualToString:@"iPhone"] || [[device model] isEqualToString:@"iPhone Simulator"])
	//{
		[uniqueIdentifier appendString:[STDeviceDetection returnDeviceName:NO]];
	//}
	//else {
		[uniqueIdentifier appendString:@"-"];
	//}

	[uniqueIdentifier appendString:[[device uniqueIdentifier] stringByReplacingOccurrencesOfString:@"-" withString:[NSString stringWithString:@""]]];
	
	NSLog(@"%@", uniqueIdentifier);
	const uint8_t *str = (uint8_t *)[uniqueIdentifier cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned int s = CFSwapInt32HostToBig([uniqueIdentifier length]);
	
	[h appendBytes:(const void *)&s length:4];
	[h appendBytes:str length:[uniqueIdentifier length]];
	//battery
	unsigned short s1 = CFSwapInt16HostToBig(100);
	[h appendBytes:(const void *)&s1 length:2];
	
	//app version
	const uint8_t *str2 = (uint8_t *) [@"3.1.1.24" cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned int o = CFSwapInt32HostToBig(8);
	
	[h appendBytes:(const void *)&o length:4];
	[h appendBytes:str2  length:8];
	AppSettings *as = [self LoadSettings];
	//crew name
	NSString *crew = nil;
	crew = as.clockName;
	
	const uint8_t *str3 = (uint8_t *) [crew cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned int o1 = CFSwapInt32HostToBig([crew length]);
	[h appendBytes:(const void *)&o1 length:4];
	[h appendBytes:str3  length:[crew length]];

	NSInteger l = [h length];
	[nett.oStream write:[h bytes] maxLength:l];  
	
	//write out date and time
	NSDate *d = [self dateToGMT:[NSDate date]];
	[nett writeInt:[self getYearFromDate:d]];
	[nett writeInt:[self getMonthFromDate:d]];
	[nett writeInt:[self getDayFromDate:d]];
	[nett writeInt:[self getHourFromDate:d]];
	[nett writeInt:[self getMinuteFromDate:d]];
	[nett writeInt:[self getSecondFromDate:d]];

	// Write out clock app version
	NSMutableData *h1 = [[[NSMutableData alloc] init] autorelease];
	const uint8_t *str4 = (uint8_t *) [@"3.1.30" cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned int o2 = CFSwapInt32HostToBig([@"3.1.30" length]);
	[h1 appendBytes:(const void *)&o2 length:4];
	[h1 appendBytes:str4  length:[@"3.1.30" length]];
	l = [h1 length];
	[nett.oStream write:[h1 bytes] maxLength:l];  
	
	
	@try {
		uint32_t clockid = [self.nett readIntFromServer];
		
		uint32_t gps = [self.nett readIntFromServer];
		BOOL isGPS=NO;
		if(gps == 1)
		{
			isGPS = YES;
		}
		if(clockid > 0)
		{
			
			as.clockId = clockid;
			as.gpsEnabled = isGPS;
			[self SaveSettings:as];
            ClockState *cs = [self LoadClockState];
            cs.clockId = clockid;
            [self SaveClockState:cs];
			
		}
		
		NSLog(@"write to server  sendclockinfo");				
	}
	@catch (NSException * e) {
		@throw [NSException
				exceptionWithName:@"sendClockInfo error"
				reason:@"Can't get response from server"
				userInfo:nil];
	}
	@finally {
		
	}
	

}


-(NSMutableArray *)createRequest:(NSString *)entityForName initWithKey:(NSString *)key asc:(BOOL)asc
{

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityForName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	if (key != [NSString stringWithString:@""]) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:asc];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
	}
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail		
	}
	
	//[mutableFetchResults release];
	[request release];
	return [mutableFetchResults autorelease];
}
	 
-(NSMutableArray *)createRequestWithKey:(NSString *)entityForName predicate:(NSPredicate *)predicate initWithKey:(NSString *)key asc:(BOOL)asc
{
	//NSPredicate * predicate;
	//predicate = [NSPredicate predicateWithFormat:@"creationDate > %@", date];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityForName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setPredicate:predicate];
	if (key != [NSString stringWithString:@""]) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:asc];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
	}
	
	 NSError *error = nil;
	 NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	 if (mutableFetchResults == nil) {
		 // Handle the error.
		 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		 exit(-1);  // Fail		
	 }
	 
	 //[mutableFetchResults release];
	 [request release];
	 return [mutableFetchResults autorelease];
	
}


-(void)sendTimeRecordsToSyncCenter
{
	NSMutableArray *array = [self createRequest:@"TimeRecording" initWithKey:@"trDate" asc:NO];
	NSMutableData *h1 = [[NSMutableData alloc] init];
	for(TimeRecording *c in array)
	{
		
		TimeRecordingBackup *tr = (TimeRecordingBackup *)[NSEntityDescription insertNewObjectForEntityForName:@"TimeRecordingBackup" inManagedObjectContext:managedObjectContext];
		
		[tr setCompanyId:c.CompanyId];
		[tr setClockId:c.ClockId];
		[tr setEmployeeId:c.EmployeeId];
		[tr setCustomerId:c.CustomerId];
		[tr setCostCodeId:c.CostCodeId];
		[tr setTrDate:c.trDate];
		[tr setEditedByEmpId:c.EditedByEmpId];
		[tr setAddedJobName:c.AddedJobName];
		[tr setAddedEmpFName:c.AddedEmpFName];
		[tr setAddedEmpMName:c.AddedEmpMName];
		[tr setAddedEmpLName:c.AddedEmpLName];
		[tr setLatitude:c.Latitude];
		[tr setLongitude:c.Longitude];
		[tr setManagerSignOffId:c.ManagerSignOffId];
		[tr setMgrSignOffDate:c.mgrSignOffDate];
		[tr setClockAddedRecord:c.ClockAddedRecord];
		[tr setEquipmentId:c.EquipmentId];
		[tr setUnits:c.Units];	
		[tr setEmployeeSignOffId:c.EmployeeSignOffId];
		[tr setEmpSignOffDate:c.EmpSignOffDate];
        [tr setCustomList1Id:c.CustomList1Id];
        [tr setCustomList2Id:c.CustomList2Id];
        [tr setCustomList3Id:c.CustomList3Id];

		
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	unsigned int s2 = CFSwapInt32HostToBig([array count]);
	[h1 appendBytes:(const void *)&s2 length:4];
	NSInteger l = [h1 length];
	[self.nett.oStream write:[h1 bytes] maxLength:l];   

	[h1 release];
	if ([array count] > 0) {
		
		for (TimeRecording *tr in array) 
		{
            NSMutableData *h = [[NSMutableData alloc] init];
			
			s2 = CFSwapInt32HostToBig([tr.CompanyId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
           // NSLog(@"%d",CFSwapInt32(s2));
			
			s2 = CFSwapInt32HostToBig([tr.ClockId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.EmployeeId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.CustomerId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.CostCodeId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			//NSLog(@"%d",CFSwapInt32(s2));
            NSLog(@"Year = %d", [self getYearFromDate:tr.trDate]);
			unsigned short s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
            NSLog(@"Month = %d", [self getMonthFromDate:tr.trDate]);
			s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
            NSLog(@"Day = %d", [self getDayFromDate:tr.trDate]);
			s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
            NSLog(@"Hour = %d", [self getHourFromDate:tr.trDate]);
			s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
            NSLog(@"Minute = %d", [self getMinuteFromDate:tr.trDate]);
			s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s2 = CFSwapInt32HostToBig([tr.EditedByEmpId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.Latitude length]);
			[h appendBytes:(const void *)&s2 length:4];
			if ([tr.Latitude length] > 0) {
				const uint8_t *str = (uint8_t *) [tr.Latitude cStringUsingEncoding:NSASCIIStringEncoding];
				[h appendBytes:str  length:[tr.Latitude length]];
			}
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.Longitude length]);
			[h appendBytes:(const void *)&s2 length:4];
			if ([tr.Longitude length] > 0) {
				const uint8_t *str = (uint8_t *) [tr.Longitude cStringUsingEncoding:NSASCIIStringEncoding];
				[h appendBytes:str  length:[tr.Longitude length]];
			}
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.EquipmentId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.Units length]);
			[h appendBytes:(const void *)&s2 length:4];
			if ([tr.Units length] > 0) {
				const uint8_t *str = (uint8_t *) [tr.Units cStringUsingEncoding:NSASCIIStringEncoding];
				[h appendBytes:str  length:[tr.Units length]];
			}
			
			s2 = CFSwapInt32HostToBig([tr.ManagerSignOffId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			
			
			s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			
			
			s2 = CFSwapInt32HostToBig([tr.EmployeeSignOffId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			
			NSLog(@"%@", tr.EmpSignOffDate);
			s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
            
            s2 = CFSwapInt32HostToBig([tr.CustomList1Id integerValue]);
			[h appendBytes:(const void *)&s2 length:4];

			s2 = CFSwapInt32HostToBig([tr.CustomList2Id integerValue]);
			[h appendBytes:(const void *)&s2 length:4];

            s2 = CFSwapInt32HostToBig([tr.CustomList3Id integerValue]);
			[h appendBytes:(const void *)&s2 length:4];

            
			NSInteger l = [h length];
			[self.nett.oStream write:[h bytes] maxLength:l];  
			//[NSThread sleepForTimeInterval:0.2];  

            [h release];
			s2 = [self.nett readIntFromServer];
			//NSLog(@"written?  %d",CFSwapInt32(s2));
			//NSInteger i = s2;
		}
        
	}
	
	
    for(TimeRecording *c in array)
	{
		
		[managedObjectContext deleteObject:c];
	}
	error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
	s2 = [self.nett readIntFromServer];
    //[array release];
}

-(void)sendTimeRecordToSyncCenter:(TimeRecording *)tr
{
	AppSettings *settings = [self LoadSettings];
		
	[self registerDevice:settings.accountNumber command:101 readTo:NO];
	
	[self.nett writeInt:settings.clockId];
	
	[self sendClockInfo];
	
	[self.nett writeInt:1];
	
            NSMutableData *h = [[NSMutableData alloc] init];
			
			unsigned int s2 = CFSwapInt32HostToBig([tr.CompanyId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			
			s2 = CFSwapInt32HostToBig([tr.ClockId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			s2 = CFSwapInt32HostToBig([tr.EmployeeId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			s2 = CFSwapInt32HostToBig([tr.CustomerId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			s2 = CFSwapInt32HostToBig([tr.CostCodeId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			
			unsigned short s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.trDate]);
			[h appendBytes:(const void *)&s3 length:2];
			NSLog(@"%d",CFSwapInt16(s3));
			s2 = CFSwapInt32HostToBig([tr.EditedByEmpId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			//NSLog(@"%d",CFSwapInt32(s2));
			s2 = CFSwapInt32HostToBig([tr.Latitude length]);
			[h appendBytes:(const void *)&s2 length:4];
			if ([tr.Latitude length] > 0) {
				const uint8_t *str = (uint8_t *) [tr.Latitude cStringUsingEncoding:NSASCIIStringEncoding];
				[h appendBytes:str  length:[tr.Latitude length]];
			}
			s2 = CFSwapInt32HostToBig([tr.Longitude length]);
			[h appendBytes:(const void *)&s2 length:4];
			if ([tr.Longitude length] > 0) {
				const uint8_t *str = (uint8_t *) [tr.Longitude cStringUsingEncoding:NSASCIIStringEncoding];
				[h appendBytes:str  length:[tr.Longitude length]];
			}
			s2 = CFSwapInt32HostToBig([tr.EquipmentId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			s2 = CFSwapInt32HostToBig([tr.Units length]);
			[h appendBytes:(const void *)&s2 length:4];
			if ([tr.Units length] > 0) {
				const uint8_t *str = (uint8_t *) [tr.Units cStringUsingEncoding:NSASCIIStringEncoding];
				[h appendBytes:str  length:[tr.Units length]];
			}
			
			s2 = CFSwapInt32HostToBig([tr.ManagerSignOffId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			
			
			s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.mgrSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			
			
			s2 = CFSwapInt32HostToBig([tr.EmployeeSignOffId integerValue]);
			[h appendBytes:(const void *)&s2 length:4];
			
			
			s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.EmpSignOffDate]);
			[h appendBytes:(const void *)&s3 length:2];
			
            s2 = CFSwapInt32HostToBig([tr.CustomList1Id integerValue]);
            [h appendBytes:(const void *)&s2 length:4];
    
            s2 = CFSwapInt32HostToBig([tr.CustomList2Id integerValue]);
            [h appendBytes:(const void *)&s2 length:4];
    
            s2 = CFSwapInt32HostToBig([tr.CustomList3Id integerValue]);
            [h appendBytes:(const void *)&s2 length:4];
    
			NSInteger l = [h length];
			[self.nett.oStream write:[h bytes] maxLength:l];  
			
            [h release];
			s2 = [self.nett readIntFromServer];

    
	s2 = [self.nett readIntFromServer];
	
	int ret = 0;
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
    //[array release];
	
}


-(void)sendTimeRecordsArrayToSyncCenter:(NSMutableArray *)array
{
	AppSettings *settings = [self LoadSettings];
	
	[self registerDevice:settings.accountNumber command:101 readTo:NO];
	
	[self.nett writeInt:settings.clockId];
	
	[self sendClockInfo];
	
	[self.nett writeInt:[array count]];
	
	for (TimeRecording *tr in array) 
	{
		NSMutableData *h = [[NSMutableData alloc] init];
		
		unsigned int s2 = CFSwapInt32HostToBig([tr.CompanyId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([tr.ClockId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		s2 = CFSwapInt32HostToBig([tr.EmployeeId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		s2 = CFSwapInt32HostToBig([tr.CustomerId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		s2 = CFSwapInt32HostToBig([tr.CostCodeId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		unsigned short s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.trDate]);
		[h appendBytes:(const void *)&s3 length:2];
		NSLog(@"%d",CFSwapInt16(s3));
		s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.trDate]);
		[h appendBytes:(const void *)&s3 length:2];
		NSLog(@"%d",CFSwapInt16(s3));
		s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.trDate]);
		[h appendBytes:(const void *)&s3 length:2];
		NSLog(@"%d",CFSwapInt16(s3));
		s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.trDate]);
		[h appendBytes:(const void *)&s3 length:2];
		NSLog(@"%d",CFSwapInt16(s3));
		s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.trDate]);
		[h appendBytes:(const void *)&s3 length:2];
		NSLog(@"%d",CFSwapInt16(s3));
		s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.trDate]);
		[h appendBytes:(const void *)&s3 length:2];
		NSLog(@"%d",CFSwapInt16(s3));
		s2 = CFSwapInt32HostToBig([tr.EditedByEmpId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		//NSLog(@"%d",CFSwapInt32(s2));
		s2 = CFSwapInt32HostToBig([tr.Latitude length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([tr.Latitude length] > 0) {
			const uint8_t *str = (uint8_t *) [tr.Latitude cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[tr.Latitude length]];
		}
		s2 = CFSwapInt32HostToBig([tr.Longitude length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([tr.Longitude length] > 0) {
			const uint8_t *str = (uint8_t *) [tr.Longitude cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[tr.Longitude length]];
		}
		s2 = CFSwapInt32HostToBig([tr.EquipmentId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		s2 = CFSwapInt32HostToBig([tr.Units length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([tr.Units length] > 0) {
			const uint8_t *str = (uint8_t *) [tr.Units cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[tr.Units length]];
		}
		
		s2 = CFSwapInt32HostToBig([tr.ManagerSignOffId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		
		s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.mgrSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.mgrSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.mgrSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.mgrSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.mgrSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.mgrSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		
		
		s2 = CFSwapInt32HostToBig([tr.EmployeeSignOffId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		
		s3 = CFSwapInt16HostToBig([self getYearFromDate:tr.EmpSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMonthFromDate:tr.EmpSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getDayFromDate:tr.EmpSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getHourFromDate:tr.EmpSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMinuteFromDate:tr.EmpSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getSecondFromDate:tr.EmpSignOffDate]);
		[h appendBytes:(const void *)&s3 length:2];
        
        
        s2 = CFSwapInt32HostToBig([tr.CustomList1Id integerValue]);
        [h appendBytes:(const void *)&s2 length:4];
        
        s2 = CFSwapInt32HostToBig([tr.CustomList2Id integerValue]);
        [h appendBytes:(const void *)&s2 length:4];
        
        s2 = CFSwapInt32HostToBig([tr.CustomList3Id integerValue]);
        [h appendBytes:(const void *)&s2 length:4];
		
		NSInteger l = [h length];
		[self.nett.oStream write:[h bytes] maxLength:l];  
		
		[h release];
		s2 = [self.nett readIntFromServer];
	}
	
    
	unsigned s4 = [self.nett readIntFromServer];
	
	int ret = 0;
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
	[self.nett writeInt:0];
	ret = [self.nett readIntFromServer];
    //[array release];
	
}


-(void)sendFieldNotesToSyncCenter
{
	NSMutableArray *array = [self createRequest:@"FieldNote" initWithKey:@"" asc:NO];
	NSMutableData *h1 = [[NSMutableData alloc] init];
	
	for(FieldNote *c in array)
	{
		
		FieldNoteBackup *tr = (FieldNoteBackup *)[NSEntityDescription insertNewObjectForEntityForName:@"FieldNoteBackup" inManagedObjectContext:managedObjectContext];
		
		[tr setCustomerId:c.CustomerId];
		[tr setEmployeeId:c.EmployeeId];
		[tr setFnDate:c.fnDate];
		[tr setNote:c.note];
		[tr setCompanyId:c.CompanyId];
		[tr setNoteData:c.NoteData];
		[tr setNoteType:c.NoteType];
		
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	
	unsigned int s2 = CFSwapInt32HostToBig([array count]);
	[h1 appendBytes:(const void *)&s2 length:4];
	NSInteger l = [h1 length];
	[self.nett.oStream write:[h1 bytes] maxLength:l];
	//[NSThread sleepForTimeInterval:0.5];  

	[h1 release];
	for (FieldNote *fn in array)
	{
		NSMutableData *h = [[[NSMutableData alloc] init] autorelease];

		s2 = CFSwapInt32HostToBig([fn.CompanyId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([fn.EmployeeId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([fn.CustomerId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		unsigned short s3 = CFSwapInt16HostToBig([self getYearFromDate:fn.fnDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMonthFromDate:fn.fnDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getDayFromDate:fn.fnDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getHourFromDate:fn.fnDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMinuteFromDate:fn.fnDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getSecondFromDate:fn.fnDate]);
		[h appendBytes:(const void *)&s3 length:2];
		
		s2 = CFSwapInt32HostToBig([fn.note length]);
		[h appendBytes:(const void *)&s2 length:4];
		//NSString *s = fn.note;
		NSString *s = fn.note;
		if ([s length] > 0) {
			
			const uint8_t *str = (uint8_t *) [s cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[s length]];

		}
		int i = [fn.NoteType integerValue];
		
		s2 = CFSwapInt32HostToBig(i);
		[h appendBytes:(const void *)&s2 length:4];
		
		if([fn.NoteData length] > 0)
		{
			s2 = CFSwapInt32HostToBig([fn.NoteData length]);
			[h appendBytes:(const void *)&s2 length:4];

			NSInteger l = [h length];
			[self.nett.oStream write:[h bytes] maxLength:l]; 
			
			int len = [fn.NoteData length];
			double dd = 0;
			
			if(len > 0)
			{
				while (dd < len) {
					int lastInd = dd + 100;
					if(lastInd > len)
					{
						lastInd = len;
					}
					NSRange range = {dd, lastInd - dd};
					
					NSData *sub = [fn.NoteData subdataWithRange:range];
					
					dd =  dd + [nett.oStream write:[sub bytes] maxLength:range.length];
				}
			}
		}
		else {
			s2 = CFSwapInt32HostToBig(0);
			[h appendBytes:(const void *)&s2 length:4];

			NSInteger l = [h length];
			[self.nett.oStream write:[h bytes] maxLength:l]; 
		}
		
		
		s2 = [self.nett readIntFromServer];

	}
    if([array count] > 0){
		
		for(FieldNote *c in array)
		{
			[managedObjectContext deleteObject:c];
		}
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
    }
      
	s2 = [self.nett readIntFromServer];
    //[array release];

}

-(void)sendPerDiemToSyncCenter
{
	NSMutableArray *array = [self createRequest:@"MealExpense" initWithKey:[NSString stringWithString:@""] asc:NO];
	NSMutableData *h1 = [[NSMutableData alloc] init];
	
	if([array count] > 0){
		
		for(MealExpense *c in array)
		{
			
			MealExpenseBackup *tr = (MealExpenseBackup *)[NSEntityDescription insertNewObjectForEntityForName:@"MealExpenseBackup" inManagedObjectContext:managedObjectContext];
			
			[tr setApproveDate:c.ApproveDate];
			[tr setEmployeeId:c.EmployeeId];
			[tr setApprovedById:c.ApprovedById];
			[tr setCompanyId:c.CompanyId];
			
		}
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		
    }
	
	
	unsigned int s2 = CFSwapInt32HostToBig([array count]);
	[h1 appendBytes:(const void *)&s2 length:4];
	NSInteger l = [h1 length];
	[self.nett.oStream write:[h1 bytes] maxLength:l];
	//[NSThread sleepForTimeInterval:0.5];  

	[h1 release];
	for (MealExpense *me in array)
	{
		NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
		
		s2 = CFSwapInt32HostToBig([me.CompanyId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([me.EmployeeId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([me.ApprovedById integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		
		unsigned short s3 = CFSwapInt16HostToBig([self getYearFromDate:me.ApproveDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMonthFromDate:me.ApproveDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getDayFromDate:me.ApproveDate]);
		[h appendBytes:(const void *)&s3 length:2];

		
		NSInteger l = [h length];
		[self.nett.oStream write:[h bytes] maxLength:l]; 
		//[NSThread sleepForTimeInterval:0.1];  

		s2 = [self.nett readIntFromServer];
		
	}
	//[NSThread sleepForTimeInterval:0.5];  
    if([array count] > 0){
		
		for(MealExpense *c in array)
		{
			
			[managedObjectContext deleteObject:c];
		}
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}

    }
	s2 = [nett readIntFromServer];
    //[array release];

}

-(void)sendFeedbackToSyncCenter
{
	NSMutableArray *array = [self createRequest:@"FeedbackAnswer" initWithKey:[NSString stringWithString:@""] asc:NO];
	NSMutableData *h1 = [[NSMutableData alloc] init];
	
	if([array count] > 0){
		
		
		for(FeedbackAnswer *c in array)
		{
			
			FeedbackAnswerBackup *tr = (FeedbackAnswerBackup *)[NSEntityDescription insertNewObjectForEntityForName:@"FeedbackAnswerBackup" inManagedObjectContext:managedObjectContext];
			
			[tr setFaDate:c.faDate];
			[tr setEmployeeId:c.EmployeeId];
			[tr setAnswer:c.Answer];
			[tr setCompanyId:c.CompanyId];
			[tr setDoubleAnswer:c.DoubleAnswer];
			[tr setQuestionId:c.QuestionId];
			[tr setClockId:c.ClockId];
			
		}
		
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
    }
	
	unsigned int s2 = CFSwapInt32HostToBig([array count]);
	[h1 appendBytes:(const void *)&s2 length:4];
	NSInteger l = [h1 length];
	[self.nett.oStream write:[h1 bytes] maxLength:l];
	//[NSThread sleepForTimeInterval:0.5];  

	[h1 release];
	for (FeedbackAnswer *fa in array)
	{
		NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
		
		s2 = CFSwapInt32HostToBig([fa.CompanyId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([fa.ClockId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([fa.EmployeeId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		
		unsigned short s3 = CFSwapInt16HostToBig([self getYearFromDate:fa.faDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMonthFromDate:fa.faDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getDayFromDate:fa.faDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getHourFromDate:fa.faDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMinuteFromDate:fa.faDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getSecondFromDate:fa.faDate]);
		[h appendBytes:(const void *)&s3 length:2];
		
		s2 = CFSwapInt32HostToBig([fa.QuestionId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([fa.Answer integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
        
        
        //uint64_t len = [fa.DoubleAnswer doubleValue];
		
		//[nett writeLong:len];
        //CFConvertDoubleSwappedToHost
		CFSwappedFloat64 p = CFConvertDoubleHostToSwapped([fa.DoubleAnswer doubleValue]);
		[h appendBytes:(const void *)&p length:8];
		
		NSInteger l = [h length];
		[self.nett.oStream write:[h bytes] maxLength:l]; 
        
        
		s2 = [self.nett readIntFromServer];
		NSLog(@"%d", s2);
		//NSInteger i = s2;
	}
    if([array count] > 0){

		
		for(FeedbackAnswer *c in array)
		{
			
			[managedObjectContext deleteObject:c];
		}
		
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
    }
    
	s2 = [self.nett readIntFromServer];
    //[array release];

}

-(void)getEmployeeDataFromCoreData{
    NSMutableArray *array = [self createRequest:@"Employee" initWithKey:[NSString stringWithString:@""] asc:YES];
	NSInteger num = [array count];
    for(int i = 0; i < num; i++){
        Employee *emp = [array objectAtIndex:i];
        NSLog(@"Emp: %@, %@, %@", emp.LastName, emp.Pin, [emp.Manager stringValue]);
    
    }
}

-(void)sendJobPhotosToSyncCenter
{
	NSMutableArray *array = [self createRequest:@"JobPhoto" initWithKey:[NSString stringWithString:@""] asc:NO];
	NSMutableData *h1 = [[NSMutableData alloc] init];
	
	unsigned int s2 = CFSwapInt32HostToBig([array count]);
	[h1 appendBytes:(const void *)&s2 length:4];
	NSInteger l = [h1 length];
	[nett.oStream write:[h1 bytes] maxLength:l];
	//[NSThread sleepForTimeInterval:0.5];  		

	[h1 release];
	for (JobPhoto *jp in array)
	{
		NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
		
		s2 = CFSwapInt32HostToBig([jp.JobId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([jp.EmployeeId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		NSLog(@"%d", [self getMonthFromDate:jp.jpDate]);
		unsigned short s3 = CFSwapInt16HostToBig([self getMonthFromDate:jp.jpDate] - 1);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getDayFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getYearFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getHourFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMinuteFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getSecondFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		
		s2 = CFSwapInt32HostToBig([jp.ImagePath length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([jp.ImagePath length] > 0) {
			const uint8_t *str = (uint8_t *) [jp.ImagePath cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[jp.ImagePath length]];
		}
		
		s2 = CFSwapInt32HostToBig([jp.Title length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([jp.Title length] > 0) {
			const uint8_t *str = (uint8_t *) [jp.Title cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[jp.Title length]];
		}
		
		s2 = CFSwapInt32HostToBig([jp.Description length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([jp.Description length] > 0) {
			const uint8_t *str = (uint8_t *) [jp.Description cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[jp.Description length]];
		}
		
		//send actual photo!
		NSInteger l = [h length];
		[nett.oStream write:[h bytes] maxLength:l]; 
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		[dateFormat setDateFormat:@"MMddyyyyhhmmss"];
		NSString *dateString = [dateFormat stringFromDate:jp.jpDate];  
		[dateFormat release];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *fullPath = [[documentsDirectory stringByAppendingPathComponent:@"jobphotos"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", dateString]];
		NSData *image = [NSData dataWithContentsOfFile:fullPath];
		uint64_t len = [image length];
		
		[nett writeLong:len];
		
		double dd = 0;
		
		if(len > 0)
		{
			while (dd < len) {
				int lastInd = dd + 100;
				if(lastInd > len)
				{
					lastInd = len;
				}
				NSRange range = {dd, lastInd - dd};
				
				NSData *sub = [image subdataWithRange:range];
				
				dd =  dd + [nett.oStream write:[sub bytes] maxLength:range.length];
				
			}
			
		}
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:fullPath error:nil];

		//[NSThread sleepForTimeInterval:0.1];  		

		s2 = [nett readIntFromServer];
		
	}
    if([array count] > 0){
        for(JobPhoto *c in array)
        {
            [managedObjectContext deleteObject:c];
        }
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
    }
	s2 = [nett readIntFromServer];
    //[array release];

}

-(void)getSystemDataFromSyncCenter
{

    unsigned int numPinKeys_ = [nett readIntFromServer];
	unsigned int jobCostCodeBudget = [nett readIntFromServer];
	unsigned int jobPhotos = [nett readIntFromServer];
	unsigned int penSignatures = [nett readIntFromServer];
	unsigned int workOrders = [nett readIntFromServer];
    
	NSMutableArray *array = [self createRequest:@"SystemData" initWithKey:[NSString stringWithString:@""] asc:NO];
	
	for(SystemData *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	SystemData *sys = (SystemData *)[NSEntityDescription insertNewObjectForEntityForName:@"SystemData" inManagedObjectContext:managedObjectContext];
		
	[sys setNumPinKeys:[NSNumber numberWithInt:numPinKeys_]];
	[sys setJobCostCodeBudgetCapable:[NSNumber numberWithInt:jobCostCodeBudget]];
	[sys setJobPhotosCapable:[NSNumber numberWithInt:jobPhotos]];
	[sys setPenSignatureCapable:[NSNumber numberWithInt:penSignatures]];
	[sys setWorkOrdersCapable:[NSNumber numberWithInt:workOrders]];
		
	
	NSManagedObjectContext *context = sys.managedObjectContext;
		
	error = nil;
	if (![context save:&error]) {
			// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    //[array release];

}


-(void)getCompanyDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];

	NSMutableArray *array = [self createRequest:@"Company" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(Company *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	if (numRecords > 0) {
		
		for(int indx = 0; indx < numRecords; indx++)
		{
			int companyId = [nett readIntFromServer];
			int nameLength = [nett readIntFromServer];
			NSString *companyName = [NSString stringWithString:[NSString stringWithString:@""]];
			if (nameLength > 0){
				
				companyName = [nett readStringFromServer:nameLength];
			}
			int earliestInHour = [nett readIntFromServer];
			int earliestInMinute = [nett readIntFromServer];
			int latestOutHour = [nett readIntFromServer];
			int latestOutMinute = [nett readIntFromServer];
			int roundToNearest = [nett readIntFromServer];
			int trackPerDiem = [nett readIntFromServer];
			
            int forceEmployeeSync = [nett readIntFromServer];
            
            int useCustomList1 = [nett readIntFromServer];
            NSLog(@"Custlist: %d", useCustomList1);
            int customList1LabelLen = [nett readIntFromServer];
            NSString *customList1Label = [NSString stringWithString:[NSString stringWithString:@""]];
			if (customList1LabelLen > 0){
				
				customList1Label = [nett readStringFromServer:customList1LabelLen];
			}
            
            int useCustomList2 = [nett readIntFromServer];
            NSLog(@"Custlist: %d", useCustomList2);
            int customList2LabelLen = [nett readIntFromServer];
            NSString *customList2Label = [NSString stringWithString:[NSString stringWithString:@""]];
			if (customList2LabelLen > 0){
				
				customList2Label = [nett readStringFromServer:customList2LabelLen];
			}
            
            int useCustomList3 = [nett readIntFromServer];
            NSLog(@"Custlist: %d", useCustomList3);
            int customList3LabelLen = [nett readIntFromServer];
            NSString *customList3Label = [NSString stringWithString:[NSString stringWithString:@""]];
			if (customList3LabelLen > 0){
				
				customList3Label = [nett readStringFromServer:customList3LabelLen];
			}
            NSLog(@"cLists = %@, %@, %@", customList1Label, customList2Label, customList3Label);
            
			// Add a new Company record
			Company *comp = (Company *)[NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:managedObjectContext];
			[comp setCompanyId:[NSNumber numberWithInteger:companyId]];
			[comp setName:companyName];
			[comp setEarliestInHours:[NSNumber numberWithInteger:earliestInHour]];
			[comp setEarliestInMinutes:[NSNumber numberWithInteger:earliestInMinute]];
			[comp setLatestOutHours:[NSNumber numberWithInteger:latestOutHour]];
			[comp setLatestOutMinutes:[NSNumber numberWithInteger:latestOutMinute]];
			[comp setRoundMinutes:[NSNumber numberWithInteger:roundToNearest]];
			[comp setTrackPerDiem:[NSNumber numberWithInteger:trackPerDiem]];
			[comp setLatestOutAmPm:[NSNumber numberWithInteger:(short)0]];
			[comp setEarliestInAmPm:[NSNumber numberWithInteger:(short)0]];
            [comp setForceEmployeeSync:[NSNumber numberWithInt:forceEmployeeSync]];
            [comp setUseCustomList1:[NSNumber numberWithInt:useCustomList1]];
            [comp setUseCustomList2:[NSNumber numberWithInt:useCustomList2]];
            [comp setUseCustomList3:[NSNumber numberWithInt:useCustomList3]];
            [comp setCustomList1Label:customList1Label];
            [comp setCustomList2Label:customList2Label];
            [comp setCustomList3Label:customList3Label];

			error = nil;
			if (![managedObjectContext save:&error]) {
				// Handle the error.
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				exit(-1);  // Fail
			}
            
            NSLog(@"CustList from Company: %d, %d, %d", [comp.useCustomList1 integerValue], [comp.useCustomList2 integerValue], [comp.useCustomList3 integerValue]);
		}
        
        //[array release];

	}
}


-(void)getEmployeeDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
    NSLog(@"getEmployeeDataFromSyncCenter numRecords %d", numRecords);
	NSMutableArray *array = [self createRequest:@"Employee" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(Employee *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	if (numRecords > 0) {
		
		
		int limit = 0;
		for(int indx = 0; indx < numRecords; indx++)
		{
			int employeeId = [nett readIntFromServer];
			if(employeeId <= 0)
			{
				exit(-1);
			}
            //NSLog(@"employeeId %d", employeeId);
            
			int len = [nett readIntFromServer];
			NSString *empCode = [NSString stringWithString:@""];
			if (len > 0){
				empCode = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *firstName = [NSString stringWithString:@""];
			if (len > 0){
				firstName = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *middleName = [NSString stringWithString:@""];
			if (len > 0){
				middleName = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *lastName = [NSString stringWithString:@""];
			if (len > 0){
				lastName = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *pin = [NSString stringWithString:@""];
			if (len > 0){
				pin = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *address = [NSString stringWithString:@""];
			if (len > 0){
				address = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *city = [NSString stringWithString:@""];
			if (len > 0){
				city = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *state = [NSString stringWithString:@""];
			if (len > 0){
				state = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *zip = [NSString stringWithString:@""];
			if (len > 0){
				zip = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *country = [NSString stringWithString:@""];
			if (len > 0){
				country = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *phone = [NSString stringWithString:@""];
			if (len > 0){
				phone = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *cell = [NSString stringWithString:@""];
			if (len > 0){
				cell = [nett readStringFromServer:len];
			}
			int manager = [nett readIntFromServer];
			int selectCostCodes = [nett readIntFromServer];
			int selectJobs = [nett readIntFromServer];
			int addJobs = [nett readIntFromServer];
			int allocate = [nett readIntFromServer];
			int addEmployees = [nett readIntFromServer];
			int editTime = [nett readIntFromServer];
			int languageVal = [nett readIntFromServer];
			int clockInOthers = [nett readIntFromServer];
			int viewTimestamps = [nett readIntFromServer];
			int ignoreRestrictions = [nett readIntFromServer];
			int equipment = [nett readIntFromServer];
			int addNotes = [nett readIntFromServer];
			len = [nett readIntFromServer];
			NSString *barcode = [NSString stringWithString:@""];
			if (len > 0){
				barcode = [nett readStringFromServer:len];
			}
			
			Employee *emp = (Employee *)[NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:managedObjectContext];
			[emp setEmployeeId:[NSNumber numberWithInteger:employeeId]];
			[emp setEmpCode:empCode];
			[emp setFirstName:firstName];
			[emp setMiddleName:middleName];
			[emp setLastName:lastName];
			[emp setPin:pin];
			[emp setAddress:address];
			[emp setCity:city];
			[emp setState:state];
			[emp setZip:zip];
			[emp setCountry:country];
			[emp setPhone:phone];
			[emp setCell:cell];
			[emp setManager:[NSNumber numberWithBool:manager == 1 ? YES : NO]];
			[emp setSetCostCodes:[NSNumber numberWithBool:selectCostCodes == 1 ? YES : NO]];
			[emp setSetJobs:[NSNumber numberWithBool:selectJobs == 1 ? YES : NO]];
			[emp setAddJobs:[NSNumber numberWithBool:addJobs == 1 ? YES : NO]];
			[emp setAddEmplyees:[NSNumber numberWithBool:addEmployees == 1 ? YES : NO]];
			[emp setAllocateTime:[NSNumber numberWithBool:allocate == 1 ? YES : NO]];
			[emp setEditTime:[NSNumber numberWithBool:editTime == 1 ? YES : NO]];
			[emp setLanguageVal:[NSNumber numberWithBool:languageVal == 1 ? YES : NO]];
			[emp setClockInOthers:[NSNumber numberWithBool:clockInOthers == 1 ? YES : NO]];
			[emp setViewTimeStamps:[NSNumber numberWithBool:viewTimestamps == 1 ? YES : NO]];
			[emp setIgnoreRestrictions:[NSNumber numberWithBool:ignoreRestrictions == 1 ? YES : NO]];
			[emp setTrackEquipment:[NSNumber numberWithBool:equipment == 1 ? YES : NO]];
			[emp setAddFieldNotes:[NSNumber numberWithBool:addNotes == 1 ? YES : NO]];
			[emp setBarCodeScannerId:barcode];
			//NSLog(@"emp written with code: %d", employeeId);
			//[NSThread sleepForTimeInterval:0.1]; 
			NSLog(@"record # %d", indx);	
			//[NSThread sleepForTimeInterval:0.1]; 
			limit = limit + 1;
			if(limit == 50)
			{
				error = nil;
				[NSThread sleepForTimeInterval:0.3]; 
				if (![managedObjectContext save:&error]) {
					// Handle the error.
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					exit(-1);  // Fail
				}
				NSLog(@"saving %d records", limit);
				limit = 0;
			}
		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			@throw [NSException
					exceptionWithName:@"getEmployeeDataFromSyncCenter error"
					reason:[error description]
					userInfo:[error userInfo]];  // Fail
		}
        
       // [array release];

	}
}

-(void)getEmployeeCostCodeDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
	NSLog(@"getEmployeeCostCodeDataFromSyncCenter numRecords %d", numRecords);
	NSMutableArray *array = [self createRequest:@"EmployeeCostCode" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(EmployeeCostCode *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	if (numRecords > 0) {
		
		int limit = 0;
		for(int indx = 0; indx < numRecords; indx++)
		{
			int employeeId = [nett readIntFromServer];
			int costCodeId = [nett readIntFromServer];
			
			EmployeeCostCode *emp = (EmployeeCostCode *)[NSEntityDescription insertNewObjectForEntityForName:@"EmployeeCostCode" inManagedObjectContext:managedObjectContext];
			[emp setEmployeeId:[NSNumber numberWithInteger:employeeId]];
			[emp setCostCodeId:[NSNumber numberWithInteger:costCodeId]];
			limit = limit + 1;
			NSLog(@"record # %d", indx);
			if(limit == 50)
			{
				error = nil;
				[NSThread sleepForTimeInterval:0.3]; 
				if (![managedObjectContext save:&error]) {
					// Handle the error.
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					exit(-1);  // Fail
				}
				NSLog(@"saving %d records", limit);
				limit = 0;
			}

		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        //[array release];

	}
}

-(void)getJobDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
    NSLog(@"getJobDataFromSyncCenter numRecords %d", numRecords);
	NSMutableArray *array = [self createRequest:@"Customer" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(Customer *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	if (numRecords > 0) {
		
		int limit = 0;
		for(int indx = 0; indx < numRecords; indx++)
		{
			int jobId = [nett readIntFromServer];
			int parentId = [nett readIntFromServer];
			int companyId = [nett readIntFromServer];
			int len = [nett readIntFromServer];
			NSString *jobCode = [NSString stringWithString:@""];
			if (len > 0){
				jobCode = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *jobName = [NSString stringWithString:@""];
			if (len > 0){
				jobName = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *address = [NSString stringWithString:@""];
			if (len > 0){
				address = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *city = [NSString stringWithString:@""];
			if (len > 0){
				city = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *state = [NSString stringWithString:@""];
			if (len > 0){
				state = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *notes = [NSString stringWithString:@""];
			if (len > 0){
				notes = [nett readStringFromServer:len];
			}
			short earliestInHours = [nett readIntFromServer];
			short earliestInMinutes = [nett readIntFromServer];
			short latestOutHours = [nett readIntFromServer];
			short latestOutMinutes = [nett readIntFromServer];
			short roundMinutes = [nett readIntFromServer];
			short sortOrder = [nett readIntFromServer];
			
			Customer *cust = (Customer *)[NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:managedObjectContext];
			[cust setCustomerId:[NSNumber numberWithInteger:jobId]];
			[cust setParentId:[NSNumber numberWithInteger:parentId]];
			[cust setCompanyId:[NSNumber numberWithInteger:companyId]];
			[cust setCode:jobCode];
			[cust setName:jobName];
			[cust setAddress:address];
			[cust setCity:city];
			[cust setState:state];
			[cust setNotes:notes];
			[cust setEarliestInHours:[NSNumber numberWithShort:earliestInHours]];
			[cust setEarliestInMinutes:[NSNumber numberWithShort:earliestInMinutes]];
			[cust setEarliestInAmPm:[NSNumber numberWithShort:(short)0]];
			[cust setLatestOutHours:[NSNumber numberWithShort:latestOutHours]];
			[cust setLatestOutMinutes:[NSNumber numberWithShort:latestOutMinutes]];
			[cust setLatestOutAmPm:[NSNumber numberWithShort:(short)0]];
			[cust setRoundMinutes:[NSNumber numberWithShort:roundMinutes]];
			[cust setSortOrder:[NSNumber numberWithShort:sortOrder]];
			[NSThread sleepForTimeInterval:0.05]; 
			limit = limit + 1;
			NSLog(@"record # %d", indx);
			if(limit == 25)
			{
				NSLog(@"record # %d", indx);
			}
			if(limit == 50)
			{
				error = nil;
				[NSThread sleepForTimeInterval:0.3]; 
				if (![managedObjectContext save:&error]) {
					// Handle the error.
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					exit(-1);  // Fail
				}
				NSLog(@"saving %d records", limit);
				limit = 0;
			}
		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
       // [array release];

	}		
}

-(void)getCostCodeDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
    NSLog(@"getCostCodeDataFromSyncCenter numRecords %d", numRecords);
	NSMutableArray *array = [self createRequest:@"CostCode" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(Customer *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	if (numRecords > 0) {
		
		int limit = 0;
		for(int indx = 0; indx < numRecords; indx++)
		{
			int costCodeId = [nett readIntFromServer];
			int parentId = [nett readIntFromServer];
			int companyId = [nett readIntFromServer];
			
			int len = [nett readIntFromServer];
			NSString *name = [NSString stringWithString:@""];
			if (len > 0){
				name = [nett readStringFromServer:len];
			}  
			int sortOrder = [nett readIntFromServer];
			int useEquipment = [nett readIntFromServer];
			int trackUnits = [nett readIntFromServer];
			
			CostCode *cc = (CostCode *)[NSEntityDescription insertNewObjectForEntityForName:@"CostCode" inManagedObjectContext:managedObjectContext];
			[cc setCostCodeId:[NSNumber numberWithInteger:costCodeId]];
			[cc setParentId:[NSNumber numberWithInteger:parentId]];
			[cc setCompanyId:[NSNumber numberWithInteger:companyId]];
			[cc setCode:[NSString stringWithString:@""]];
			[cc setName:name];
			[cc setSortOrder:[NSNumber numberWithShort:(short)sortOrder]];
			[cc setActive:[NSNumber numberWithShort:(short)1]];
			[cc setTrackEquipment:[NSNumber numberWithShort:(short)useEquipment]];
			[cc setTrackUnits:[NSNumber numberWithShort:(short)trackUnits]];
			
			limit = limit + 1;
			NSLog(@"record # %d", indx);
			if(limit == 50)
			{
				error = nil;
				[NSThread sleepForTimeInterval:0.3]; 
				if (![managedObjectContext save:&error]) {
					// Handle the error.
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					exit(-1);  // Fail
				}
				NSLog(@"saving %d records", limit);
				limit = 0;
			}
		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        //[array release];

	}
}

-(void)getJobCostCodeDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
    NSLog(@"getJobCostCodeDataFromSyncCenter numRecords %d", numRecords);

	NSMutableArray *array = [self createRequest:@"CustomerCostCode" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(CustomerCostCode *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	if (numRecords > 0) {

				int limit = 0;
		for(int indx = 0; indx < numRecords; indx++)
		{
			int jobId = [nett readIntFromServer];
			int costCodeId = [nett readIntFromServer];
			double budgetedHours = [nett readDoubleFromServer];
			double accruedHours = [nett readDoubleFromServer];
			double budgetedUnits = [nett readDoubleFromServer];
			double accruedUnits = [nett readDoubleFromServer];
			
			CustomerCostCode *ccc = (CustomerCostCode *)[NSEntityDescription insertNewObjectForEntityForName:@"CustomerCostCode" inManagedObjectContext:managedObjectContext];
			[ccc setCustomerId:[NSNumber numberWithInteger:jobId]];
			[ccc setCostCodeId:[NSNumber numberWithInteger:costCodeId]];
			[ccc setBudgetedHours:[NSNumber numberWithDouble:budgetedHours]];
			[ccc setAccruedHours:[NSNumber numberWithDouble:accruedHours]];
			[ccc setBudgetedUnits:[NSNumber numberWithDouble:budgetedUnits]];
			[ccc setAccruedUnits:[NSNumber numberWithDouble:accruedUnits]];
			limit = limit + 1;
			NSLog(@"record # %d", indx);
			if(limit == 50)
			{
				error = nil;
				[NSThread sleepForTimeInterval:0.3]; 
				if (![managedObjectContext save:&error]) {
					// Handle the error.
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					exit(-1);  // Fail
				}
				NSLog(@"saving %d records", limit);
				limit = 0;
			}

		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
	}
}

-(void)getJobEmployeeDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
    NSLog(@"getJobEmployeeDataFromSyncCenter numRecords %d", numRecords);

	NSMutableArray *array = [self createRequest:@"CustomerEmployee" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(CustomerEmployee *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	if (numRecords > 0) {
		
		int limit = 0;
		for(int indx = 0; indx < numRecords; indx++)
		{
			int jobId = [nett readIntFromServer];
			int employeeId = [nett readIntFromServer];
			
			CustomerEmployee *ce = (CustomerEmployee *)[NSEntityDescription insertNewObjectForEntityForName:@"CustomerEmployee" inManagedObjectContext:managedObjectContext];
			[ce setCustomerId:[NSNumber numberWithInteger:jobId]];
			[ce setEmployeeId:[NSNumber numberWithInteger:employeeId]];
			limit = limit + 1;
			NSLog(@"record # %d", indx);
			if(limit == 50)
			{
				error = nil;
				[NSThread sleepForTimeInterval:0.3]; 
				if (![managedObjectContext save:&error]) {
					// Handle the error.
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					exit(-1);  // Fail
				}
				NSLog(@"saving %d records", limit);
				limit = 0;
			}

		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        //[array release];

	}
}

-(void)getFBQuestionDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
    NSLog(@"getFBQuestionDataFromSyncCenter numRecords %d", numRecords);

	NSMutableArray *array = [self createRequest:@"FeedbackQuestion" initWithKey:@"" asc:NO];
	for(FeedbackQuestion *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	if (numRecords > 0) {

		
		for(int indx = 0; indx < numRecords; indx++)
		{
			int fbQuestionId = [nett readIntFromServer];
			int len = [nett readIntFromServer];
			NSString *question = [NSString stringWithString:@""];
			if (len > 0){
				question = [nett readStringFromServer:len];
			}
			int feedbackType = [nett readIntFromServer];
			int itemOrder = [nett readIntFromServer];
			int active = [nett readIntFromServer];
			FeedbackQuestion *fq = (FeedbackQuestion *)[NSEntityDescription insertNewObjectForEntityForName:@"FeedbackQuestion" inManagedObjectContext:managedObjectContext];
			[fq setFeedbackQuestionId:[NSNumber numberWithInteger:fbQuestionId]];
			[fq setQuestion:question];
			[fq setFeedbackType:[NSNumber numberWithInteger:feedbackType]];
			[fq setItemOrder:[NSNumber numberWithInteger:itemOrder]];
			[fq setActive:[NSNumber numberWithInteger:active]];
		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        //[array release];

	}
}

-(void)getEquipmentDataFromSyncCenter
{
	int numRecords = [nett readIntFromServer];
    NSLog(@"getEquipmentDataFromSyncCenter numRecords %d", numRecords);
	NSMutableArray *array = [self createRequest:@"Equipment" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(Equipment *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	if (numRecords > 0) {
		
		for(int indx = 0; indx < numRecords; indx++)
		{
			int equipmentId = [nett readIntFromServer];
			int parentId = [nett readIntFromServer];
			int companyId = [nett readIntFromServer];
			int len = [nett readIntFromServer];
			NSString *code = [NSString stringWithString:@""];
			if (len > 0){
				code = [nett readStringFromServer:len];
			}
			len = [nett readIntFromServer];
			NSString *name = [NSString stringWithString:@""];
			if (len > 0){
				name = [nett readStringFromServer:len];
			}  
			int sortOrder = [nett readIntFromServer];
			
			Equipment *eq = (Equipment *)[NSEntityDescription insertNewObjectForEntityForName:@"Equipment" inManagedObjectContext:managedObjectContext];
			[eq setEquipmentId:[NSNumber numberWithInteger:equipmentId]];
			[eq setParentId:[NSNumber numberWithInteger:parentId]];
			[eq setCompanyId:[NSNumber numberWithInteger:companyId]];
			[eq setCode:code];
			[eq setName:name];
			[eq setSortOrder:[NSNumber numberWithInteger:sortOrder]];
		}
		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        //[array release];

	}

}

-(void)getCustomListDataFromSyncCenter
{
    int numRecords = [nett readIntFromServer];
    NSLog(@"getCustomListDataFromSyncCenter numRecords %d", numRecords);
	NSMutableArray *array = [self createRequest:@"CustomList" initWithKey:[NSString stringWithString:@""] asc:NO];
	for(CustomList *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    if (numRecords > 0) {
		
		for(int indx = 0; indx < numRecords; indx++)
		{
			int customListId = [nett readIntFromServer];
			int companyId = [nett readIntFromServer];
			int customListType = [nett readIntFromServer];
			int len = [nett readIntFromServer];
			NSString *name = [NSString stringWithString:@""];
			if (len > 0){
				name = [nett readStringFromServer:len];
			}
			
			
			CustomList *customList = (CustomList *)[NSEntityDescription insertNewObjectForEntityForName:@"CustomList" inManagedObjectContext:managedObjectContext];
			[customList setCustomListId:[NSNumber numberWithInteger:customListId]];
            [customList setCompanyId:[NSNumber numberWithInteger:companyId]];
			[customList setCustomListType:[NSNumber numberWithInteger:customListType]];
            [customList setName:name];
            
            NSLog(@"Custom list added - %@, %d, %d, %d", name, customListId, customListType, companyId);
        }

		error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        
	}
}


-(int)sendSignatureFile:(NSInteger)empId image:(NSMutableData *)image
{
	AppSettings *sett = [self LoadSettings];
	
	[self registerDevice:sett.accountNumber command:108 readTo:NO];
	
	[nett writeInt:sett.clockId];
	
	[nett writeInt:empId];
	
	uint64_t len = [image length];
	
	[nett writeLong:len];
	
	double d = 0;
	
	if(len > 0)
	{
		while (d < len) {
			int lastInd = d + 100;
			if(lastInd > len)
			{
				lastInd = len;
			}
			NSRange range = {d, lastInd - d};
			
			NSData *sub = [image subdataWithRange:range];
						
			d =  d + [nett.oStream write:[sub bytes] maxLength:range.length];
						   
			//[sub release];
		}
		
	}
	
	
	int processedSignature = [nett readIntFromServer];
	
	return processedSignature;
	
	
}

-(int)syncJobPhotos
{
	AppSettings *sett = [self LoadSettings];
	
	[self registerDevice:sett.accountNumber command:104 readTo:NO];
	
	[nett writeInt:sett.clockId];
	
	NSMutableArray *array = [self createRequest:@"JobPhoto" initWithKey:[NSString stringWithString:@""] asc:NO];
	
	[nett writeInt:[array count]];
	unsigned int s2 = 0;
	
	for (JobPhoto *jp in array)
	{
		
		[self performSelectorOnMainThread:@selector(showProgressSyncing:) withObject:[NSString stringWithFormat:@"Sending JobPhoto: %@", jp.Title] waitUntilDone:NO];
		
		NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
		
		s2 = CFSwapInt32HostToBig([jp.JobId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		s2 = CFSwapInt32HostToBig([jp.EmployeeId integerValue]);
		[h appendBytes:(const void *)&s2 length:4];
		
		
		unsigned short s3 = CFSwapInt16HostToBig([self getMonthFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getDayFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getYearFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getHourFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getMinuteFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		s3 = CFSwapInt16HostToBig([self getSecondFromDate:jp.jpDate]);
		[h appendBytes:(const void *)&s3 length:2];
		
		
		s2 = CFSwapInt32HostToBig([jp.ImagePath length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([jp.ImagePath length] > 0) {
			const uint8_t *str = (uint8_t *) [jp.ImagePath cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[jp.ImagePath length]];
		}
		
		s2 = CFSwapInt32HostToBig([jp.Title length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([jp.Title length] > 0) {
			const uint8_t *str = (uint8_t *) [jp.Title cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[jp.Title length]];
		}
		
		s2 = CFSwapInt32HostToBig([jp.Description length]);
		[h appendBytes:(const void *)&s2 length:4];
		if ([jp.Description length] > 0) {
			const uint8_t *str = (uint8_t *) [jp.Description cStringUsingEncoding:NSASCIIStringEncoding];
			[h appendBytes:str  length:[jp.Description length]];
		}
		
		//send actual photo!
		NSInteger l = [h length];
		[nett.oStream write:[h bytes] maxLength:l]; 
		
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		[dateFormat setDateFormat:@"MMddyyyyhhmmss"];
		NSString *dateString = [dateFormat stringFromDate:jp.jpDate];  
		[dateFormat release];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *fullPath = [[documentsDirectory stringByAppendingPathComponent:@"jobphotos"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", dateString]];
		NSData *image = [NSData dataWithContentsOfFile:fullPath];
		uint64_t len = [image length];
		
		[nett writeLong:len];
		
		double dd = 0;
		
		if(len > 0)
		{
			while (dd < len) {
				int lastInd = dd + 100;
				if(lastInd > len)
				{
					lastInd = len;
				}
				NSRange range = {dd, lastInd - dd};
				
				NSData *sub = [image subdataWithRange:range];
				
				dd =  dd + [nett.oStream write:[sub bytes] maxLength:range.length];
				
			}
			
		}
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:fullPath error:nil];
				
		s2 = [nett readIntFromServer];
		
	}
    if([array count] > 0){
        for(JobPhoto *c in array)
        {
            [managedObjectContext deleteObject:c];
        }
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
    }
	s2 = [nett readIntFromServer];
	
	return s2;
	
}


-(void)SyncAllData:(UIProgressView *)progr;
{
	AppSettings *sett = [self LoadSettings];
	  
	[self registerDevice:sett.accountNumber command:103 readTo:NO];
	
	[nett writeInt:sett.clockId];
	
	//[NSThread sleepForTimeInterval:0.5];  

	//[sett release];
	
	progr.progress = 0.0;  

	NSLog(@"sendClockInfo");
	[self sendClockInfo];

	progr.progress = 0.2;  
	NSLog(@"sendTimeRecordsToSyncCenter");	
	[self sendTimeRecordsToSyncCenter];
	
	NSLog(@"sendFieldNotesToSyncCenter");	
	[self sendFieldNotesToSyncCenter];

	NSLog(@"sendPerDiemToSyncCenter");
	[self sendPerDiemToSyncCenter];
	progr.progress = 0.4;  
	
	NSLog(@"sendFeedbackToSyncCenter");
	[self sendFeedbackToSyncCenter];
	
	NSLog(@"sendJobPhotosToSyncCenter");
	[self sendJobPhotosToSyncCenter];
	
	NSLog(@"getSystemDataFromSyncCenter");
	[self getSystemDataFromSyncCenter];
	[nett writeInt:1];

	//[NSThread sleepForTimeInterval:0.2];  		

	NSLog(@"getCompanyDataFromSyncCenter");
	[self getCompanyDataFromSyncCenter];
	[nett writeInt:1];
	
	//[NSThread sleepForTimeInterval:0.2];  		

	NSLog(@"getEmployeeDataFromSyncCenter");
	[self getEmployeeDataFromSyncCenter];
	[nett writeInt:1];

	//[NSThread sleepForTimeInterval:0.2];  		

	NSLog(@"getEmployeeCostCodeDataFromSyncCenter");
	[self getEmployeeCostCodeDataFromSyncCenter];
	[nett writeInt:1];

	//[NSThread sleepForTimeInterval:0.2];  		
	
	NSLog(@"getJobDataFromSyncCenter");
	[self getJobDataFromSyncCenter];
	[nett writeInt:1];

	//[NSThread sleepForTimeInterval:0.2];  		
	
	NSLog(@"getCostCodeDataFromSyncCenter");
	[self getCostCodeDataFromSyncCenter];
	[nett writeInt:1];
	
	//[NSThread sleepForTimeInterval:0.2];  		

	NSLog(@"getJobCostCodeDataFromSyncCenter");
	[self getJobCostCodeDataFromSyncCenter];
	[nett writeInt:1];

	//[NSThread sleepForTimeInterval:0.2];  		

	NSLog(@"getJobEmployeeDataFromSyncCenter");
	[self getJobEmployeeDataFromSyncCenter];
	[nett writeInt:1];
	
	//[NSThread sleepForTimeInterval:0.2];  		

	NSLog(@"getFBQuestionDataFromSyncCenter");
	[self getFBQuestionDataFromSyncCenter];
	[nett writeInt:1];
	
	//[NSThread sleepForTimeInterval:0.2];  		

	NSLog(@"getEquipmentDataFromSyncCenter");
	[self getEquipmentDataFromSyncCenter];
	[nett writeInt:1];
	
}



/*
#pragma mark AsyncSocket methods
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if(regDevice)
	{
		//read data
				
		regDevice = NO;
	}
	if(sendTimeRecords)
	{
		//NSData *strData = [data subdataWithRange:NSMakeRange(0, 4)];
		uint32_t p[1];
		[data getBytes:p];
		uint32_t index = CFSwapInt32(p[0]);
	}
	[sock readDataWithTimeout:-1 tag:0];
}
 */
 
/*
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	//NSLog(@"willDisconnectWithError: %@", err);
	//[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	//(NSData *) data = [[NSData alloc] init];
	//[sock readDataWithTimeout:-1 tag:0];
	connect = YES;
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"after onSocketDidDisconnect");
	[connectedSockets removeObject:sock];
}
 */

#pragma mark Settings methods

-(void)SaveSettings:(NSString *)accountNumber cName:(NSString *)clName lastEmpIDList:(NSInteger)lastEmpIDList clockId:(NSInteger)clockId gpsEnabled:(BOOL)gpsEnabled myServer:(NSString *)myServer myPort:(NSString *)myPort
{
	AppSettings *as = [[AppSettings alloc] init];
	[as setAccountNumber:accountNumber];
	[as setClockName:clName];
	[as setLastEmpIDList:lastEmpIDList];
	[as setClockId:clockId];
	[as setGpsEnabled:gpsEnabled];

	//NSFileManager *fileManager = [NSFileManager defaultManager];

	NSMutableData *theData;
	NSKeyedArchiver *encoder;
		
	theData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
		
	[encoder encodeObject:as forKey:@"AppSettings"];
	[encoder finishEncoding];
    [as release];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"abouttime.dat"];
		
	[theData writeToFile:path atomically:YES];
	[encoder release];

}

-(void)SaveSettings:(AppSettings *)settings 
{
		
	NSMutableData *theData;
	NSKeyedArchiver *encoder;
	
	theData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	
	[encoder encodeObject:settings forKey:@"AppSettings"];
	[encoder finishEncoding];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"abouttime.dat"];
	
	[theData writeToFile:path atomically:YES];
	[encoder release];
	
}

-(AppSettings *)LoadSettings
{
	AppSettings *as = [[[AppSettings alloc] init] autorelease];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"abouttime.dat"];
	if([fileManager fileExistsAtPath:path]) {
		//open it and read it 
		//NSLog(@"data file found. reading into memory");
		NSMutableData *theData;
		NSKeyedUnarchiver *decoder;
		//NSMutableArray *tempArray;
		
		theData = [NSData dataWithContentsOfFile:path];
		decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		as = [decoder decodeObjectForKey:@"AppSettings"];
		[decoder finishDecoding];
		[decoder release];	
        
    } else {
		NSLog(@"no file found. creating empty array");
		//as = [[NSMutableArray alloc] init];
	}
	return as;
}

-(void)SaveClockState:(ClockState *)state
{
	
	NSMutableData *theData;
	NSKeyedArchiver *encoder;
	
	theData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	
	[encoder encodeObject:state forKey:@"ClockState"];
	[encoder finishEncoding];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"clockstate.dat"];
	
	[theData writeToFile:path atomically:YES];
	[encoder release];
}

-(ClockState *)LoadClockState
{
	ClockState *as = [[[ClockState alloc] init] autorelease];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"clockstate.dat"];
	if([fileManager fileExistsAtPath:path]) {
		//open it and read it 
		//NSLog(@"clockstate file found. reading into memory");
		NSMutableData *theData;
		NSKeyedUnarchiver *decoder;
		//NSMutableArray *tempArray;
		
		theData = [NSData dataWithContentsOfFile:path];
		decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		as = [decoder decodeObjectForKey:@"ClockState"];
		[decoder finishDecoding];
		[decoder release];	
        
    } else {
		NSLog(@"no clockstate file found. creating empty array");
		//as = [[NSMutableArray alloc] init];
	}
	return as;
}


-(NSDate *)getCurrentDate
{
	NSDate* sourceDate = [NSDate date];
	
	NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	
	NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
	
	return destinationDate;
}


-(NSDate *)getDate:(NSDate *)d
{
	NSDate* sourceDate = d;
	
	NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	
	NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
	
	return destinationDate;
}

- (NSDate *)dateToGMT:(NSDate *)sourceDate {
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:destinationGMTOffset sinceDate:sourceDate] autorelease];
    return destinationDate;
	//return sourceDate;
}

-(NSInteger)getYearFromDate:(NSDate *)date
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSString *dateString = [dateFormat stringFromDate:date];  
	[dateFormat release];
	return [dateString integerValue];
}

-(NSInteger)getMonthFromDate:(NSDate *)date
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MM"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSString *dateString = [dateFormat stringFromDate:date];  
	[dateFormat release];
	return [dateString integerValue];
}

-(NSInteger)getDayFromDate:(NSDate *)date
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"dd"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSString *dateString = [dateFormat stringFromDate:date];  
	[dateFormat release];
	return [dateString integerValue];
}

-(NSInteger)getHourFromDate:(NSDate *)date
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"HH"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSString *dateString = [dateFormat stringFromDate:date];  
	[dateFormat release];
	return [dateString integerValue];
}

-(NSInteger)getMinuteFromDate:(NSDate *)date
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"mm"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSString *dateString = [dateFormat stringFromDate:date];  
	[dateFormat release];
	return [dateString integerValue];
}

-(NSInteger)getSecondFromDate:(NSDate *)date
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"ss"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSString *dateString = [dateFormat stringFromDate:date];  
	[dateFormat release];
	return [dateString integerValue];
}


-(void)deleteAllRecords
{
	
	NSMutableArray *array = [self createRequest:@"TimeRecording" initWithKey:@"" asc:NO];
	for(TimeRecording *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"TimeRecordingBackup" initWithKey:@"" asc:NO];
	for(TimeRecordingBackup *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"FieldNote" initWithKey:@"" asc:NO];
	for(FieldNote *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"FieldNoteBackup" initWithKey:@"" asc:NO];
	for(FieldNoteBackup *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"MealExpense" initWithKey:@"" asc:NO];
	for(MealExpense *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"MealExpenseBackup" initWithKey:@"" asc:NO];
	for(MealExpenseBackup *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"FeedbackAnswer" initWithKey:@"" asc:NO];
	for(FeedbackAnswer *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"FeedbackAnswerBackup" initWithKey:@"" asc:NO];
	for(FeedbackAnswerBackup *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	
	array = [self createRequest:@"JobPhoto" initWithKey:@"" asc:NO];
	for(JobPhoto *c in array)
	{
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMddyyyyhhmmss"];
		NSString *dateString = [dateFormat stringFromDate:c.jpDate];  
		[dateFormat release];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *fullPath = [[documentsDirectory stringByAppendingPathComponent:@"jobphotos"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", dateString]];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:fullPath error:nil];
		[managedObjectContext deleteObject:c];
	}
	array = nil;
	array = [self createRequest:@"FeedbackAnswerBackup" initWithKey:@"" asc:NO];
	for(FeedbackAnswerBackup *c in array)
	{
		[managedObjectContext deleteObject:c];
	}
	
	AppSettings *as = [self LoadSettings];
	as.clockId = -1;
	as.gpsEnabled = NO;
	[self SaveSettings:as];
	
	ClockState *cs = [self LoadClockState];
	cs.EmployeeId = -1;
	cs.customerId = -1;
	cs.customerName = @"";
	cs.companyId = -1;
	cs.companyName = @"";
	cs.lastEmployees = nil;
	[self SaveClockState:cs];
	
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

-(void)Disconnect
{
	[nett disconnect];
	//[nett release];

}

- (void)dealloc {
	if(nett != nil)
	{
		[nett disconnect];
		[nett release];
	}

    [managedObjectContext release];
    [super dealloc];
}
@end
