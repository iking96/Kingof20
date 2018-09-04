//
//  GameState.m
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import "ScoreManager.h"
#import "GameRack.h"
#import "MoveType.h"

@interface GameState()

/// Track legality of possible play
@property BOOL legal;

/// Class to calculate score
@property ScoreManager* scoreManager;

@end

static const NSInteger GRID_SIZE = 12;

@implementation GameState {
    
    // Current tiles to be displayed as temp
    NSUInteger _tempboard[GRID_SIZE][GRID_SIZE];
    
    // Current tiles last played
    BOOL _lastPlayerboard[GRID_SIZE][GRID_SIZE];
    
    // Can use delegate to communicate change of turn
    //id<TurnDelegate> _delegate;
}

#pragma mark Class Initilization / TempBoard Clear

- (id)init
{
    if ( self = [super init] ) {
        // board will be clear
        [self clearTempBoard];
        
        //Set score manager
        _scoreManager = [[ScoreManager alloc] init];
        
        //_nextMove = FirstPlayer;
        _firstScore = 0;
        _secondScore = 0;
        _firstturn = YES;
        
        //Setup connection to second player
        //Second player will add itself to delegate list
        //_turnDelegate = [[MulticastDelegate alloc] init];
        //_delegate = (id)_turnDelegate;
    }
    
    return self;
}

-(void)setGameBoardArray:(GameBoardArray *)gameBoardArray {
    _gameBoardArray = gameBoardArray;
    
    // Give gameBoardArray to scoreManager
    _scoreManager.gameBoardArray = gameBoardArray;
}

-(void)setGameScene:(GameScene *)gameScene {
    _gameScene = gameScene;
    
    //Disable play button
    [_gameScene gameStateTempEmpty:([self isTempEmpty])];
}

- (void)clearTempBoard
{
    memset(_tempboard, 0, sizeof(NSUInteger) * 12 * 12);
}

- (void)clearLastPlayed
{
    //Push LastPlayed to Perm
    for (int i = 0; i < GRID_SIZE; i++)
    {
        for (int j = 0; j < GRID_SIZE; j++)
        {
            if ( _lastPlayerboard[i][j] ) {
                BoardCellState state = [_gameBoardArray cellStateAtColumn:i andRow:j];
                [_gameBoardArray setCellState:state forColumn:i andRow:j type:PERMANENT_MOVE];
            }
        }
    }
    
    memset(_lastPlayerboard, 0, sizeof(BOOL) * 12 * 12);
}

#pragma mark Place Tile

-(BOOL)isBlankAtColumn:(NSInteger)column andRow:(NSInteger)row
{
    // check the cell is empty
    if ([_gameBoardArray cellStateAtColumn:column andRow:row] != BoardCellStateEmpty)
        return NO;
    
    return YES;
}

- (void)makeTempToColumn:(NSInteger)column Row:(NSInteger)row andState:(BoardCellState)state
{
    // Place the playing piece at the given location
    [_gameBoardArray setCellState:state forColumn:column andRow:row type:TEMP_MOVE];
    _tempboard[column][row] = state;
    
    //Disable play button - if tempBoard is empty
    [_gameScene gameStateTempEmpty:([self isTempEmpty])];
}

- (void)makeLatestMoveToColumn:(NSInteger)column Row:(NSInteger)row andState:(BoardCellState)state
{
    // Place the playing piece at the given location
    [_gameBoardArray setCellState:state forColumn:column andRow:row type:LAST_PLAYED];
    _lastPlayerboard[column][row] = ( state == BoardCellStateEmpty ) ? NO : YES ;
}

- (void)makeMoveToColumn:(NSInteger)column Row:(NSInteger)row andState:(BoardCellState)state
{
    // place the playing piece at the given location
    [_gameBoardArray setCellState:state forColumn:column andRow:row type:PERMANENT_MOVE];
}

-(void)pushTomakeMove
{
    // Clear last played
    [self clearLastPlayed];
    
    for (int i = 0; i < GRID_SIZE; i++)
    {
        for (int j = 0; j < GRID_SIZE; j++)
        {
            //Move tempboard move to real board
            if (_tempboard[i][j] != 0)
            {
                // Push Temp Board to Real Board
                BoardCellState state = [_gameBoardArray cellStateAtColumn:i andRow:j];
                //[self makeMoveToColumn:i Row:j andState:state];
                
                // Make move to lastPlayed
                [self makeLatestMoveToColumn:i Row:j andState:state];
            }
        }
    }
    
    // Clear Temp Board
    [self clearTempBoard];

    //Disable play button
    [_gameScene gameStateTempEmpty:([self isTempEmpty])];
}

#pragma mark Evaluate Move

-(BOOL) boardisValidWithErrorString: (NSString**) error {
    
    //test that there are tiles on the starting space
    if(![self onStarting]){
        *error = @"Starting spaces must be occupied.";
        return NO;
    }
    
    //Ensure strightness and direction of equation
    if(![self ensureStraight] || !_legal)
    {
        *error = @"Tiles must be placed in a line adjacent to existing tiles.";
        return NO;
    }
    
    //Test that all tiles are on the same island
    if([self countIslands] >1){
        *error = @"Tiles must be placed adjacent to existing tiles.";
        return NO;
    }
    else
    {
        //check there is a maximum of 3
        int count = 0;
        for (int i = 0; i < GRID_SIZE; ++i)
        {
            for (int j = 0; j < GRID_SIZE; ++j)
            {
                if (_tempboard[j][i] != 0)
                {
                    count++;
                    if (count > 3)
                    {
                        *error = @"Only three tiles may be played at once.";
                        return NO;
                    }
                }
            }
        }
    }
    
    //determin score
    if (![self findScore])
    {
        *error = @"Expression must contain only whole, positive number.";
        return NO;
    }
    
    //No longer first turn
    _firstturn = NO;
    
    //Reset legal flag
    _legal = NO;
    
    return YES;
}

/*
 * Ensure tiles are on the starting space; game rules
 */
-(BOOL) onStarting
{
    if([_gameBoardArray cellStateAtColumn:2 andRow:9]||[_gameBoardArray cellStateAtColumn:2 andRow:8]||[_gameBoardArray cellStateAtColumn:3 andRow:9]||[_gameBoardArray cellStateAtColumn:3 andRow:8])
        return YES;
    else
        return NO;
}

/**
 ***** Ensure the proposed tiles are all in a line; not in multiple rows and columns *****
 */
-(BOOL) ensureStraight
{
    
    int row = -1;
    int col = -1;
    
    BOOL horiz = NO;
    BOOL vert = NO;
    
    for (int i = 0; i < GRID_SIZE; ++i)
    {
        for (int j = 0; j < GRID_SIZE; ++j)
        {
            //For every non-empty space on the tempBoard
            if (_tempboard[j][i] != 0)
            {
                //Get the tile
                BoardCellState state = _tempboard[j][i];
                
                if (row == -1)
                {
                    row = i;
                    col = j;
                    if(state > 0 && state < 10)
                    {
                        //If the state is a number...
                        int status = [self numberDirectionalcol:j androw:i];
                        if (status == 0)
                            return NO;
                        if (status == 1)
                            vert = TRUE;
                        if (status == 2)
                            horiz = TRUE;
                    }
                    
                    else if(state > 9)
                    {
                        //If the state is an operation...
                        int status = [self operationDirectionalcol:j androw:i];
                        if (status == 0)
                            return NO;
                        if (status == 1)
                            vert = TRUE;
                        if (status == 2)
                            horiz = TRUE;
                    }
                }
                else if (row == i && !vert)
                {
                    horiz = YES;
                    if(state > 0 && state < 10)
                    {
                        int status = [self numberDirectionalcol:j androw:i];
                        if (status == 0)
                            return NO;
                        if (status == 1)
                            vert = TRUE;
                        if (status == 2)
                            horiz = TRUE;
                    }
                    
                    else if(state > 9)
                    {
                        int status = [self operationDirectionalcol:j androw:i];
                        if (status == 0)
                            return NO;
                        if (status == 1)
                            vert = TRUE;
                        if (status == 2)
                            horiz = TRUE;
                    }
                }
                else if (col == j && !horiz)
                {
                    vert = YES;
                    if(state > 0 && state < 10)
                    {
                        int status = [self numberDirectionalcol:j androw:i];
                        if (status == 0)
                            return NO;
                        if (status == 1)
                            vert = TRUE;
                        if (status == 2)
                            horiz = TRUE;
                    }
                    
                    else if(state > 9)
                    {
                        int status = [self operationDirectionalcol:j androw:i];
                        if (status == 0)
                            return NO;
                        if (status == 1)
                            vert = TRUE;
                        if (status == 2)
                            horiz = TRUE;
                    }
                }
                else
                {
                    return NO;
                }
            }
        }
    }
    return YES;
}

-(int) numberDirectionalcol:(int) col androw:(int)row
{
    // These arrays are used to get row and column numbers of 8 neighbors
    // of a given cell
    static int rowNbr[] = {-1, 1, 0,  0};
    static int colNbr[] = { 0, 0, 1, -1};
    
    BOOL horiz = NO;
    BOOL vert = NO;
    
    for (int k = 0; k < 2; ++k)
        //For the tiles above and below the given tile...
        if ([self isSafewithrow:row+rowNbr[k] col:col andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col andRow:row+rowNbr[k]]>9)
        {
            //If the adjacent tile is an operation...
            if ([self isSafewithrow:row+2*rowNbr[k] col:col andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col andRow:row+2*rowNbr[k]] >0 && [_gameBoardArray cellStateAtColumn:col andRow:row+2*rowNbr[k]] <10)
            {
                //If the second adjacent tile is a number...
                vert = YES;
                if (_firstturn)
                {
                    _legal = YES;
                }
                
                //Account for corner case - gaps!
                if (!_tempboard[col][row+rowNbr[k]] || !_tempboard[col][row+2*rowNbr[k]])
                {
                    _legal = YES;
                }
            }
        }
    
    for (int k = 2; k < 4; ++k)
        //For the tiles left and right the given tile...
        if ([self isSafewithrow:row col:col+colNbr[k] andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col+colNbr[k] andRow:row]>9)
        {
            //If the adjacent tile is an operation...
            if ([self isSafewithrow:row col:col+2*colNbr[k] andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col+2*colNbr[k] andRow:row] >0 && [_gameBoardArray cellStateAtColumn:col+2*colNbr[k] andRow:row] <10)
            {
                //If the second adjacent tile is a number...
                horiz = YES;
                if (_firstturn)
                {
                    _legal = YES;
                }
                
                //Account for corner case - gaps!
                if (!_tempboard[col+colNbr[k]][row] || !_tempboard[col+2*colNbr[k]][row])
                {
                    _legal = YES;
                }
            }
        }
    if((vert && horiz) || (!vert && !horiz))
    {
        //Tiles can't be placed both horz and vert
        return 0;
    }
    else if(vert && !horiz)
    {
        _scoreManager.direction = YES;
        return 1;
    }
    else if(!vert && horiz)
    {
        _scoreManager.direction = NO;
        return 2;
    }
    return 0;
}

-(int) operationDirectionalcol:(int) col androw:(int)row
{
    // These arrays are used to get row and column numbers of 8 neighbors
    // of a given cell
    static int rowNbr[] = {-1, 1, 0,  0};
    static int colNbr[] = { 0, 0, 1, -1};
    
    BOOL horiz = NO;
    BOOL vert = NO;
    
    for (int k = 0; k < 2; ++k)
        //For the tiles above and below the given tile...
        if ([self isSafewithrow:row+rowNbr[k] col:col andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col andRow:row+rowNbr[k]] >0 && [_gameBoardArray cellStateAtColumn:col andRow:row+rowNbr[k]] <10)
        {
            //If the above tile is an operation...
            if ([self isSafewithrow:row-rowNbr[k] col:col andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col andRow:row-rowNbr[k]] >0 && [_gameBoardArray cellStateAtColumn:col andRow:row-rowNbr[k]] <10)
            {
                //If the below tile is an operation...
                vert = YES;
                if (_firstturn)
                {
                    _legal = YES;
                }
                
                //Account for corner case - gaps!
                if (!_tempboard[col][row+rowNbr[k]] || !_tempboard[col][row-rowNbr[k]])
                {
                    _legal = YES;
                }
            }
        }
    
    for (int k = 2; k < 4; ++k)
        //For the tiles left and right the given tile...
        if ([self isSafewithrow:row col:col+colNbr[k] andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col+colNbr[k] andRow:row] >0 && [_gameBoardArray cellStateAtColumn:col+colNbr[k] andRow:row] <10)
        {
            //If the left tile is an operation...
            if ([self isSafewithrow:row col:col-colNbr[k] andVisitedarray:NULL] && [_gameBoardArray cellStateAtColumn:col-colNbr[k] andRow:row] >0 && [_gameBoardArray cellStateAtColumn:col-colNbr[k] andRow:row] <10)
            {
                //If the right tile is an operation...
                horiz = YES;
                if (_firstturn)
                {
                    _legal = YES;
                }
                
                //Account for corner case - gaps!
                if (!_tempboard[col+colNbr[k]][row] || !_tempboard[col-colNbr[k]][row])
                {
                    _legal = YES;
                }
            }
        }
    if((vert && horiz) || (!vert && !horiz))
    {
        //Tiles can't be placed both horz and vert
        return 0;
    }
    else if(vert && !horiz)
    {
        _scoreManager.direction = YES;
        return 1;
    }
    else if(!vert && horiz)
    {
        _scoreManager.direction = NO;
        return 2;
    }
    return 0;
}

-(int) countIslands
{
    // Make a bool array to mark visited cells.
    // Initially all cells are unvisited
    bool visited[GRID_SIZE][GRID_SIZE];
    memset(visited, 0, sizeof(visited));
    
    // Initialize count as 0 and travese through the all cells of
    // given matrix
    int count = 0;
    for (int i = 0; i < GRID_SIZE; ++i)
        for (int j = 0; j < GRID_SIZE; ++j)
            if ([_gameBoardArray cellStateAtColumn:j andRow:i] && !visited[j][i]) // If a cell with value 1 is not  visited yet, then new island found
            {
                [self DFSwithrow:i col:j andVisitedarray:visited];     // Visit all cells in this island.
                ++count;                   // and increment island count
            }
    
    return count;
}

// the 8 neighbors as adjacent vertices
-(void) DFSwithrow:(int)row col:(int)col andVisitedarray:(bool[GRID_SIZE][GRID_SIZE])visited
{
    // These arrays are used to get row and column numbers of 8 neighbors
    // of a given cell
    static int rowNbr[] = {-1,  0, 0, 1};
    static int colNbr[] = { 0, -1, 1, 0};
    
    // Mark this cell as visited
    visited[col][row] = true;
    
    // Recur for all connected neighbours
    for (int k = 0; k < 4; ++k)
        if ([self isSafewithrow:row + rowNbr[k] col:col + colNbr[k] andVisitedarray:visited])
            [self DFSwithrow:row + rowNbr[k] col:col + colNbr[k] andVisitedarray:visited];
}

#pragma mark Scoring

-(BOOL) findScore {
    float score;
    score = [_scoreManager determinScorewithtempBoard:_tempboard];
    if (fmod(score, 1.0) != 0.0)
    {
        return NO;
    }
    if (score < 0.0)
    {
        return NO;
    }
    
    [self setFirstScore:_firstScore +fabsf(20-score)];
    
//    if (_nextMove == FirstPlayer){
//        _firstScore = _firstScore +fabsf(20-score);
//        if(_gameScene){
//            [self updateScores];
//        }
//    }
//    if (_nextMove == SecondPlayer){
//        _secondScore = _secondScore +fabsf(20-score);
//        if(_gameScene){
//            [self updateScores];
//        }
//    }
    return YES;
}

-(void) setFirstScore:(NSInteger)firstScore {
    _firstScore = firstScore;
    
    [_gameScene gameStateScoreUpdated:firstScore];
}

#pragma mark Helpers

-(BOOL) isTempEmpty
{
    BOOL result = YES;
    for (int i = 0; i < GRID_SIZE; ++i)
    {
        for (int j = 0; j < GRID_SIZE; ++j)
        {
            if (_tempboard[j][i] != 0)
            {
                result = NO;
            }
        }
    }
    return result;
}
    


-(int) isSafewithrow:(int) row col:(int)col andVisitedarray:(bool[GRID_SIZE][GRID_SIZE]) visited
{
    if (visited != NULL)
    {
        return (row >= 0) && (row < GRID_SIZE) &&     // row number is in range
        (col >= 0) && (col < GRID_SIZE) &&     // column number is in range
        ([_gameBoardArray cellStateAtColumn:col andRow:row] && !visited[col][row]); // value is 1 and not yet visited
    }
    else
    {
        return (row >= 0) && (row < GRID_SIZE) &&     // row number is in range
        (col >= 0) && (col < GRID_SIZE);
    }
}

#pragma mark Pass/Swap

-(void) clearTempBoardToRack {
    for (int i = 0; i < GRID_SIZE; i++)
    {
        for (int j = 0; j < GRID_SIZE; j++)
        {
            //For every occupied space; place that tile back on the rack
            if (_tempboard[i][j] != 0)
            {
                [_gameScene valueToRack:_tempboard[i][j]];
                
                [self makeMoveToColumn:i Row:j andState:BoardCellStateEmpty];
            }
        }
    }
    
    [self clearTempBoard];
    
    //Disable play button
    [_gameScene gameStateTempEmpty:([self isTempEmpty])];
}

-(void) increaseScoreBy: (NSInteger) delta {
    [self setFirstScore:_firstScore + delta];
}

#pragma mark Set/Retrieve last cell value

-(NSMutableArray*) returnLastPlayedArray
{
    NSMutableArray* board = [[NSMutableArray alloc] init];
    for (int i = 0; i < GRID_SIZE; i++)
    {
        NSMutableArray* subboard = [[NSMutableArray alloc] init];
        for (int j = 0; j < GRID_SIZE; j++)
        {
            [subboard addObject:[NSNumber numberWithBool:_lastPlayerboard[i][j]]];
        }
        [board addObject:subboard];
    }
    
    return board;
}

-(void) updateLastPlayedArray:(NSMutableArray*) newArray {
    
    // Clear last played
    [self clearLastPlayed];
    
    //Set board as determined
    for (int i = 0; i < GRID_SIZE; i++)
    {
        for (int j = 0; j < GRID_SIZE; j++)
        {
            if ( [(NSNumber*)newArray[i][j] boolValue] ) {
                // Add to lastPlayed Array and update display
                _lastPlayerboard[i][j] = [(NSNumber*)newArray[i][j] boolValue];
                BoardCellState state = [_gameBoardArray cellStateAtColumn:i andRow:j];
                [_gameBoardArray setCellState:state forColumn:i andRow:j type:LAST_PLAYED];
            }
        }
    }
}

@end
