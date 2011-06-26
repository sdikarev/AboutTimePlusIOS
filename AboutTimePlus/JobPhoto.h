//
//  JobPhoto.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JobPhoto : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSNumber * EmployeeId;
@property (nonatomic, retain) NSString * ImagePath;
@property (nonatomic, retain) NSNumber * JobId;
@property (nonatomic, retain) NSDate * jpDate;
@property (nonatomic, retain) NSString * Title;

@end
