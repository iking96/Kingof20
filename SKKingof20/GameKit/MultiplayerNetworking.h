//
//  MultiplayerNetworking.h
//  1Kingof20
//
//  Created by Ishmael King on 11/11/17.
//  Copyright © 2017 Apportable. All rights reserved.
//

#ifndef MultiplayerNetworking_h
#define MultiplayerNetworking_h

#import "GameKitHelper.h"
#import "ActiveGameState.h"

@protocol MultiplayerNetworkingProtocol <NSObject>

/**
 * Update GameScene when turn changes or when saved
 * @param myTurn - TRUE is it is current players turn; always false if game is over
 */
-(void) loadGamewithLS: (NSInteger)localScore OS: (NSInteger)opponantScore FT: (BOOL)firstTurn AT: (NSMutableArray*)availableArray Board: (NSMutableArray*)board LastPlayed: (NSMutableArray*)lastPlayedArray LR:(NSMutableArray*)localrack OR: (NSMutableArray*) opponantrack Complete:(ActiveGameState)done Endgame:(NSInteger)endGame first:(NSString*) firstName second: (NSString*) secondName startOfRound:(BOOL)startFlag endOfRound:(BOOL)endFlag myTurn:(BOOL)myTurn opponentPassed:(BOOL)oPassed opponentSwapped:(BOOL)oSwapped;

@end

@interface MultiplayerNetworking : NSObject <GameKitHelperDelegate>

// Delegate - called when game entered or state changed
@property (nonatomic, assign) id<MultiplayerNetworkingProtocol> delegate;

#pragma mark Save

/**
 * End turn
 * @param myscore Score of player ending turn
 * @param myrack Rack of player ending turn
 * @param currentBoard Board after turn end
 * @param availableTiles Tile Collection after turn end
 * @param firstTurn First turn flag
 * @param complete Complete flag
 * @param endGame EndGame flag
 */
-(void) sendEndTurnwithScore:(NSInteger)myscore
                        Rack:(NSMutableArray*)myrack
                       Board:(NSMutableArray*)currentBoard
             LastPlayedArray:(NSMutableArray*)currentArray
              AvailableTiles:(NSMutableArray*)availableTiles
               FirstTurnFlag:(BOOL)firstTurn
                ActiveGameState:(ActiveGameState)complete
                 EndgameFlag:(NSInteger)endGame
                     didSwap:(BOOL)swapped
                     didPass:(BOOL)passed
        andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

-(void) sendSaveTurnwithScore:(NSInteger)myscore
                        Rack:(NSMutableArray*)myrack
                       Board:(NSMutableArray*)currentBoard
              LastPlayedArray:(NSMutableArray*)currentArray
              AvailableTiles:(NSMutableArray*)availableTiles
               FirstTurnFlag:(BOOL)firstTurn
                ActiveGameState:(ActiveGameState)complete
                 EndgameFlag:(NSInteger)endGame
         andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

/**
 * End match due to quit
 */
-(void) quitMatchWithCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

@end


#endif /* MultiplayerNetworking_h */
