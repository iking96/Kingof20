//
//  ScoreManager.h
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef ScoreManager_h
#define ScoreManager_h

@class GameBoardArray;
@interface ScoreManager : NSObject

/// Direction (Up-Down; Left-Right) of play
@property BOOL direction;

/// Class storing game array
@property (weak) GameBoardArray* gameBoardArray;

/**
 * Sets the state of the cell at the given location.
 * Exception if out of bounds.
 * @param temp Temp board array
 * @return returns score as float
 */
-(float) determinScorewithtempBoard:(NSUInteger[12][12]) temp;

@end

#endif /* ScoreManager_h */
