//
//  BoardDelegate.h
//  1Kingof20
//
//  Created by Ishmael King on 5/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardCellState.h"
#import "MoveType.h"

@protocol BoardDelegate <NSObject>

- (void)cellStateChanged:(BoardCellState)state forColumn:(NSInteger)column andRow:(NSInteger) row type:(MoveType) type;

@end
