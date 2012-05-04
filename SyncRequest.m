//
//  RZRequest.m
//  AnimalsOnTheFarm
//
//  Created by roger on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncRequest.h"
#import <CommonCrypto/CommonDigest.h>
static NSString* kAPIFriendsURL = @"http://localhost:3000/users";

@implementation SyncRequest
@synthesize delegate = _delegate, url = _url, method = _method;

+ (SyncRequest*)requestWithDelegate:(id<SyncRequestDelegate>)delegate {
	SyncRequest* request = [[[SyncRequest alloc] init] autorelease];
	request.delegate = delegate;
	return request;
	
}

+(NSString *) urlEncode: (NSString *) url
{
	NSString *result=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return result;
}


- (void)doSearch:(CLLocation *)location query:(NSString *)query offset:(NSString *)offset facebookId:(NSString *)fbId{
	self.method = @"doSearch";
	_responseText = [[NSMutableData data] retain];
	
	NSString *requestUrl = kAPIFriendsURL;
	requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"/searchJson?lat=%g&lon=%g&address=%@&offset=%@&fb_id=%@", location.coordinate.latitude, location.coordinate.longitude, query, offset, fbId]];
	
	//TODO we also need to pass the FacebookId here
	//requestUrl = [NSString stringWithFormat:requestUrl, 37.775, -122.4183333, query, offset];
	
	NSLog(@"Url: %@ ", [SyncRequest urlEncode:requestUrl]);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[SyncRequest urlEncode:requestUrl]]];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)addUser:(NSString *)accessToken facebookId:(NSString *)fbId{
	self.method = @"addUser";
	
	_responseText = [[NSMutableData data] retain];
	
	NSString *requestUrl = kAPIFriendsURL;
	//TODO we also need to pass the FacebookId here
	requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"/addUser?fb_id=%@&auth_token=%@", fbId, accessToken]];
	//requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&auth_token=%@", accessToken]];
	//requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&fbid=%@", fbId]];
	
	NSLog(@"Url: %@ ", requestUrl);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[SyncRequest urlEncode:requestUrl]]];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)loadMyFriends:(NSString *)fbId{
	self.method = @"loadMyFriends";
	
	_responseText = [[NSMutableData data] retain];
	
	NSString *requestUrl = kAPIFriendsURL;
	//TODO we also need to pass the FacebookId here
	requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"/loadMyFriends?fb_id=%@", fbId]];
	//requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&auth_token=%@", accessToken]];
	//requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&fbid=%@", fbId]];
	
	NSLog(@"Url: %@ ", requestUrl);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[SyncRequest urlEncode:requestUrl]]];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}


+ (NSString *)uniqueId {
	static NSString *uid = nil;
	if (uid) return uid;
	
	// avoid sending UDID over the network in the clear
	NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
	NSData *udidData = [udid dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char md[CC_MD5_DIGEST_LENGTH];
	CC_MD5_CTX ctx;
	CC_MD5_Init(&ctx);
	CC_MD5_Update(&ctx, [udidData bytes], [udidData length]);
	CC_MD5_Update(&ctx, "AdSpeek", 7);
	CC_MD5_Final(md, &ctx);
	uid = [NSString stringWithFormat:(@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X"),
		   md[ 0],md[ 1],md[ 2],md[ 3],
		   md[ 4],md[ 5],md[ 6],md[ 7],
		   md[ 8],md[ 9],md[10],md[11],
		   md[12],md[13],md[14],md[15]];
	[uid retain];
	return uid;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_responseText setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_responseText appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[_delegate request:self didFailWithError:error];
	} 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *responseString = [[NSString alloc] initWithData:_responseText encoding:NSUTF8StringEncoding];
	[_responseText release];
	NSLog(@"Response: %@", responseString);
	if ([_delegate respondsToSelector:@selector(request:didLoadSyncRequest:)]) {
		[_delegate request:self didLoadSyncRequest:[responseString JSONValue]];
	}
}

@end
