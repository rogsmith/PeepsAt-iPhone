//
//  PeepFacebook.m
//  PeepsAt
//
//  Created by Roger on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PeepFacebook.h"


@implementation PeepFacebook
@synthesize delegate = _delegate, url = _url, method = _method;

+ (PeepFacebook*)requestWithDelegate:(id<PeepFacebookDelegate>)delegate {
	PeepFacebook* request = [[[PeepFacebook alloc] init] autorelease];
	[request initFacebook];
	request.delegate = delegate;
	return request;
	
}

-(void)initFacebook{
	_facebook = [[[[Facebook alloc] init] autorelease] retain];
}

- (NSDictionary *)getFriendList:(NSString *)authToken{
	self.method = @"getFriendList";
	//_facebook.accessToken = authToken;
	//[_facebook requestWithGraphPath:@"me/friends" andDelegate:self];
	FbGraph *graph = [[FbGraph alloc] initWithFbClientID:@"215461935149197"];
	graph.accessToken = authToken;
	FbGraphResponse *graphResponse = [graph doGraphGet:@"me/friends" withGetVars:nil];
	return [graphResponse.htmlResponse JSONValue];
}

- (void)getFriend:(NSString *)authToken facebookId:(NSString *)fbId{
	self.method = @"getFriend";
	_facebook.accessToken = authToken;
	[_facebook requestWithGraphPath:fbId andDelegate:self];
}

////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
		if ([_delegate respondsToSelector:@selector(request:didLoadSyncRequest:)]) {
			[_delegate request:self didLoadFacebookRequest:result];
		}
	}
	if ([result objectForKey:@"owner"]) {
		//[self.label setText:@"Photo upload Success"];
	} else {
		//[self.label setText:[result objectForKey:@"name"]];
	}
};

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	
};

@end
