//
//  RackSquare.h
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef RackSquare_h
#define RackSquare_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
#import "GameState.h"
#import "TileCollection.h"

@interface RackSquare : SKSpriteNode

#pragma mark Square Initilization

-(void)setInitPosition:(CGPoint)position;

#pragma mark Public Variables

/// Tile Distibution Class
@property (nonatomic) TileCollection* availableTiles;

/// Corresponding gameScene - handels tile placement/movement actions
@property (nonatomic) GameScene* gameScene;

/// Tile Interactivity Toggles
@property BOOL allowTouch;
@property BOOL swapping;
@property (nonatomic) BOOL selected;

/// Value represented by tile
@property (nonatomic) BoardCellState value;

/**
 * Square gets new value for itself
 */
-(void) refillSquare;

/**
 * Return true is empty
 */
- (BOOL) isEmpty;

@end

#endif /* RackSquare_h */
