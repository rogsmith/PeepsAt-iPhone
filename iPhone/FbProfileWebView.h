//
//  FbProfileWebView.h
//  PeepsAt
//
//  Created by roger on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FbProfileWebView : UIViewController {
	IBOutlet UIWebView* webView;
}
@property (nonatomic, retain) UIWebView *webView;
- (IBAction)doneAction:(id)sender;

@end
