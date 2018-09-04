//
//  TileCollection.m
//  SKKingof20
//
//  Created by Ishmael King on 1/28/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TileCollection.h"

@interface TileCollection()

/// Full list of tiles left in game
@property (nonatomic) NSMutableArray* availableTiles;

@end

@implementation TileCollection

#pragma mark Collection Initilization

-(instancetype) init
{
    self = [super init];
    _availableTiles = [NSMutableArray arrayWithObjects:@"1",@"1",@"1",@"1",@"2",@"2",@"2",@"2",@"2",@"3",@"3",@"3",@"3",@"4",@"4",@"4",@"4",@"4",@"4",@"5",@"5",@"5",@"5",@"5",@"6",@"6",@"6",@"6",@"6",@"6",@"7",@"7",@"7",@"7",@"7",@"8",@"8",@"8",@"8",@"8",@"8",@"9",@"9",@"9",@"9",@"Times",@"Times",@"Times",@"Times",@"Times",@"Times",@"Times",@"Times",@"Plus",@"Plus",@"Plus",@"Plus",@"Plus",@"Plus",@"Plus",@"Plus",@"Minus",@"Minus",@"Minus",@"Minus",@"Minus",@"Minus",@"Minus",@"Minus",@"Over",@"Over",@"Over",@"Over",@"Over", nil];

    return self;
}

-(BoardCellState) retreiveState
{
    if ([_availableTiles count]){
        int string = arc4random()%[_availableTiles count];
        BoardCellState state = [self determinState:_availableTiles[string]];
        [_availableTiles removeObjectAtIndex:string];
        return state;
    } else {
        return BoardCellStateEmpty;
    }
}

#pragma mark Mod/Interperate Collection

-(void) updateTileCollection:(NSMutableArray*) newCollection {
    _availableTiles = newCollection;
}

-(BoardCellState) determinState:(NSString*) string
{
    BoardCellState state;
    if ([string isEqual:@"1"])
    {
        state = BoardCellStateOne;
    }
    else if ([string isEqual:@"2"])
    {
        state = BoardCellStateTwo;
    }
    else if ([string isEqual:@"3"])
    {
        state = BoardCellStateThree;
    }
    else if ([string isEqual:@"4"])
    {
        state = BoardCellStateFour;
    }
    else if ([string isEqual:@"5"])
    {
        state = BoardCellStateFive;
    }
    else if ([string isEqual:@"6"])
    {
        state = BoardCellStateSix;
    }
    else if ([string isEqual:@"7"])
    {
        state = BoardCellStateSeven;
    }
    else if ([string isEqual:@"8"])
    {
        state = BoardCellStateEight;
    }
    else if ([string isEqual:@"9"])
    {
        state = BoardCellStateNine;
    }
    else if ([string isEqual:@"Times"])
    {
        state = BoardCellStateTimes;
    }
    else if ([string isEqual:@"Over"])
    {
        state = BoardCellStateOver;
    }
    else if ([string isEqual:@"Minus"])
    {
        state = BoardCellStateMinus;
    }
    else
    {
        state = BoardCellStatePlus;
    }
    return state;
}

-(void) returnState:(BoardCellState)state
{
    if (state == 1)
    {
        [_availableTiles addObject:@"1"];
    }
    else if (state == 2)
    {
        [_availableTiles addObject:@"2"];
    }
    else if (state == 3)
    {
        [_availableTiles addObject:@"3"];
    }
    else if (state == 4)
    {
        [_availableTiles addObject:@"4"];
    }
    else if (state == 5)
    {
        [_availableTiles addObject:@"5"];
    }
    else if (state == 6)
    {
        [_availableTiles addObject:@"6"];
    }
    else if (state == 7)
    {
        [_availableTiles addObject:@"7"];
    }
    else if (state == 8)
    {
        [_availableTiles addObject:@"8"];
    }
    else if (state == 9)
    {
        [_availableTiles addObject:@"9"];
    }
    else if (state == BoardCellStateTimes)
    {
        [_availableTiles addObject:@"Times"];
    }
    else if (state == BoardCellStateOver)
    {
        [_availableTiles addObject:@"Over"];
    }
    else if (state == BoardCellStateMinus)
    {
        [_availableTiles addObject:@"Minus"];
    }
    else
    {
        [_availableTiles addObject:@"Plus"];
    }
}

#pragma mark Return Collection Info


-(NSMutableArray*) returnAvailableTiles
{
    return _availableTiles;
}

-(NSUInteger) countOfAvailableTiles
{
    return [_availableTiles count];
}
@end
