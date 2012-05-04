//
//  SplashViewController.h
//  PlacePin
//
//  Created by roger on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FbGraph.h"
#import "FBConnect.h"
#import "FBLoginButton.h"
#import "SyncRequest.h"

@interface SplashViewController : UIViewController <SyncRequestDelegate, FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate> {
	FbGraph *fbGraph;
	
	IBOutlet FBLoginButton *fbButton;
	Facebook* _facebook;
	UINavigationBar *toolbar;
}
@property (nonatomic, retain) FbGraph *fbGraph;
@property (nonatomic, retain) FBLoginButton *fbButton;
@property (nonatomic, retain) UINavigationBar *toolbar;
- (IBAction)facebookLoginAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
-(IBAction)doneButtonClicked:(id)sender;
@end
