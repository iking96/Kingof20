//
//  PastGameButtons.h
//  SKKingof20
//
//  Created by Ishmael King on 4/10/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef PastGameButtons_h
#define PastGameButtons_h

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import <GameKit/GameKit.h>
#import "CustomKTButton.h"

@interface PastGameButtons : CustomKTButton <UIGestureRecognizerDelegate>

/// Selectors to be called on action
@property (nonatomic, readonly) SEL actionQuitButton;

/// Target assosiated with each selector
@property (nonatomic, readonly, weak) id targetQuitButton;

/// Init method
- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled labelLastPlayed:(NSString*) lastPlayedPropt opponentName:(NSString*) opponentNamePropt activeGameState:(NSString*) activeGameStatePrompt match:(GKTurnBasedMatch*) match; // Designated Initializer

/// Respond to swipe
- (void) handleSwipe:(BOOL) allowDelete;

/** Sets the target-action pair, that is called when the Quit Button is tapped.
 "target" won't be retained.
 */
- (void)setQuitTarget:(id)target action:(SEL)action;

@end

#endif /* PastGameButtons_h */
