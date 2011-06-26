//
//  EquipmentUse.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EquipmentUse : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSNumber * costCodeId;
@property (nonatomic, retain) NSDate * equDate;
@property (nonatomic, retain) NSNumber * equipmentId;
@property (nonatomic, retain) NSNumber * hours;
@property (nonatomic, retain) NSNumber * jobId;
@property (nonatomic, retain) NSNumber * mileage;
@property (nonatomic, retain) NSString * note;

@end
