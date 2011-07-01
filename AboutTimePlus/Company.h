//
//  Company.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Company : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSString * customList1Label;
@property (nonatomic, retain) NSString * customList2Label;
@property (nonatomic, retain) NSString * customList3Label;
@property (nonatomic, retain) NSNumber * EarliestInAmPm;
@property (nonatomic, retain) NSNumber * EarliestInHours;
@property (nonatomic, retain) NSNumber * EarliestInMinutes;
@property (nonatomic, retain) NSNumber * forceEmployeeSync;
@property (nonatomic, retain) NSNumber * LatestOutAmPm;
@property (nonatomic, retain) NSNumber * LatestOutHours;
@property (nonatomic, retain) NSNumber * LatestOutMinutes;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSNumber * RoundMinutes;
@property (nonatomic, retain) NSNumber * TrackPerDiem;
@property (nonatomic, retain) NSNumber * useCustomList1;
@property (nonatomic, retain) NSNumber * useCustomList2;
@property (nonatomic, retain) NSNumber * useCustomList3;
@property (nonatomic, retain) NSNumber * UseGPS;

@end
