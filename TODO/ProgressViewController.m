#import "ProgressViewController.h"
#import "AddViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import "EditViewController.h"

@interface ProgressViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSArray<Task *> *allTasks;
@property (strong, nonatomic) NSArray<Task *> *lowPriorityTasks;
@property (strong, nonatomic) NSArray<Task *> *mediumPriorityTasks;
@property (strong, nonatomic) NSArray<Task *> *highPriorityTasks;

@property (assign, nonatomic) BOOL isSorted;


@end

@implementation ProgressViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSorted = NO;
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;

    
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sortButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = sortButton;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self reloadData];
}

- (void)sortButtonTapped {
    self.isSorted = !self.isSorted;

    if (self.isSorted) {
        self.navigationItem.rightBarButtonItem.title = @"UnSort";
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Sort";
    }

    [self.myTableView reloadData];
}


- (void)reloadData {
    self.allTasks = [TaskManager getProgressTasks];

    NSPredicate *lowPredicate = [NSPredicate predicateWithFormat:@"priority == 0"];
    NSPredicate *mediumPredicate = [NSPredicate predicateWithFormat:@"priority == 1"];
    NSPredicate *highPredicate = [NSPredicate predicateWithFormat:@"priority == 2"];

    self.lowPriorityTasks = [self.allTasks filteredArrayUsingPredicate:lowPredicate];
    self.mediumPriorityTasks = [self.allTasks filteredArrayUsingPredicate:mediumPredicate];
    self.highPriorityTasks = [self.allTasks filteredArrayUsingPredicate:highPredicate];

    [self.myTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isSorted ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSorted) {
        switch (section) {
            case 0: return self.highPriorityTasks.count;
            case 1: return self.mediumPriorityTasks.count;
            case 2: return self.lowPriorityTasks.count;
            default: return 0;
        }
    } else {
        return self.allTasks.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.isSorted) return @"All Tasks";
    switch (section) {
        case 0: return @"High Priority";
        case 1: return @"Normal Priority";
        case 2: return @"Low Priority";
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"pCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }


    Task *task;
    if (self.isSorted) {
        switch (indexPath.section) {
            case 0: task = self.highPriorityTasks[indexPath.row]; break;
            case 1: task = self.mediumPriorityTasks[indexPath.row]; break;
            case 2: task = self.lowPriorityTasks[indexPath.row]; break;
        }
    } else {
        task = self.allTasks[indexPath.row];
    }

    cell.textLabel.text = task.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Date: %@", task.date];

    NSString *imageName;
    switch (task.priority) {
        case 0: imageName = @"l"; break;
        case 1: imageName = @"m"; break;
        case 2: imageName = @"h"; break;
        default: imageName = @"l"; break;
    }

    UIImage *image = [UIImage imageNamed:imageName];
    CGSize itemSize = CGSizeMake(36, 36);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0);
    [image drawInRect:CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return cell;
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
   trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

   UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"Delete"
                                                                             handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {

       Task *task = [self getTaskForIndexPath:indexPath];
       [self showDeleteAlert:task];
       completionHandler(YES);
   }];

   return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

-(void) showDeleteAlert : (Task*)task{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Task Deletion"
                                                                   message:@"Are You Want to Delete This Task"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [TaskManager deleteTaskWithTitle:task.name];
        [self reloadData];

    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

    UIContextualAction *editStatusAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                   title:@"Move to Done"
                                                                                 handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {

        Task *task = [self getTaskForIndexPath:indexPath];
        task.status = @"done";
        [TaskManager editTaskWithTitle:task.name updatedTask:task];
        [self reloadData];
        completionHandler(YES);
    }];
    editStatusAction.backgroundColor = [UIColor systemGreenColor];

    return [UISwipeActionsConfiguration configurationWithActions:@[editStatusAction]];
}

- (Task *)getTaskForIndexPath:(NSIndexPath *)indexPath {
    if (!self.isSorted) {
        return self.allTasks[indexPath.row];
    }
    switch (indexPath.section) {
        case 0: return self.highPriorityTasks[indexPath.row];
        case 1: return self.mediumPriorityTasks[indexPath.row];
        case 2: return self.lowPriorityTasks[indexPath.row];
        default: return nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Task *task = [self getTaskForIndexPath:indexPath];

    EditViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"edit"];
    editVC.task = task;
    editVC.isTodo = NO;
    
    editVC.editDataBlock = ^{
        [self reloadData];
    };
    
    editVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:editVC animated:YES];
}



@end
