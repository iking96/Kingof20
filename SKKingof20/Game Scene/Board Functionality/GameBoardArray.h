//
//  GameBoardArray.h
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GameBoardArray_h
#define GameBoardArray_h

#import "BoardCellState.h"
#import "MulticastDelegate.h"
#import "MoveType.h"

// Was BoardState
@interface GameBoardArray : NSObject <NSCopying>

// multicasts changes in cell state. Each delegate is informed of changes in state of individual cells.
@property (readonly) MulticastDelegate* boardDelegate;

/**
 * Returns the state of the cell at the given location.
 * Exception if out of bounds.
 * @param column Tile column.
 * @param row Tile row.
 * @return Value at the above location
 */
- (BoardCellState) cellStateAtColumn:(NSInteger)column andRow:(NSInteger)row;

/**
 * Sets the state of the cell at the given location.
 * Exception if out of bounds.
 * @param state State to change to.
 * @param column Tile column.
 * @param row Tile row.
 * @param type What type of move is being preformed
 */
- (void) setCellState:(BoardCellState)state forColumn:(NSInteger)column andRow:(NSInteger)row type:(MoveType)type;

/**
 * Clear gameboard memory area - deep clear.
 */
- (void)clearBoard;

/**
 * Return tiles that have been played.
 * @return returnArray current _returnArray
 */
-(NSMutableArray*)returnCurrentArray;

/**
 * Sets board to determined state - updates visuals.
 * @param newBoard new board to load
 */
-(void) updateBoard: (NSMutableArray*) newBoard;
@end

#endif /* GameBoardArray_h */
