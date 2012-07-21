//
//  main.m
//  4SquareAsync
//
//  Created by Sam Gray on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FourSquare.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        [[FourSquare sharedSquare] searchVenuesASync:[NSNumber numberWithFloat:32.766491] longitude:[NSNumber numberWithFloat:-96.690674] completion:^(NSArray *venuesArray) {
            NSLog(@"venues: %@\n", venuesArray);
        }];
        
        while (1) {
            //NSLog(@"cached venues array: %@", [[FourSquare sharedSquare] cachedVenuesArray]);
        }
        
    }
    return 0;
}

