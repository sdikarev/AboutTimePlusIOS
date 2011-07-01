//
//  FeedbackAnswer.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FeedbackAnswer : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Answer;
@property (nonatomic, retain) NSNumber * ClockId;
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSNumber * DoubleAnswer;
@property (nonatomic, retain) NSNumber * EmployeeId;
@property (nonatomic, retain) NSDate * faDate;
@property (nonatomic, retain) NSNumber * QuestionId;

@end
