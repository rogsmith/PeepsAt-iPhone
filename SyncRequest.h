//
//  RZRequest.h
//  AnimalsOnTheFarm
//
//  Created by roger on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol SyncRequestDelegate;

@interface SyncRequest : NSObject {
	id<SyncRequestDelegate> _delegate;
	NSString* _url;
	NSURLConnection* _connection;
	NSMutableData* _responseText;
	NSString* _method;
}

/**
 * Creates a new API request for the global session.
 */
+ (SyncRequest*)request;

/**
 * Creates a new API request for the global session with a delegate.
 */
+ (SyncRequest*)requestWithDelegate:(id<SyncRequestDelegate>)delegate;

@property(nonatomic,assign) id<SyncRequestDelegate> delegate;

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

- (void)doSearch:(CLLocation *)location query:(NSString *)query offset:(NSString *)offset facebookId:(NSString *)fbId;

@end

@protocol SyncRequestDelegate <NSObject>

@optional
/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(SyncRequest*)request didLoadSyncRequest:(NSArray *)result;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(SyncRequest*)request didFailWithError:(NSError*)error;
+(NSString *) urlEncode: (NSString *) url;

- (NSString *)applicationId;
@end
