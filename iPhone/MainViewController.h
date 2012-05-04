//
//  MainViewController.h
//  PeepsAt
//
//  Created by roger on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncRequest.h"
#import "SettingsViewController.h"
#import "MJGeocodingServices.h"
//#import "AdSpeekDelegateProtocol.h"

@class HoverView;
@interface MainViewController : UIViewController <SyncRequestDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, MJGeocoderDelegate> {
	IBOutlet UISearchBar *searchbar;
	UITableView *tableView;
	
	BOOL _isDataSourceAvailable;
	CLLocation *currentLocation;
	
	int nextOffset;
	NSArray *searchResults;
	IBOutlet HoverView *hoverView;
	int adCounter;
	NSIndexPath *selectedIndexPath;
	MJGeocoder *forwardGeocoder;
	SettingsViewController *settingsViewController;

}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UISearchBar *searchbar;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic, retain) HoverView *hoverView;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property(nonatomic, retain) MJGeocoder *forwardGeocoder;
@property(nonatomic, retain) SettingsViewController *settingsViewController;

-(IBAction)logoutButtonClicked:(id)sender;
-(IBAction)refreshButtonClicked:(id)sender;

@end
