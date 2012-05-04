//
//  SettingsViewController.m
//  PeepsAt
//
//  Created by Roger on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate_iPhone.h"


@implementation SettingsViewController
@synthesize fbButton;

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
	_facebook = [[[[Facebook alloc] init] autorelease] retain];
	[self setFbButton];
    [super viewDidLoad];
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
		[delegate.mainViewController hideSettingsShowSplash];
		//[self dismissModalViewControllerAnimated:true];
		
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)setFbButton{
	AppDelegate_iPhone *delegate = [[UIApplication sharedApplication] delegate];
	if(delegate.fbIdString != nil){
		self.fbButton.isLoggedIn = YES;
		[self.fbButton updateImage];
	}else{
		self.fbButton.isLoggedIn = NO;
		[self.fbButton updateImage];
	}
}

-(IBAction)doneButtonClicked:(id)sender{
	[self dismissModalViewControllerAnimated:true];
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
