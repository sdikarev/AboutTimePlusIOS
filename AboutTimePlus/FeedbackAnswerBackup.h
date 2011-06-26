//
//  FeedbackAnswerBackup.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FeedbackAnswerBackup : NSManagedObject {
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
