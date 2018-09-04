//
//  GameKitHelper.h
//  1Kingof20
//
//  Created by Ishmael King on 11/6/17.
//  Copyright © 2017 Apportable. All rights reserved.
//

#ifndef GameKitHelper_h
#define GameKitHelper_h

extern NSString *const LocalPlayerIsAuthenticated;
extern NSString *const LocalPlayerIsUnauthenticated;
extern NSString *const LocalPlayerGamesChanged;

@import GameKit;

@protocol GameKitHelperDelegate

/**
 * Use match data to setup gamescene - Implemented by MultiplayerNetworking
 * @param match current match
 * @param myTurn Is it my turn?
 */
- (void)turnHandler:(GKTurnBasedMatch *)match isMyTurn:(BOOL)myTurn withCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

/**
 * Quit match in turn after opponent quits - Implemented by MultiplayerNetworking
 */
-(void) endMatchOnQuit;

@end

@protocol sceneHelperDelegate

/**
* Informs delegate that match can be entered - Implemented by SceneOrganizer
* @param match current match
*/
-(void)onlineGameEnteredwithMatch:(GKTurnBasedMatch*)match;

@end

@interface GameKitHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener>

#pragma mark Variables

// View to present login/menus
@property UIViewController * view;

// lastError from authenticator
@property (nonatomic, readonly) NSError *lastError;

// Delegates
// MultiNetworking Class
@property (nonatomic, assign) id <GameKitHelperDelegate> gkDelegate;

// Reference to active match
@property (nonatomic, strong) GKTurnBasedMatch *match;

// Reference to local player -- not needed, has singleton
@property (nonatomic, strong) GKLocalPlayer *localPlayer;

// Reference to current scene leading GK
@property (nonatomic, weak) id currentLeader;

#pragma mark Init

/**
 * Allow outside access via singleton
 */
+(instancetype)sharedGameKitHelper;

/**
 * Set authentication handeler
 */
- (void)authenticateLocalPlayer;

// Setter
- (BOOL)getEnableGameCenter;

#pragma mark GamePlay

/**
 * Join new/existing match
 * @param gkDelegate Object responsible for LocalPlayer responses
 */
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
               specificOpponent:(GKPlayer*)opponent
               useVC:(bool)presentVC
          gameKitHelperDelegate:(id<GameKitHelperDelegate>)gkDelegate
          withCompletionHandler:(nonnull void (^)(GKTurnBasedMatch*,NSError*))completionHandler;

/**
 * Join called when match data changes
 * @param player future index of button
 * @param match match in question
 * @param didBecomeActive Usually "false", true if opened from notification
 */
- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive withCompletionHandler:(nullable void (^)(NSError*))completionHandler;

/**
 * End Turn, Begin Polling for Turn
 * @param newGameData Data from this last turn
 */
- (void)endTurnwithData:(NSData*) newGameData andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

/**
 * Save Match - Without Advancing Turn
 * @param newGameData Data from this last turn
 */
-(void) saveTurnwithData:(NSData*) newGameData andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

/**
 * End/Quit Match
 * @param newGameData Data from this last turn
 */
-(void) endMatchwithData:(NSData*) newGameData andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;
-(void) quitMatchwithData:(NSData*) newGameData andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

/**
 * Remove Match
 */
-(void) removeMatchWithCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

#pragma mark Helpers

/**
 * Find last move of match
 * @param match Match in question
 * @return NSDate with last move date
 */
+(NSDate *)lastMoveInMatch:(GKTurnBasedMatch*) match;

/**
 * Sort given array by date
 * @param matches Array of GKTurnBasedMatch
 */
+(NSArray<GKTurnBasedMatch *>*)sortMatchArraybyDate:(NSArray<GKTurnBasedMatch *>*) matches;

/**
 * Sort given array by date
 * @param players Array of GKPlayer
 */
+(NSMutableArray<GKPlayer *>*)sortPlayerArraybyName:(NSMutableArray<GKPlayer *>*) players;

/**
 * Send notification if match changed after test date
 * @param testDate Date for comparison
 */
-(void)haveMatchesChangedSinceCallIn: (NSDate*) testDate count: (NSUInteger) count;

@end

#endif /* GameKitHelper_h */
