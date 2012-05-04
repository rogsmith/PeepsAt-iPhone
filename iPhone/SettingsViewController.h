//
//  SettingsViewController.h
//  PeepsAt
//
//  Created by Roger on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginButton.h"
#import "FBConnect.h"


@interface SettingsViewController : UIViewController {
	IBOutlet FBLoginButton *fbButton;
	Facebook* _facebook;
}
@property (nonatomic, retain) FBLoginButton *fbButton;
-(IBAction)doneButtonClicked:(id)sender;
- (IBAction)facebookLoginAction:(id)sender;

@end
