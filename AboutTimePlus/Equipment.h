//
//  Equipment.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Equipment : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Active;
@property (nonatomic, retain) NSString * Code;
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSNumber * EquipmentId;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSNumber * ParentId;
@property (nonatomic, retain) NSNumber * SortOrder;

@end
