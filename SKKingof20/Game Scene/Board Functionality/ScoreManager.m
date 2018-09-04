//
//  ScoreManager.m
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreManager.h"
#import "GameBoardArray.h"

@interface ScoreManager()

/// Array to collect temp tiles - as pair [x][x+1]
@property NSMutableArray* tempTiles;

/// Record if all temp tiles have been found
@property BOOL first;
@property BOOL second;
@property BOOL third;

@end

static const NSInteger GRID_SIZE = 12;

@implementation ScoreManager

#pragma mark Class Initilization

-(id) init
{
    if ( self = [super init] ) {
        
        // Init _tempTiles
        _tempTiles = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark Score Calculator

-(float) determinScorewithtempBoard:(NSUInteger[GRID_SIZE][GRID_SIZE]) temp
{
    
    // Reset for new calculation
    BOOL further = YES;
    _first = NO;
    _second = NO;
    _third = NO;
    [_tempTiles removeAllObjects];
    
    for (int i = 0; i < GRID_SIZE && further; ++i)
    {
        for (int j = 0; j < GRID_SIZE && further; ++j)
        {
            //For every non-empty element on the tempboard; record its coordinates
            if (temp[j][i] != 0)
            {
                [_tempTiles addObject:[NSNumber numberWithInt:i]];
                [_tempTiles addObject:[NSNumber numberWithInt:j]];
            }
        }
    }
    further = YES;
    
    //Bring row and col to the start of the expression
    for (int i = 0; i < GRID_SIZE && further; ++i)
    {
        for (int j = 0; j < GRID_SIZE && further; ++j)
        {
            if (temp[j][i] != 0)
            {
                further = NO;
                if (_direction)//vert
                {
                    int row = i;
                    
                    // Re-wind to start of expression
                    while ([self isSafewithrow:row+1 col:j] && [_gameBoardArray cellStateAtColumn:j andRow:row+1] != 0)
                    {
                        row++;
                    }
                    
                    // Calculate score vertically
                    if ([_gameBoardArray cellStateAtColumn:j andRow:row] > 9)
                        return [self Scorecol:j androw:row-1];
                    return [self Scorecol:j androw:row];
                }
                if (!_direction)//horiz
                {
                    int col = j;
                    
                    // Re-wind to start of expression
                    while ([self isSafewithrow:i col:col-1] && [_gameBoardArray cellStateAtColumn:col-1 andRow:i] != 0)
                    {
                        col--;
                    }
                    
                    // Calculate score horizontally
                    if ([_gameBoardArray cellStateAtColumn:col andRow:i] > 9)
                        return [self Scorecol:col+1 androw:i];
                    return [self Scorecol:col androw:i];
                }
            }
        }
    }
    //Will count as an invalid move
    return -100;
}

/**
 * From starting row and col find score
 */
-(float) Scorecol:(int)col androw:(int)row
{
    float scoreCount = 0.0;
    if (_direction)//vert
    {
        //Array to collect numbers
        NSMutableArray* numbers = [[NSMutableArray alloc] init];
        //Add first one
        [numbers addObject:[NSNumber numberWithInteger:[_gameBoardArray cellStateAtColumn:col andRow:row]]];
        
        //Have we accounted for a temp tile?
        [self isIntempcol:col row:row];
        
        //Init score count
        scoreCount = [(NSNumber*)numbers[0] floatValue];
        int rowCounter = row;
        
        //Record all the numbers in the expression
        while ([self isSafewithrow:rowCounter-2 col:col] && [_gameBoardArray cellStateAtColumn:col andRow:rowCounter-1] != 0 && [_gameBoardArray cellStateAtColumn:col andRow:rowCounter-2] != 0)
        {
            //Add new number
            [numbers addObject:[NSNumber numberWithInteger:[_gameBoardArray cellStateAtColumn:col andRow:rowCounter-2]]];
            
            //Have we accounted for a temp tile?
            [self isIntempcol:col row:rowCounter-2];
            rowCounter = rowCounter-2;
        }
        
        //Reset for operations
        rowCounter = row-1;
        for (int k = 0; k < [numbers count]-1; k++)
        {
            //For each suspected operation...
            int state = [_gameBoardArray cellStateAtColumn:col andRow:rowCounter];
            if (state == 10)
            {
                //Addition
                scoreCount = scoreCount+[(NSNumber*)numbers[k+1] floatValue];
            }
            else if (state == 11)
            {
                //Subtraction
                scoreCount = scoreCount-[(NSNumber*)numbers[k+1] floatValue];
                if (scoreCount < 0.0)
                {
                    //No negatives
                    return -100;
                }
            }
            else if (state == 12)
            {
                //Division
                scoreCount = scoreCount/[(NSNumber*)numbers[k+1] floatValue];
                if (fmod(scoreCount, 1.0) != 0.0)
                {
                    //No fractions
                    return -100;
                }
            }
            else if (state == 13)
            {
                //Multiplication
                scoreCount = scoreCount*[(NSNumber*)numbers[k+1] floatValue];
            }
            
            //Have we accounted for a temp tile?
            [self isIntempcol:col row:rowCounter];
            rowCounter = rowCounter-2;
        }
        if (_first && _second && _third){
            return scoreCount;
        } else {
            //If we did not find all temp tiles
            return -100;
        }
    }
    if (!_direction)//horiz
    {
        //Array to collect numbers
        NSMutableArray* numbers = [[NSMutableArray alloc] init];
        
        //Add the first one
        [numbers addObject:[NSNumber numberWithInteger:[_gameBoardArray cellStateAtColumn:col andRow:row]]];
        
        //Have we accounted for a temp tile?
        [self isIntempcol:col row:row];
        //Init score count
        scoreCount = [(NSNumber*)numbers[0] floatValue];
        int colCounter = col;
        
        //Record all the numbers in the expression
        while ([self isSafewithrow:row col:colCounter+2] && [_gameBoardArray cellStateAtColumn:colCounter+1 andRow:row] != 0 && [_gameBoardArray cellStateAtColumn:colCounter+2 andRow:row] != 0)
        {
            //Record new number
            [numbers addObject:[NSNumber numberWithInteger:[_gameBoardArray cellStateAtColumn:colCounter+2 andRow:row]]];
            
            //Have we accounted for a temp tile?
            [self isIntempcol:colCounter+2 row:row];
            colCounter = colCounter+2;
        }
        
        //Reset for operations
        colCounter = col+1;
        for (int k = 0; k < [numbers count]-1; k++)
        {
            //For each suspected operation...
            int state = [_gameBoardArray cellStateAtColumn:colCounter andRow:row];
            if (state == 10)
            {
                //Addition
                scoreCount = scoreCount+[(NSNumber*)numbers[k+1] floatValue];
            }
            else if (state == 11)
            {
                //Subtraction
                scoreCount = scoreCount-[(NSNumber*)numbers[k+1] floatValue];
                if (scoreCount < 0.0)
                {
                    //No negative numbers.
                    return -100;
                }
            }
            else if (state == 12)
            {
                //Division
                scoreCount = scoreCount/[(NSNumber*)numbers[k+1] floatValue];
                if (fmod(scoreCount, 1.0) != 0.0)
                {
                    //No fractions.
                    return -100;
                }
            }
            else if (state == 13)
            {
                //Multiplication
                scoreCount = scoreCount*[(NSNumber*)numbers[k+1] floatValue];
            }
            
            //Have we accounted for a temp tile?
            [self isIntempcol:colCounter row:row];
            colCounter = colCounter+2;
        }
        if (_first && _second && _third){
            return scoreCount;
        } else {
            //If we did not find all temp tiles.
            return -100;
        }
    }
    return -100;
}

-(void)isIntempcol:(int)col row:(int)row
{
    //If there is only one set of coordinates then _second and _thid don't matter
    if([_tempTiles count] <= 2){
        _second = YES;
        _third = YES;
    }
    //If there are only two sets of coordinates then _thid dosen't matter
    if([_tempTiles count] <= 4){
        _third = YES;
    }
    //If we found the following coordinates; then the corresponding tile has been found
    if([_tempTiles count] >= 2 && [(NSNumber*)_tempTiles[0] integerValue] == row && [(NSNumber*)_tempTiles[1] integerValue] == col){
        _first = YES;
    }
    if([_tempTiles count] >= 4 && [(NSNumber*)_tempTiles[2] integerValue] == row && [(NSNumber*)_tempTiles[3] integerValue] == col){
        _second = YES;
    }
    if([_tempTiles count] >= 6 && [(NSNumber*)_tempTiles[4] integerValue] == row && [(NSNumber*)_tempTiles[5] integerValue] == col){
        _third = YES;
    }
}

#pragma mark Helpers

-(int) isSafewithrow:(int) row col:(int)col
{
    return (row >= 0) && (row < GRID_SIZE) &&     // row number is in range
    (col >= 0) && (col < GRID_SIZE);
}

@end
