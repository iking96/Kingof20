//
//  GameMenuLayer.h
//  SKKingof20
//
//  Created by Ishmael King on 1/28/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GameMenuLayer_h
#define GameMenuLayer_h

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "SceneOrganizerViewController.h"
#import "GameScene.h"
#import "GameMenuHeader.h"

typedef NS_ENUM(NSUInteger, PopoverType) {
    ErrorPopover = 0,
    WarningPopover = 1
};

@interface GameMenuLayer : SKNode

/**
 * Convenience creation method.
 *
 * @param size The size required for the Menu.
 */
-(id) initWithSize:(CGSize) size;

/// Corresponding gameScene - handels button pressed actions
@property GameScene* gameScene;

/// Displayed participant score
@property (nonatomic) NSInteger participantScore;
/// Displayed opponant score
@property (nonatomic) NSInteger opponentScore;

/// Displayed tile amount
@property SKLabelNode* tileTotalText;

/// A persistance error when set via setter
@property (nonatomic) NSString* persistanceText;

/// Names of both players
@property (nonatomic) NSString* participantName;
@property (nonatomic) NSString* opponentName;
#pragma mark Disable/Enable for reasons

/**
 * Disablers.
 *
 * @param should_disable True if it should be disabled.
 */
-(void) disableButtonsForTileMoving:(BOOL) should_disable;
-(void) disablePlaybutton:(BOOL) should_disable;
-(void) disablePassbutton:(BOOL) should_disable;
-(void) disableSwapbutton:(BOOL) should_disable;

#pragma mark Score/Popovers for reasons

/**
 * Update score display.
 *
 * @param score New score.
 */
-(void) updateFirstPlayerScore: (NSInteger) score;
-(void) updateSecondPlayerScore: (NSInteger) score;
-(void) updatePlayerNames:(NSString*)firstName and:(NSString*)secondName;

/**
 * Pop a message
 * @param message - NSString to display
 * @param type - PopoverType to display
 */
-(void) popoverDown:(PopoverType) type andString:(NSString*) message;

/**
 * Show persistance popover
 */
-(void) popverPersistant;

/**
 * Remove persistance popover
 */
-(void) removePersistanceText;

#pragma mark Other animations

-(void) animateHeader:(BOOL)myTurn;

@end

#endif /* GameMenuLayer_h */
