//
//  AppSettings.h
//  FieldClock
//
//  Created by Bartimeus on 18.07.10.
//  Copyright 2010 Incoding.biz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppSettings : NSObject {
	
	NSString *accountNumber;
    NSString *clockName;
    NSInteger lastEmpIDList;
    NSInteger clockId;
    BOOL gpsEnabled;
	BOOL isAutoSync;
	NSString *myServer;
	NSString *myPort;
	NSInteger fontSize;
}
@property (nonatomic, retain) NSString *accountNumber;
@property (nonatomic, retain) NSString *clockName;
@property (nonatomic) NSInteger lastEmpIDList;
@property (nonatomic) NSInteger clockId;
@property (nonatomic) BOOL gpsEnabled;
@property (nonatomic) BOOL isAutoSync;
@property (nonatomic, retain) NSString *myServer;
@property (nonatomic, retain) NSString *myPort;
@property (nonatomic)  NSInteger fontSize;
@end
