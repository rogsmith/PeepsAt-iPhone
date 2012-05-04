//
//  DetailViewController.h
//  PeepsAt
//
//  Created by roger on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UIViewController < UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
	NSDictionary *detailItem;
	NSIndexPath *selectedIndexPath;
	
	IBOutlet UITableViewCell *buttonCell;
	IBOutlet UIButton *mapButton;
	IBOutlet UIButton *callButton;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSDictionary *detailItem;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) UIButton *mapButton;
@property (nonatomic, retain) UIButton *callButton;
@property (nonatomic, retain) UITableViewCell *buttonCell;

- (IBAction)mapAction:(id)sender;
- (IBAction)callAction:(id)sender;
@end
