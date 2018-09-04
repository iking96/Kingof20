//
//  GameBoardView.h
//  SKKingof20
//
//  Created by Ishmael King on 2/5/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GameBoardView_h
#define GameBoardView_h

#import <SpriteKit/SpriteKit.h>
#import "GameRack.h"
#import "GameState.h"
#import "GameBoardArray.h"

@interface GameBoardView : SKNode

/**
 * Create Board View
 */
- (id)initWithPosition:(CGPoint)position size:(CGSize)size;

// Setters to pass to BoardSquare
-(void) setGameBoardArray:(GameBoardArray*) gameBoardArray;
-(void) setGameRack:(GameRack*) gameRack;
-(void) setGameState:(GameState*)gameState;

@end

#endif /* GameBoardView_h */
