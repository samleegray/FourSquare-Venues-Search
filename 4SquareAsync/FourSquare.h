//
//  FourSquare.h
//  FourSquare
//
//  Created by Sam Gray on 7/2/12.
//  Copyright (c) 2012 Sam Gray. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VenuesBlock)(NSArray *); //block typedef for the completion handler
#define BlankMutableString [NSMutableString stringWithCapacity:100]; //just a convenience definition 

//the protocol you must use to get the venue data returned if your using the sync method(I'd recommend async)
@protocol FourSquareDelegate <NSObject>

@required
-(void)returnedVenues:(NSArray *)venuesArray;

@end

@interface FourSquare : NSObject <NSURLConnectionDelegate, FourSquareDelegate>
@property(readwrite)id<FourSquareDelegate> delegate; //the delegate needs to be set by others, hence readwrite
@property(readonly)NSArray *cachedVenuesArray; //cached array shouldn't be able to be written to by others, so it's readonly

+(FourSquare *)sharedSquare; //get our singleton
//search venues synchronously
-(void)searchVenuesSync:(NSNumber *)latitude longitude:(NSNumber *)longitude;
//search venues asynchonously with a block to run on completion
-(void)searchVenuesASync:(NSNumber *)latitude longitude:(NSNumber *)longitude completion:(VenuesBlock)completionBlock;

@end

