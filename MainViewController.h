//
//  MainViewController.h
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>

@interface MainViewController : UIViewController <UIActionSheetDelegate, AVAudioPlayerDelegate>{
    IBOutlet UILabel *lblGPS;
    IBOutlet UIButton *menuButton;
	IBOutlet UILabel *setCompanyLabel;
	IBOutlet UILabel *readyLabel;
	IBOutlet UIProgressView *progressView;
    IBOutlet UIActivityIndicatorView *spinner;
	NSMutableString *pinCode;
    IBOutlet UILabel *points;
    AVAudioPlayer *audioPlayer;
}
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UILabel *setCompanyLabel;
@property (nonatomic, retain) IBOutlet UILabel *readyLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSMutableString *pinCode;
@property (nonatomic, retain) IBOutlet UILabel *points;

-(IBAction)ShowClockInOut;
-(IBAction)showSetCompany;
-(IBAction)ShowMenu;
-(IBAction)pinButtonPressed:(id)sender;
-(IBAction)buttonSyncAll;


@end
