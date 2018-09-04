//
//  BoardCellState.h
//  SKKingof20
//
//  Created by Ishmael King on 1/28/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef BoardCellState_h
#define BoardCellState_h

typedef NS_ENUM(NSUInteger, BoardCellState) {
    BoardCellStateEmpty = 0,
    BoardCellStateOne = 1,
    BoardCellStateTwo = 2,
    BoardCellStateThree = 3,
    BoardCellStateFour = 4,
    BoardCellStateFive = 5,
    BoardCellStateSix = 6,
    BoardCellStateSeven = 7,
    BoardCellStateEight = 8,
    BoardCellStateNine = 9,
    BoardCellStatePlus = 10,
    BoardCellStateMinus = 11,
    BoardCellStateOver = 12,
    BoardCellStateTimes = 13,
    FirstPlayer = 14,
    SecondPlayer = 15
};

#endif /* BoardCellState_h */
