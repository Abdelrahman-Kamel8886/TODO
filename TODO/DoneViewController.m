//
//  DoneViewController.m
//  TODO
//
//  Created by Abdelrahman on 07/05/2025.
//

#import "DoneViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import "DetailsViewController.h"
#import "DoneCustomCell.h"

@interface DoneViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray<Task *> *allTasks;
@property (strong, nonatomic) NSArray<Task *> *lowPriorityTasks;
@property (strong, nonatomic) NSArray<Task *> *mediumPriorityTasks;
@property (strong, nonatomic) NSArray<Task *> *highPriorityTasks;

@property (assign, nonatomic) BOOL isSorted;

@end

@implementation DoneViewController

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
    
    _myTableView.rowHeight=52;

    
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
    self.allTasks = [TaskManager getDoneTasks];

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
    
    DoneCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dCell" forIndexPath:indexPath];

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

    cell.myCellLabel.text = [NSString stringWithFormat:@"%@", task.name];
    

    NSString *imageName;
    switch (task.priority) {
        case 0: imageName = @"l"; break;
        case 1: imageName = @"m"; break;
        case 2: imageName = @"h"; break;
        default: imageName = @"l"; break;
    }

    UIImage *image = [UIImage imageNamed:imageName];
    cell.myCellImageView.image = image;

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

    DetailsViewController *dVC = [self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    
    dVC.task = task;
    
    dVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:dVC animated:YES];
}

@end
