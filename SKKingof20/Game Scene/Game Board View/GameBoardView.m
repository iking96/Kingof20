//
//  GameBoardView.m
//  SKKingof20
//
//  Created by Ishmael King on 2/5/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardView.h"
#import "BoardSquare.h"

static const float BOARD_DIMENTION = 12;

@implementation GameBoardView {
    NSMutableArray* boardSquares;
}

#pragma mark View Initilization

- (id)initWithPosition:(CGPoint)position size:(CGSize)size {
    if (self = [super init])
    {
        // Init intenral array
        boardSquares = [NSMutableArray array];
        
        float rowHeight = size.height / BOARD_DIMENTION;
        float columnWidth = size.width / BOARD_DIMENTION;

        position.x = position.x + columnWidth/2;
        position.y = position.y + rowHeight/2;
        
        // create the BOARD_DIMENTIONxBOARD_DIMENTION cells for this board
        for (int row = 0; row < BOARD_DIMENTION; row++)
        {
            for (int col = 0; col < BOARD_DIMENTION; col++)
            {
                BoardSquare* square = [[BoardSquare alloc] initWithPosition:CGPointMake(col*columnWidth+position.x, row*rowHeight+position.y) size:CGSizeMake(columnWidth, rowHeight) column:col row:row];
                
                //Add reference to internal array
                [boardSquares addObject:square];
                
                [self addChild:square];
            }
        }
    }
    return self;
}

#pragma mark Setters for Board Square

-(void) setGameBoardArray:(GameBoardArray *) gameBoardArray {
    // Give Game Array to all Squares
    for ( BoardSquare* currentSquare in boardSquares) {
        currentSquare.gameBoardArray = gameBoardArray;
    }
}

-(void) setGameState:(GameState *) gameState {
    // Give Game State to all Squares
    for ( BoardSquare* currentSquare in boardSquares) {
        currentSquare.gameState = gameState;
    }
}

-(void) setGameRack:(GameRack *) gameRack {
    // Give Game Rack to all Squares
    for ( BoardSquare* currentSquare in boardSquares) {
        currentSquare.gameRack = gameRack;
    }
}

@end
