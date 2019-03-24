//
//  NSMutableArray+Shuffling.m
//  SKKingof20
//
//  Created by Ishmael King on 9/7/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

// NSMutableArray+Shuffling.m
#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (uint i = 0; i < count - 1; ++i)
    {
        // Select a random element between i and end of array to swap with.
        int nElements = (int)count - i;
        int n = arc4random_uniform(nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
