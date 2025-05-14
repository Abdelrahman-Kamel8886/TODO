#import "AddViewController.h"
#import "TaskManager.h"
#import "Task.h"
#import <UserNotifications/UserNotifications.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <MobileCoreServices/MobileCoreServices.h>



@interface AddViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataTimePicker;
@property (weak, nonatomic) IBOutlet UITextView *descField;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (strong, nonatomic) NSURL *attachedFileURL;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;


@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _descField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _descField.layer.borderWidth = 1.0;
    _descField.layer.cornerRadius = 8.0;
    _descField.clipsToBounds = YES;
    
    self.dataTimePicker.minimumDate = [NSDate date];

    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(saveButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)saveButtonTapped {
    NSLog(@"Save button tapped");

    NSString *taskTitle = [self.titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *taskDesc = [self.descField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger priorityIndex = self.prioritySegment.selectedSegmentIndex;
    NSDate *dueDate = self.dataTimePicker.date;

    if (taskTitle.length == 0 || taskDesc.length == 0) {
        [self showAlertWithTitle:@"Error" message:@"Title and description must not be empty or just spaces."];
        return;
    }

    if ([TaskManager isTaskNameExists:taskTitle]) {
        [self showAlertWithTitle:@"Error" message:@"A task with the same name already exists."];
        return;
    }

    Task *newTask = [[Task alloc] initWithTitle:taskTitle
                                           desc:taskDesc
                                       priority:priorityIndex
                                        dueDate:dueDate];
    
    newTask.color = self.attachedFileURL;

    [TaskManager addTask:newTask];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:@"Task saved successfully!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        if (self.reloadDataBlock) {
            self.reloadDataBlock();
        }
        if(self.reminderSwitch.isOn){
            [self scheduleNotificationWithTitle:newTask.name message:@"Your task is due soon!"];
        }
        [self.navigationController popViewControllerAnimated:YES];
    
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)scheduleNotificationWithTitle:(NSString *)title message:(NSString *)message {
    NSDate *selectedDate = self.dataTimePicker.date;
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = message;
    content.sound = [UNNotificationSound defaultSound];
    
    NSDateComponents *triggerDate = [[NSCalendar currentCalendar]
        components:(NSCalendarUnitYear |
                    NSCalendarUnitMonth |
                    NSCalendarUnitDay |
                    NSCalendarUnitHour |
                    NSCalendarUnitMinute |
                    NSCalendarUnitSecond)
        fromDate:selectedDate];

    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:triggerDate
                                                                                                      repeats:NO];
    
    NSString *identifier = @"customNotification";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content
                                                                          trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error scheduling notification: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)attachFileTapped:(id)sender {
    UIDocumentPickerViewController *picker;

    picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];

    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *selectedFileURL = [urls firstObject];
    self.attachedFileURL = selectedFileURL;
    _filenameLabel.text = [self.attachedFileURL lastPathComponent];
}






@end
