//
//  EquipmentUse.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
