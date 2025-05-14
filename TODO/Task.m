//
//  Task.m
//  TODO
//
//  Created by Abdelrahman on 06/05/2025.
//

#import "Task.h"

@implementation Task

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.status forKey:@"status"];
    [coder encodeObject:self.desc forKey:@"desc"];
    [coder encodeInt:self.priority forKey:@"priority"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.time forKey:@"time"];
    [coder encodeObject:self.color forKey:@"color"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.status = [coder decodeObjectOfClass:[NSString class] forKey:@"status"];
        self.desc = [coder decodeObjectOfClass:[NSString class] forKey:@"desc"];
        self.priority = [coder decodeIntForKey:@"priority"];
        self.date = [coder decodeObjectOfClass:[NSString class] forKey:@"date"];
        self.time = [coder decodeObjectOfClass:[NSString class] forKey:@"time"];
        self.color = [coder decodeObjectOfClass:[NSURL class] forKey:@"color"];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                        desc:(NSString *)desc
                    priority:(NSInteger)priority
                     dueDate:(NSDate *)dueDate {
    if (self = [super init]) {
        self.name = title;
        self.desc = desc;
        self.priority = priority;
        self.date = [NSDateFormatter localizedStringFromDate:dueDate
                                                   dateStyle:NSDateFormatterShortStyle
                                                   timeStyle:NSDateFormatterShortStyle];
        self.time = [NSDateFormatter localizedStringFromDate:dueDate
                                                   dateStyle:NSDateFormatterNoStyle
                                                   timeStyle:NSDateFormatterShortStyle];
        self.status = @"todo";
        self.color = nil;
    }
    return self;
}

@end

