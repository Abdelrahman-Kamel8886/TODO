//
//  DetailsViewController.m
//  TODO
//
//  Created by Abdelrahman on 07/05/2025.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegm;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateTimePicker;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _descField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _descField.layer.borderWidth = 1.0;
    _descField.layer.cornerRadius = 8.0;
    _descField.clipsToBounds = YES;
    
    _titleLabel.text = self.task.name;
    _descField.text = self.task.desc;
    _prioritySegm.selectedSegmentIndex = self.task.priority;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSDate *parsedDate = [formatter dateFromString:self.task.date];
    if (parsedDate) {
       _dateTimePicker.date = parsedDate;
    }


}


@end
