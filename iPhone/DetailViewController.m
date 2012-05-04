//
//  DetailViewController.m
//  PeepsAt
//
//  Created by roger on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "SyncRequest.h"
#import "FbProfileWebView.h"


@implementation DetailViewController
@synthesize tableView;
@synthesize detailItem;
@synthesize selectedIndexPath;
@synthesize callButton;
@synthesize mapButton;
@synthesize buttonCell;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:NO];
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0){
		return 2;
	}else{
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = [self.detailItem objectForKey:@"name"];
            break;
        default:
            break;
    }
    return title;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	switch (indexPath.section) {
		case 0:{
			if(indexPath.row == 0){
				cell.textLabel.text = [self.detailItem objectForKey:@"address"];
			}else if(indexPath.row == 1){
				cell.textLabel.text = @"View Profile";
				cell.textLabel.adjustsFontSizeToFitWidth = YES;
			}
			return cell;
		}
	}
	return cell;
    
    // Set up the cell...
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0 || indexPath.section == 2){
		return 44;
	}else{
		return 191;//245;
	}
	
}

- (void)mapAction:(id)sender
{
	NSString *latlong = @""; 
	latlong = [latlong stringByAppendingString:[self.detailItem valueForKey:@"lat"]];
	latlong = [latlong stringByAppendingString:@","];
	latlong = [latlong stringByAppendingString:[self.detailItem valueForKey:@"lng"]];
	NSString *query =  [self.detailItem objectForKey:@"title"];
	query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *mapUrl=@"http://maps.google.com/maps?q=";
	mapUrl = [mapUrl stringByAppendingString:query];
	mapUrl = [mapUrl stringByAppendingString:@"@"];
	mapUrl = [mapUrl stringByAppendingString: [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *url = [NSString stringWithFormat: mapUrl]; 
	BOOL opened = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[SyncRequest urlEncode:url]]];
	if(!opened){
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Could not open map"
							  message:@"Sorry I could not find your map application."
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)callAction:(id)sender
{
	NSString *phoneNumber = @"tel://";
	phoneNumber = [phoneNumber stringByAppendingString:[self.detailItem objectForKey:@"phone"]];
	
	BOOL opened = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
	if(!opened){
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Could not open phone"
							  message:@"Sorry I could not find your phone."
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	if(row == 1){
			//this should be the url. Open in a browse
		FbProfileWebView *anotherViewController = [[FbProfileWebView alloc] initWithNibName:@"FbProfileWebView" bundle:nil];
		[[self parentViewController] pushViewController:anotherViewController animated:YES];
		
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[SyncRequest urlEncode: [self.detailItem objectForKey:@"url"]]]];
		[anotherViewController.webView loadRequest:urlRequest];
		[anotherViewController release];

		//BOOL opened = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[SyncRequest urlEncode: [self.detailItem objectForKey:@"url"]]]];
		//[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

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
