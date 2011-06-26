//
//  CustomList.h
//  AboutTimePlus
//
//  Created by Bartimeus on 26.06.11.
//  Copyright (c) 2011 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomList : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * CompanyId;
@property (nonatomic, retain) NSNumber * CustomListId;
@property (nonatomic, retain) NSNumber * CustomListType;
@property (nonatomic, retain) NSString * Name;

@end
