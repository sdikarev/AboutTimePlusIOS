//
//  FieldNoteBackup.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FieldNoteBackup : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSNumber * CustomerId;
@property (nonatomic, retain) NSNumber * EmployeeId;
@property (nonatomic, retain) NSDate * fnDate;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSData * NoteData;
@property (nonatomic, retain) NSNumber * NoteType;

@end
