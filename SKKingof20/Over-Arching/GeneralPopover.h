//
//  GeneralPopover.h
//  SKKingof20
//
//  Created by Ishmael King on 5/1/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef GeneralPopover_h
#define GeneralPopover_h

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

@interface GeneralPopover : SKNode

/// Editable error visuals
@property (nonatomic, readwrite, strong) SKTexture *networkTexture;
@property (nonatomic, readwrite, strong) SKTexture *unknownTexture;
@property (nonatomic, readwrite, strong) SKTexture *loginTexture;
@property (nonatomic, readwrite, strong) SKTexture *gameCenterTexture;

#pragma mark Init

/**
 * Convenience creation method.
 *
 * @param size The size required for the Menu.
 */
-(id) initWithSize:(CGSize) size;

#pragma mark Change Display

/**
 * Show/Remove popover
 *
 * @param error Error number associated with error display
 */
-(void) showWithError:(NSError*) error;
-(void) removeError;

@end

#endif /* GeneralPopover_h */
