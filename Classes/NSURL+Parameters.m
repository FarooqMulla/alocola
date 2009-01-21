#import "NSURL+Parameters.h";

@implementation NSURL (Parameters)
- (NSMutableDictionary *)dictionaryFromParameterString {
	NSMutableDictionary* result = [NSMutableDictionary dictionary];
	NSArray* pairs = [[self query] componentsSeparatedByString:@"&"];
	for (NSString * pair in pairs) {
		NSRange firstEqual = [pair rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
		if (firstEqual.location==NSNotFound) {
			continue;
		}
		NSString *key = [pair substringToIndex:firstEqual.location];
		NSString *value = [pair substringFromIndex:firstEqual.location+1];
		[result setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
				   forKey:[key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	return result;
}
@end