//
//  TimeRecordManager.m
//  iFieldClock
//
//  Created by Bartimeus on 06.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#define UIAppDelegate ((iFieldClockAppDelegate *)[UIApplication sharedApplication].delegate)

#import "AboutTimePlusAppDelegate.h"
#import "TimeRecordManager.h"
#import "TimeRecording.h"
#import "TimeRecordingBackup.h"
#import "EmployeeManager.h"
#import "Employee.h"
#import "Customer.h"
#import "CustomerManager.h"
#import "Company.h"
#import "SyncCenter.h"

@implementation TimeRecordManager
@synthesize sc;
Employee *emp;
Company *company;
Customer *c;
NSMutableArray *timeRecords;

-(id)init
{
	self = [super init];

	
	return self;
	
}

-(void)getData:(TimeRecording *)tr
{
	NSPredicate * predicate;

	predicate = [NSPredicate predicateWithFormat:@"EmployeeId = %@", tr.EmployeeId];
	NSMutableArray *array = [sc createRequestWithKey:@"Employee" predicate:predicate initWithKey:@"" asc:NO];
	emp = [array objectAtIndex:0];
	array = nil;
	
	if([tr.CustomerId integerValue] > 0)
	{
		predicate = [NSPredicate predicateWithFormat:@"CustomerId = %@", tr.CustomerId];
		array = [sc createRequestWithKey:@"Customer" predicate:predicate initWithKey:@"" asc:NO];
		c = [array objectAtIndex:0];
		NSLog(@"%@, %d", c.Name, [c.RoundMinutes integerValue]);
		array = nil;
	}
	
	
	predicate = [NSPredicate predicateWithFormat:@"CompanyId = %@", tr.CompanyId];
	array = [sc createRequestWithKey:@"Company" predicate:predicate initWithKey:@"" asc:NO];
	company = [array objectAtIndex:0];
	array = nil;
	
	array = [sc createRequest:@"TimeRecording" initWithKey:@"" asc:YES];
	timeRecords = array;
	array = nil;
}


-(void)setCorrectDate:(TimeRecording *)tr 
{
	[self getData:tr];
	BOOL jobTimeLimiter = NO;
	BOOL timeModified = NO;
	BOOL timeRounded = NO;
	
	int ee = [c.EarliestInAmPm shortValue];
	if([c.EarliestInAmPm shortValue] == 0)
	{
		ee = [c.EarliestInHours shortValue];
	}
	else {
		ee = [c.EarliestInHours shortValue];
	}
	
	int ll = [c.LatestOutAmPm shortValue];
	if([c.LatestOutAmPm shortValue] == 0)
	{
		ll = [c.LatestOutHours shortValue];
	}
	
	if(![emp.IgnoreRestrictions boolValue])
	{
		if([tr.CustomerId integerValue] > 0)
		{
			if([c.EarliestInHours shortValue] > 0 || [c.LatestOutHours shortValue] > 0)
			{
				jobTimeLimiter = YES;
			}
			
			if([tr.CostCodeId integerValue] == -1 || [tr.CostCodeId integerValue] > 0)
			{
				if([c.EarliestInHours shortValue] > 0 && [sc getHourFromDate:tr.trDate] < ee || ([sc getHourFromDate:tr.trDate] == ee && [sc getMinuteFromDate:tr.trDate] < [c.EarliestInMinutes shortValue]))
				{
					NSDateComponents *components = [[NSDateComponents alloc] init];
					[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
					
					[components setDay:[sc getDayFromDate:tr.trDate]];
					[components setMonth:[sc getMonthFromDate:tr.trDate]]; 
					[components setYear:[sc getYearFromDate:tr.trDate]];
					[components setHour:ee];
					[components setMinute:[c.EarliestInMinutes shortValue]];
					[components setSecond:0];
					
					NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
					NSDate *date = [gregorian dateFromComponents:components];
					[components release];
					[gregorian release];
					[tr setTrDate:date];
					timeModified = YES;
				}
			}
			else
			{
				if([tr.CostCodeId integerValue] == -2)
				{
					if([c.LatestOutHours shortValue] > 0 && [sc getHourFromDate:tr.trDate] > ll || ([sc getHourFromDate:tr.trDate] == ll && [sc getMinuteFromDate:tr.trDate] > [c.LatestOutMinutes shortValue]))
					{
						NSDateComponents *components = [[NSDateComponents alloc] init];
						[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
						
						[components setDay:[sc getDayFromDate:tr.trDate]];
						[components setMonth:[sc getMonthFromDate:tr.trDate]]; 
						[components setYear:[sc getYearFromDate:tr.trDate]];
						[components setHour:ll];
						[components setMinute:[c.LatestOutMinutes shortValue]];
						[components setSecond:0];
						
						NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
						NSDate *date = [gregorian dateFromComponents:components];
						[components release];
						[gregorian release];
						[tr setTrDate:date];
						timeModified = YES;
					}
				}
			}
			if([c.RoundMinutes shortValue] > 0)
			{
				
				tr = [self roundMinutes:[c.RoundMinutes shortValue] timeRec:tr];
				timeRounded = YES;
			}
		}
		
		if(!jobTimeLimiter && !timeModified)
		{
			int eee = [company.EarliestInAmPm shortValue];
			if([company.EarliestInAmPm shortValue] != 0)
			{
				eee = [company.EarliestInHours shortValue];
			}
			else {
				eee = [company.EarliestInHours shortValue];
			}
			
			int lll = [company.LatestOutAmPm shortValue];
			if([company.LatestOutAmPm shortValue] == 0)
			{
				lll = [company.LatestOutHours shortValue];
			}
			if([tr.CostCodeId integerValue] == -1 || [tr.CostCodeId integerValue] > 0)
			{
				if([company.EarliestInHours shortValue] > 0 && [sc getHourFromDate:tr.trDate] < eee || ([sc getHourFromDate:tr.trDate] == eee && [sc getMinuteFromDate:tr.trDate] < [company.EarliestInMinutes shortValue]))
				{
					NSDateComponents *components = [[NSDateComponents alloc] init];
					[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
					[components setDay:[sc getDayFromDate:tr.trDate]];
					[components setMonth:[sc getMonthFromDate:tr.trDate]]; 
					[components setYear:[sc getYearFromDate:tr.trDate]];
					[components setHour:eee];
					[components setMinute:[company.EarliestInMinutes shortValue]];
					[components setSecond:0];
					NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
					NSDate *date = [gregorian dateFromComponents:components];
					[components release];
					[gregorian release];
					[tr setTrDate:date];
				}
			}
			else 
			{
				if([tr.CostCodeId integerValue] == -2)
				{
					if([company.LatestOutHours shortValue] > 0 && [sc getHourFromDate:tr.trDate] > lll || ([sc getHourFromDate:tr.trDate] == lll && [sc getMinuteFromDate:tr.trDate] > [company.LatestOutMinutes shortValue]))
					{
						NSDateComponents *components = [[NSDateComponents alloc] init];
						[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
						[components setDay:[sc getDayFromDate:tr.trDate]];
						[components setMonth:[sc getMonthFromDate:tr.trDate]]; 
						[components setYear:[sc getYearFromDate:tr.trDate]];
						[components setHour:lll];
						[components setMinute:[company.LatestOutMinutes shortValue]];
						[components setSecond:0];
						NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
						NSDate *date = [gregorian dateFromComponents:components];
						[components release];
						[gregorian release];
						[tr setTrDate:date];
					}
				}
			}
			if(!timeRounded && [company.RoundMinutes shortValue] > 0)
			{
				tr = [self roundMinutes:[company.RoundMinutes shortValue] timeRec:tr];
			}
			
		}
		
	}
	// Make sure there isn't a record within the same minute. If there is, replace the old
	// earlier record's information with the new records information and leave the time
	// the same.
	[self isTimeRecordWithEmployeeExists:tr timeRecords:timeRecords];
	
}


-(TimeRecording *)roundMinutes:(NSInteger)roundMinutesTo timeRec:(TimeRecording *)timeRec
{
	int roundingPoints = 60 / roundMinutesTo;
    NSLog(@"date to round = %@", timeRec.trDate);
	for (short indx = 1; indx <= roundingPoints; indx++)
	{
		if([sc getMinuteFromDate:timeRec.trDate] <= (indx * roundMinutesTo))
		{
			if([sc getMinuteFromDate:timeRec.trDate] <= ((indx * roundMinutesTo) - (roundMinutesTo / 2)))
			{
				NSDateComponents *components = [[NSDateComponents alloc] init];
				[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
				
				[components setDay:[sc getDayFromDate:timeRec.trDate]];
				[components setMonth:[sc getMonthFromDate:timeRec.trDate]]; 
				[components setYear:[sc getYearFromDate:timeRec.trDate]];
				[components setHour:[sc getHourFromDate:timeRec.trDate]];
				[components setMinute:((indx * roundMinutesTo) - roundMinutesTo)];
				[components setSecond:0];
				NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
				NSDate *date = [gregorian dateFromComponents:components];
				[components release];
				[gregorian release];
				[timeRec setTrDate:date];
				break;
			}
			else 
			{
				if(indx == roundingPoints)
				{
					if([sc getHourFromDate:timeRec.trDate] == 23)
					{
						if([sc getDayFromDate:timeRec.trDate] == 31)
						{
							if([sc getMonthFromDate:timeRec.trDate] == 12)
							{
								NSDateComponents *components = [[NSDateComponents alloc] init];
								[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
								
								[components setDay:1];
								[components setMonth:1]; 
								[components setYear:([sc getYearFromDate:timeRec.trDate] + 1)];
								[components setHour:0];
								[components setMinute:0];
								[components setSecond:0];
								
								NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
								NSDate *date = [gregorian dateFromComponents:components];
								[components release];
								[gregorian release];
								[timeRec setTrDate:date];
								break;
							}
							else 
							{
								NSDateComponents *components = [[NSDateComponents alloc] init];
								[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
								[components setDay:1];
								[components setMonth:([sc getMonthFromDate:timeRec.trDate] + 1)]; 
								[components setYear:[sc getYearFromDate:timeRec.trDate]];
								[components setHour:0];
								[components setMinute:0];
								[components setSecond:0];
								NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
								NSDate *date = [gregorian dateFromComponents:components];
								[components release];
								[gregorian release];
								[timeRec setTrDate:date];
								break;
							}

						}
						else 
						{
							NSDateComponents *components = [[NSDateComponents alloc] init];
							[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
							[components setDay:([sc getDayFromDate:timeRec.trDate] + 1)];
							[components setMonth:[sc getMonthFromDate:timeRec.trDate]]; 
							[components setYear:[sc getYearFromDate:timeRec.trDate]];
							[components setHour:0];
							[components setMinute:0];
							[components setSecond:0];
							NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
							NSDate *date = [gregorian dateFromComponents:components];
							[components release];
							[gregorian release];
							[timeRec setTrDate:date];
							break;
						}

					}
					else 
					{
						NSDateComponents *components = [[NSDateComponents alloc] init];
						[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
						[components setDay:[sc getDayFromDate:timeRec.trDate]];
						[components setMonth:[sc getMonthFromDate:timeRec.trDate]]; 
						[components setYear:[sc getYearFromDate:timeRec.trDate]];
						[components setHour:([sc getHourFromDate:timeRec.trDate] + 1)];
						[components setMinute:0];
						[components setSecond:0];
						NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
						NSDate *date = [gregorian dateFromComponents:components];
						[components release];
						[gregorian release];
						[timeRec setTrDate:date];
						break;
					}

				}
				else 
				{
					NSDateComponents *components = [[NSDateComponents alloc] init];
					[components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
					[components setDay:[sc getDayFromDate:timeRec.trDate]];
					[components setMonth:[sc getMonthFromDate:timeRec.trDate]]; 
					[components setYear:[sc getYearFromDate:timeRec.trDate]];
					[components setHour:[sc getHourFromDate:timeRec.trDate]];
					[components setMinute:(indx * roundMinutesTo)];
					[components setSecond:0];
					NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
					NSDate *date = [gregorian dateFromComponents:components];
					[components release];
					[gregorian release];
					[timeRec setTrDate:date];
					break;
				}

			}

		}
	}
    NSLog(@"date after round = %@", timeRec.trDate);

	return timeRec;
}

-(TimeRecording *)getLastTimeRec:(NSInteger)companyId empId:(NSInteger)empId jobId:(NSInteger)jobId timeRecords:(NSArray *)timeRecords
{
	for(TimeRecording *timeRec in timeRecords)
	{
		if (timeRec != nil && [timeRec.CompanyId integerValue] == companyId && [timeRec.EmployeeId integerValue] == empId && [timeRec.CustomerId integerValue] == jobId && ([timeRec.CostCodeId integerValue] > 0 || [timeRec.CostCodeId integerValue] == -1))
		{
			return timeRec;
		}
	}
	return nil;
}

-(BOOL)isTimeRecordExists:(TimeRecordingBackup *)tr timeRecords:(NSMutableArray *)timeRecords
{
	for(TimeRecording *timeRec in timeRecords)
	{
		BOOL dates = NO;
		switch ([timeRec.trDate compare:tr.trDate]){
			case NSOrderedAscending:
				break;
			case NSOrderedSame:
				dates = YES;
				break;
			case NSOrderedDescending:
				break;
		}
				
		if (timeRec != nil && [timeRec.CompanyId integerValue] == [tr.CompanyId integerValue] && [timeRec.EmployeeId integerValue] == [tr.EmployeeId integerValue] && [timeRec.CustomerId integerValue] == [tr.CustomerId integerValue] && [timeRec.CostCodeId integerValue] == [tr.CostCodeId integerValue] && [timeRec.ClockId integerValue] == [tr.ClockId integerValue] && [timeRec.EquipmentId integerValue] == [tr.EquipmentId integerValue] && dates)
		{
			return YES;
		}
	}
	return NO;
}

-(BOOL)isTimeRecordBackupExists:(TimeRecordingBackup *)tr timeRecords:(NSMutableArray *)timeRecords
{
	for(TimeRecordingBackup *timeRec in timeRecords)
	{
		BOOL dates = NO;
		switch ([timeRec.trDate compare:tr.trDate]){
			case NSOrderedAscending:
				//NSLog(@”NSOrderedAscending”);
				break;
			case NSOrderedSame:
				//NSLog(@”NSOrderedSame”);
				dates = YES;
				break;
			case NSOrderedDescending:
				//NSLog(@”NSOrderedDescending”);
				break;
		}
		
		
		if (timeRec != nil && [timeRec.CompanyId integerValue] == [tr.CompanyId integerValue] && [timeRec.EmployeeId integerValue] == [tr.EmployeeId integerValue] && [timeRec.CustomerId integerValue] == [tr.CustomerId integerValue] && [timeRec.CostCodeId integerValue] == [tr.CostCodeId integerValue] && [timeRec.ClockId integerValue] == [tr.ClockId integerValue] && [timeRec.EquipmentId integerValue] == [tr.EquipmentId integerValue] && dates)
		{
			return YES;
		}
	}
	return NO;
}


-(void)isTimeRecordWithEmployeeExists:(TimeRecording *)tr timeRecords:(NSMutableArray *)timeRecords
{
	for(TimeRecording *timeRec in timeRecords)
	{
		BOOL dates = NO;
        NSLog(@"%@", timeRec.trDate);
        NSLog(@"%@", tr.trDate);
		switch ([timeRec.trDate compare:tr.trDate]){
			case NSOrderedAscending:
				//NSLog(@”NSOrderedAscending”);
				break;
			case NSOrderedSame:
				//NSLog(@”NSOrderedSame”);
				dates = YES;
				break;
			case NSOrderedDescending:
				//NSLog(@”NSOrderedDescending”);
				break;
		}
		
		
		if ([timeRec.EmployeeId integerValue] == [tr.EmployeeId integerValue] && dates)
		{
            NSLog(@"%d", [timeRec.CostCodeId integerValue]);
            NSLog(@"%d", [tr.CostCodeId integerValue]);
            if(!([timeRec.CostCodeId integerValue] != -2 && [tr.CostCodeId integerValue] == -2))
            {
                [timeRec setCompanyId:tr.CompanyId];
                [timeRec setClockId:tr.ClockId];
                [timeRec setCustomerId:tr.CustomerId];
                [timeRec setCostCodeId:tr.CostCodeId];
                [timeRec setEquipmentId:tr.EquipmentId];
                [timeRec setUnits:tr.Units];
                [timeRec setLatitude:tr.Latitude];
                [timeRec setLongitude:tr.Longitude];
                [timeRec setEditedByEmpId:tr.EditedByEmpId];	
            }
				
		}
	}
}



@end
