//
//  CustomKTButton.h
//  SKKingof20
//
//  Created by Ishmael King on 1/21/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef CustomKTButton_h
#define CustomKTButton_h

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

@interface CustomKTButton : SKSpriteNode

/// Selectors to be called on action
@property (nonatomic, readonly) SEL actionTouchUpInside;
@property (nonatomic, readonly) SEL actionTouchDown;
@property (nonatomic, readonly) SEL actionTouchUp;

/// Target assosiated with each selector
@property (nonatomic, readonly, weak) id targetTouchUpInside;
@property (nonatomic, readonly, weak) id targetTouchDown;
@property (nonatomic, readonly, weak) id targetTouchUp;

/// Object assosiated with every selector
//@property (nonatomic, readonly, weak) id targetObject;
@property (nonatomic, readonly) id targetObject;

/// Activity toggles
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isSelected;

/// Editable button visuals
@property (nonatomic, readonly, strong) SKLabelNode *title;
@property (nonatomic, readwrite, strong) SKTexture *normTexture;
@property (nonatomic, readwrite, strong) SKTexture *selectedTexture;
@property (nonatomic, readwrite, strong) SKTexture *disabledTexture;

/// Init methods
- (id)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected;
- (id)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected disabled:(SKTexture *)disabled; // Designated Initializer

- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected;
- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled;

/** Sets the target-action pair, that is called when the Button is tapped.
 "target" won't be retained.
 */
- (void)setTouchUpInsideTarget:(id)target action:(SEL)action object:(id) object;
- (void)setTouchDownTarget:(id)target action:(SEL)action object:(id) object;
- (void)setTouchUpTarget:(id)target action:(SEL)action object:(id) object;

@end

#endif /* CustomKTButton_h */
