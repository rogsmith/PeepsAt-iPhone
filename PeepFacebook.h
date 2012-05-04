//
//  RZRequest.h
//  AnimalsOnTheFarm
//
//  Created by roger on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FbGraph.h"
#import "FBConnect.h"
#import "FBLoginButton.h"
#import "FbGraph.h"

@protocol PeepFacebookDelegate;

@interface PeepFacebook : NSObject <FBRequestDelegate> {
	id<PeepFacebookDelegate> _delegate;
	Facebook* _facebook;
}

/**
 * Creates a new API request for the global session.
 */
+ (PeepFacebook*)request;

/**
 * Creates a new API request for the global session with a delegate.
 */
+ (PeepFacebook*)requestWithDelegate:(id<PeepFacebookDelegate>)delegate;

@property(nonatomic,assign) id<PeepFacebookDelegate> delegate;

/**
 * The URL which will be contacted to execute the request.
 */
@property(nonatomic,readonly) NSString* url;
@property(nonatomic,assign) NSString* method;

/**
 * Calls a method on the server asynchronously.
 *
 * The delegate will be called for each stage of the loading process.
 */ 

- (void)getFriendList:(NSString *)authToken;
- (void)getFriend:(NSString *)authToken facebookId:(NSString *)fbId;

@end

@protocol PeepFacebookDelegate <NSObject>

@optional
/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(PeepFacebook*)request didLoadFacebookRequest:(NSArray *)result;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(PeepFacebook*)request didFailWithError:(NSError*)error;
+(NSString *) urlEncode: (NSString *) url;

- (NSString *)applicationId;
@end
