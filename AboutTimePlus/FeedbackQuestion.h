//
//  FeedbackQuestion.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FeedbackQuestion : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Active;
@property (nonatomic, retain) NSNumber * FeedbackQuestionId;
@property (nonatomic, retain) NSNumber * FeedbackType;
@property (nonatomic, retain) NSNumber * ItemOrder;
@property (nonatomic, retain) NSString * Question;

@end
