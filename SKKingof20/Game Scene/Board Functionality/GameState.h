//
//  GameState.h
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GameState_h
#define GameState_h

#import "GameBoardArray.h"
#import "ScoreManager.h"
#import "GameScene.h"

@class GameRack;
@interface GameState : NSObject // no longer needed <NSCopying>

#pragma mark External Connection

/// Class storing game array
@property (nonatomic) GameBoardArray* gameBoardArray;

/// Corresponding gameScene - handels tile placement/movement actions
@property (nonatomic) GameScene* gameScene;

#pragma mark Gameplay Params

// Turn recognition
@property BOOL firstturn;

// Scores
@property (nonatomic) NSInteger firstScore;
@property (nonatomic) NSInteger secondScore;

#pragma mark Place Tile

/**
 * BOOL for wether space if free.
 * @param column Tile column.
 * @param row Tile row.
 * @return True is valid
 */
-(BOOL)isBlankAtColumn:(NSInteger)column andRow:(NSInteger)row;

/**
 * Set new state.
 * @param column Tile column.
 * @param row Tile row.
 * @param state New state.
 */
- (void)makeTempToColumn:(NSInteger)column Row:(NSInteger)row andState:(BoardCellState)state;

/**
 * Valid move in temp board push to permanent board.
 */
-(void)pushTomakeMove;

/**
 * Returns true if current temp board can be pushed.
 */
-(BOOL)boardisValidWithErrorString: (NSString**) error;

#pragma mark Pass/Swap

/**
 * Remove tiles from temp and place in given rack.
 */
-(void) clearTempBoardToRack;

/**
 * Increase 1st player score.
 * @param delta Amount to increasen score
 */
-(void) increaseScoreBy: (NSInteger) delta;

#pragma mark Set/Retrieve last cell value

/**
 * Return tiles that were last placed.
 * @return returnArray current _returnArray
 */
-(NSMutableArray*)returnLastPlayedArray;

/**
 * Sets last played array to determined state - updates visuals.
 * @param newArray new array to load
 */
-(void) updateLastPlayedArray:(NSMutableArray*) newArray;

/**
* Clear last played array - updates visuals.
*/
- (void)clearLastPlayed;

@end
#endif /* GameState_h */
