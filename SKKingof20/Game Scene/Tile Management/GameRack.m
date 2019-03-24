//
//  GameRack.m
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameRack.h"
#import "NSMutableArray+Shuffling.h"

static const NSInteger TILE_AMOUNT = 7;
static const float RACK_WIDTH = 520;

@implementation GameRack {
    NSMutableArray* rackSquares;
}

#pragma mark Rack Initilization

-(instancetype) initWithSize:(CGSize)size {
    self = [super init];
    
    // Init intenral array
    rackSquares = [NSMutableArray array];
    
    // Position self
    self.position = CGPointMake(0, -370);
    
    for (int col = 0; col < TILE_AMOUNT; col++)
    {
        //Place tiles on rack
        RackSquare* tileMain = [[RackSquare alloc] init];
        [self addChild:tileMain];
        float off_set = ((RACK_WIDTH/2.0) - col*(RACK_WIDTH/(float)(TILE_AMOUNT-1)));
        [tileMain setInitPosition:CGPointMake(off_set, 0)];
        
        //Add reference to internal array
        [rackSquares addObject:tileMain];
    }
    
    return self;
}

-(void)setAvailableTiles:(TileCollection *)availableTiles {
    _availableTiles = availableTiles;
    
    BOOL operationSet = NO;
    
    // Give Tile Collection to all Squares
    for ( RackSquare* currentSquare in rackSquares) {
        currentSquare.availableTiles = availableTiles;
        
        // Operation found
        if ( currentSquare.value >= BoardCellStatePlus )
            operationSet = YES;
    }
    
    // Ensure first rack always has operation
    RackSquare* firstSquare = rackSquares[0];
    while ( !operationSet ) {
        [_availableTiles returnState:firstSquare.value];
        firstSquare.value = [_availableTiles retreiveState];
        
        // Operation found
        if ( firstSquare.value >= BoardCellStatePlus )
            operationSet = YES;
    }
    
}

-(void)setGameScene:(GameScene *)gameScene {
    _gameScene = gameScene;
    
    // Give Tile Collection to all Squares
    for ( RackSquare* currentSquare in rackSquares) {
        currentSquare.gameScene = gameScene;
    }
    
}

#pragma mark Retrive Square

-(RackSquare*)emptyRackSquare {
    
    // Return first empty rack square
    for ( RackSquare* currentSquare in rackSquares ) {
        if ( [currentSquare isEmpty] ) {
            return currentSquare;
        }
    }
    
    // Something went wrong - die
    NSAssert(NO, @"Request for empty tiles when none are empty");
    return nil; // Silence error
}

#pragma mark Manage Rack

-(void)refillRack {
    
    // Return first empty rack square
    for ( RackSquare* currentSquare in rackSquares) {
        if ( [currentSquare isEmpty] ) {
            [currentSquare refillSquare];
        }
    }
    
}

-(NSMutableArray*) returnCurrentRack {
    NSMutableArray* rack = [[NSMutableArray alloc] init];
    for (RackSquare* tile in self.children){
        [rack addObject:[NSNumber numberWithInteger:tile.value]];
    }
    return rack;
}

-(void)setRack:(NSMutableArray*)newRack {
    
    for (int col = 0; col < TILE_AMOUNT; col++) {
        // For each tile set the value as defined in newRack
        RackSquare* tile = (RackSquare*)rackSquares[col];
        [tile setValue:(BoardCellState)[newRack[col] integerValue]];
    }
    
}

#pragma mark Swapping

-(void)beginSwap {
    // Set all Rack Squares to Swap
    for (RackSquare* tile in self.children){
        tile.swapping = YES;
        tile.selected = NO;
    }
}

-(bool) confirmSwap {
    
    bool swap_confirmed = NO;
    
    // Replace all selected squares
    for (RackSquare* tile in self.children){
        if ( tile.selected) {
            [_availableTiles returnState:tile.value];
            tile.value = [_availableTiles retreiveState];
            swap_confirmed = YES;
        }
    }
    
    return swap_confirmed;
}

-(void)endSwap {
    // Return all Rack Squares from Swap
    for (RackSquare* tile in self.children){
        tile.swapping = NO;
        tile.selected = NO;
    }
}

#pragma mark Shuffle
-(void)shuffleRack {
    // Collect rack values and re-distribute them
    NSMutableArray* rack = [[NSMutableArray alloc] init];
    for ( int i = 0; i < rackSquares.count; i++ ){
        RackSquare* tile = rackSquares[i];
        [rack addObject:[NSNumber numberWithInteger:tile.value]];
    }
    [rack shuffle];
    for ( int i = 0; i < rackSquares.count; i++ ){
        RackSquare* tile = rackSquares[i];
        tile.value = [rack[i] integerValue];
    }
}

@end
