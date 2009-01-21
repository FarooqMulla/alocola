#import <UIKit/UIKit.h>
#import "MyCLController.h"
#import "NSURL+Parameters.h"

#define ENGLISH_UNITS [[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_US"]

@interface AlocolaViewController : UIViewController <MyCLControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
	IBOutlet UITableView *locationTableView;
	IBOutlet UIActivityIndicatorView *statusActivityIndicatorView;
	IBOutlet UILabel *statusLabel;
	MyCLController *locationController;
	CLLocation *currentLocation;
	NSMutableDictionary *config;
}

- (void)handleURL:(NSURL *)url;
- (void)handleLocation;

@end

