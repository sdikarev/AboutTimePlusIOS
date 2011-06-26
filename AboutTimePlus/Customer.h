//
//  Customer.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Customer : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Active;
@property (nonatomic, retain) NSString * Address;
@property (nonatomic, retain) NSString * City;
@property (nonatomic, retain) NSString * Code;
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSNumber * CustomerId;
@property (nonatomic, retain) NSNumber * EarliestInAmPm;
@property (nonatomic, retain) NSNumber * EarliestInHours;
@property (nonatomic, retain) NSNumber * EarliestInMinutes;
@property (nonatomic, retain) NSDate * LatestOut;
@property (nonatomic, retain) NSNumber * LatestOutAmPm;
@property (nonatomic, retain) NSNumber * LatestOutHours;
@property (nonatomic, retain) NSNumber * LatestOutMinutes;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSNumber * ParentId;
@property (nonatomic, retain) NSNumber * RoundMinutes;
@property (nonatomic, retain) NSNumber * SortOrder;
@property (nonatomic, retain) NSString * State;

@end
