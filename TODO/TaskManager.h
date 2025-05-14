#import <Foundation/Foundation.h>
#import "Task.h"

@interface TaskManager : NSObject

+ (void)addTask:(Task *)task;
+ (void)editTaskWithTitle:(NSString *)title updatedTask:(Task *)updatedTask;
+ (void)deleteTaskWithTitle:(NSString *)title;
+ (NSArray<Task *> *)getAllTasks;

+ (NSArray<Task *> *)getTodoTasks;
+ (NSArray<Task *> *)getProgressTasks;
+ (NSArray<Task *> *)getDoneTasks;
+ (BOOL)isTaskNameExists:(NSString *)taskName;

@end
