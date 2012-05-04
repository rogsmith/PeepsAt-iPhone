//
//  MainViewController.m
//  PeepsAt
//
//  Created by roger on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "DetailViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "HoverView.h"
#import "MainViewTableCell.h"
#import "AppDelegate_iPhone.h"
#import "SplashViewController.h"
#import "SettingsViewController.h"


@implementation MainViewController

@synthesize searchbar;
@synthesize tableView;
@synthesize currentLocation;
@synthesize searchResults;
@synthesize hoverView;
@synthesize selectedIndexPath;
@synthesize forwardGeocoder;
@synthesize settingsViewController;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	CLLocationManager *locationManager=[[CLLocationManager alloc] init];
	locationManager.delegate=self;
	locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
	
	[locationManager startUpdatingLocation];
	
	// determine the size of HoverView
	CGRect frame = hoverView.frame;
	frame.origin.x = round((self.view.frame.size.width - frame.size.width) / 2.0);
	frame.origin.y = self.view.frame.size.height - 260;
	hoverView.frame = frame;
	
	[self.view addSubview:hoverView];
	
    [super viewDidLoad];
	
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	delegate.mainViewController = self;
	
	if(delegate.fbIdString == nil){
		[self showSplashScreen];
	}
}


- (void)showSplashScreen{
	SplashViewController *controller = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
	[self presentModalViewController:controller animated:YES];
	//[self presentModalViewController:addNoteController animated:YES];
	//[controller release];
}

-(void)showSettingsScreen{
	self.settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	[self presentModalViewController:self.settingsViewController animated:YES];
}

-(void)hideSettingsShowSplash{
	[self.settingsViewController dismissModalViewControllerAnimated:NO];
	[self showSplashScreen];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	self.currentLocation = newLocation; 
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	//[[SyncRequest requestWithDelegate:self] doSearch:self.currentLocation query:@"" offset:@"0" facebookId:delegate.fbIdString];
	NSArray *results = [delegate doSearch:[self getBounds:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude]];
	self.searchResults = results;

	[tableView reloadData];
	[self showHideHoverView:NO];
}

-(void)reloadSearch{
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	//[[SyncRequest requestWithDelegate:self] doSearch:self.currentLocation query:@"" offset:@"0" facebookId:delegate.fbIdString];
	NSArray *results = [delegate doSearch:[self getBounds:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude]];
	self.searchResults = results;
	
	[tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
}

-(void)showHideHoverView:(BOOL)show{
	if(show){
		self.hoverView.alpha = 1.0;
		[self.hoverView.activityIndicator startAnimating];
	}else{
		self.hoverView.alpha = 0.0;
		[self.hoverView.activityIndicator stopAnimating];
	}
}	

// Use the SystemConfiguration framework to determine if the host that provides
// the RSS feed is available.
- (BOOL)isDataSourceAvailable
{
    static BOOL checkNetwork = YES;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
        Boolean success;    
        const char *host_name = "ajax.googleapis.com";
		
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return _isDataSourceAvailable;
}

//Sync Request Delegate Callback
- (void)request:(SyncRequest*)request didLoadSyncRequest:(NSArray *)result{
	
	adCounter = 4;
	if(request.method == @"doSearch") {
		//nextOffset = [[self.searchResults objectForKey:@"responseData"] intValue];
		self.searchResults = result;
		[tableView reloadData];
		[self showHideHoverView:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:NO];
	[self.navigationController setNavigationBarHidden:true animated:NO];
}


-(NSArray *)getBounds:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
	float factor = fabs(cos(latitude * M_PI / 180.0) * 69.0);
    float minLatitude = latitude - (50 / 69.0);
	float maxLatitude = latitude + (50 / 69.0);
	float minLongitude = longitude - (50 / factor);
	float maxLongitude = longitude + (50 / factor);
	return [NSArray arrayWithObjects:[[NSNumber alloc] initWithFloat:minLatitude],[[NSNumber alloc] initWithFloat:maxLatitude],[[NSNumber alloc] initWithFloat:minLongitude],[[NSNumber alloc] initWithFloat:maxLongitude], nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"Cell";
    
	NSUInteger row = [indexPath row];
	/*∫
	 if(row == adCounter){
	 static NSString *MyIdentifier = @"MyIdentifier";
	 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	 if (cell == nil) {
	 cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	 // Request an AdSpeek ad for this table view cell
	 //[cell.contentView addSubview:[AdSpeekView requestWithDelegate:self]];
	 }
	 return cell;
	 }else{
	 */
	MainViewTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[MainViewTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	//if(row > adCounter){
	//	row--;
	//}
	NSDictionary *item = [self.searchResults objectAtIndex:row];
	[cell setDetails: item];
	//cell.textLabel.text = [item objectForKey:@"name"];
	//cell.detailTextLabel.text = [item objectForKey:@"address"];
	
	return cell;
	//}
	
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	//if(row > adCounter){
	//	row--;
	//}
	NSDictionary* info = [self.searchResults objectAtIndex:row];
	DetailViewController *anotherViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    anotherViewController.detailItem = info;
	
	[[self parentViewController] pushViewController:anotherViewController animated:YES];
	[anotherViewController release];
	self.selectedIndexPath = indexPath;
	[self.navigationController setNavigationBarHidden:false animated:NO];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if([self.searchResults count] > 0){
		return [self.searchResults count];
		//return [self.searchResults count]+1;
	}else{
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//if(indexPath.row == adCounter){
//		return 50;
//	}else{
		return 64;
//	}
}

- (void)geocoder:(MJGeocoder *)geocoder didFindLocations:(NSArray *)locations{
	//hide network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	AddressComponents *foundLocation = [locations objectAtIndex:0];
	
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	//[[SyncRequest requestWithDelegate:self] doSearch:self.currentLocation query:@"" offset:@"0" facebookId:delegate.fbIdString];
	NSArray *results = [delegate doSearch:[self getBounds:foundLocation.coordinate.latitude longitude:foundLocation.coordinate.longitude]];
	self.searchResults = results;
	
	[tableView reloadData];
	[self showHideHoverView:NO];
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	/*
	 if ([self isDataSourceAvailable] == NO) {
	 UIAlertView *alert = [[UIAlertView alloc]
	 initWithTitle:@"Network Required"
	 message:@"SearchNearby requires that you have a connection to the internet."
	 delegate: nil
	 cancelButtonTitle:@"OK"
	 otherButtonTitles:nil];
	 [alert show];
	 [alert release];
	 return;
	 }else{
	 */
	[self showHideHoverView:YES];
	[searchBar resignFirstResponder];
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	//[[SyncRequest requestWithDelegate:self] doSearch:self.currentLocation query:searchbar.text offset:@"0" facebookId:delegate.fbIdString];
	//}
	//if reverse geocoder is not initialized, initilize it 
	if(!forwardGeocoder){
		forwardGeocoder = [[MJGeocoder alloc] init];
		forwardGeocoder.delegate = self;
	}
	
	//show network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[forwardGeocoder findLocationsWithAddress:searchbar.text title:nil];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction)logoutButtonClicked:(id)sender{
	[self showSettingsScreen];
	/*
	UIAlertView *alert1 = [[UIAlertView alloc]
						   initWithTitle:@"Logout"
						   message:@"Are you sure you wish to logout of Facebook?"
						   delegate: self
						   cancelButtonTitle:@"Cancel"
						   otherButtonTitles:nil];
	[alert1 addButtonWithTitle:@"OK"];
	[alert1 show];
	[alert1 release];
	 */
}

-(IBAction)refreshButtonClicked:(id)sender{
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	[delegate loadFriends:false];
}

-(void)showLoadingMessage{
	UIAlertView *alert1 = [[UIAlertView alloc]
						   initWithTitle:@"Syncing"
						   message:@"We are geo-locating your friends. This might take a while if you have a lot of friends. If you don't want to hang around we will email you when we are done."
						   delegate: self
						   cancelButtonTitle:@"OK"
						   otherButtonTitles:nil];
	[alert1 show];
	[alert1 release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if([alertView title] == @"Logout"){
		if(buttonIndex == 1){
			AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
			[delegate setFacebookCreds:nil facebookId:nil];
			[self showSplashScreen];
		}
	}else{
		[self reloadSearch];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
