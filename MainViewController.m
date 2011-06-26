//
//  MainViewController.m
//  AboutTimePlus
//
//  Created by Sergey Dikarev on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "Defines.h"
#import "Company.h"
#import "SystemData.h"
#import "EmployeeManager.h"
#import "Employee.h"
#import "ClockState.h"
#import "AppSettings.h"
#import "networking.h"
#import "Reachability.h"
#import "TimeRecordingBackup.h"

@implementation MainViewController
@synthesize menuButton, setCompanyLabel, readyLabel, progressView, spinner,pinCode, points;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        ////
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    if(AppDelegate.isIphone)
    {
        //lblTest.text = @"Iphone";
    }
    else
    {
        //lblTest.text = @"IPAD";
    }
    
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Tink1.mp3", [[NSBundle mainBundle] resourcePath]]];
	//NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	audioPlayer.numberOfLoops = 1;
	spinner.hidden = YES;
    points.text = @"";
	self.pinCode = [NSMutableString stringWithString:@""];
	
	[AppDelegate.sc makeNiceButton:menuButton];
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

	[self updateInterfaceWithReachability: AppDelegate.hostReach];
    
	ClockState *cs = [AppDelegate.sc LoadClockState];
    
	if(cs.companyId > 0)
	{		
		setCompanyLabel.text = cs.companyName;
	}
	else
	{
		setCompanyLabel.text = @"<Choose Company>";
	}
    
	[super viewDidLoad];
	
	if(AppDelegate.settings.myServer == nil || [AppDelegate.settings.myServer length] <= 0)
	{
		//Preferences
		
	}
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == AppDelegate.hostReach)
    {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        //BOOL connectionRequired= [curReach connectionRequired];
		
        //summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        NSString* baseLabel=  @"";
        if(netStatus == 0)
        {
            baseLabel=  @"Connection to server is not available";
        }
        else
        {
            baseLabel=  @"Ready. Connection is available";
        }
        readyLabel.text= baseLabel;
    }

}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

-(IBAction)ShowMenu
{
	
	UIActionSheet *act = [[UIActionSheet alloc] initWithTitle:@"Menu"
													 delegate:self 
											cancelButtonTitle:@"Close" 
									   destructiveButtonTitle:@"Set Company" 
											otherButtonTitles:@"Preferences", @"Register Device", @"Sync Company Data Only", @"Sync Device Data Only", @"Sync All", nil];
	[act showInView:self.view];
	[act release];
	
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		[self showSetCompany];
	}
	if (buttonIndex == 1)
	{
        //Preferences
		//[[UIAppDelegate switchViewController] switchViews:@"PreferencesView" currentView:self obj:nil];
	}
	if (buttonIndex == 2) {
		NetworkStatus netStatus = [AppDelegate.hostReach currentReachabilityStatus];
		if(netStatus != 0)
		{
			@try {
				[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
				[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:100 readTo:YES];
			}
			@catch (NSException * e) {
				NSLog(@"%@", [e description]);
				readyLabel.text = [e description];
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
				[alert show];
			}
			@finally {
				[AppDelegate.sc Disconnect];
			}
			
			
		}
		else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"There are no connection to server. Please check internet availability." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
			[alert show];
		}
	}
	if(buttonIndex == 3)
	{
		//sc.managedObjectContext = [UIAppDelegate switchViewController].managedObjectContext;
		//[sc getEmployeeDataFromCoreData];
		NetworkStatus netStatus = [AppDelegate.hostReach currentReachabilityStatus];
		
		if(netStatus != 0)
		{
			@try {
				spinner.hidden = NO;
				[spinner startAnimating];
				progressView.progress = 0.0; 
				
				[NSThread detachNewThreadSelector:@selector(beginSyncingCompanyData) toTarget:self withObject:nil];
			}
			@catch (NSException * e) {
				NSLog(@"%@", [e description]);
				readyLabel.text = [e description];
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
				[alert show];
			}
			@finally {
				[AppDelegate.sc Disconnect];
			}
		}
		else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"There are no connection to server. Please check internet availability." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
			[alert show];
		}
        
	}
    if(buttonIndex == 4)
	{
		//sc.managedObjectContext = [UIAppDelegate switchViewController].managedObjectContext;
		//[sc getEmployeeDataFromCoreData];
		NetworkStatus netStatus = [AppDelegate.hostReach currentReachabilityStatus];
		
		if(netStatus != 0)
		{
			@try {
				spinner.hidden = NO;
				[spinner startAnimating];
				progressView.progress = 0.0;
                
				[NSThread detachNewThreadSelector:@selector(beginSendingDeviceDataOnly) toTarget:self withObject:nil];
				
			}
			@catch (NSException * e) {
				NSLog(@"%@", [e description]);
				readyLabel.text = [e description];
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
				[alert show];
			}
			@finally {
				[AppDelegate.sc Disconnect];
			}
		}
		else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"There are no connection to server. Please check internet availability." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
			[alert show];
		}
        
	}
	if(buttonIndex == 5)
	{
        
		NetworkStatus netStatus = [AppDelegate.hostReach currentReachabilityStatus];
		
		if(netStatus != 0)
		{
			@try {
				spinner.hidden = NO;
				[spinner startAnimating];
				progressView.progress = 0.0; 
				[NSThread detachNewThreadSelector:@selector(beginSyncingAll) toTarget:self withObject:nil];				
			}
			@catch (NSException * e) {
				NSLog(@"%@", [e description]);
				readyLabel.text = [e description];
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
				[alert show];
			}
			@finally {
				[AppDelegate.sc Disconnect];
			}
		}
		else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"There are no connection to server. Please check internet availability." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
			[alert show];
		}
		
	}
}

-(IBAction)buttonSyncAll
{
	NetworkStatus netStatus = [AppDelegate.hostReach currentReachabilityStatus];
	if(netStatus != 0)
	{
		@try {
			spinner.hidden = NO;
			[spinner startAnimating];
			progressView.progress = 0.0; 
			//[self beginSyncingAll];
			[NSThread detachNewThreadSelector:@selector(beginSyncingAll) toTarget:self withObject:nil];				
		}
		@catch (NSException * e) {
			NSLog(@"%@", [e description]);
			readyLabel.text = [e description];
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
			[alert show];
		}
		@finally {
			[AppDelegate.sc Disconnect];
			
			//[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Ready" waitUntilDone:NO];  
			
			//[self performSelectorOnMainThread:@selector(afterSync) withObject:nil waitUntilDone:NO];  
		}
	}
	else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"There are no connection to server. Please check internet availability." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

- (IBAction)beginSyncingCompanyData
{
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
	//[UIAppDelegate switchViewController].btnBackScreen.enabled = NO;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	@try
	{
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:200 readTo:NO];
		
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Sending Clock Info" waitUntilDone:NO];  
		
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving System Data" waitUntilDone:NO];  
		
		NSLog(@"getSystemDataFromSyncCenter");
		[AppDelegate.sc getSystemDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		//[AppDelegate.sc.nett writeInt:1];
		
		
		//company data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Company Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:201 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getCompanyDataFromSyncCenter");
		[AppDelegate.sc getCompanyDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		//employees data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Employees Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:202 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getEmployeeDataFromSyncCenter");
		[AppDelegate.sc getEmployeeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		//job data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Job Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:203 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getJobDataFromSyncCenter");
		[AppDelegate.sc getJobDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//cost code data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Cost Codes" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:204 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getCostCodeDataFromSyncCenter");
		[AppDelegate.sc getCostCodeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//job employee data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Job Empl. Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:205 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getJobEmployeeDataFromSyncCenter");
		[AppDelegate.sc getJobEmployeeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//emp cost code data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Emp. Cost Code Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:206 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getEmployeeCostCodeDataFromSyncCenter");
		[AppDelegate.sc getEmployeeCostCodeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//job cost code data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Job Cost Code Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:207 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getJobCostCodeDataFromSyncCenter");
		[AppDelegate.sc getJobCostCodeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//feedback data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Feedb. Questions" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:208 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getFBQuestionDataFromSyncCenter");
		[AppDelegate.sc getFBQuestionDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		// Sync Equipment Data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Equipment Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:209 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getEquipmentDataFromSyncCenter");
		[AppDelegate.sc getEquipmentDataFromSyncCenter];
        
        
        // Sync Custom List Data
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Receiving Custom List Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:210 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getCustomListDataFromSyncCenter");
		[AppDelegate.sc getCustomListDataFromSyncCenter];
        
	}
	@catch (NSException * e) {
		NSLog(@"%@", [e description]);
		readyLabel.text = [e description];
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	@finally {
		[AppDelegate.sc Disconnect];
		
		
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Ready" waitUntilDone:NO];  
		
		[self performSelectorOnMainThread:@selector(afterSync) withObject:nil waitUntilDone:NO];  
	}
	
    
    [pool release];  
}

- (IBAction)beginSendingDeviceDataOnly
{
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
	//[UIAppDelegate switchViewController].btnBackScreen.enabled = NO;
    
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:101 readTo:NO];
		
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		
		[self performSelectorOnMainThread:@selector(showProgressSendingDevice:) withObject:@"Sending Clock Info" waitUntilDone:NO];
		
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		
		[self performSelectorOnMainThread:@selector(showProgressSendingDevice:) withObject:@"Sending Time records" waitUntilDone:NO];  
		
		NSLog(@"sendTimeRecordsToSyncCenter");	
		[AppDelegate.sc sendTimeRecordsToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgressSendingDevice:) withObject:@"Sending Field Notes" waitUntilDone:NO];  
		
		NSLog(@"sendFieldNotesToSyncCenter");	
		[AppDelegate.sc sendFieldNotesToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgressSendingDevice:) withObject:@"Sending Per Diems" waitUntilDone:NO];  
		
		NSLog(@"sendPerDiemToSyncCenter");
		[AppDelegate.sc sendPerDiemToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgressSendingDevice:) withObject:@"Sending Feedbacks" waitUntilDone:NO];  
		
		NSLog(@"sendFeedbackToSyncCenter");
		[AppDelegate.sc sendFeedbackToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgressSendingDevice:) withObject:@"Sending Job Photos" waitUntilDone:NO];  
		
		NSLog(@"sendJobPhotosToSyncCenter");
		[AppDelegate.sc sendJobPhotosToSyncCenter];
	}
	@catch (NSException * e) {
		NSLog(@"%@", [e description]);
		readyLabel.text = [e description];
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	@finally {
		[AppDelegate.sc Disconnect];
		
		
		[self performSelectorOnMainThread:@selector(showProgressSyncingCompanyData:) withObject:@"Ready" waitUntilDone:NO];  
		
		[self performSelectorOnMainThread:@selector(afterSync) withObject:nil waitUntilDone:NO];  
	}
	
    [pool release];  
}

- (IBAction)beginSyncingAll
{
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	//[UIAppDelegate switchViewController].btnBackScreen.enabled = NO;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:101 readTo:NO];
		
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Sending Clock Info" waitUntilDone:NO];
		
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Sending Time records" waitUntilDone:NO];  
		
		NSLog(@"sendTimeRecordsToSyncCenter");	
		[AppDelegate.sc sendTimeRecordsToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Sending Field Notes" waitUntilDone:NO];  
		
		NSLog(@"sendFieldNotesToSyncCenter");	
		[AppDelegate.sc sendFieldNotesToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Sending Per Diems" waitUntilDone:NO];  
		
		NSLog(@"sendPerDiemToSyncCenter");
		[AppDelegate.sc sendPerDiemToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Sending Feedbacks" waitUntilDone:NO];  
		
		NSLog(@"sendFeedbackToSyncCenter");
		[AppDelegate.sc sendFeedbackToSyncCenter];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Sending Job Photos" waitUntilDone:NO];  
		
		NSLog(@"sendJobPhotosToSyncCenter");
		[AppDelegate.sc sendJobPhotosToSyncCenter]; 
		
		
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:200 readTo:NO];
		
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Sending Clock Info" waitUntilDone:NO];  
		
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving System Data" waitUntilDone:NO];  
		
		NSLog(@"getSystemDataFromSyncCenter");
		[AppDelegate.sc getSystemDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		//[AppDelegate.sc.nett writeInt:1];
		
		
		//company data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Company Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:201 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getCompanyDataFromSyncCenter");
		[AppDelegate.sc getCompanyDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		//employees data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Employees Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:202 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getEmployeeDataFromSyncCenter");
		[AppDelegate.sc getEmployeeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		//job data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Job Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:203 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getJobDataFromSyncCenter");
		[AppDelegate.sc getJobDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//cost code data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Cost Codes" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:204 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getCostCodeDataFromSyncCenter");
		[AppDelegate.sc getCostCodeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//job employee data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Job Empl. Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:205 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getJobEmployeeDataFromSyncCenter");
		[AppDelegate.sc getJobEmployeeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//emp cost code data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Emp. Cost Code Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:206 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getEmployeeCostCodeDataFromSyncCenter");
		[AppDelegate.sc getEmployeeCostCodeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//job cost code data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Job Cost Code Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:207 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getJobCostCodeDataFromSyncCenter");
		[AppDelegate.sc getJobCostCodeDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		//feedback data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Feedb. Questions" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:208 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getFBQuestionDataFromSyncCenter");
		[AppDelegate.sc getFBQuestionDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
		
		
		// Sync Equipment Data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Equipment Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:209 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getEquipmentDataFromSyncCenter");
		[AppDelegate.sc getEquipmentDataFromSyncCenter];
		[AppDelegate.sc Disconnect];
        
        
        // Sync Custom List Data
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Receiving Custom List Data" waitUntilDone:NO];  
		[AppDelegate.sc Connect:AppDelegate.settings.myServer port:[AppDelegate.settings.myPort intValue]];
		[AppDelegate.sc registerDevice:AppDelegate.settings.accountNumber command:210 readTo:NO];
		[AppDelegate.sc.nett writeInt:AppDelegate.settings.clockId];
		NSLog(@"sendClockInfo");
		[AppDelegate.sc sendClockInfo];
		NSLog(@"getCustomListDataFromSyncCenter");
		[AppDelegate.sc getCustomListDataFromSyncCenter];
		
	}
	@catch (NSException * e) {
		NSLog(@"%@", [e description]);
		readyLabel.text = [e description];
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Trouble connecting. Please keep trying or contact you network administrator if it keeps happening." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	@finally {
		[AppDelegate.sc Disconnect];
		[self performSelectorOnMainThread:@selector(showProgress:) withObject:@"Ready" waitUntilDone:NO];  
		
		[self performSelectorOnMainThread:@selector(afterSync) withObject:nil waitUntilDone:NO];  
	}
	
    
	
    [pool release];  
	
}

-(void)showProgress:(NSString *)step
{
	float actual = [progressView progress]; 
	readyLabel.text = step;
	if (actual < 1) {
		progressView.progress = actual + 0.06;
	}
    
}


-(void)showProgressSendingDevice:(NSString *)step
{
	float actual = [progressView progress]; 
	readyLabel.text = step;
	if (actual < 1) {
		progressView.progress = actual + 0.14;
	}
	
}

-(void)showProgressSyncingCompanyData:(NSString *)step
{
	float actual = [progressView progress]; 
	readyLabel.text = step;
	if (actual < 1) {
		progressView.progress = actual + 0.09;
	}
	
}

-(void)afterSync
{
	[UIApplication sharedApplication].idleTimerDisabled = NO;
    
	//[UIAppDelegate switchViewController].btnBackScreen.enabled = YES;
    
	progressView.progress = 1;
	[spinner stopAnimating];
	spinner.hidden = YES;
	
}

/*
 - (void)backgroundThinking
 {
 
 //[NSThread sleepForTimeInterval:5];
 
 sc.managedObjectContext = [UIAppDelegate switchViewController].managedObjectContext;
 [sc SyncAllData];
 
 [self performSelectorOnMainThread:@selector(didFindAnswer:) withObject:@"42" waitUntilDone:YES];
 [pool release];
 }
 */
- (void)didFindAnswer:(NSString *)answer
{
    [spinner stopAnimating];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
-(IBAction)showSetCompany
{
	//[[UIAppDelegate switchViewController] switchViews:@"SetCompanyView" currentView:self obj:nil];
	
}

-(IBAction)ShowClockInOut
{
	//[[UIAppDelegate switchViewController] switchViews:@"ClockInOutView" currentView:self obj:nil];
    
}

-(IBAction)ShowManagerClockInOut
{
	//[[UIAppDelegate switchViewController] switchViews:@"ManagerView" currentView:self obj:nil];
	
}

-(void)fillPoints{
    NSMutableString *str = [NSMutableString stringWithString:@""];
    
    for(int i = 0; i < [self.pinCode length]; i++){
        [str appendString:@"*"];
    }
    points.text = str;
    //[str release];
}

-(IBAction)pinButtonPressed:(id)sender
{
	UIButton *btn  = (UIButton *)sender;
	//[NSString stringWithFormat:@"%d", myINT]
    
	[audioPlayer play];
	
	
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"Tink1" ofType:@"mp3"];
	//SystemSoundID soundID;
	//AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundID);
	//AudioServicesPlaySystemSound(soundID);
	
	if(btn.tag == 0 || btn.tag == 1 || btn.tag == 2 || btn.tag == 3 || btn.tag == 4 || btn.tag == 5 || btn.tag == 6 || btn.tag == 7 || btn.tag == 8 || btn.tag == 9)
	{
		NSMutableArray *array = [[[NSArray alloc] init] autorelease];
		//SyncCenter *s = (SyncCenter *)[UIAppDelegate switchViewController].sc;
		array = [AppDelegate.sc createRequest:@"SystemData" initWithKey:[NSString stringWithString:@""] asc:NO];
		if([array count] > 0)
		{
			NSInteger myInt = btn.tag;
			[self.pinCode appendString:[NSMutableString stringWithFormat:@"%d", myInt]];
			[self fillPoints];
			
			
			
			SystemData *sd = [array objectAtIndex:0];
			//[array release];
			NSInteger i = [sd.NumPinKeys integerValue];
			if (i == [self.pinCode length]) {
				array = [AppDelegate.sc createRequest:@"Employee" initWithKey:[NSString stringWithString:@""] asc:YES];
				EmployeeManager *em = [[[EmployeeManager alloc] init] autorelease];
				Employee *emp = [em getEmployeeByPin:self.pinCode employees:array];
				if(emp != nil)
				{
					
					AppDelegate.cs.EmployeeId = [emp.EmployeeId integerValue];
					[AppDelegate.sc SaveClockState:AppDelegate.cs];
					if([emp.Manager boolValue])
					{
						//show screen for manager
						[self ShowManagerClockInOut];
						
					}
					else
					{
						[self ShowClockInOut];
						
					}
					
				}
				else
				{
					
					UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"No employee was found by that pin number. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
					[alert show];
					//pinCode = nil;
					//[pinCode release];
					self.pinCode = [NSMutableString stringWithString:@""];
				}
				//pinCode = nil;
				//[pinCode release];
				self.pinCode = [NSMutableString stringWithString:@""];
				
			}
		}
		else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"You need to make a register device and full sync from menu" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
			[alert show];
		}
        
		
		
		
	}
	if (btn.tag == 11) {
		
		
		//NonManagerClockViewController *controller = [[NonManagerClockViewController alloc] initWithNibName:@"NonManagerClockViewController" bundle:nil];
		//[[FieldClockAppDelegate getInstance] showView:self.view newView:controller.view];
		//[controller release];
		
	}
	if (btn.tag == 10) {
		
		self.pinCode = [NSMutableString stringWithString:@""];
		[self fillPoints];
		
		
		/*sc.managedObjectContext = [UIAppDelegate switchViewController].managedObjectContext;
         NSMutableArray *array = [sc createRequest:@"Employee" initWithKey:[NSString stringWithString:@""] asc:YES];
         for(Employee *emp in array)
         {
         NSLog(@"%@, %d", emp.Pin, [emp.Manager integerValue]);
         }*/
		//NonManagerClockViewController *controller = [[NonManagerClockViewController alloc] initWithNibName:@"NonManagerClockViewController" bundle:nil];
		//[[FieldClockAppDelegate getInstance] showView:self.view newView:controller.view];
		//[controller release];
		
	}
	
    
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
