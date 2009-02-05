#import "AlocolaViewController.h"

#define LABEL_TAG 1 
#define VALUE_TAG 2 

@implementation AlocolaViewController

- (void)viewDidLoad { 	
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc {
	[locationTableView release];
	[statusActivityIndicatorView release];
	[statusLabel release];
	[locationController release];
	[currentLocation release];	
	[config release];
	[super dealloc];
	
	
}

// MyCLControllerDelegate Related

- (void)locationUpdate:(CLLocation *)location {
	[currentLocation release];
	currentLocation = [location retain];
	
	[locationTableView reloadData];
	[self handleLocation]; 
}

- (void)userDeniedLocationAccess {
	statusLabel.text = @"Location Access Denied";
}

// Protocol Handler Related

- (void)handleURL:(NSURL *)url {
	[config release];
	config = [[url dictionaryFromParameterString] retain];

	NSURL *queryUrl = [config objectForKey:@"url"] ? [[NSURL alloc] initWithString:[config objectForKey:@"url"]] : nil;
	
	UIAlertView *alertView;
	
	if (queryUrl) 
		alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\"%@\" would like to use your current location", [queryUrl host]] message:nil delegate:self cancelButtonTitle:@"Don't Allow" otherButtonTitles:@"OK", nil];
	else {
		config = nil;
		alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Invalid or missing URL" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	}
		
	[alertView show];
	[alertView release];		
}

// UIAlertViewDelegate Releated

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[config setObject: [NSNumber numberWithBool:YES] forKey: @"permission"];
		[self handleLocation];
	} else
		config = nil;
}

// UITableViewDataSource and UITableViewDelegate Related

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *myIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
	UILabel *label, *value;
	
	if (cell == nil) {
		CGRect frame = CGRectMake(0, 0, 300, 44); 
		
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:myIdentifier] autorelease]; 
		cell.selectionStyle = UITableViewCellSelectionStyleNone; 
		
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 12.0, 70.0, 25.0)] autorelease];
		label.tag = LABEL_TAG; 
		label.font = [UIFont systemFontOfSize:12.0]; 
		label.textAlignment = UITextAlignmentRight; 
		label.textColor = [UIColor blueColor]; 
		label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight; 
		[cell.contentView addSubview:label]; 
		
		value = [[[UILabel alloc] initWithFrame:CGRectMake(75, 12.0, 200.0, 25.0)] autorelease]; 
		value.tag = VALUE_TAG;
		value.textColor = [UIColor blackColor]; 
		value.lineBreakMode = UILineBreakModeWordWrap; 
		value.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
		[cell.contentView addSubview:value]; 
	} else { 
		label = (UILabel *)[cell.contentView viewWithTag:LABEL_TAG]; 
		value = (UILabel *)[cell.contentView viewWithTag:VALUE_TAG]; 
	} 
			
	switch (indexPath.row) {
		case 0:
			label.text = @"Longitude";
			value.text =  currentLocation == nil ? @"" : [NSString stringWithFormat:@"%f°", currentLocation.coordinate.longitude];
			break;
		case 1:
			label.text = @"Latitude";
			value.text = currentLocation == nil ? @"" : [NSString stringWithFormat:@"%f°", currentLocation.coordinate.latitude];
			break;
		case 2:
			label.text = @"Altitude";
			value.text = currentLocation == nil || currentLocation.verticalAccuracy == -1 ? @"" : (ENGLISH_UNITS ? [NSString stringWithFormat:@"%.0f feet", currentLocation.altitude * 3.28083989501312] : [NSString stringWithFormat:@"%.0f meters", currentLocation.altitude]);
			break;
		case 3:
			label.text = @"Speed";
			value.text = currentLocation == nil || currentLocation.speed == -1 ? @"" :  (ENGLISH_UNITS ? [NSString stringWithFormat:@"%.0f mph", currentLocation.speed * 2.2369362920544] : [NSString stringWithFormat:@"%.0f kph", currentLocation.speed * 3.6]);
			break;
		case 4:
			label.text = @"Course";
			value.text = currentLocation == nil || currentLocation.course == -1 ? @"" : [NSString stringWithFormat:@"%.0f°", currentLocation.course];
			break;
		case 5:
			label.text = @"H Accuracy";
			value.text = currentLocation == nil ? @"" : (ENGLISH_UNITS ? [NSString stringWithFormat:@"%.0f feet", currentLocation.horizontalAccuracy * 3.28083989501312] : [NSString stringWithFormat:@"%.0f meters", currentLocation.horizontalAccuracy]);
			break;
		case 6:
			label.text = @"V Accuracy";
			value.text = currentLocation == nil || currentLocation.verticalAccuracy == -1 ? @"" : (ENGLISH_UNITS ? [NSString stringWithFormat:@"%.0f feet", currentLocation.verticalAccuracy * 3.28083989501312] : [NSString stringWithFormat:@"%.0f meters", currentLocation.verticalAccuracy]);
			break;		
	}
		
	return cell;
}

- (void)handleLocation {		
	if (currentLocation) {
		if (config == nil) {
			[statusActivityIndicatorView stopAnimating];
			statusLabel.hidden = TRUE;
		} else if ([config objectForKey:@"permission"] && 
				   (! [[config objectForKey:@"horizontalAccuracy"] doubleValue] || currentLocation.horizontalAccuracy <= [[config objectForKey:@"horizontalAccuracy"] doubleValue]) && 
				   (! [[config objectForKey:@"verticalAccuracy"] doubleValue] || currentLocation.verticalAccuracy <= [[config objectForKey:@"verticalAccuracy"] doubleValue])) {
			
			NSString *urlString = [config objectForKey:@"url"];
			
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_altitude_" withString: [NSString stringWithFormat:@"%f", currentLocation.altitude]];
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_course_" withString: [NSString stringWithFormat:@"%f", currentLocation.course]];
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_horizontalAccuracy_" withString: [NSString stringWithFormat:@"%f", currentLocation.horizontalAccuracy]];
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_latitude_" withString: [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude]];
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_longitude_" withString: [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude]];
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_speed_" withString: [NSString stringWithFormat:@"%f", currentLocation.speed]];
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_timestamp_" withString: [[currentLocation.timestamp description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			urlString = [urlString stringByReplacingOccurrencesOfString: @"_verticalAccuracy_" withString: [NSString stringWithFormat:@"%f", currentLocation.verticalAccuracy]];
			
			NSURL *u = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:u];				
		}		
	}
}

@end
