//
//  RackSqure.m
//  SKKingof20
//
//  Created by Ishmael King on 1/30/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "math.h"
#import "RackSquare.h"
#import "BoardCellState.h"

static const double DEG_TO_RAD = M_PI / 180;
static const int NUM_FONT_SIZE = 75;
static const int PLUS_OVER_FONT_SIZE = 35;
static const int TIMES_MINUS_FONT_SIZE = 30;

@interface RackSquare()

// Nothing

@end

@implementation RackSquare {
    
    /// Text Nodes
    SKLabelNode* _numberText;
    SKLabelNode* _operationText;
    
    /// Initial position when moving
    CGPoint _initialPosition;
}

#pragma mark Square Initilization

-(id) init {
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"Tile_Racked"]];
    
    [self setUserInteractionEnabled:YES];
    _allowTouch = YES;
    _swapping = NO;
    _selected = NO;
    
    _numberText = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    _operationText = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    
    // Center Everything
    [_numberText setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_numberText setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    _numberText.fontSize = NUM_FONT_SIZE;
    [_operationText setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_operationText setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [_operationText setZRotation:(-45*DEG_TO_RAD)];
    _operationText.fontSize = PLUS_OVER_FONT_SIZE;

    [self addChild:_numberText];
    [self addChild:_operationText];

    return self;
}

-(void)setAvailableTiles:(TileCollection *)availableTiles {
    _availableTiles = availableTiles;
    
    // Call value setter
    [self setValue:[_availableTiles retreiveState]];
}

#pragma mark Square Updated / Should Update

-(void)setValue:(BoardCellState)value {
    _value = value;
    
    // Premptively display tile - with hidden text
    self.hidden = NO;
    self.allowTouch = YES;
    _numberText.hidden = YES;
    _operationText.hidden = YES;

    //Change alpha of tile depending on state
    if (value == BoardCellStateEmpty)
    {
        // Should be empty
        self.hidden = YES;
        self.allowTouch = NO;
    }
    else if (value > BoardCellStateEmpty && value < BoardCellStatePlus)
    {
        // Should be a number
        _numberText.hidden = NO;
        [self setNumberText:value];
    }
    else if (value >= BoardCellStatePlus)
    {
        // Should be an operation
        _operationText.hidden = NO;
        [self setOperationText:value];
    }
    
}

-(void)setNumberText:(BoardCellState) value {
    _numberText.text = [@(value) stringValue];
}

-(void)setOperationText:(BoardCellState) value {
    if ( value == BoardCellStatePlus )
    {
        _operationText.text = @"Plus";
        _operationText.fontSize = PLUS_OVER_FONT_SIZE;
    }
    else if ( value == BoardCellStateMinus )
    {
        _operationText.text = @"Minus";
        _operationText.fontSize = TIMES_MINUS_FONT_SIZE;
    }
    else if ( value == BoardCellStateOver )
    {
        _operationText.text = @"Over";
        _operationText.fontSize = PLUS_OVER_FONT_SIZE;
    }
    else if ( value == BoardCellStateTimes )
    {
        _operationText.text = @"Times";
        _operationText.fontSize = TIMES_MINUS_FONT_SIZE;
    }
}

-(void) refillSquare {
    
    // Call value setter
    [self setValue:[_availableTiles retreiveState]];
    
}

#pragma mark Square Touch Mecahnics

/**
 * This method only occurs, if the touch was inside this node.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_allowTouch) {
        if (_swapping) {
            if (_selected) {
                [self setSelected:NO];
            } else {
                // Save non-selected position - disable touch
                _initialPosition = self.position;
                
                [self setSelected:YES];
            }
            
            return;
        } else {
            
            // Tell GameScene tile is moving
            _gameScene.tileIsMoving = YES;
            
            // Get initial state to use later and move with the touch
            //_initialPosition = self.position;
            UITouch* firstTouch = [touches allObjects][0];
            self.position = [firstTouch locationInNode:(SKNode*)self.parent];
        }
    }
}

/**
 * This method only occurs, if the touch was inside this node.
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_swapping) {
        return;
    } else if (_allowTouch) {
        // Tell GameScene tile is moving
        _gameScene.tileIsMoving = YES;
        
        // Move with touch
        UITouch* firstTouch = [touches allObjects][0];
        self.position = [firstTouch locationInNode:(SKNode*)self.parent];
    }
}

/**
 * This method only occurs, if the touch was inside this node.
 */
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_swapping) {
        return;
    } else if (_allowTouch) {
        
        UITouch* firstTouch = [touches allObjects][0];
        if ( [_gameScene tileDroppedWithTouch:firstTouch andValue:_value] ) {
            // Tile could be placed - Rack space empty
            [self setValue:BoardCellStateEmpty];
            
        } else {
            // Tile could not be placed - Do nothing
        }
        
        // Return to initial potision
        self.position = _initialPosition;
        
        // Tell GameScene tile is done moving - and where it dropped
        _gameScene.tileIsMoving = NO;
        [_gameScene tileDroppedWithTouch:firstTouch andValue:_value];
        
    }
}

/**
 * This method only occurs, if the touch was cancelled.
 */
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark Helpers

-(BOOL) isEmpty {
    
    if ( _value == BoardCellStateEmpty ) {
        return YES;
    }
    
    return NO;
}

-(void)setSelected:(BOOL)selected {
    _selected = selected;
    
    [self setUserInteractionEnabled:NO];
    _allowTouch = NO;
    
    if (_selected) {
        SKAction* moveUp = [SKAction moveToY:_initialPosition.y+100 duration:.1 ];
        [self runAction:moveUp completion:^(void){
            
            //Enable touch
            [self setUserInteractionEnabled:YES];
            self->_allowTouch = YES;
        }];
    } else {
        SKAction* moveDown = [SKAction moveToY:_initialPosition.y duration:.1 ];
        [self runAction:moveDown completion:^(void){
            
            //Enable touch
            [self setUserInteractionEnabled:YES];
            self->_allowTouch = YES;
        }];
    }
}

-(void)setInitPosition:(CGPoint)position {
    self.position = position;
    _initialPosition = position;
}

@end
