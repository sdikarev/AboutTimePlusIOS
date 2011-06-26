//
//  Clock.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Clock : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * BatteryStatus;
@property (nonatomic, retain) NSNumber * ClockId;
@property (nonatomic, retain) NSString * ClockName;
@property (nonatomic, retain) NSString * CrewName;
@property (nonatomic, retain) NSNumber * ForemanId;
@property (nonatomic, retain) NSNumber * GPSEnabled;

@end
