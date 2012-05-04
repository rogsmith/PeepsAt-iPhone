//
//  SplashViewController.m
//  PlacePin
//
//  Created by roger on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate_iPhone.h"
#import "SyncRequest.h"

@implementation SplashViewController
@synthesize fbGraph;
@synthesize fbButton;
@synthesize toolbar;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	_facebook = [[[[Facebook alloc] init] autorelease] retain];
	[self setFbButton];
    [super viewDidLoad];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void) login {
	NSString *client_id = @"215461935149197";
	[_facebook authorize:client_id permissions:[NSArray arrayWithObjects: 
												@"email,offline_access",nil] delegate:self];
}

/**
 * Callback for facebook login
 */ 
-(void) fbDidLogin {
	fbButton.isLoggedIn         = YES;
	[fbButton updateImage];
	[_facebook requestWithGraphPath:@"me" andDelegate:self];
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin {
	NSLog(@"did not login");
}

-(IBAction)doneButtonClicked:(id)sender{
	[self dismissModalViewControllerAnimated:true];
}

/**
 * Callback for facebook logout
 */ 
-(void) fbDidLogout {
	fbButton.isLoggedIn         = NO;
	[fbButton updateImage];
}

-(void)hideToolBar:(BOOL)hidden{
	//toolbar.hidden = hidden;	
	[self setNavigationBarHidden:YES animated:NO];
}

- (IBAction)facebookLoginAction:(id)sender{
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
	/*Facebook Application ID*/
	NSString *client_id = @"215461935149197";
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	if(delegate.fbIdString != nil){
		[delegate setFacebookCreds:nil facebookId:nil];
		[self setFbButton];
		[_facebook logout:self]; 
		
		//alloc and initalize our FbGraph instance
	}else{
		[self login];
		//self.fbGraph = [[FbGraph alloc] initWithFbClientID:client_id];
		
		//begin the authentication process.....
		//[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access"];
		
		/**
		 * OR you may wish to 'anchor' the login UIWebView to a window not at the root of your application...
		 * for example you may wish it to render/display inside a UITabBar view....
		 *
		 * Feel free to try both methods here, simply (un)comment out the appropriate one.....
		 **/
		//[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"offline_access,email" andSuperView:self.view];
		
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Callback when a request receives Response
 */ 
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
};

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	//[self.label setText:[error localizedDescription]];
};

- (void)request:(SyncRequest*)request didLoadSyncRequest:(NSArray *)result{
	if(request.method == @"addUser") {
		NSString *status = [result objectAtIndex:0];
		NSLog(@"%@", status);
		
		if([status isEqualToString: @"NEW_USER"]){
			AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
			[[SyncRequest requestWithDelegate:self] loadMyFriends:delegate.fbIdString];
		
			[delegate.mainViewController showLoadingMessage];
		}
		[self dismissModalViewControllerAnimated:YES];
	}
}

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result{
	NSLog(@"%@", result);
	//[[SyncRequest requestWithDelegate:self] addUser:_facebook.accessToken facebookId:[result objectForKey:@"id"]];
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	[delegate setFacebookCreds:_facebook.accessToken facebookId:[result objectForKey:@"id"]];
	//[[SyncRequest requestWithDelegate:self] loadMyFriends:[result objectForKey:@"id"]];
	[delegate loadFriends: false];
	//[delegate.mainViewController showLoadingMessage];
	[self dismissModalViewControllerAnimated:YES];
};

- (void)fbGraphCallback:(id)sender {
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me" withGetVars:nil];
	NSDictionary *user = [fb_graph_response.htmlResponse JSONValue];
	
	//[[SyncRequest requestWithDelegate:self] addUser:fbGraph.accessToken facebookId:[user objectForKey:@"id"]];
	//pop a message letting them know most of the info will be dumped in the log
	NSLog(@"------------>CONGRATULATIONS<------------, You're logged into Facebook...  Your oAuth token is:  %@", fbGraph.accessToken);
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	[delegate setFacebookCreds:fbGraph.accessToken facebookId:[user objectForKey:@"id"] canPublishStream:YES];
	[self setFbButton];
	//[[SyncRequest requestWithDelegate:self] loadMyFriends:[user objectForKey:@"id"]];
	//[delegate.mainViewController showLoadingMessage];
	//[self dismissModalViewControllerAnimated:YES];
	[delegate loadFriends:false];
	//[delegate.mainViewController showLoadingMessage];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)setFbButton{
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	if(delegate.fbIdString != nil){
		self.fbButton.isLoggedIn = YES;
		[self.fbButton updateImage];
	}else{
		self.fbButton.isLoggedIn = NO;
		[self.fbButton updateImage];
	}}

- (IBAction)cancelButtonAction:(id)sender{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
