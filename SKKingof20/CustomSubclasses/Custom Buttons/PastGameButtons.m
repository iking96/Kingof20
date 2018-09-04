//
//  PastGameButtons.m
//  SKKingof20
//
//  Created by Ishmael King on 4/10/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PastGameButtons.h"

@interface PastGameButtons ()

/// Label Nodes
@property (nonatomic) SKLabelNode* lastPlayedLabel;
@property (nonatomic) SKLabelNode* opponentNameLabel;

/// Match to display when pressed
@property (nonatomic) GKTurnBasedMatch* match;

/// Actions for game deletion
@property SKAction* buttonToDeletePosition;
@property SKAction* buttonToActivePosition;
@property SKAction* quitToDeletePosition;
@property SKAction* quitToActivePosition;

/// Button for quitting
@property CustomKTButton* quitButton;

@end

@implementation PastGameButtons

#pragma mark Init

/**
 * Override the super-classes designated initializer, to get a properly set SKButton in every case
 */
- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled {
    return [self initWithImageNamedNormal:normal selected:selected disabled:disabled labelLastPlayed:@"Not Set" opponentName:@"Not Set" activeGameState:@"Not Set" match:NULL];
}

/**
 * This is the designated Initializer - Overridden from CustomKTButton
 */
- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled labelLastPlayed:(NSString*) lastPlayedPropt opponentName:(NSString*) opponentNamePropt activeGameState:(NSString*) activeGameStatePrompt match:(GKTurnBasedMatch*) match {
    
    self = [super initWithImageNamedNormal:normal selected:selected disabled:disabled];
    
    if (self) {
        
        _opponentNameLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial Bold"];
        [_opponentNameLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_opponentNameLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [_opponentNameLabel setText:opponentNamePropt];
        _opponentNameLabel.position = CGPointMake(0, 15);
        _opponentNameLabel.fontSize = 45;

        NSArray *stringCollection;
        if ( lastPlayedPropt ) {
            stringCollection = [[NSArray alloc] initWithObjects:activeGameStatePrompt,@" - ",@"Last Played ", lastPlayedPropt, nil];
        } else {
            stringCollection = [[NSArray alloc] initWithObjects:activeGameStatePrompt, nil];
        }
        NSString *lastPlayedPropt = [stringCollection componentsJoinedByString:@""];
        
        _lastPlayedLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        [_lastPlayedLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_lastPlayedLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [_lastPlayedLabel setText:lastPlayedPropt];
        _lastPlayedLabel.position = CGPointMake(0, -25);
        _lastPlayedLabel.fontSize = 30;
        
        // Create Quit Button
        _quitButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Past_Game_Button_Quit.png" selected:@"Past_Game_Button_Quit.png"];
        _quitButton.position = CGPointMake(self.frame.size.width/5, 0);
        [_quitButton setIsEnabled:NO];
        _quitButton.zPosition = self.zPosition - 1;
        
        _match = match;
        
        [self addChild:_lastPlayedLabel];
        [self addChild:_opponentNameLabel];
        [self addChild:_quitButton];
        
        // Init actions
        _buttonToDeletePosition = [SKAction moveToX:-75 duration:.1 ];
        _buttonToActivePosition = [SKAction moveToX:0 duration:.1 ];
        _quitToDeletePosition = [SKAction moveToX:self.frame.size.width/4+150 duration:.1 ];
        _quitToActivePosition = [SKAction moveToX:self.frame.size.width/5 duration:.1 ];

    }
    
    return self;
}

#pragma mark Helpers

void adjustLabelFontSizeToFitRect( SKLabelNode* labelNode, CGSize size ) {
    
    // Determine the font scaling factor that should let the label text fit in the given rectangle.
    float scalingFactor = MIN(size.width / labelNode.frame.size.width, size.height / labelNode.frame.size.height);
    
    // Change the fontSize.
    labelNode.fontSize *= scalingFactor *= 0.8;
    
}

#pragma -
#pragma mark Setting Target-Action pairs

- (void)setQuitTarget:(id)target action:(SEL)action {
    _targetQuitButton = target;
    _actionQuitButton = action;
    
    [_quitButton setTouchUpInsideTarget:_targetQuitButton action:_actionQuitButton object:_match];
}

#pragma -
#pragma mark Touch Handling - Overriden from CustomKTButton class

- (void) handleSwipe:(BOOL) allowDelete {
    
    if ( allowDelete ) {
        [self runAction:_buttonToDeletePosition];
        [self setIsEnabled:NO];
        [_quitButton runAction:_quitToDeletePosition];
        [_quitButton setIsEnabled:YES];
    } else {
        [self runAction:_buttonToActivePosition];
        [self setIsEnabled:YES];
        [_quitButton runAction:_quitToActivePosition];
        [_quitButton setIsEnabled:NO];
    }
    
    NSLog(@"Gesture Preformed - %d", allowDelete);
    
}

/**
 * This method only occurs, if the touch was inside this node. Furthermore if
 * the Button is enabled, the texture should change to "selectedTexture".
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        [self.targetTouchDown performSelector:self.actionTouchDown withObject:_match];
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
        
//                [self setIsSelected:NO];
        
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
    
    if ([self isEnabled] && self.isSelected && CGRectContainsPoint(self.frame, touchPoint)) {
        [self.targetTouchUpInside performSelector:self.actionTouchUpInside withObject:_match];
        //objc_msgSend(_targetTouchUpInside, _actionTouchUpInside);
    }
    [self setIsSelected:NO];
    [self.targetTouchUp performSelector:self.actionTouchUp withObject:_match];
    //objc_msgSend(_targetTouchUp, _actionTouchUp);
}

@end
