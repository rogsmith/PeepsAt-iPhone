//
//  AppDelegate_iPhone.h
//  PeepsAt
//
//  Created by roger on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "FBConnect.h"
#import "/usr/include/sqlite3.h"
#import "PeepFacebook.h"
#import "MJGeocodingServices.h"
#define kFilename @"data.sqlite3"

@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate, FBSessionDelegate, PeepFacebookDelegate, MJGeocoderDelegate> {
    UIWindow *window;
	IBOutlet UINavigationController *navigationController;
	
	MainViewController *mainViewController;
	
	BOOL _isConnectionAvailable;
	Facebook *facebook;
	
	NSString *fbIdString;
	NSString *authToken;
	sqlite3 *database;
	MJGeocoder *forwardGeocoder;
	BOOL _forceRefresh;
}

@property (nonatomic, retain) NSString *fbIdString;
@property (nonatomic, retain) NSString *authToken;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) MainViewController *mainViewController;
@property(nonatomic, retain) MJGeocoder *forwardGeocoder;

@end

