//
//  HoverView.h
//  SearchNearby
//
//  Created by roger on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HoverView : UIView {
	IBOutlet UILabel *loadingLabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *loadingLabel;
@end
