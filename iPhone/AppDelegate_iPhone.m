//
//  AppDelegate_iPhone.m
//  PeepsAt
//
//  Created by roger on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPhone.h"

@implementation AppDelegate_iPhone

@synthesize window;
@synthesize facebook;

@synthesize fbIdString;
@synthesize authToken;
@synthesize mainViewController;
@synthesize forwardGeocoder;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[self loadFacebookCreds];
	
	// Override point for customization after application launch.
    [window addSubview:[navigationController view]];
	//[window addSubview:navigationController.view];
    [window makeKeyAndVisible];    
	
	//facebook = [[Facebook alloc] initWithAppId:@"215461935149197"];
	//[facebook authorize:nil delegate:self];
	[self initializeDb];
    
    return YES;
}

//the user has logged into Facebook
- (void)fbDidLogin{
	
}


- (void)initializeDb{
	if(sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}else{
		
		char *errorMsg;
		/*NSString *createUsersSql = @"CREATE TABLE IF NOT EXISTS USERS (ROW INTEGER PRIMARY KEY, FACEBOOK_ID TEXT, FACEBOOK_TOKEN TEXT, PERSON_ID INTEGER);";
		if(sqlite3_exec(database, [createUsersSql UTF8string], NULL, NULL, &errorMsg) != SQLITE_OK){
			sqlite3_close(database);
		}*/
		const char *createPeopleSql = "CREATE TABLE IF NOT EXISTS PEOPLE (FACEBOOK_ID TEXT PRIMARY KEY, NAME TEXT, URL TEXT, PROFILE_IMAGE_URL TEXT, FB_EMAIL TEXT, CITY TEXT, STATE TEXT, COUNTRY TEXT, LAT REAL, LON REAL)";
		if(sqlite3_exec(database, createPeopleSql, NULL, NULL, &errorMsg) != SQLITE_OK){
			sqlite3_close(database);
			NSAssert(0, @"Sql Error: %s", errorMsg);
		}
		/*NSString *createFriendsSql = @"CREATE TABLE IF NOT EXISTS FRIENDS (ROW INTEGER PRIMARY KEY, USER_ID INTEGER, PERSON_ID INTEGER);";
		if(sqlite3_exec(database, [createFriendsSql UTF8string], NULL, NULL, &errorMsg) != SQLITE_OK){
			sqlite3_close(database);
		}
		const char *createLocationsSql = @"CREATE TABLE IF NOT EXISTS LOCATIONS (ID INTEGER PRIMARY KEY AUTOINCREMENT, CITY TEXT, STATE TEXT, COUNTRY TEXT, LAT REAL, LON REAL);";
		if(sqlite3_exec(database, createLocationsSql, NULL, NULL, &errorMsg) != SQLITE_OK){
			sqlite3_close(database);
			NSAssert(0, @"Sql Error: %s", errorMsg);
		}*/
	}
}

-(NSString *)dataFilePath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

-(void)loadFriends:(BOOL)forceRefresh{
	_forceRefresh = forceRefresh;
	[NSThread detachNewThreadSelector:@selector(loadFriendsJob) toTarget:self withObject:nil];  
}

-(void)loadFriendsJob{
	[self.mainViewController showHideHoverView:true];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
    // wait for 3 seconds before starting the thread, you don't have to do that. This is just an example how to stop the NSThread for some time  
    [NSThread sleepForTimeInterval:3];  
    [self performSelectorOnMainThread:@selector(loadAllFriends) withObject:nil waitUntilDone:NO];  
    [pool release]; 
}

-(void)loadAllFriends{
	//[[PeepFacebook requestWithDelegate:self] getFriendList:self.authToken];
	FbGraph *graph = [[FbGraph alloc] initWithFbClientID:@"215461935149197"];
	graph.accessToken = authToken;
	FbGraphResponse *graphResponse = [graph doGraphGet:@"me/friends" withGetVars:nil];
	NSDictionary *data = [graphResponse.htmlResponse JSONValue];
	NSArray *dataArray = [data objectForKey:@"data"];
	for (int i = 0; i < [dataArray count] ; i++) {
		NSDictionary *person = [dataArray objectAtIndex:i];
		NSString *query = [[NSString alloc] initWithFormat:@"SELECT FACEBOOK_ID FROM PEOPLE WHERE FACEBOOK_ID = '%@'", [person objectForKey:@"id"]];
		sqlite3_stmt *stmt;
		if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK){
			if(!_forceRefresh  && sqlite3_step(stmt) == SQLITE_ROW){
				char *rowData = (char *)sqlite3_column_text(stmt, 0);
				NSString *fbid = [[NSString alloc] initWithUTF8String:rowData];
			}else{
				char *errorMsg;
				NSString *insertQuery = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO PEOPLE (NAME, FACEBOOK_ID) VALUES('%@', '%@');", [[person objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [person objectForKey:@"id"]];
				if(sqlite3_exec(database, [insertQuery UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK){
					NSAssert(0, @"Sql Error: %s", errorMsg);
				}else{
					[self refreshFriend:[person objectForKey:@"id"]];
				}
			}
		}
		sqlite3_finalize(stmt);
	}
	//[self refreshAllFriendDetails];
	[self.mainViewController showHideHoverView:false];
	[self.mainViewController reloadSearch];
}

-(void)refreshAllFriendDetails{
	FbGraph *graph = [[FbGraph alloc] initWithFbClientID:@"215461935149197"];
	graph.accessToken = authToken;

	NSString *query = [[NSString alloc] initWithFormat:@"SELECT FACEBOOK_ID FROM PEOPLE"];
	sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK){
		while(sqlite3_step(stmt) == SQLITE_ROW){
			char *rowData = (char *)sqlite3_column_text(stmt, 0);
			NSString *fbid = [[NSString alloc] initWithUTF8String:rowData];
			FbGraphResponse *graphResponse = [graph doGraphGet:fbid withGetVars:nil];
			NSDictionary *person = [graphResponse.htmlResponse JSONValue];
			NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE PEOPLE SET NAME = '%@', URL = '%@', PROFILE_IMAGE_URL = '%@' WHERE FACEBOOK_ID = '%@';", [[person objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [[person objectForKey:@"link"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture", [person objectForKey:@"id"]], [person objectForKey:@"id"]];
			char *errorMsg;
			if(sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK){
				NSAssert(0, @"Sql Error: %s", errorMsg);
			}
			if([person objectForKey:@"location"]){
				NSDictionary *loc = [person objectForKey:@"location"];
				[self geocodeFriend:fbid withAddress:[loc objectForKey:@"name"]];
			}
		}
	}
	sqlite3_finalize(stmt);
}

-(void)refreshFriend:(NSString *)fbid{
	FbGraph *graph = [[FbGraph alloc] initWithFbClientID:@"215461935149197"];
	graph.accessToken = authToken;
	
	FbGraphResponse *graphResponse = [graph doGraphGet:fbid withGetVars:nil];
	NSDictionary *person = [graphResponse.htmlResponse JSONValue];
	NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE PEOPLE SET NAME = '%@', URL = '%@', PROFILE_IMAGE_URL = '%@' WHERE FACEBOOK_ID = '%@';", [[person objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [[person objectForKey:@"link"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture", [person objectForKey:@"id"]], [person objectForKey:@"id"]];
	char *errorMsg;
	if(sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK){
		NSAssert(0, @"Sql Error: %s", errorMsg);
	}
	if([person objectForKey:@"location"]){
		NSDictionary *loc = [person objectForKey:@"location"];
		[self geocodeFriend:fbid withAddress:[loc objectForKey:@"name"]];
	}
}

-(void)geocodeFriend:(NSString *)fbId withAddress:(NSString *)address{
	
	//if reverse geocoder is not initialized, initilize it 
	if(!forwardGeocoder){
		forwardGeocoder = [[MJGeocoder alloc] init];
		forwardGeocoder.delegate = self;
	}
	
	//show network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[forwardGeocoder findLocationsWithAddress:address title:fbId];
	 
}

- (void)geocoder:(MJGeocoder *)geocoder didFindLocations:(NSArray *)locations{
	//hide network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	AddressComponents *foundLocation = [locations objectAtIndex:0];
	NSString *fbId = foundLocation.title;
	
	NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE PEOPLE SET CITY = '%@', STATE = '%@', COUNTRY = '%@', LAT = %f, LON = %f WHERE FACEBOOK_ID = '%@';", foundLocation.city, foundLocation.stateCode, foundLocation.countryName, foundLocation.coordinate.latitude, foundLocation.coordinate.longitude, fbId];
	char *errorMsg;
	if(sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK){
		NSAssert(0, @"Sql Error: %s", errorMsg);
	}
	
}

-(NSMutableArray *)doSearch:(NSArray *)bounds{
	NSMutableArray * results = [[NSMutableArray alloc] init];
	
	if(self.fbIdString != nil){
		NSString *query = [[NSString alloc] initWithFormat:@"SELECT FACEBOOK_ID, NAME, URL, PROFILE_IMAGE_URL, CITY, STATE, COUNTRY, LAT, LON FROM PEOPLE WHERE lat > %f AND lat < %f AND lon > %f AND lon < %f ORDER BY NAME ASC", [[bounds objectAtIndex:0] floatValue], [[bounds objectAtIndex:1] floatValue], [[bounds objectAtIndex:2] floatValue], [[bounds objectAtIndex:3] floatValue]];
		sqlite3_stmt *stmt;
		if(sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK){
			while(sqlite3_step(stmt) == SQLITE_ROW){
				char *rowData = (char *)sqlite3_column_text(stmt, 0);
				NSString *fbid = [[NSString alloc] initWithUTF8String:rowData];
				
				rowData = (char *)sqlite3_column_text(stmt, 1);
				NSString *name = [[NSString alloc] initWithUTF8String:rowData];
				
				rowData = (char *)sqlite3_column_text(stmt, 2);
				NSString *url = [[NSString alloc] initWithUTF8String:rowData];
				
				rowData = (char *)sqlite3_column_text(stmt, 3);
				NSString *profileImageUrl = [[NSString alloc] initWithUTF8String:rowData];
				
				rowData = (char *)sqlite3_column_text(stmt, 4);
				NSString *city = [[NSString alloc] initWithUTF8String:rowData];
				
				rowData = (char *)sqlite3_column_text(stmt, 5);
				NSString *state = [[NSString alloc] initWithUTF8String:rowData];
				
				rowData = (char *)sqlite3_column_text(stmt, 6);
				NSString *country = [[NSString alloc] initWithUTF8String:rowData];
				
				NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				 fbid, @"facebook_id", name, @"name", profileImageUrl, @"profile_image_url", url, @"url", city, @"city", state, @"state", country, @"country", [[NSString alloc] initWithFormat:@"%@, %@", city,state], @"address", nil];
				[results addObject:result];
			}
		}
		sqlite3_finalize(stmt);
	}
	return results;
}

//Sync Request Delegate Callback
- (void)request:(PeepFacebook *)request didLoadFacebookRequest:(NSArray *)result{
	
	
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
    return [facebook handleOpenURL:url]; 
}

- (void)setFacebookCreds:(NSString *)accessToken facebookId:(NSString *)fbId{
	self.fbIdString = fbId;
	self.authToken = accessToken;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.fbIdString forKey:@"fb_id"];
	[defaults setObject:self.authToken forKey:@"fb_auth_token"];
	
}

- (void)loadFacebookCreds{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.fbIdString = [defaults stringForKey:@"fb_id"];
	self.authToken = [defaults stringForKey:@"fb_auth_token"];
	
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
