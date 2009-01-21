#import <UIKit/UIKit.h>

@class AlocolaViewController;

@interface AlocolaAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AlocolaViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AlocolaViewController *viewController;

@end

