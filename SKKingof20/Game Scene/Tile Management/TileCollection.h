//
//  TileCollection.h
//  SKKingof20
//
//  Created by Ishmael King on 1/28/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef TileCollection_h
#define TileCollection_h

#import "BoardCellState.h"

@interface TileCollection : NSObject

/**
 * Remove one state from the collection.
 */
-(BoardCellState) retreiveState;

/**
 * Add a state back to the collection
 */
-(void) returnState:(BoardCellState)state;

/**
 * Get count of collection
 */
-(NSUInteger) countOfAvailableTiles;

/**
 * Return full collection
 */
-(NSMutableArray*)returnAvailableTiles;

/**
 * Load new collection
 */
-(void) updateTileCollection:(NSMutableArray*) newCollection;

@end

#endif /* TileCollection_h */
