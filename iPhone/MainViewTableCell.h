//
//  MainViewTableCell.h
//  PeepsAt
//
//  Created by roger on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainViewTableCell : UITableViewCell {
	NSString *pictureUrl;
}

@property (nonatomic, retain) NSString *pictureUrl;

- (void)setDetails:(NSDictionary *)friend;@end
