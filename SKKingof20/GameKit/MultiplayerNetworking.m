//
//  MultiplayerNetworking.m
//  1Kingof20 iOS
//
//  Created by Ishmael King on 11/11/17.
//  Copyright © 2017 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiplayerNetworking.h"

// Dictionary keys
#define playerIdKey @"PlayerId"
#define playerScoreKey @"myScore"
#define playerRackKey @"myRack"
#define playerIndexKey @"myIndex"
#define playerSwapKey @"mySwap"
#define playerPassKey @"myPass"

#pragma mark Game Data Helper Class

@interface GameData : NSObject <NSCoding>

// NOTE: Remember to add more NSCoding entries as needed

    // Is the game active?
    //@property ActiveGameState gameState;

    // Current board
    @property (retain, atomic) NSMutableArray * gameBoard;

    // Current last played array
    @property (retain, atomic) NSMutableArray * gameLastPlayedArray;

    // Current tile collection
    @property (retain, atomic) NSMutableArray * availableTiles;

    // Current first-turn setting
    @property BOOL firstTurn;
    @property ActiveGameState activeState;
    @property NSInteger endGame;
    
    /** Array containing player specifics
     * - NSMutableArray of NSMutableDictionary
    **/
    @property (retain, atomic) NSMutableArray * orderOfPlayers;

@end

@implementation GameData

-(instancetype)init {
    self = [super init];
    
    self.orderOfPlayers = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    //[aCoder encodeInteger:self.gameState forKey:@"gameState"];
    [aCoder encodeObject:self.orderOfPlayers forKey:@"orderofPlayers"];
    [aCoder encodeObject:self.gameBoard forKey:@"gameBoard"];
    [aCoder encodeObject:self.gameLastPlayedArray forKey:@"lastPlayedArray"];
    [aCoder encodeObject:self.availableTiles forKey:@"availableTiles"];
    [aCoder encodeBool:self.firstTurn forKey:@"firstTurn"];
    [aCoder encodeInteger:self.activeState forKey:@"activeState"];
    [aCoder encodeInteger:self.endGame forKey:@"endGame"];
    
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    //self.gameState = [aDecoder decodeIntegerForKey:@"gameState"];
    self.orderOfPlayers = [aDecoder decodeObjectForKey:@"orderofPlayers"];
    self.gameBoard = [aDecoder decodeObjectForKey:@"gameBoard"];
    self.gameLastPlayedArray = [aDecoder decodeObjectForKey:@"lastPlayedArray"];
    self.availableTiles = [aDecoder decodeObjectForKey:@"availableTiles"];
    self.firstTurn = [aDecoder decodeBoolForKey:@"firstTurn"];
    self.activeState = [aDecoder decodeIntegerForKey:@"activeState"];
    self.endGame = [aDecoder decodeIntegerForKey:@"endGame"];

    return self;
}

@end

@implementation MultiplayerNetworking

#pragma mark Turn Handler

-(void) turnHandler:(GKTurnBasedMatch*)match isMyTurn:(BOOL)myTurn withCompletionHandler:(void (^)(NSError *))completionHandler {
    
    // Get GK shared object
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    // Load data from match
    [gameKitHelper.match loadMatchDataWithCompletionHandler: ^(NSData *matchData, NSError *error) {
        
        // If there is no match data - throw error
        if ( matchData )
        {
            // Get opponent gamekit info
            GKTurnBasedMatch* blockScopeMatch = [GameKitHelper sharedGameKitHelper].match;
            GKTurnBasedParticipant *opponent = [blockScopeMatch.participants objectAtIndex:0];
            if ([[GKLocalPlayer localPlayer].playerID isEqualToString:opponent.player.playerID]) {
                opponent = [blockScopeMatch.participants objectAtIndex:1];
            }
            
            // Unarchive game data
            GameData *gameData = [NSKeyedUnarchiver unarchiveObjectWithData:matchData];
            
            if (!gameData){
                // Check if there is any game data
                NSLog(@"No game data!");
                
                [self->_delegate loadGamewithLS:0 OS:0 FT:1 AT:nil Board:nil LastPlayed:nil LR:nil OR:nil Complete:0 Endgame:0 first:[GKLocalPlayer localPlayer].alias second:opponent.player.alias startOfRound:0 endOfRound:0 myTurn:myTurn opponentPassed:NO opponentSwapped:NO];
                
                // Ensure nil is returned for error - No error
                completionHandler(nil);
                
                return;
            }
            
            // Set Default values - should be overriden
            NSNumber* localScore = nil;
            NSMutableArray* localRack = nil;
            NSNumber* localIndex = nil;
            NSNumber* opponentScore = nil;
            NSMutableArray* opponentRack = nil;
            NSMutableArray* currentBoard = nil;
            NSMutableArray* currentArray = nil;
            NSMutableArray* availableTiles = nil;
            BOOL firstTurn = YES;
            ActiveGameState activeState = kGameStateActive;
            NSInteger endGame = 0;
            BOOL startFlag = NO;
            BOOL endFlag = NO;
            NSNumber* opponentPassed = [NSNumber numberWithBool:NO];
            NSNumber* opponentSwapped = [NSNumber numberWithBool:NO];
            
            // Check if local player is in player order
            NSUInteger localPlayerIndex = [self indexForLocalPlayer: gameData];
            if ( localPlayerIndex == -1 ) {
                // No local details available
                NSLog(@"No details for local player!");
            } else {
                // local details exist
                NSLog(@"Local details for local player exist!");
                
                /* Get local details
                 - Score
                 - Local Rack
                 - localIndex
                 - startFlag
                 - endFlag
                 */
                localScore = gameData.orderOfPlayers[localPlayerIndex][playerScoreKey];
                localRack = gameData.orderOfPlayers[localPlayerIndex][playerRackKey];
                localIndex = gameData.orderOfPlayers[localPlayerIndex][playerIndexKey];
                startFlag = (localIndex.integerValue == 0) ? YES : NO;
                endFlag = (localIndex.integerValue != 0) ? YES : NO; // Will need to change for 3+ players
            }
            
            // Check if opponent is in player order
            NSUInteger opponentPlayerIndex = [self indexForPlayerWithId:opponent.player.playerID inData: gameData];
            if ( opponentPlayerIndex == -1 ) {
                // No local details available
                NSLog(@"No details for opponent player!");
            } else {
                // local details exist
                NSLog(@"Local details for opponent player exist!");
                
                /* Get local details
                 - Score
                 - Local Rack
                 */
                opponentScore = gameData.orderOfPlayers[opponentPlayerIndex][playerScoreKey];
                opponentRack = gameData.orderOfPlayers[opponentPlayerIndex][playerRackKey];
                opponentPassed = gameData.orderOfPlayers[opponentPlayerIndex][playerPassKey];
                opponentSwapped = gameData.orderOfPlayers[opponentPlayerIndex][playerSwapKey];
            }
            
            /* Get shared game data
            - board
            - availableTiles
            */
            currentBoard = gameData.gameBoard;
            currentArray = gameData.gameLastPlayedArray;
            availableTiles = gameData.availableTiles;
            firstTurn = gameData.firstTurn;
            activeState = gameData.activeState;
            endGame = gameData.endGame;
            
            BOOL myTurnReturn;
            if ( activeState == kGameStateDone ) {
                // No ones turn if game is over
                myTurnReturn = NO;
            } else {
                myTurnReturn = myTurn;
            }
            
            [self->_delegate loadGamewithLS:localScore.integerValue OS:opponentScore.integerValue FT:firstTurn AT:availableTiles Board:currentBoard LastPlayed:currentArray LR:localRack OR:opponentRack Complete:activeState Endgame:endGame first:[GKLocalPlayer localPlayer].alias second:opponent.player.alias startOfRound:startFlag endOfRound:endFlag myTurn:myTurnReturn opponentPassed:[opponentPassed boolValue] opponentSwapped:[opponentSwapped boolValue]];
            
            // Ensure nil is returned for error - No error
            completionHandler(nil);
            
        } else if (error) {
            completionHandler(error);
        }
    }];
}

-(void) sendEndTurnwithScore:(NSInteger)myscore
                        Rack:(NSMutableArray *)myrack
                       Board:(NSMutableArray*)currentBoard
             LastPlayedArray:(NSMutableArray*)currentArray
              AvailableTiles:(NSMutableArray*)availableTiles
               FirstTurnFlag:(BOOL)firstTurn
                ActiveGameState:(ActiveGameState)activeState
                 EndgameFlag:(NSInteger)endGame
                     didSwap:(BOOL)swapped
                     didPass:(BOOL)passed
        andCompletionHandler:(void (^)(NSError*))completionHandler {
    
    // Get GK shared object
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    // Load data from match
    [gameKitHelper.match loadMatchDataWithCompletionHandler: ^(NSData *matchData, NSError *error) {
        if (matchData)
        {
            // Get opponent gamekit info
            GKTurnBasedMatch* blockScopeMatch = [GameKitHelper sharedGameKitHelper].match;
            GKTurnBasedParticipant *opponent = [blockScopeMatch.participants objectAtIndex:0];
            GKTurnBasedParticipant *localPlayer = [blockScopeMatch.participants objectAtIndex:1];
            if ([[GKLocalPlayer localPlayer].playerID isEqualToString:opponent.player.playerID]) {
                opponent = [blockScopeMatch.participants objectAtIndex:1];
                localPlayer = [blockScopeMatch.participants objectAtIndex:0];
            }
            
            // Unarchive game data
            GameData *gameData = [NSKeyedUnarchiver unarchiveObjectWithData:matchData];
            
            // Check/Edit data then re-load
            NSLog(@"Reading previous match data!");
            
            if (!gameData){
                // If there was no game data - make a new active one
                gameData = [[GameData alloc] init];
                gameData.activeState = kGameStateActive;
            }
            
            // Check if local player is in player order
            NSMutableDictionary *localDetails = [[NSMutableDictionary alloc] init];
            NSUInteger localPlayerIndex = [self indexForLocalPlayer: gameData];
            if ( localPlayerIndex == -1 ) {
                // New details - add local player to player order
                localDetails = [NSMutableDictionary dictionaryWithObjectsAndKeys: [GKLocalPlayer localPlayer].playerID, playerIdKey, [NSNumber numberWithInteger:[gameData.orderOfPlayers count]], playerIndexKey, nil ];
                [gameData.orderOfPlayers addObject:localDetails];
                localPlayerIndex = [self indexForLocalPlayer: gameData];
            } else {
                // Load old details
                localDetails = (NSMutableDictionary *)gameData.orderOfPlayers[localPlayerIndex];
            }
            
            /* Update local details
            - Local Score
            - Local Rack
            - did Swap
            - did Pass
            */
            [localDetails setObject:[NSNumber numberWithInteger:myscore] forKey:playerScoreKey];
            [localDetails setObject:myrack forKey:playerRackKey];
            [localDetails setObject:[NSNumber numberWithBool:swapped] forKey:playerSwapKey];
            [localDetails setObject:[NSNumber numberWithBool:passed] forKey:playerPassKey];
            
            // Add to game data
            gameData.orderOfPlayers[localPlayerIndex] = localDetails;
            gameData.gameBoard = currentBoard;
            gameData.gameLastPlayedArray = currentArray;
            gameData.availableTiles = availableTiles;
            gameData.firstTurn = firstTurn;
            gameData.activeState = activeState;
            gameData.endGame = endGame;

            // Check if opponent is in player order
            NSUInteger opponentPlayerIndex = [self indexForPlayerWithId:opponent.player.playerID inData: gameData];
            if ( opponentPlayerIndex == -1 ) {
                // No local details available
                NSLog(@"No details for opponent player!");
            } else {
                /* Update opponent Pass/Swap flag
                 - didSwap
                 - didPass
                 */
                NSMutableDictionary *opponentLocalDetails = (NSMutableDictionary *)gameData.orderOfPlayers[opponentPlayerIndex];
                [opponentLocalDetails setObject:[NSNumber numberWithBool:NO] forKey:playerSwapKey];
                [opponentLocalDetails setObject:[NSNumber numberWithBool:NO] forKey:playerPassKey];
                
                // Add to game data
                gameData.orderOfPlayers[opponentPlayerIndex] = opponentLocalDetails;
            }
            
            // Archive new game data
            NSData* newGameData = [NSKeyedArchiver archivedDataWithRootObject:gameData];
            
            // Possibly end match
            if ( gameData.activeState == kGameStateDone ) {
                
                // Get oppenent Index
                NSUInteger opponentPlayerIndex = [self indexForPlayerWithId:opponent.player.playerID inData: gameData];
                
                NSNumber* localScore = gameData.orderOfPlayers[localPlayerIndex][playerScoreKey];
                NSNumber* opponentScore = gameData.orderOfPlayers[opponentPlayerIndex][playerScoreKey];
                
                // Set match outcomes
                if ( [localScore integerValue] < [opponentScore integerValue] ) {
                    localPlayer.matchOutcome = GKTurnBasedMatchOutcomeWon;
                    opponent.matchOutcome = GKTurnBasedMatchOutcomeLost;
                } else if ( [opponentScore integerValue] < [localScore integerValue] ) {
                    localPlayer.matchOutcome = GKTurnBasedMatchOutcomeLost;
                    opponent.matchOutcome = GKTurnBasedMatchOutcomeWon;
                } else {
                    localPlayer.matchOutcome = GKTurnBasedMatchOutcomeTied;
                    opponent.matchOutcome = GKTurnBasedMatchOutcomeTied;
                }
                
                // End match
                [gameKitHelper endMatchwithData:(NSData*) newGameData andCompletionHandler:completionHandler];
            } else {
                [gameKitHelper endTurnwithData:(NSData*) newGameData andCompletionHandler:completionHandler];
            }
            
        } else if (error) {
            completionHandler(error);
        }
    }];
}

-(void) sendSaveTurnwithScore:(NSInteger)myscore
                        Rack:(NSMutableArray *)myrack
                       Board:(NSMutableArray*)currentBoard
              LastPlayedArray:(NSMutableArray*)currentArray
              AvailableTiles:(NSMutableArray*)availableTiles
               FirstTurnFlag:(BOOL)firstTurn
                ActiveGameState:(ActiveGameState)activeState
                 EndgameFlag:(NSInteger)endGame
         andCompletionHandler:(void (^)(NSError*))completionHandler {
    
    // Get GK shared object
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    // Load data from match
    [gameKitHelper.match loadMatchDataWithCompletionHandler: ^(NSData *matchData, NSError *error) {
        if (matchData)
        {
            // Unarchive game data
            GameData *gameData = [NSKeyedUnarchiver unarchiveObjectWithData:matchData];
            
            // Check/Edit data then re-load
            NSLog(@"Reading previous match data!");
            
            if (!gameData){
                // If there was no game data - make a new active one
                gameData = [[GameData alloc] init];
                gameData.activeState = kGameStateActive;
            }
            
            // Check if local player is in player order
            NSMutableDictionary *localDetails = [[NSMutableDictionary alloc] init];
            NSUInteger localPlayerIndex = [self indexForLocalPlayer: gameData];
            if ( localPlayerIndex == -1 ) {
                // New details
                localDetails = [NSMutableDictionary dictionaryWithObjectsAndKeys: [GKLocalPlayer localPlayer].playerID, playerIdKey, [NSNumber numberWithInteger:[gameData.orderOfPlayers count]], playerIndexKey, nil ];
                [gameData.orderOfPlayers addObject:localDetails];
                localPlayerIndex = [self indexForLocalPlayer: gameData];
            } else {
                // Load old details
                localDetails = (NSMutableDictionary *)gameData.orderOfPlayers[localPlayerIndex];
            }
            
            /* Update local details
             - Score
             - Local Rack
             */
            [localDetails setObject:[NSNumber numberWithInteger:myscore] forKey:playerScoreKey];
            [localDetails setObject:myrack forKey:playerRackKey];
            
            // Add to game data
            gameData.orderOfPlayers[localPlayerIndex] = localDetails;
            gameData.gameBoard = currentBoard;
            gameData.gameLastPlayedArray = currentArray;
            gameData.availableTiles = availableTiles;
            gameData.firstTurn = firstTurn;
            gameData.activeState = activeState;
            gameData.endGame = endGame;
            
            NSData* newGameData = [NSKeyedArchiver archivedDataWithRootObject:gameData];
                        
            [gameKitHelper saveTurnwithData:(NSData*) newGameData andCompletionHandler:completionHandler];
            
        } else if (error) {
            completionHandler(error);
        }
    }];
}

#pragma mark Player indexing logic

- (NSUInteger)indexForPlayerWithId:(NSString*)playerId inData:(GameData*) gameData
{
    __block NSUInteger index = -1;
    [gameData.orderOfPlayers enumerateObjectsUsingBlock:^(NSDictionary
                                                  *obj, NSUInteger idx, BOOL *stop){
        NSString *pId = obj[playerIdKey];
        if ([pId isEqualToString:playerId]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (NSUInteger)indexForLocalPlayer:(GameData*) gameData
{
    NSString *playerId = [GKLocalPlayer localPlayer].playerID;
    
    return [self indexForPlayerWithId:playerId inData:gameData];
}

#pragma mark Quit match helper

-(void) quitMatchWithCompletionHandler:(void (^)(NSError*))completionHandler {
    
    // Get GK shared object
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    // Open match data
    [gameKitHelper.match loadMatchDataWithCompletionHandler: ^(NSData *matchData, NSError *error) {
        if (matchData)
        {
            
            // Unarchive game data
            GameData *gameData = [NSKeyedUnarchiver unarchiveObjectWithData:matchData];
            
            if (!gameData){
                // If there was no game data - make a new new one
                gameData = [[GameData alloc] init];
            }
            
            gameData.activeState = kGameStateDone;
            
            // Archive new game data
            NSData* newGameData = [NSKeyedArchiver archivedDataWithRootObject:gameData];
            
            // Get opponent gamekit info
            GKTurnBasedMatch* blockScopeMatch = [GameKitHelper sharedGameKitHelper].match;
            GKTurnBasedParticipant *opponent = [blockScopeMatch.participants objectAtIndex:0];
            GKTurnBasedParticipant *localPlayer = [blockScopeMatch.participants objectAtIndex:1];
            if ([[GKLocalPlayer localPlayer].playerID isEqualToString:opponent.player.playerID]) {
                opponent = [blockScopeMatch.participants objectAtIndex:1];
                localPlayer = [blockScopeMatch.participants objectAtIndex:0];
            }
            
            localPlayer.matchOutcome = GKTurnBasedMatchOutcomeQuit;
            opponent.matchOutcome = GKTurnBasedMatchOutcomeWon;
            
            // End match -- send through completionHandler
            [gameKitHelper quitMatchwithData:(NSData*) newGameData andCompletionHandler:completionHandler];
            
        } else if (error)
        {            
            // Call completionHandler
            completionHandler(error);
        }
    }];
}

-(void) endMatchOnQuit {
    
    // Get GK shared object
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    // Open match data
    [gameKitHelper.match loadMatchDataWithCompletionHandler: ^(NSData *matchData, NSError *error) {
        if (matchData)
        {
            
            // Unarchive game data
            GameData *gameData = [NSKeyedUnarchiver unarchiveObjectWithData:matchData];
            
            if (!gameData){
                // If there was no game data - make a new new one
                gameData = [[GameData alloc] init];
            }
            
            gameData.activeState = kGameStateDone;
            
            // Archive new game data
            NSData* newGameData = [NSKeyedArchiver archivedDataWithRootObject:gameData];
            
            // Get opponent gamekit info
            GKTurnBasedMatch* blockScopeMatch = [GameKitHelper sharedGameKitHelper].match;
            GKTurnBasedParticipant *opponent = [blockScopeMatch.participants objectAtIndex:0];
            GKTurnBasedParticipant *localPlayer = [blockScopeMatch.participants objectAtIndex:1];
            if ([[GKLocalPlayer localPlayer].playerID isEqualToString:opponent.player.playerID]) {
                opponent = [blockScopeMatch.participants objectAtIndex:1];
                localPlayer = [blockScopeMatch.participants objectAtIndex:0];
            }
            
            localPlayer.matchOutcome = GKTurnBasedMatchOutcomeWon;
            opponent.matchOutcome = GKTurnBasedMatchOutcomeQuit;
            
            // End match -- Print debug message is failure
            [gameKitHelper endMatchwithData:(NSData*) newGameData andCompletionHandler:^(NSError * error) {
                if (error) {
                    NSLog(@"endMatchOnQuit: Unable to end game after opponent quit - no error message required.");
                }
            }];
            
        } else if (error) {
            // Print debug message
            NSLog(@"endMatchOnQuit: Error loading matches %@ - no error message required.", error.localizedDescription);
        }
    }];
}

@end
