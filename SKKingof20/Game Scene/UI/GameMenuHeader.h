//
//  GameMenuHeader.h
//  SKKingof20
//
//  Created by Ishmael King on 3/15/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GameMenuHeader_h
#define GameMenuHeader_h

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

@interface GameMenuHeader : SKNode

/**
 * Convenience creation method.
 *
 * @param size The size required for the Menu.
 */
-(id) initWithSize:(CGSize) size;

/**
 * Update score display.
 *
 * @param score New score.
 */
-(void) updateFirstPlayerScore: (NSInteger) score;
-(void) updateSecondPlayerScore: (NSInteger) score;
-(void) updatePlayerNames:(NSString*)firstName and:(NSString*)secondName;

#pragma mark Animations

-(void) animateTurn:(BOOL)myTurn;

@end
#endif /* GameMenuHeader_h */
