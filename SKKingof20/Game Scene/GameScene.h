//
//  RulesScene.h
//  SKKingof20
//
//  Created by Ishmael King on 1/23/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GameScene_h
#define GameScene_h

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "SceneOrganizerViewController.h"
#import "BoardCellState.h"
#import "MultiplayerNetworking.h"
#import "ActiveGameState.h"

@interface GameScene : SKScene <MultiplayerNetworkingProtocol>

// Allows scene changes
@property id <SceneOrganizerDelegate> sceneOrganizer;

// Class for networking protocols
@property (nonatomic, strong) MultiplayerNetworking *networkingEngine;

#pragma mark UI Functions/Params

//Back Action
-(void)shouldBack;

//Play Action
-(void)handlePlayAttempt;

//Pass Action
-(void)handlePass;

//Shuffle Actions
-(void)handleShuffle;
-(void)handleRecall;

//Swap Actions
-(void)handleSwap;
-(void)handleSwapCancel;
-(bool)handleSwapConfirm;

//Return available tile count
-(NSUInteger)requestAvailableTileCount;

#pragma mark Rack Functions/Params

/// Is tile being dragged?
@property (nonatomic) BOOL tileIsMoving;

/**
 * Tile dropped by rack - handel.
 *
 * @param touch Ending touch for tile movement.
 * @param value Value of tile dropped.
 */
-(BOOL) tileDroppedWithTouch:(UITouch*) touch andValue:(BoardCellState) value;

#pragma mark GameState Functions

/**
 * Temp board is empty - handel.
 *
 * @param isEmpty True if empty.
 */
-(void)gameStateTempEmpty:(BOOL)isEmpty;

/**
 * Add value to rack if space is available.
 *
 * @param value Value to add to rack.
 */
-(void) valueToRack:(BoardCellState) value;

/**
 * Score has changed - handel.
 *
 * @param score New score.
 */
-(void)gameStateScoreUpdated:(NSInteger)score;

@end

#endif /* RulesScene_h */
