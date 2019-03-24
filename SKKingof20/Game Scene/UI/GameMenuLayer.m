//
//  GameMenuLayer.m
//  SKKingof20
//
//  Created by Ishmael King on 1/28/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameMenuLayer.h"
#import "CustomKTButton.h"

static const int SWAP_POPOVER_MOVE_DIST = 305;
static const int TOP_CENTER_NODE_RESTING = 400;
static const int BOTTOM_CENTER_NODE_RESTING = -425;

@interface GameMenuLayer()

// Animations
@property NSMutableArray<SKTexture*>*  buttonAnimationFrames;

// Buttons
@property CustomKTButton* playButton;
@property CustomKTButton* passButton;
@property CustomKTButton* swapButton;
@property CustomKTButton* moreButton;
@property CustomKTButton* shuffleButton;
@property SKLabelNode* shuffleRecallLabel;
@property CustomKTButton* recallButton;
@property CustomKTButton* confirmButton;
@property CustomKTButton* cancelButton;
@property CustomKTButton* tilesButton;

// Popovers
@property SKSpriteNode* distubutionNode;
@property SKSpriteNode* warningPopover;
@property SKSpriteNode* errorPopover;
@property SKSpriteNode* persistancePopover; // Set via setter
@property SKSpriteNode* swapPopover;
@property SKSpriteNode* gameShader;

@property SKLabelNode* warningText;
@property SKLabelNode* errorText;

// Header
@property GameMenuHeader* headerNode;

@end

@implementation GameMenuLayer {
    CGSize _size;
    
    SKAction* _popoverDown;
    SKAction* _popoverUp;
    SKAction* _popoverPop;
    
    bool moreActive;
    bool morePrevPlayToggle;
}

#pragma mark Node Initilization

-(id) initWithSize:(CGSize)size {
    self = [super init];
    
    _size = size;
    _buttonAnimationFrames = [[NSMutableArray alloc] init];
    moreActive = false;
    
    /**
     * TOP OVERLAY
    **/
    // Create Back Button
    CustomKTButton* backButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Back_Button.png" selected:@"Game_Scene_Back_Button.png"];
    backButton.position = CGPointMake((-_size.width)/2 + 50, ((TOP_CENTER_NODE_RESTING+(_size.height)/2)/2)-TOP_CENTER_NODE_RESTING+5);
    [backButton setTouchUpInsideTarget:self action:@selector(backButtonPressed) object:nil];
    [backButton setZPosition:1];
    
    // Create Tiles Button
    _tilesButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Tiles_Active.png" selected:@"Game_Scene_Tiles_Active.png"];
    _tilesButton.position = CGPointMake((_size.width)/2 - 110, 0);
    [_tilesButton setTouchUpInsideTarget:self action:@selector(tilesButtonPressed) object:nil];
    [_tilesButton setZPosition:0];
    
    // Create Warning Popover
    _warningPopover = [SKSpriteNode spriteNodeWithImageNamed:@"Game_Scene_Warning_Popover.png"];
    _warningPopover.position = CGPointMake(-(_size.width)/2 + 250, (_warningPopover.size.height/2)+10);
    _warningText = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [_warningText setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_warningText setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    _warningText.position = CGPointMake( 0, -15);
    _warningText.fontSize = 32;
    [_warningPopover addChild:_warningText];
    [_warningPopover setZPosition:0];
    
    // Create Error Popover
    _errorPopover = [SKSpriteNode spriteNodeWithImageNamed:@"Game_Scene_Error_Popover.png"];
    _errorPopover.position = CGPointMake(-(_size.width)/2 + 250, (_warningPopover.size.height/2)+10);
    _errorText = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [_errorText setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_errorText setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    _errorText.position = CGPointMake( 0, -15);
    _errorText.fontSize = 32;
    [_errorPopover addChild:_errorText];
    [_errorPopover setZPosition:0];
    
    _persistancePopover = nil;
    
    CGFloat popoverHight = _warningPopover.size.height/2;
    
    // Create popover actions
    _popoverDown = [SKAction sequence:@[
                                        [SKAction moveToY:popoverHight+10 duration:.25 ],
                                        [SKAction moveToY:0 duration:.25 ]
                                        ]];
    
    _popoverUp = [SKAction sequence:@[
                                      [SKAction moveToY:popoverHight+10 duration:.25 ]
                                      ]];
    
//    _popoverPop = [SKAction sequence:@[
//                                      _popoverDown,
//                                      [SKAction waitForDuration:3 ],
//                                      _popoverUp
//                                      ]];
    
    // Create Header Node
    _headerNode = [[GameMenuHeader alloc] initWithSize:size];
    [_headerNode setZPosition:1];
    _headerNode.position = CGPointMake( 0, ((TOP_CENTER_NODE_RESTING+(_size.height)/2)/2)-TOP_CENTER_NODE_RESTING+5);
    
    // Create top overlay
    SKSpriteNode* topLayover = [SKSpriteNode spriteNodeWithImageNamed:@"Game_Scene_Top_Overlay.png"];
    [topLayover setZPosition:1];
    topLayover.anchorPoint = CGPointMake(.5, 0);
    
    SKNode* topCenterNode = [SKNode node]; //Top-Center Node
    topCenterNode.position = CGPointMake(0, (_size.height)/2);
    [topCenterNode addChild:topLayover];
    [topCenterNode addChild:backButton];
    [topCenterNode addChild:_tilesButton];
    [topCenterNode addChild:_headerNode];
    [topCenterNode addChild:_warningPopover];
    [topCenterNode addChild:_errorPopover];


    [topCenterNode runAction:[SKAction sequence:@[
                                                  [SKAction moveToY:TOP_CENTER_NODE_RESTING duration:.5 ]
                                                  ]]];
    /**
     * BOTTOM OVERLAY
     **/
    // Create Play Button
    _playButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Play_Active.png" selected:@"Game_Scene_Play_Active.png" disabled:@"Game_Scene_Play_Unactive.png"];
    _playButton.position = CGPointMake(0, -75);
    [_playButton setTouchUpInsideTarget:self action:@selector(playButtonPressed) object:nil];
    
    // Create More Button
    _moreButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"more1.png" selected:@"more1.png" disabled:@"more1.png"];
    _moreButton.position = CGPointMake( -210, -65);
    [_moreButton setTouchUpInsideTarget:self action:@selector(moreButtonPressed) object:nil];
    SKLabelNode* moreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    [moreLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [moreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    moreLabel.position = CGPointMake( -210, -115);
    moreLabel.fontSize = 25;
    moreLabel.text = @"MORE";
    
    // Create GameScene shader
    _gameShader = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:_size]; //center Node
    [_gameShader setAlpha:.25];
    [_gameShader setZPosition:1];
    _gameShader.hidden = true;
    
    // Create Shuffle Button
    _shuffleButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Shuffle.png" selected:@"Game_Scene_Shuffle.png" disabled:@"Game_Scene_Shuffle.png"];
    _shuffleButton.position = CGPointMake( 210, -65);
    [_shuffleButton setTouchUpInsideTarget:self action:@selector(shuffleButtonPressed) object:nil];
    _shuffleRecallLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    [_shuffleRecallLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_shuffleRecallLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    _shuffleRecallLabel.position = CGPointMake( 210, -115);
    _shuffleRecallLabel.fontSize = 25;
    _shuffleRecallLabel.text = @"SHUFFLE";
    
    // Create Shuffle Button
    _recallButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Recall.png" selected:@"Game_Scene_Recall.png" disabled:@"Game_Scene_Recall.png"];
    _recallButton.position = CGPointMake( 210, -65);
    [_recallButton setTouchUpInsideTarget:self action:@selector(recallButtonPressed) object:nil];
    _recallButton.hidden = YES;
    
//    // Create Swap Button
//    _swapButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Swap_Active.png" selected:@"Game_Scene_Swap_Active.png" disabled:@"Game_Scene_Swap_Unactive.png"];
//    _swapButton.position = CGPointMake( 210, -75);
//    [_swapButton setTouchUpInsideTarget:self action:@selector(swapButtonPressed) object:nil];
//    
//    // Create Cancel Button
//    _cancelButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Cancel_Active.png" selected:@"Game_Scene_Cancel_Active.png"];
//    _cancelButton.position = CGPointMake( 210, -75);
//    [_cancelButton setTouchUpInsideTarget:self action:@selector(cancelButtonPressed) object:nil];
//    _cancelButton.hidden = YES;
//    
//    // Create Confirm Button
//    _confirmButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Confirm_Active.png" selected:@"Game_Scene_Confirm_Active.png"];
//    _confirmButton.position = CGPointMake( -210, -75);
//    [_confirmButton setTouchUpInsideTarget:self action:@selector(confirmButtonPressed) object:nil];
//    _confirmButton.hidden = YES;
//    
//    // Create Pass Button
//    _passButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Pass_Active.png" selected:@"Game_Scene_Pass_Active.png" disabled:@"Game_Scene_Pass_Unactive.png"];
//    _passButton.position = CGPointMake( -210, -75);
//    [_passButton setTouchUpInsideTarget:self action:@selector(passButtonPressed) object:nil];
//    
//    // Create Pass Button
//    _swapPopover = [SKSpriteNode spriteNodeWithImageNamed:@"Game_Scene_Swap_Popup.png"];
//    _swapPopover.anchorPoint = CGPointMake(.5, 1);
//    _swapPopover.position = CGPointMake( 0, 0 );
    
    // Create bottom overlay
    SKSpriteNode* bottom_layover = [SKSpriteNode spriteNodeWithImageNamed:@"Game_Scene_Bottom_Overlay.png"];
    bottom_layover.anchorPoint = CGPointMake(.5, 1);
    
    SKNode* bottomCenterNode = [SKNode node]; //Bottom-Center Node
    bottomCenterNode.position = CGPointMake(0, -(_size.height)/2);
    [bottomCenterNode setZPosition:1];
//    [bottomCenterNode addChild:_swapPopover];
    [bottomCenterNode addChild:bottom_layover];
    [bottomCenterNode addChild:_playButton];
    [bottomCenterNode addChild:_moreButton];
    [bottomCenterNode addChild:moreLabel];
    [bottomCenterNode addChild:_shuffleButton];
    [bottomCenterNode addChild:_recallButton];
    [bottomCenterNode addChild:_shuffleRecallLabel];
//    [bottomCenterNode addChild:_swapButton];
//    [bottomCenterNode addChild:_cancelButton];
//    [bottomCenterNode addChild:_confirmButton];
//    [bottomCenterNode addChild:_passButton];

    [bottomCenterNode runAction:[SKAction sequence:@[
                                                  [SKAction moveToY:BOTTOM_CENTER_NODE_RESTING duration:.5]
                                                  ]]];
    
    // Create Tile Distribution
    SKSpriteNode* tile_distribution = [SKSpriteNode spriteNodeWithImageNamed:@"Tile_Distribution.png"];
    _tileTotalText = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    [_tileTotalText setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_tileTotalText setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    _tileTotalText.position = CGPointMake(161, 170);
    _tileTotalText.fontSize = 30;
    _tileTotalText.text = @"0";
    
    // Create TD close Button
    CustomKTButton* closeButton = [[CustomKTButton alloc] initWithImageNamedNormal:@"Tile_Distribution_Close_Button.png" selected:@"Tile_Distribution_Close_Button.png"];
    closeButton.position = CGPointMake( -(tile_distribution.size.width/2) , (tile_distribution.size.height/2) );
    [closeButton setTouchUpInsideTarget:self action:@selector(closeTileDistribution) object:nil];
    
    // Add collect tile distribution assets
    _distubutionNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:_size]; //center Node
    [_distubutionNode addChild:tile_distribution];
    [_distubutionNode addChild:_tileTotalText];
    [_distubutionNode addChild:closeButton];
    [_distubutionNode setZPosition:100]; // Above everything
    _distubutionNode.hidden = YES;
    
    // Make Collector Nodes Visible
    [self addChild:_gameShader];
    [self addChild:topCenterNode];
    [self addChild:bottomCenterNode];
    [self addChild:_distubutionNode];

    
    return self;
}

#pragma mark Button Selectors

-(void) backButtonPressed {
    // Tell GameScene to go back
    [_gameScene shouldBack];
}

-(void) tilesButtonPressed {
    // Make Tile Distribution Visible
    _distubutionNode.hidden = NO;
    //_tileTotalText = [@(value) stringValue]
    _tileTotalText.text = [@([_gameScene requestAvailableTileCount]) stringValue];
}

-(void) closeTileDistribution {
    // Make Tile Distribution Invisible
    _distubutionNode.hidden = YES;
}

-(void) playButtonPressed {
    // Tell GameScene to evaluate move
    [_gameScene handlePlayAttempt];
}

-(void) moreButtonPressed {
    
    [self buildAnimationFramesfromatlasNamed:@"more"];
    
    if ( moreActive ) {
        // Reverse frames if more is active
        _buttonAnimationFrames = [[[_buttonAnimationFrames reverseObjectEnumerator] allObjects] mutableCopy];
        
        // Remove shader
        _gameShader.hidden = true;
        
        // Enable play button - If applicable
        [self disablePlaybutton:!morePrevPlayToggle];
        
    } else {
        _gameShader.hidden = false;
        
        // Disable play button
        morePrevPlayToggle = _playButton.isEnabled;
        [self disablePlaybutton:true];
    }
    
    moreActive = !moreActive;
    
    // Make SKAction gif
    SKAction* repeatGIF = [SKAction animateWithTextures:_buttonAnimationFrames timePerFrame:0.05 resize:true restore:false];
    
    [_moreButton setNormTexture:_buttonAnimationFrames.lastObject];
    [_moreButton runAction:repeatGIF];
    
}

-(void) shuffleButtonPressed {
    // Tell GameScene to shuffle tiles
    [_gameScene handleShuffle];
}

-(void) recallButtonPressed {
    // Tell GameScene to shuffle tiles
    [_gameScene handleRecall];
    
    // Force play to be disabled if more is active
    if ( moreActive ) {
        morePrevPlayToggle = false;
    }
}

//-(void) swapButtonPressed {
//    // Tell GameScene to evaluate swap
//    [_gameScene handleSwap];
//
//    // Disable/Enable buttons
//    _swapButton.hidden = YES;
//    _passButton.hidden = YES;
//
//    _confirmButton.hidden = NO;
//    _cancelButton.hidden = NO;
//
//    // Move popover
//    [_swapPopover runAction:[SKAction moveToY:SWAP_POPOVER_MOVE_DIST duration:.25 ]];
//
//}

-(void) cancelButtonPressed {
    // Tell GameScene to evaluate swap
    [_gameScene handleSwapCancel];
    
    // Disable/Enable buttons
    _swapButton.hidden = NO;
    _passButton.hidden = NO;
    
    _confirmButton.hidden = YES;
    _cancelButton.hidden = YES;
    
    // Move popover
    [_swapPopover runAction:[SKAction moveToY:0 duration:.25 ]];
}

-(void) confirmButtonPressed {
    // Tell GameScene to evaluate swap
    if ( [_gameScene handleSwapConfirm] ) {
        // Disable/Enable buttons - if swap was confirmed
        _swapButton.hidden = NO;
        _passButton.hidden = NO;
        
        _confirmButton.hidden = YES;
        _cancelButton.hidden = YES;
        
        // Move popover
        [_swapPopover runAction:[SKAction moveToY:0 duration:.25 ]];
    }
}

-(void) passButtonPressed {
    // Tell GameScene to about pass
    [_gameScene handlePass];
}

#pragma -
#pragma mark Setter overrides

-(void)setParticipantScore:(NSInteger)participantScore {
    _participantScore = participantScore;
}

-(void)setOpponantScore:(NSInteger)opponantScore {
    _opponentScore = opponantScore;
}

#pragma -
#pragma mark Disable/Enable for reasons

-(void) disableButtonsForTileMoving:(BOOL) should_disable {
    
    // Soft Disable/Enable action buttons
    _playButton.userInteractionEnabled = !should_disable;
    _passButton.userInteractionEnabled = !should_disable;
    _swapButton.userInteractionEnabled = !should_disable;
    _tilesButton.userInteractionEnabled = !should_disable;
    _moreButton.userInteractionEnabled = !should_disable;
    _shuffleButton.userInteractionEnabled = !should_disable;
    _recallButton.userInteractionEnabled = !should_disable;

}

-(void) disablePlaybutton:(BOOL) should_disable {
    
    // Disable/Enable action buttons
    _playButton.isEnabled = !should_disable;
    
}

-(void) disableSwapbutton:(BOOL) should_disable {
    
    // Disable/Enable action buttons
    _swapButton.isEnabled = !should_disable;
    
}

-(void) disablePassbutton:(BOOL) should_disable {
    
    // Disable/Enable action buttons
    _passButton.isEnabled = !should_disable;
    
}

-(void) shuffleRecallToggle:(BOOL) should_shuffle {
    
    // If "should_shuffle"; do that
    _shuffleButton.hidden = !should_shuffle;
    if (should_shuffle){
     _shuffleRecallLabel.text = @"SHUFFLE";
    }
    
    _recallButton.hidden = should_shuffle;
    if (!should_shuffle) {
        _shuffleRecallLabel.text = @"RECALL";
    }
}

#pragma -
#pragma mark Change Display

-(void) updatePlayerNames:(NSString*)firstName and:(NSString*)secondName {
    
    NSString* firstNameProcessed = [[firstName componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString* secondNameProcessed = [[secondName componentsSeparatedByString:@" "] objectAtIndex:0];
    
    // DEBUG
    //firstNameProcessed = @"Tyler";
    //secondNameProcessed = @"Maddy";

    // Shorten Name to 12 chacters
    _participantName = (firstNameProcessed.length > 12) ? [NSString stringWithFormat:@"%@...", [firstNameProcessed substringToIndex:10]] : firstNameProcessed;
    
    if ( secondName ) {
        _opponentName = (secondNameProcessed.length > 12) ? [NSString stringWithFormat:@"%@...", [secondNameProcessed substringToIndex:10]] : secondNameProcessed;
    } else {
        _opponentName = @"Searching...";
    }
    
    [_headerNode updatePlayerNames:_participantName and:_opponentName];
}

-(void) updateFirstPlayerScore: (NSInteger) score {
    [_headerNode updateFirstPlayerScore:score];
}

-(void) updateSecondPlayerScore: (NSInteger) score {
    [_headerNode updateSecondPlayerScore:score];
}

-(void) setPersistanceText:(NSString *)persistanceText {
    _persistanceText = persistanceText;
    _persistancePopover = _errorPopover;
}

-(void) removePersistanceText {
    _persistancePopover = nil;
}

-(void) popverPersistant {
    
    // Put everything up just incase
    [self popoverUp];
    
    if ( _persistancePopover ) {
        [_persistancePopover runAction:_popoverDown];
        _errorText.text = _persistanceText;
    }
}

-(void) popoverDown:(PopoverType) type andString:(NSString*) message {
    
    // Put everything up just incase
    [self popoverUp];
    
    SKSpriteNode* movingNode = (type == ErrorPopover) ? _errorPopover : _warningPopover;
    SKLabelNode* changingLabel = (type == ErrorPopover) ? _errorText : _warningText;
    changingLabel.text = message;
    
    // Stop Previous Actions - move down
    [movingNode removeAllActions];
    [movingNode runAction:_popoverDown];
}

-(void) popoverUp {
    
    // Move both popovers up
    [_errorPopover removeAllActions];
    [_errorPopover runAction:_popoverUp];
    
    [_warningPopover removeAllActions];
    [_warningPopover runAction:_popoverUp];
}

//-(void) popoverPop:(PopoverType) type andString:(NSString*) message {
//
//    SKSpriteNode* movingNode = (type == ErrorPopover) ? _errorPopover : _warningPopover;
//    SKLabelNode* changingLabel = (type == ErrorPopover) ? _errorText : _warningText;
//
//    // Move Persistance Popover Up - if existing
//    if ( _persistancePopover ) {
//        [_persistancePopover removeAllActions];
//        [_persistancePopover runAction:_popoverUp completion:^(void) {
//            changingLabel.text = message;
//            // Stop Previous Actions - pop
//            [movingNode removeAllActions];
//            [movingNode runAction:_popoverPop completion:^(void) {
//                // Move Persistance Popover Down
//                if ( _persistancePopover ) {
//                    [_persistancePopover removeAllActions];
//                    [_persistancePopover runAction:_popoverDown];
//                    _errorText.text = _persistanceText;
//                }
//            }];
//        }];
//    } else {
//        changingLabel.text = message;
//        // Stop Previous Actions - pop
//        [movingNode removeAllActions];
//        [movingNode runAction:_popoverPop completion:^(void) {
//            // Move Persistance Popover Down
//            if ( _persistancePopover ) {
//                [_persistancePopover removeAllActions];
//                [_persistancePopover runAction:_popoverDown];
//                _errorText.text = _persistanceText;
//            }
//        }];
//    }
//
//}

#pragma mark Other animations

-(void) animateHeader:(BOOL)myTurn {
    [_headerNode animateTurn:myTurn];
}

-(void) buildAnimationFramesfromatlasNamed:(NSString *)baseName {
    SKTextureAtlas* AnimatedAtlas = [SKTextureAtlas atlasNamed:baseName];
    NSMutableArray<SKTexture*>* animationFrames = [[NSMutableArray alloc] init];
    
    NSUInteger numImages = AnimatedAtlas.textureNames.count;
    for ( int i = 1; i <=numImages; i++ ) {
        NSString * textureName = [NSString stringWithFormat:@"%@%d",baseName,i];
        [animationFrames addObject:[AnimatedAtlas textureNamed:textureName]];
    }
    _buttonAnimationFrames = animationFrames;
}

@end
