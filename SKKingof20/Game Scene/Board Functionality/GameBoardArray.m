//
//  GameBoardArray.m
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardArray.h"
#import "BoardDelegate.h"

static const NSInteger GRID_SIZE = 12;

@implementation GameBoardArray {
    
    // Current tiles to be displayed
    NSUInteger _board[GRID_SIZE][GRID_SIZE];
    
    // Offical state of tiles (not including temp)
    NSUInteger _boardreturn[GRID_SIZE][GRID_SIZE];
    
    // BoardSqures register to be notified
    __weak id<BoardDelegate> _delegate;
}

#pragma mark Array Initilization/Clear

- (id)init
{
    if (self = [super init]){
        [self clearBoard];
        _boardDelegate = [[MulticastDelegate alloc] init];
        _delegate = (id)_boardDelegate;
    }
    return self;
}

- (void)clearBoard
{
    memset(_board, 0, sizeof(NSUInteger) * 12 * 12);
    [self informDelegateOfStateChanged:BoardCellStateEmpty forColumn:-1 andRow:-1 type:PERMANENT_MOVE];
}

#pragma mark Set/Retrieve cell value

- (void)setCellState:(BoardCellState)state forColumn:(NSInteger)column andRow:(NSInteger)row type:(MoveType)type
{
    [self checkBoundsForColumn:column andRow:row];
    _board[column][row] = state;
    if ( type != TEMP_MOVE ){
        _boardreturn[column][row] = state;
    }
    [self informDelegateOfStateChanged:state forColumn:column andRow:row type:type];
}

- (BoardCellState)cellStateAtColumn:(NSInteger)column andRow:(NSInteger)row
{
    [self checkBoundsForColumn:column andRow:row];
    return _board[column][row];
}

-(NSMutableArray*) returnCurrentArray
{
    NSMutableArray* board = [[NSMutableArray alloc] init];
    for (int i = 0; i < GRID_SIZE; i++)
    {
        NSMutableArray* subboard = [[NSMutableArray alloc] init];
        for (int j = 0; j < GRID_SIZE; j++)
        {
            [subboard addObject:[NSNumber numberWithInteger:_boardreturn[i][j]]];
        }
        [board addObject:subboard];
    }
    
    return board;
}

-(void) updateBoard:(NSMutableArray*)newBoard {
   
    //Set board as determined
    for (int i = 0; i < GRID_SIZE; i++)
    {
        for (int j = 0; j < GRID_SIZE; j++)
        {
            [self setCellState:(BoardCellState)[(NSNumber*)newBoard[i][j] integerValue] forColumn:i andRow:j type:PERMANENT_MOVE];
        }
    }
}

#pragma mark Delegate Informing

-(void)informDelegateOfStateChanged:(BoardCellState) state forColumn:(NSInteger)column andRow:(NSInteger) row type:(MoveType)type
{
    if ([_delegate respondsToSelector:@selector(cellStateChanged:forColumn:andRow:type:)]) {
        [_delegate cellStateChanged:state forColumn:column andRow:row type:type];
    }
}

#pragma mark Bound Check

- (void)checkBoundsForColumn:(NSInteger)column andRow:(NSInteger)row
{
    if (column < 0 || column > GRID_SIZE-1 || row < 0 || row > GRID_SIZE-1)
        [NSException raise:NSRangeException format:@"row or column out of bounds"];
}

#pragma mark NS COPY

//Copy board for computer opponent
//Zone: A region in memory - ensures the copy is in the same zone as original
//allocwithZone is remotly faster than alloc
- (id)copyWithZone:(NSZone *)zone
{
    GameBoardArray* board = [[[self class] allocWithZone:zone] init];
    memcpy(board->_board, _board, sizeof(NSUInteger) * 12 * 12);
    board->_boardDelegate = [[MulticastDelegate alloc] init];
    board->_delegate = (id)_boardDelegate;
    return board;
}

@end
