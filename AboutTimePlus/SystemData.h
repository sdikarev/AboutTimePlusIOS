//
//  SystemData.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SystemData : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * JobCostCodeBudgetCapable;
@property (nonatomic, retain) NSNumber * JobPhotosCapable;
@property (nonatomic, retain) NSNumber * NumPinKeys;
@property (nonatomic, retain) NSNumber * PenSignatureCapable;
@property (nonatomic, retain) NSNumber * WorkOrdersCapable;

@end
