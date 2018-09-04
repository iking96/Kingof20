//
//  BoardSquare.h
//  SKKingof20
//
//  Created by Ishmael King on 2/5/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef BoardSquare_h
#define BoardSquare_h

#import <SpriteKit/SpriteKit.h>
#import "GameState.h"
#import "BoardDelegate.h"
#import "GameRack.h"
#import "GameBoardArray.h"

@interface BoardSquare : SKSpriteNode <BoardDelegate>

/**
 * Create Board Square
 */
- (id) initWithPosition:(CGPoint)position size:(CGSize)size column:(NSInteger)column row:(NSInteger)row;

/// Corresponding gameRack - acts are arbitor for tile distribution
@property (nonatomic) GameBoardArray* gameBoardArray;

/// Corresponding gameState - stores current game array
@property (nonatomic) GameState* gameState;

/// Corresponding gameRack - acts are arbitor for tile distribution
@property (nonatomic) GameRack* gameRack;

@end

#endif /* BoardSquare_h */
