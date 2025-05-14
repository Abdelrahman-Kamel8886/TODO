//
//  Task.h
//  TODO
//
//  Created by Abdelrahman on 06/05/2025.
//

#ifndef Task_h
#define Task_h


#endif /* Task_h */

#import <Foundation/Foundation.h>

@interface Task : NSObject<NSSecureCoding>

@property NSString *name;
@property NSString *status;
@property NSString *desc;
@property int priority;
@property NSString *date;
@property NSString *time;
@property NSURL *color;

- (instancetype)initWithTitle:(NSString *)title
                        desc:(NSString *)desc
                    priority:(NSInteger)priority
                     dueDate:(NSDate *)dueDate;


@end
