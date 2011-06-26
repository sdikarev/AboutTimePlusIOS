//
//  AppSettings.m
//  FieldClock
//
//  Created by Bartimeus on 18.07.10.
//  Copyright 2010 Incoding.biz. All rights reserved.
//

#import "AppSettings.h"


@implementation AppSettings
@synthesize accountNumber, clockName, lastEmpIDList, clockId, gpsEnabled, myServer, myPort, fontSize, isAutoSync;

- (id) init {
	if(self = [super init]) {
		accountNumber = @"";
		clockName = @"";
		myServer = @"";
		myPort = @"";
		fontSize = 10;
	}
	
	return self;
}

- (void) dealloc {
	[accountNumber release];
	[clockName release];
	[myServer release];
	[myPort release];
	[super dealloc];
}

- (id) initWithCoder:(NSCoder *)coder {
	accountNumber = [[coder decodeObjectForKey:@"accountNumber"] retain];
	clockName = [[coder decodeObjectForKey:@"clockName"] retain];
	myServer = [[coder decodeObjectForKey:@"myServer"] retain];
	myPort = [[coder decodeObjectForKey:@"myPort"] retain];
	lastEmpIDList = [coder decodeIntegerForKey:@"lastEmpIDList"];
	clockId =[coder decodeIntegerForKey:@"clockId"];
	gpsEnabled = (BOOL)[coder decodeBoolForKey:@"gpsEnabled"];
	isAutoSync = (BOOL)[coder decodeBoolForKey:@"isAutoSync"];
	fontSize =[coder decodeIntegerForKey:@"fontSize"];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:accountNumber forKey:@"accountNumber"];
	[encoder encodeObject:clockName forKey:@"clockName"];
	[encoder encodeObject:myServer forKey:@"myServer"];
	[encoder encodeObject:myPort forKey:@"myPort"];
	[encoder encodeInteger:lastEmpIDList forKey:@"lastEmpIDList"];
	[encoder encodeInteger:clockId forKey:@"clockId"];
	[encoder encodeBool:gpsEnabled forKey:@"gpsEnabled"];
	[encoder encodeBool:isAutoSync forKey:@"isAutoSync"];
	[encoder encodeInteger:fontSize forKey:@"fontSize"];
}
@end
