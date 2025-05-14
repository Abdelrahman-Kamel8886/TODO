



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ReloadDataBlock)(void);

@interface AddViewController : UIViewController<UIDocumentPickerDelegate>

@property (nonatomic, copy) ReloadDataBlock reloadDataBlock;

@end

NS_ASSUME_NONNULL_END
