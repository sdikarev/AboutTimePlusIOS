//
//  CustomList.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 01.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
