#import "EditViewController.h"
#import "Task.h"
#import "TaskManager.h"

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface EditViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *descField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegm;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegm;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateTimePicker;
@property (weak, nonatomic) IBOutlet UIButton *openFielButton;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;

@property (strong, nonatomic) NSURL *attachedFileURL;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;


@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _descField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _descField.layer.borderWidth = 1.0;
    _descField.layer.cornerRadius = 8.0;
    _descField.clipsToBounds = YES;
    
    UIView *segmentView = [self.statusSegm.subviews lastObject];
    
    
    if(self.isTodo == NO){
        segmentView.userInteractionEnabled = NO;
    }
    
    _titleField.text = self.task.name;
    _descField.text = self.task.desc;
    
    _prioritySegm.selectedSegmentIndex = self.task.priority;

    if ([self.task.status.lowercaseString isEqualToString:@"todo"]) {
        self.statusSegm.selectedSegmentIndex = 0;
    } else if ([self.task.status.lowercaseString isEqualToString:@"progress"]) {
        self.statusSegm.selectedSegmentIndex = 1;
    } else if ([self.task.status.lowercaseString isEqualToString:@"done"]) {
        self.statusSegm.selectedSegmentIndex = 2;
    }
    
    if(self.task.color){
        _attachedFileURL = _task.color;
        _filenameLabel.text = [_task.color lastPathComponent];
        _openFielButton.hidden = NO;
        _closeButton.hidden = NO;
    }
    else{
        _openFielButton.hidden = YES;
        _closeButton.hidden = YES;

    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSDate *parsedDate = [formatter dateFromString:self.task.date];
    if (parsedDate) {
       _dateTimePicker.date = parsedDate;
    }

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)editButtonTapped {
    NSLog(@"Save button tapped");


    NSString *taskDesc = [self.descField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSInteger priorityIndex = self.prioritySegm.selectedSegmentIndex;
    NSInteger statusIndex = self.statusSegm.selectedSegmentIndex;
    NSDate *dueDate = self.dateTimePicker.date;

    if (taskDesc.length == 0) {
        [self showAlertWithTitle:@"Error" message:@"description must not be empty or just spaces."];
        return;
    }


    self.task.desc = taskDesc;
    self.task.priority = priorityIndex;
    
    self.task.date = [NSDateFormatter localizedStringFromDate:dueDate
                                               dateStyle:NSDateFormatterShortStyle
                                               timeStyle:NSDateFormatterShortStyle];
    
    switch (statusIndex) {
        case 1:
            self.task.status = @"progress";
            break;
        case 2:
            self.task.status = @"done";
            break;
        default:
            self.task.status = @"todo";
            break;
    }
    
    self.task.color = _attachedFileURL;
    
    [TaskManager editTaskWithTitle:self.task.name updatedTask:self.task];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:@"Task Updated successfully!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        if (self.editDataBlock) {
            self.editDataBlock();
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
    _openFielButton.hidden = NO;
    _closeButton.hidden = NO;

}

- (IBAction)openFileinSystem:(id)sender {
    [self openFileFromURL:self.attachedFileURL];
}

- (void)openFileFromURL:(NSURL *)fileURL {
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentInteractionController.delegate = self;
    [self.documentInteractionController presentPreviewAnimated:YES];
}


- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (IBAction)removeFileAttach:(id)sender {
    _attachedFileURL = nil;
    _filenameLabel.text = @"No File Attached";
    _openFielButton.hidden = YES;
    _closeButton.hidden = YES;
    
}



@end
