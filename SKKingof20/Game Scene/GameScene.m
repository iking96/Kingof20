//
//  RulesScene.m
//  SKKingof20
//
//  Created by Ishmael King on 1/23/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameScene.h"
#import "CustomScrollView.h"
#import "CustomKTButton.h"
#import "GameMenuLayer.h"
#import "TileCollection.h"
#import "GameRack.h"
#import "GameBoardView.h"
#import "GameBoardArray.h"
#import "GameState.h"

static const NSInteger GRID_SIZE = 12;
static const NSInteger PASS_PENALTY = 10;

static const NSInteger END_WIDTH = 1850;
//static const NSInteger END_WIDTH = 850;

@interface GameScene()

/// Layer responsible to user button interactions
@property GameMenuLayer* gameMenuLayer;

/// Class responsible for management of remaining tiles
@property TileCollection* tileCollection;

/// Class responsible for display/operation of rack
@property GameRack* gameRack;

/// Class responsible for display/operation of board tiles
@property GameBoardView* gameBoardView;

/// Class stores game array
@property GameBoardArray* gameBoardArray;

/// Class tracks game progress
@property GameState* gameState;

//Reference to variables that track game ending
@property ActiveGameState done; //NO = In play; YES = Game Over
@property NSInteger endGame;
@property BOOL myTurn;

@end

@implementation GameScene {
    
    /// Space where gameboard appears
    SKSpriteNode* _boardImage;
    
    // Track round rotation
    BOOL _startOfRound;
    BOOL _endOfRound;
    
    //Actions for end game
    SKAction* _leftIn;
    SKAction* _leftTitleIn;
    SKAction* _leftOut;
    SKAction* _rightIn;
    SKAction* _rightTitleIn;
    SKAction* _rightOut;
    SKAction* _grow;
    SKAction* _shade;
}

#pragma mark Node Initilization

- (void)sceneDidLoad {
    
    // Set endGame Params
    _endGame = NO;
    _done = kGameStateActive;
    noTilesPresented = NO;
    gameOverPresented = NO;
    
    // Place-holder values
    _startOfRound = NO;
    _endOfRound = NO;
    _myTurn = YES;

    // Create GameMenuLayer
    _gameMenuLayer = [[GameMenuLayer alloc] initWithSize:self.frame.size];
    [self addChild:_gameMenuLayer];
    _gameMenuLayer.gameScene = self;
    [_gameMenuLayer setZPosition:1]; // Above Board
    
    // Create Tile Collection
    _tileCollection = [[TileCollection alloc] init];
    
    // Create Game Rack - Assign TileCollection - Assign GameScene
    _gameRack = [[GameRack alloc] initWithSize:self.frame.size];
    [self addChild:_gameRack];
    _gameRack.availableTiles = _tileCollection;
    _gameRack.gameScene = self;
    [_gameRack setZPosition:1]; // Above board and UI
    
    _tileIsMoving = NO;
    
    // -> Separate "Board State": has game array (no more delegates)
    // -> From "Game State": Interacts with outside, has an instance of Board State
    
    // Create Game Board Array
    _gameBoardArray = [[GameBoardArray alloc] init];
    
    // Create Game State
    _gameState = [[GameState alloc] init];
    _gameState.gameBoardArray = _gameBoardArray;
    _gameState.gameScene = self;
    
    // Create Game Board View
    _boardImage = (SKSpriteNode*)[self childNodeWithName:@"gameBoard"];
    CGPoint boardImage_BotLeft = CGPointMake(_boardImage.position.x - _boardImage.size.width/2.0, _boardImage.position.y - _boardImage.size.height/2.0);
    _gameBoardView = [[GameBoardView alloc] initWithPosition:boardImage_BotLeft  size:_boardImage.size];
    [self addChild:_gameBoardView];
    [_gameBoardView setGameBoardArray:_gameBoardArray];
    [_gameBoardView setGameState:_gameState];
    [_gameBoardView setGameRack:_gameRack];
    
    // Init Actions
    _leftIn = [SKAction moveToX:2 duration:.5];
    _leftTitleIn = [SKAction moveToX:-(850/8) duration:.5];
    _leftOut = [SKAction moveToX:-END_WIDTH duration:1];
    _rightIn = [SKAction moveToX:-2 duration:.5];
    _rightTitleIn = [SKAction moveToX:(850/8) duration:.5];
    _rightOut = [SKAction moveToX:END_WIDTH duration:1];

    _grow = [SKAction scaleBy:2 duration:.5];
    _shade = [SKAction colorizeWithColorBlendFactor:.5 duration:.5];
}

#pragma mark UI Functions

-(void)shouldBack {
    NSLog(@"Go back to main menu!");
    
    [_gameState clearTempBoardToRack];
    
    // Send save game message if my turn
    if ( _myTurn ) {
        [_networkingEngine sendSaveTurnwithScore: _gameState.firstScore
                                           Rack:[_gameRack returnCurrentRack]
                                          Board:[_gameBoardArray returnCurrentArray]
                                 LastPlayedArray: [_gameState returnLastPlayedArray]
                                 AvailableTiles:[_tileCollection returnAvailableTiles]
                                  FirstTurnFlag:_gameState.firstturn
                                   ActiveGameState:self.done
                                    EndgameFlag:self.endGame
                            andCompletionHandler:^(NSError * error) {
                                if ( error ) {
                                    // PRESENT ERROR SCREEN - SHOULD NEVER BE CALLED IN CURRENT BUILDS
                                    NSLog(@"Could save because: %@", error);
                                }
                            }];
    }
    
    // Present Main
    [_sceneOrganizer presentMainScene];
}

-(void)handlePlayAttempt {
    NSLog(@"Handle Play Button!");
    
    NSString* error = @"Error not set";
    if ( [_gameState boardisValidWithErrorString: &error] ) {
        
        // Disable pass and swap
        [_gameMenuLayer disableSwapbutton:YES];
        [_gameMenuLayer disablePassbutton:YES];
        
        // Re-Fill Rack
        [_gameRack refillRack];
    
        // Push temp to actual board
        [_gameState pushTomakeMove];
        
        // Evaluate end game
        [self checkGameEndwith:_startOfRound and:_endOfRound];
        
        // Send end turn message
        [_networkingEngine sendEndTurnwithScore: _gameState.firstScore
                                           Rack:[_gameRack returnCurrentRack]
                                          Board:[_gameBoardArray returnCurrentArray]
                                LastPlayedArray: [_gameState returnLastPlayedArray]
                                 AvailableTiles:[_tileCollection returnAvailableTiles]
                                  FirstTurnFlag:_gameState.firstturn
                                   ActiveGameState:self.done
                                    EndgameFlag:self.endGame
                                        didSwap: NO
                                        didPass: NO
                           andCompletionHandler:^(NSError * error) {
                               if ( error ) {
                                   // Return to main menu - PRESENT ERROR SCREEN
                                   NSLog(@"Could not end turn because: %@", error);
                                   [self->_sceneOrganizer presentMainScene];
                               }
                           }];
        
        // Present persistance popover
        [_gameMenuLayer popverPersistant];
        [_gameMenuLayer animateHeader:NO];

    } else {
        // Present error popover
        NSLog(@"%@", error);
        [_gameMenuLayer popoverDown:ErrorPopover andString:@"Tile Placement Incorrect!"];
    }
    
}

-(void)handlePass {
    NSLog(@"Handle Pass Button!");
    
    // Clear rack and apply penelty
    [_gameState clearTempBoardToRack];
    [_gameState clearLastPlayed];
    [_gameState increaseScoreBy:PASS_PENALTY];
    
    // Disable pass and swap
    [_gameMenuLayer disableSwapbutton:YES];
    [_gameMenuLayer disablePassbutton:YES];
    
    // Evaluate end game
    [self checkGameEndwith:_startOfRound and:_endOfRound];
    
    // Send end turn message
    [_networkingEngine sendEndTurnwithScore: _gameState.firstScore
                                       Rack:[_gameRack returnCurrentRack]
                                      Board:[_gameBoardArray returnCurrentArray]
                            LastPlayedArray: [_gameState returnLastPlayedArray]
                             AvailableTiles:[_tileCollection returnAvailableTiles]
                              FirstTurnFlag:_gameState.firstturn
                               ActiveGameState:self.done
                                EndgameFlag:self.endGame
                                    didSwap: NO
                                    didPass: YES
                       andCompletionHandler:^(NSError * error) {
                           if ( error ) {
                               // Return to main menu - PRESENT ERROR SCREEN
                               NSLog(@"Could not end turn because: %@", error);
                               [self->_sceneOrganizer presentMainScene];
                           }
                        }];
    
    // Present persistance popover
    [_gameMenuLayer popverPersistant];
    [_gameMenuLayer animateHeader:NO];

}

-(void)handleSwap {
    NSLog(@"Handle Swap Button!");
    
    // Present warning
    //[_gameMenuLayer popoverDown:WarningPopover andString:@"+10 Swapping Penalty"];
    
    // Clear rack
    [_gameState clearTempBoardToRack];
    
    // Set rack to swapping
    [_gameRack beginSwap];
}

-(void)handleSwapCancel {
    
    // Return rack from swapping
    [_gameRack endSwap];
}

-(bool) handleSwapConfirm {
    
    if ( ![_gameRack confirmSwap] ) {
        // No tiles selected - present error
        [_gameMenuLayer popoverDown:ErrorPopover andString:@"No Tiles Selected!"];
        return NO;
    }
    
    // End swap
    [_gameRack endSwap];
    
    // Apply penelty
    [_gameState increaseScoreBy:PASS_PENALTY];
    
    // Disable pass and swap
    [_gameMenuLayer disableSwapbutton:YES];
    [_gameMenuLayer disablePassbutton:YES];
    
    // Clear last played
    [_gameState clearLastPlayed];

    // Evaluate end game
    [self checkGameEndwith:_startOfRound and:_endOfRound];
    
    // Send end turn message
    [_networkingEngine sendEndTurnwithScore: _gameState.firstScore
                                       Rack:[_gameRack returnCurrentRack]
                                      Board:[_gameBoardArray returnCurrentArray]
                            LastPlayedArray: [_gameState returnLastPlayedArray]
                             AvailableTiles:[_tileCollection returnAvailableTiles]
                              FirstTurnFlag:_gameState.firstturn
                               ActiveGameState:self.done
                                EndgameFlag:self.endGame
                                    didSwap: YES
                                    didPass: NO
                       andCompletionHandler:^(NSError * error) {
                           if ( error ) {
                               // Return to main menu - PRESENT ERROR SCREEN
                               NSLog(@"Could not end turn because: %@", error);
                               [self->_sceneOrganizer presentMainScene];
                           }
                       }];
    
    // Present persistance popover
    [_gameMenuLayer popverPersistant];
    [_gameMenuLayer animateHeader:NO];

    return YES;
}

-(void) handleShuffle {
    
    // Clear to rack
    [_gameState clearTempBoardToRack];
    
    // Shuffle rack
    [_gameRack shuffleRack];
    
}

-(void) handleRecall {
    
    // Clear to rack
    [_gameState clearTempBoardToRack];
    
}

-(NSUInteger) requestAvailableTileCount {
    return [_tileCollection countOfAvailableTiles];
}

#pragma mark Rack Functions

-(void)setTileIsMoving:(BOOL)tileIsMoving {
    _tileIsMoving = tileIsMoving;
    
    // Tell game menu layer tile is moving
    [_gameMenuLayer disableButtonsForTileMoving:tileIsMoving];
}

-(BOOL) tileDroppedWithTouch:(UITouch*) touch andValue:(BoardCellState) value {
    
    // Find row/col
    NSInteger row;
    NSInteger column;
    
    CGPoint touchLocation = [touch locationInNode:_boardImage];
    float x = touchLocation.x + _boardImage.size.width/2.0;
    float y = touchLocation.y + _boardImage.size.height/2.0;
    
    column = (x/(_boardImage.size.width))*GRID_SIZE;
    row = (y/(_boardImage.size.height))*GRID_SIZE;
    
    if (x < 0 || column > (GRID_SIZE-1) || y < 0 || row > (GRID_SIZE-1))
    {
        // Out of bounds don't place tile
        return NO;
    }
    else
    {
        // In bounds attempt to place tile
        if ([_gameState isBlankAtColumn:column andRow:row]) {
            
            //If valid make temp move
            [_gameState makeTempToColumn:column Row:row andState:value];
            
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

#pragma mark End Game

-(void) checkGameEndwith:(BOOL) startFlag and:(BOOL) endFlag
{
    
    _myTurn = NO;
    
    //check for endgame
    if (_endGame && startFlag == YES) {
        _endGame++;
    }
    
    if (_endGame == 3 && endFlag == YES) {
        _done = kGameStateDone;
    }
    
    //disable swap if empty
    if (![_tileCollection countOfAvailableTiles] && _endGame == 0){
        _endGame = 1;
        [_gameMenuLayer disableSwapbutton:YES];
    }
}

// Present messages once at given events
static bool noTilesPresented;
static bool gameOverPresented;
-(void) update:(NSTimeInterval)currentTime {
    //If no tiles - show message
    if ([_tileCollection countOfAvailableTiles] == 0 && _done != kGameStateDone && !noTilesPresented){
        noTilesPresented = true;
        
        NSLog(@"OUT OF TILES!");
        [_gameMenuLayer removePersistanceText];
        [_gameMenuLayer setPersistanceText:@"Out of Tiles"];
        [_gameMenuLayer popverPersistant];
    }
        
    //Game over - show message
    if (_done == kGameStateDone && !gameOverPresented){
        gameOverPresented = true;

        NSLog(@"GAME IS DONE!");
        [_gameMenuLayer removePersistanceText];
        [_gameMenuLayer setPersistanceText:@"Game Over"];
        [_gameMenuLayer popverPersistant];
        
        [self presentEndGameBummper];
    }
}

#pragma mark GameState Functions

-(void)gameStateTempEmpty:(BOOL)isEmpty {
    
    // Don't enable play if it is not our turn
    if ( isEmpty || _myTurn) {
        // Disable play button if temp is empty
        [_gameMenuLayer disablePlaybutton:isEmpty];
    }
    
    // Shuffle is Recall if temp not empty
    [_gameMenuLayer shuffleRecallToggle:isEmpty];
    
}

-(void) valueToRack:(BoardCellState) value {
    
    // Find square and fill with value
    RackSquare* selectedSquare = [_gameRack emptyRackSquare];
    selectedSquare.value = value;
    
}

-(void)gameStateScoreUpdated:(NSInteger)score {
    
    // Update score text
    [_gameMenuLayer updateFirstPlayerScore:score];
}

#pragma mark Networking

- (void)loadGamewithLS:(NSInteger)localScore OS:(NSInteger)opponantScore FT:(BOOL)firstTurn AT:(NSMutableArray *)availableArray Board:(NSMutableArray *)board LastPlayed:(NSMutableArray *) lastPlayedArray LR:(NSMutableArray *)localrack OR:(NSMutableArray *)opponantrack Complete:(ActiveGameState)done Endgame:(NSInteger)endGame first:(NSString *)firstName second:(NSString *)secondName startOfRound:(BOOL)startFlag endOfRound:(BOOL)endFlag myTurn:(BOOL)myTurn opponentPassed:(BOOL)oPassed opponentSwapped:(BOOL)oSwapped {
    
    // Remove any tiles that may be on temp board
    [_gameState clearTempBoardToRack];

    /* Update GameBoardArray - Order before _gameState
     // - board: Set within GameBoardArray and update visuals
     */
    if ( board ) {
        [_gameBoardArray updateBoard:board];
    }
    
    /* Update GameState
     // - localScore: Set within GameState and GameMenuLayer
     // - firstTurn
    */
    [_gameState setFirstScore:localScore];
    [_gameState setSecondScore:opponantScore];
    [_gameState setFirstturn:firstTurn];
    if ( lastPlayedArray ) {
        [_gameState updateLastPlayedArray:lastPlayedArray];
    }

    /* Update Game Menu Layer
     // - opponantScore: Set within GameMenuLayer
     */
    [_gameMenuLayer updateSecondPlayerScore:opponantScore];
    [_gameMenuLayer animateHeader:myTurn];
    
    // Screenshot - DEBUG
//    firstName = @"Joyce";
//    secondName = @"Rob";
    
    [_gameMenuLayer updatePlayerNames:firstName and:secondName];
    
    //DEBUG - Handel first name and second name
    
    /* Update Game Rack
     // - localrack: My rack
     */
    if ( localrack ) {
        [_gameRack setRack:localrack];
    }
    
    /* Update Tile Collection
     // - availableArray: Array of tiles left in game
    */
    if ( availableArray ) {
        [_tileCollection updateTileCollection:availableArray];
    }
    
    /* Update Game Rack
     // - done
     // - endGame
     // - startFlag
     // - endFlag
     // - myTurn
     */
    _done = done;
    _endGame = endGame;
    _startOfRound = startFlag;
    _endOfRound = endFlag;
    _myTurn = myTurn;
    
    // Show popover if opponent made non-scoring move
    if ( oPassed ) [_gameMenuLayer popoverDown:WarningPopover andString:@"Opponent Passed!"];
    if ( oSwapped ) [_gameMenuLayer popoverDown:WarningPopover andString:@"Opponent Swapped!"];
    
    // Swap/Pass active only if it is not the end game and myTurn
    if (_endGame) {
        [_gameMenuLayer disableSwapbutton:YES];
        [_gameMenuLayer disablePassbutton:YES];
    } else {
        [_gameMenuLayer disableSwapbutton:!_myTurn];
        [_gameMenuLayer disablePassbutton:!_myTurn];
    }
    
}

#pragma mark End Game Helper

-(void) presentEndGameBummper {
    SKSpriteNode* Ending_Left = (SKSpriteNode*)[self childNodeWithName:@"Ending_Left"];
    SKSpriteNode* Ending_Right = (SKSpriteNode*)[self childNodeWithName:@"Ending_Right"];
    
    SKSpriteNode* Ending_Left_Text_Box = (SKSpriteNode*)[self childNodeWithName:@"Ending_Left_Text_Box"];
    SKSpriteNode* Ending_Right_Text_Box = (SKSpriteNode*)[self childNodeWithName:@"Ending_Right_Text_Box"];
    
    // Add score label - left
    SKLabelNode*  Ending_Participant_Score = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [Ending_Participant_Score setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [Ending_Participant_Score setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    Ending_Participant_Score.position = CGPointMake( 0, 0);
    Ending_Participant_Score.fontSize = 75;
    Ending_Participant_Score.text = [@(_gameState.firstScore) stringValue];
    [Ending_Left_Text_Box addChild:Ending_Participant_Score];
    
    // Add score label - right
    SKLabelNode*  Ending_Opponent_Score = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [Ending_Opponent_Score setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [Ending_Opponent_Score setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    Ending_Opponent_Score.position = CGPointMake( 0, 0);
    Ending_Opponent_Score.fontSize = 75;
    Ending_Opponent_Score.text = [@(_gameState.secondScore) stringValue];
    [Ending_Right_Text_Box addChild:Ending_Opponent_Score];
    
    // Add name label - left
    SKLabelNode*  Ending_Participant_Text = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [Ending_Participant_Text setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [Ending_Participant_Text setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    Ending_Participant_Text.position = CGPointMake( 0, 150);
    Ending_Participant_Text.fontSize = 65;
    Ending_Participant_Text.text = _gameMenuLayer.participantName;
    [Ending_Left_Text_Box addChild:Ending_Participant_Text];
    
    // Add score label - right
    SKLabelNode*  Ending_Opponent_Text = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [Ending_Opponent_Text setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [Ending_Opponent_Text setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    Ending_Opponent_Text.position = CGPointMake( 0, 150);
    Ending_Opponent_Text.fontSize = 65;
    Ending_Opponent_Text.text = _gameMenuLayer.opponentName;
    [Ending_Right_Text_Box addChild:Ending_Opponent_Text];
    
    // Set action depending on score
    SKAction* participantAction;
    SKAction* opponentAction;
    if ( _gameState.firstScore < _gameState.secondScore ) {
        participantAction = _grow;
        opponentAction = _shade;
        Ending_Left.zPosition = 99;
    } else if ( _gameState.firstScore == _gameState.secondScore ) {
        opponentAction = [SKAction waitForDuration:.5];
        participantAction = [SKAction waitForDuration:.5];
    } else {
        opponentAction = _grow;
        participantAction = _shade;
        Ending_Right.zPosition = 99;
    }
    
    [Ending_Left runAction:[SKAction sequence:@[
                                                [SKAction waitForDuration:.5],
                                                _leftIn,
                                                [SKAction waitForDuration:.5],
                                                participantAction,
                                                [SKAction waitForDuration:2],
                                                _leftOut
                                                ]]];
    [Ending_Right runAction:[SKAction sequence:@[
                                                 [SKAction waitForDuration:.5],
                                                 _rightIn,
                                                 [SKAction waitForDuration:.5],
                                                 opponentAction,
                                                 [SKAction waitForDuration:2],
                                                 _rightOut
                                                 ]]];
    [Ending_Left_Text_Box runAction:[SKAction sequence:@[
                                                         [SKAction waitForDuration:.5],
                                                         _leftTitleIn,
                                                         [SKAction waitForDuration:3],
                                                         _leftOut
                                                         ]]];
    [Ending_Right_Text_Box runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:.5],
                                                          _rightTitleIn,
                                                          [SKAction waitForDuration:3],
                                                          _rightOut
                                                          ]]];
}

@end
