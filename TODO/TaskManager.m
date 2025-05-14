#import "TaskManager.h"

@implementation TaskManager

+ (NSUserDefaults *)defaults {
    return [NSUserDefaults standardUserDefaults];
}

+ (NSString *)tasksKey {
    return @"tasks";
}

+ (NSMutableArray<Task *> *)loadTasks {
    NSData *data = [[self defaults] objectForKey:[self tasksKey]];
    if (data) {
        NSSet *classes = [NSSet setWithObjects:[NSArray class], [Task class], nil];
        NSArray *savedTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:nil];
        return [savedTasks mutableCopy];
    }
    return [NSMutableArray array];
}

+ (void)saveTasks:(NSArray<Task *> *)tasks {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tasks requiringSecureCoding:YES error:nil];
    [[self defaults] setObject:data forKey:[self tasksKey]];
    [[self defaults] synchronize];
}

+ (void)addTask:(Task *)task {
    NSMutableArray *tasks = [self loadTasks];
    [tasks addObject:task];
    [self saveTasks:tasks];
}

+ (void)editTaskWithTitle:(NSString *)title updatedTask:(Task *)updatedTask {
    NSMutableArray *tasks = [self loadTasks];
    for (int i = 0; i < tasks.count; i++) {
        Task *task = tasks[i];
        if ([task.name isEqualToString:title]) {
            tasks[i] = updatedTask;
            break;
        }
    }
    [self saveTasks:tasks];
}

+ (void)deleteTaskWithTitle:(NSString *)title {
    NSMutableArray *tasks = [self loadTasks];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@", title];
    NSArray *filtered = [tasks filteredArrayUsingPredicate:predicate];
    [self saveTasks:filtered];
}

+ (NSArray<Task *> *)getAllTasks {
    return [self loadTasks];
}

+ (NSArray<Task *> *)getTodoTasks {
    return [self filterTasksByStatus:@"todo"];
}

+ (NSArray<Task *> *)getProgressTasks {
    return [self filterTasksByStatus:@"progress"];
}

+ (NSArray<Task *> *)getDoneTasks {
    return [self filterTasksByStatus:@"done"];
}

+ (NSArray<Task *> *)filterTasksByStatus:(NSString *)status {
    NSArray<Task *> *allTasks = [self loadTasks];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status ==[c] %@", status];
    return [allTasks filteredArrayUsingPredicate:predicate];
}

+ (BOOL)isTaskNameExists:(NSString *)taskName {
    NSArray<Task *> *allTasks = [self getTodoTasks];
    for (Task *task in allTasks) {
        if ([task.name isEqualToString:taskName]) {
            return YES;
        }
    }
    return NO;
}


@end

