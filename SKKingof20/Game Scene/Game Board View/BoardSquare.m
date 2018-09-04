//
//  BoardSquare.m
//  SKKingof20
//
//  Created by Ishmael King on 2/5/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardSquare.h"
#import "MoveType.h"

static const double DEG_TO_RAD = M_PI / 180;
static const int NUM_FONT_SIZE = 50;
static const int PLUS_OVER_FONT_SIZE = 25;
static const int TIMES_MINUS_FONT_SIZE = 20;

@interface BoardSquare()

/// Row/Column identifiers
@property NSInteger row;
@property NSInteger column;

@end

@implementation BoardSquare  {
    
    /// Text Nodes
    SKLabelNode* _numberText;
    SKLabelNode* _operationText;
    
    /// Touch toggle
    BOOL _allowTouch;
    
    /// Temp tile used when square is selected
    RackSquare* _selectedSquare;
    
    /// Textures
    SKTexture* _normal;
    SKTexture* _tempPlacement;
}

#pragma mark Square Initilization

- (id) initWithPosition:(CGPoint)position size:(CGSize)size column:(NSInteger)column row:(NSInteger)row {
    
    _normal = [SKTexture textureWithImageNamed:@"Tile_Board.png"];
    _tempPlacement = [SKTexture textureWithImageNamed:@"Tile_Board_Temp.png"];

    if ( self = [super initWithTexture:_normal] ) {
        
        // No touching initially
        [self setUserInteractionEnabled:NO];
        _allowTouch = NO;
        
        // Position and size node
        self.position = position;
        self.size = size;
        
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
        
        // Set identifier
        _row = row;
        _column = column;
        
        // Hide self until made visible
        self.hidden = YES;
    }
    
    return self;
}

-(void) setGameBoardArray:(GameBoardArray *)gameBoardArray {
    _gameBoardArray = gameBoardArray;
    
    // Add self to delegate list - will get notifications
    [_gameBoardArray.boardDelegate addDelegate:self];
}

#pragma mark Square State Changes

- (void)cellStateChanged:(BoardCellState)state forColumn:(NSInteger)column andRow:(NSInteger)row type:(MoveType) type
{
    if ((column == _column && row == _row) ||
        (column == -1 && row == -1))
    {
        // Update tiles if selected tile
        [self update: type];
    }
}

- (void)update:(MoveType)type
{
    // show / hide the images based on the cell state
    NSInteger value = [_gameBoardArray cellStateAtColumn:_column andRow:_row];
    
    self.hidden = NO;
    self.userInteractionEnabled = (type == TEMP_MOVE) ? YES : NO; // Moveable is temp placement
    _allowTouch =  (type == TEMP_MOVE) ? YES : NO; // Moveable is temp placement
    UIColor* visibleColor = (type == LAST_PLAYED) ? [UIColor colorWithRed:240.0f/255.0f green:218.0f/255.0f blue:94.0f/255.0f alpha:1] : [UIColor whiteColor];
    _numberText.hidden = YES;
    _operationText.hidden = YES;
    
    // Change Texture if needed
    SKTexture* visibleTexture = (type == TEMP_MOVE) ? _tempPlacement : _normal;
    self.texture = visibleTexture;
    
    //Change alpha of tile depending on state
    if (value == BoardCellStateEmpty)
    {
        self.hidden = YES;
        _allowTouch = NO;
        self.userInteractionEnabled = NO;
    }
    else if (value > BoardCellStateEmpty && value < BoardCellStatePlus)
    {
        // Should be a number
        _numberText.hidden = NO;
        _numberText.fontColor = visibleColor;
        [self setNumberText:value];
    }
    else if (value >= BoardCellStatePlus)
    {
        // Should be an operation
        _operationText.hidden = NO;
        _operationText.fontColor = visibleColor;
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

#pragma mark Square Touch Mecahnics

/**
 * This method only occurs, if the touch was inside this node.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_allowTouch)
    {
        // Find empty rack square
        _selectedSquare = [_gameRack emptyRackSquare];
        
        // Set it to board value - prepare for touch
        _selectedSquare.value = [_gameBoardArray cellStateAtColumn:_column andRow:_row];
        _selectedSquare.allowTouch = YES;
        
        // Clear board square
        [_gameState makeTempToColumn:_column Row:_row andState:BoardCellStateEmpty];
        
        // "Delegate" to RackSquare touch handeler
        [_selectedSquare touchesBegan:touches withEvent:event];
        
        // For allowTouch
        _allowTouch = YES;
    }
}

/**
 * This method only occurs, if the touch was inside this node.
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //if (_allowTouch)
    if (YES)
    {
        // "Delegate" to RackSquare touch handeler
        [_selectedSquare touchesMoved:touches withEvent:event];
    }
}

/**
 * This method only occurs, if the touch was inside this node.
 */
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //if (_allowTouch)
    if (YES)
    {
        
        // Square is clear stop interaction
        _allowTouch = NO;
        self.userInteractionEnabled = NO;
        
        // "Delegate" to RackSquare touch handeler
        [_selectedSquare touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
    }
}

/**
 * This method only occurs, if the touch was inside this node.
 */
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

@end
