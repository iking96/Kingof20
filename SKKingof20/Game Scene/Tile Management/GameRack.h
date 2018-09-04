//
//  GameRack.h
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GameRack_h
#define GameRack_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
#import "GameState.h"
#import "TileCollection.h"
#import "RackSquare.h"
#import "BoardCellState.h"

@interface GameRack : SKNode

/**
 * Create Rack Layout
 */
-(instancetype) initWithSize:(CGSize) size;

/// Tile Distibution Class
@property (nonatomic) TileCollection* availableTiles;

/// Corresponding gameScene - handels tile placement/movement actions
@property (nonatomic) GameScene* gameScene;

/**
 * Return first empty RackSquare
 * @return above
 */
-(RackSquare*)emptyRackSquare;

/**
 * All empty squares get new value
 */
-(void)refillRack;

/**
 * Return rack as array
 */
-(NSMutableArray*) returnCurrentRack;

/**
 * Set rack elements and update view
 * @param newRack NSMutableArray with new rack elements
 */
-(void)setRack:(NSMutableArray*)newRack;

/**
 * Enter/Exit swap mode
 */
-(void)beginSwap;
-(bool)confirmSwap;
-(void)endSwap;

@end

#endif /* GameRack_h */
