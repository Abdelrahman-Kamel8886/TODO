#import "ViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import "AddViewController.h"
#import "EditViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<Task *> *lowPriorityTasks;
@property (strong, nonatomic) NSArray<Task *> *mediumPriorityTasks;
@property (strong, nonatomic) NSArray<Task *> *highPriorityTasks;

@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;

@property (strong, nonatomic) NSArray<Task *> *allTasks;
@property (strong, nonatomic) NSArray<Task *> *filteredTasks;
@property (assign, nonatomic) BOOL isSearching;


@property (strong, nonatomic) UIImageView *placeholderImageView;
@property (strong, nonatomic) UILabel *placeholderLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                             target:self
                             action:@selector(addTaskTapped)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.mySearchBar.delegate = self;
    self.isSearching = NO;
    
    [self setupPlaceholderViews];
    [self reloadData];

}

- (void)setupPlaceholderViews {
    // Create and configure placeholder image view
    self.placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    self.placeholderImageView.image = [UIImage imageNamed:@"p"];
    self.placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;

    self.placeholderImageView.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    [self.view addSubview:self.placeholderImageView];

    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.placeholderLabel.text = @"No tasks yet";
    self.placeholderLabel.font = [UIFont systemFontOfSize:24];
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
    [self.placeholderLabel sizeToFit];

    // Position label below image
    self.placeholderLabel.center = CGPointMake(self.view.center.x, CGRectGetMaxY(self.placeholderImageView.frame) + 0);
    [self.view addSubview:self.placeholderLabel];

    // Hide by default
    self.placeholderImageView.hidden = YES;
    self.placeholderLabel.hidden = YES;
}



- (void)addTaskTapped {
    AddViewController *addVC = [self.storyboard instantiateViewControllerWithIdentifier:@"add"];
    addVC.reloadDataBlock = ^{
        [self reloadData];
    };
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)updatePlaceholderVisibility {
    BOOL isEmpty = self.isSearching ? self.filteredTasks.count == 0 : self.allTasks.count == 0;
    self.placeholderImageView.hidden = !isEmpty;
    self.placeholderLabel.hidden = !isEmpty;
}


- (void)reloadData {
    self.allTasks = [TaskManager getTodoTasks];

    NSPredicate *lowPredicate = [NSPredicate predicateWithFormat:@"priority == 0"];
    NSPredicate *mediumPredicate = [NSPredicate predicateWithFormat:@"priority == 1"];
    NSPredicate *highPredicate = [NSPredicate predicateWithFormat:@"priority == 2"];

    self.lowPriorityTasks = [self.allTasks filteredArrayUsingPredicate:lowPredicate];
    self.mediumPriorityTasks = [self.allTasks filteredArrayUsingPredicate:mediumPredicate];
    self.highPriorityTasks = [self.allTasks filteredArrayUsingPredicate:highPredicate];

    [self.tableView reloadData];
    [self updatePlaceholderVisibility];

}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.isSearching = NO;
    } else {
        self.isSearching = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        self.filteredTasks = [self.allTasks filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.filteredTasks = self.allTasks;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isSearching ? 1 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.filteredTasks.count;
    }

    switch (section) {
        case 0: return self.highPriorityTasks.count;
        case 1: return self.mediumPriorityTasks.count;
        case 2: return self.lowPriorityTasks.count;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.allTasks.count == 0) {
        return nil;
    }
    
    else if (self.isSearching) return @"Search Results";

    switch (section) {
        case 0: return @"High Priority";
        case 1: return @"Normal Priority";
        case 2: return @"Low Priority";
        default: return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TaskCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    Task *task;
    if (self.isSearching) {
        task = self.filteredTasks[indexPath.row];
    } else {
        switch (indexPath.section) {
            case 0: task = self.highPriorityTasks[indexPath.row]; break;
            case 1: task = self.mediumPriorityTasks[indexPath.row]; break;
            case 2: task = self.lowPriorityTasks[indexPath.row]; break;
        }
    }

    cell.textLabel.text = task.name;
   // cell.detailTextLabel.text = [NSString stringWithFormat:@"Date: %@", task.date];

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

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
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
                                                                                   title:@"Move to In Progress"
                                                                                 handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {

        Task *task = [self getTaskForIndexPath:indexPath];
        task.status = @"progress";
        [TaskManager editTaskWithTitle:task.name updatedTask:task];
        [self reloadData];
        completionHandler(YES);
    }];
    editStatusAction.backgroundColor = [UIColor systemGreenColor];

    return [UISwipeActionsConfiguration configurationWithActions:@[editStatusAction]];
}
- (Task *)getTaskForIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        return self.filteredTasks[indexPath.row];
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
    editVC.isTodo = YES;

    editVC.editDataBlock = ^{
        [self reloadData];
    };
    
    editVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:editVC animated:YES];
}


@end
