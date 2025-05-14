//
//  EditViewController.h
//  TODO
//
//  Created by Abdelrahman on 07/05/2025.
//

#import <UIKit/UIKit.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^EditDataBlock)(void);

@interface EditViewController : UIViewController<UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate>

@property Task *task;
@property (nonatomic, copy) EditDataBlock editDataBlock;
@property Boolean isTodo;

@end

NS_ASSUME_NONNULL_END
