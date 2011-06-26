#import "AboutTimePlusAppDelegate.h"
//#define TOOLBAR_BACKGROUND [UIImage imageNamed:@"Bottom_ControlField.png"]
//#define LIGHT_BLUE_COLOR [UIColor colorWithRed:90. / 255 green:150. / 255 blue:200. / 255 alpha:1]
//#define BLUE_TEXT_COLOR [UIColor colorWithRed:10 / 255 green:40 / 255 blue:200. / 255 alpha:1]
//#define PATH_TO_SERVER @"http://mal.cloudmill.ru/api/jsonrpc"
#define AppDelegate ((AboutTimePlusAppDelegate *)[[UIApplication sharedApplication] delegate]) 
//#define mHandler [ManagerHandler sharedManager]
#define FONT @"Helvetica Neue"
#define UI_USER_INTERFACE_IDIOM() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? [[UIDevice currentDevice] userInterfaceIdiom] : UIUserInterfaceIdiomPhone)