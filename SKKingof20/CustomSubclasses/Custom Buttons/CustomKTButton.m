//
//  CustomKTButton.m
//  SKKingof20
//
//  Created by Ishmael King on 1/21/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomKTButton.h"

@implementation CustomKTButton

#pragma mark Texture Initializer

/**
 * Override the super-classes designated initializer, to get a properly set SKButton in every case
 */
- (id)initWithTexture:(SKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    return [self initWithTextureNormal:texture selected:nil disabled:nil];
}

- (id)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected {
    return [self initWithTextureNormal:normal selected:selected disabled:nil];
}

/**
 * This is the designated Initializer
 */
- (id)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected disabled:(SKTexture *)disabled {
    self = [super initWithTexture:normal color:[UIColor whiteColor] size:normal.size];
    if (self) {
        [self setNormTexture:normal];
        [self setSelectedTexture:selected];
        [self setDisabledTexture:disabled];
        [self setIsEnabled:YES];
        [self setIsSelected:NO];
        
        _title = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        [_title setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_title setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self addChild:_title];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

#pragma mark Image Initializer

- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected {
    return [self initWithImageNamedNormal:normal selected:selected disabled:nil];
}

- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled {
    SKTexture *textureNormal = nil;
    if (normal) {
        textureNormal = [SKTexture textureWithImageNamed:normal];
    }
    
    SKTexture *textureSelected = nil;
    if (selected) {
        textureSelected = [SKTexture textureWithImageNamed:selected];
    }
    
    SKTexture *textureDisabled = nil;
    if (disabled) {
        textureDisabled = [SKTexture textureWithImageNamed:disabled];
    }
    
    return [self initWithTextureNormal:textureNormal selected:textureSelected disabled:textureDisabled];
}

#pragma -
#pragma mark Setting Target-Action pairs

- (void)setTouchUpInsideTarget:(id)target action:(SEL)action object:(id) object {
    _targetTouchUpInside = target;
    _actionTouchUpInside = action;
    _targetObject = object;
}

- (void)setTouchDownTarget:(id)target action:(SEL)action object:(id) object {
    _targetTouchDown = target;
    _actionTouchDown = action;
    _targetObject = object;
}

- (void)setTouchUpTarget:(id)target action:(SEL)action object:(id) object {
    _targetTouchUp = target;
    _actionTouchUp = action;
    _targetObject = object;
}

#pragma -
#pragma mark Setter overrides

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    if ([self disabledTexture]) {
        if (!_isEnabled) {
            [self setTexture:_disabledTexture];
        } else {
            [self setTexture:_normTexture];
        }
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if ([self selectedTexture] && [self isEnabled]) {
        if (_isSelected) {
            [self setTexture:_selectedTexture];
        } else {
            [self setTexture:_normTexture];
        }
    }
}

#pragma -
#pragma mark Touch Handling

/**
 * This method only occurs, if the touch was inside this node. Furthermore if
 * the Button is enabled, the texture should change to "selectedTexture".
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        if ( _targetObject ) {
            [_targetTouchDown performSelector:_actionTouchDown withObject:_targetObject];
        } else {
            [_targetTouchDown performSelector:_actionTouchDown];
        }
        //objc_msgSend(_targetTouchDown, _actionTouchDown);
        [self setIsSelected:YES];
    }
}

/**
 * If the Button is enabled: This method looks, where the touch was moved to.
 * If the touch moves outside of the button, the isSelected property is restored
 * to NO and the texture changes to "normalTexture".
 *
 * CHANGE: Any movement turns off selection
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];
        
//        [self setIsSelected:NO];

//        if (CGRectContainsPoint(self.frame, touchPoint)) {
//            [self setIsSelected:YES];
//        } else {
//            [self setIsSelected:NO];
//        }
        
        if (!CGRectContainsPoint(self.frame, touchPoint)) {
            [self setIsSelected:NO];
        }
    }
}

/**
 * If the Button is enabled AND the touch ended in the buttons frame, the
 * selector of the target is run.
 *
 * CHANGE: Button must also have been selected
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.parent];
    
    if ([self isEnabled] && _isSelected && CGRectContainsPoint(self.frame, touchPoint)) {
        if ( _targetObject ) {
            [_targetTouchUpInside performSelector:_actionTouchUpInside withObject:_targetObject];
        } else {
            [_targetTouchUpInside performSelector:_actionTouchUpInside];
        }
        //objc_msgSend(_targetTouchUpInside, _actionTouchUpInside);
    }
    [self setIsSelected:NO];
    if ( _targetObject ) {
        [_targetTouchUp performSelector:_actionTouchUp withObject:_targetObject];
    } else {
        [_targetTouchUp performSelector:_actionTouchUp];
    }
    //objc_msgSend(_targetTouchUp, _actionTouchUp);
}
@end
