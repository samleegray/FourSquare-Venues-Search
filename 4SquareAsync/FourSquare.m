//
//  FourSquare.m
//  FourSquare
//
//  Created by Sam Gray on 7/2/12.
//  Copyright (c) 2012 Sam Gray. All rights reserved.
//

#import "FourSquare.h"
#import "JSONKit.h"

//SET YOUR OWN CLIENT ID & SECRET HERE
#define CLIENT_ID @"DJV2ISJM4AQ50CMX2OJ3BMUIUG5M1NXQTSRXG2XVWT044B1P"
#define CLIENT_SECRET @"SRHVXHTPL0BUZ5WBYFKAF2PQ1VA4SUBFUTYER05NLKRVCKDG"

static FourSquare *sharedSquare = nil;

@interface FourSquare ()

@property(readwrite)NSMutableString *dataString;

@end

@implementation FourSquare
@synthesize dataString = _dataString;
@synthesize delegate = _delegate;
@synthesize cachedVenuesArray = _cachedVenuesArray;

+(FourSquare *)sharedSquare {
    //dispatch_once to make sure this only gets called once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(sharedSquare == nil)
            sharedSquare = [[self alloc] init];
    });
    
    return sharedSquare;
}

-(id)init {
    if(self = [super init]) {
        _dataString = [[NSMutableString alloc] initWithCapacity:100];
    }
    
    return self;
}

-(void)searchVenuesASync:(NSNumber *)latitude longitude:(NSNumber *)longitude completion:(VenuesBlock)completionBlock {
    //get a dispatch queue
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //dispatch an async process to handle everything, so after a user calls this method it'll instantly return without interrupting the flow of their app
    dispatch_async(concurrentQueue, ^{
        NSError *requestError; // obviously for error handling
        
        //construct the URL request string
        NSString *url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=%@&client_secret=%@",latitude, longitude, CLIENT_ID, CLIENT_SECRET];
        
        //make the request and perform it synchronously so the calls below it won't happen before it returns
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
        NSLog(@"error: %@", [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
        //change the json data we got returned to us, into a NSDictionary we can handle
        NSDictionary *venuesDictionary = [returnData objectFromJSONData];
        
        //parse through all the junk we don't need, and get just the venues as an array of dictionaries
        NSArray *venuesArray = [[[[venuesDictionary valueForKey:@"response"] valueForKey:@"groups"] valueForKey:@"items"] objectAtIndex:0];
        
        //keep a cached copy of this incase the user wants to get what was previously loaded instead of loading the data again each time
        _cachedVenuesArray = venuesArray;
        completionBlock(venuesArray);
    });
}

-(void)searchVenuesSync:(NSNumber *)latitude longitude:(NSNumber *)longitude
{
    //construct the proper URL for the request
    NSString *url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=%@&client_secret=%@",latitude, longitude, CLIENT_ID, CLIENT_SECRET];
    
    //make the request so our delegate methods can happen
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //set the data string blank again, so it can take new information the next time
    _dataString = BlankMutableString;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //make sure there is a delgate to call to
    if(_delegate) {
        //get the information from the JSON that got returned to us
        NSDictionary *venuesDictionary = [_dataString objectFromJSONString];
        
        //return only the venues, so we're value keying down to only the venues
        [_delegate returnedVenues:[[[[venuesDictionary valueForKey:@"response"] valueForKey:@"groups"] valueForKey:@"items"] objectAtIndex:0]];
    }
    
    //make sure we make the data string blank again
    _dataString = BlankMutableString;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{   
    //change the NSData we get to a NSString so we can append it to the data string
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_dataString appendString:json];
}

@end
