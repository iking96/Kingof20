//
//  NSMutableArray+Shuffling.h
//  SKKingof20
//
//  Created by Ishmael King on 9/7/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef NSMutableArray_Shuffling_h
#define NSMutableArray_Shuffling_h

// NSMutableArray+Shuffling.h
#import <Foundation/Foundation.h>

/** This category enhances NSMutableArray by providing methods to randomly
 * shuffle the elements using the Fisher-Yates algorithm.
 */
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end

#endif /* NSMutableArray_Shuffling_h */
