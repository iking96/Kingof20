//
//  GameKitHelper.m
//  1Kingof20 iOS
//
//  Created by Ishmael King on 11/6/17.
//  Copyright © 2017 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKitHelper.h"
#import "GameScene.h"
#import "MainScene.h"

NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";
NSString *const LocalPlayerIsUnauthenticated = @"local_player_unauthenticated";
NSString *const LocalPlayerGamesChanged = @"local_player_games_changed";
static const int poll_time = 2.5;

#pragma mark NSMutableArray extention

@implementation NSMutableArray (Helper)

-(void) removeAllTimers {
    [self makeObjectsPerformSelector:@selector(invalidate)];
    [self removeAllObjects];
}

@end

@interface GameKitHelper()
{
    // Could player be autenticated?
    BOOL _enableGameCenter;
    BOOL _matchStarted;
    BOOL _inTurnPolling;
    
    GKTurnBasedMatchmakerViewController* _savedViewController;
    
    NSMutableArray* _turnTimer;
    NSMutableArray* _mainMenuTimer;
    
    void (^_pollerHandler)(NSError*);
    void (^_savedEntryHandler)(GKTurnBasedMatch*,NSError*);
}

/**
 * Poll for turn; reset if not
 */
-(void)monitorOutOfTurn;
-(void)monitorInTurn;

@end

@implementation GameKitHelper

#pragma mark Init

// Assume Game Center is enabled - Checked in AppDelegate
- (id)init
{
    self = [super init];
    if (self) {
        _enableGameCenter = NO;
        _turnTimer = [[NSMutableArray alloc] init];
        _mainMenuTimer = [[NSMutableArray alloc] init];
        _savedEntryHandler = nil;
    }
    return self;
}

// Allow access via helper singleton
+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

#pragma mark Player Authentication

- (void) authenticateLocalPlayer
{
    // Get localPlayer instance from GK
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    _localPlayer = localPlayer;
    
    
    // Notify all watchers that a player is authenticated
    if (localPlayer.isAuthenticated && _enableGameCenter) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        return;
    }
    
    // Set GK block to enable GK
    [localPlayer setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
        
        // Check/Save possible error
        [self setLastError:error];
        
        if ( error ) {
            //Here's a fun fact... even if you're in airplane mode and can't communicate to the server,
            //when this call back fires with an error code, localPlayer.authenticated is set to YES despite the total failure. ><
            //error.code == -1009 -> authenticated = YES
            //error.code == 2 -> authenticated = NO
            //error.code == 3 -> authenticated = YES
            
            if ([GKLocalPlayer localPlayer].authenticated == YES)
            {
                //Game center blatantly lies!
                NSLog( @"error.code = %ld but localPlayer.authenticated = %d", (long)error.code, [GKLocalPlayer localPlayer].authenticated);
            }
            
            // Label Game Center as inactive
            self->_enableGameCenter = NO;
            
            // Notify all watchers that a player is unauthenticated
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsUnauthenticated object:nil userInfo:[NSDictionary dictionaryWithObject:self->_lastError forKey:@"index"]];
            
            return;
        }
        
        if( viewController != nil ) {
            // Present login
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated && !error) {
            self->_enableGameCenter = YES;
            // Notify all watchers that a player is authenticated
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        }
    }];
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController {
    // Present View Controller
    [_view presentViewController:authenticationViewController animated:YES completion:nil];

}

- (void)setLastError:(NSError *)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", _lastError);
    }
}

- (BOOL) getEnableGameCenter {
    return _enableGameCenter;
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    // Dismiss window
    [viewController dismissViewControllerAnimated:YES completion:nil];
    NSError* error = [NSError errorWithDomain:@"turnBasedMatchmakerViewControllerWasCancelled" code:0 userInfo:nil];
    _savedEntryHandler(nil,error);
    _savedEntryHandler = nil;
}

// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    // Dismiss window and log error
    [viewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
    _savedEntryHandler(nil,error);
    _savedEntryHandler = nil;
}

#pragma mark GamePlay

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
               specificOpponent:(GKPlayer*)opponentID
               useVC:(bool)presentVC
          gameKitHelperDelegate:(id<GameKitHelperDelegate>)gkDelegate
          withCompletionHandler:(void (^)(GKTurnBasedMatch*,NSError*))completionHandler {
    
    // Early exit if Game Center was never enabled
    if (!_enableGameCenter) {
        NSLog(@"Error finding match: Game Center not enabled!");
        return;
    }
    
    // Set match status
    _matchStarted = NO;
    _inTurnPolling = NO;
    
    // Set communicator for match
    _gkDelegate = gkDelegate;
    
    [_view dismissViewControllerAnimated:NO completion:nil];
    
    // Create TB-VC
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    // Set calls GKTurnBasedEventListener
    [[GKLocalPlayer localPlayer] registerListener:self];
    
    _savedEntryHandler = nil;
    if ( presentVC ) {
        GKTurnBasedMatchmakerViewController* mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
        mmvc.turnBasedMatchmakerDelegate = self;
        mmvc.showExistingMatches = false;

        [_view presentViewController:mmvc animated:YES completion:^{
            //nothing - handled elsewhere
            self->_savedEntryHandler = completionHandler;
        }];
        return;
    }
    
    if ( opponentID ) {
        request.recipients = @[opponentID];
        request.inviteMessage = @"You have been invited to play King of 20!";
    }
    
    [GKTurnBasedMatch findMatchForRequest: request withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
         completionHandler(match,error);
     }];
}

-(void) endTurnwithData:(NSData*) newGameData andCompletionHandler:(void (^)(NSError*))completionHandler {
    
    GKTurnBasedParticipant *opponent = [self.match.participants objectAtIndex:0];
    GKTurnBasedParticipant *localPlayer = [self.match.participants objectAtIndex:1];
    if ([self.localPlayer.playerID isEqualToString:opponent.player.playerID]) {
        opponent = [self.match.participants objectAtIndex:1];
        localPlayer = [self.match.participants objectAtIndex:0];
    }
    
    [_match endTurnWithNextParticipants:[NSArray arrayWithObjects:opponent, nil] turnTimeout:GKTurnTimeoutDefault matchData:newGameData completionHandler:^(NSError *error) {
        if (!error)
        {
            // Cancel monitorInTurn (or others) - poll for out of turn
            [self->_turnTimer removeAllTimers];
            [self monitorOutOfTurn];
        } else {
            completionHandler(error);
        }
    }];
    
}

-(void) saveTurnwithData:(NSData*) newGameData andCompletionHandler:(void (^)(NSError*))completionHandler {
    
    // Addresses issue:
    // P1 playes and loses connection
    // P2 players
    // P1 goes back (saves) before board update
    // Can still fail is above happens before monitorOutOfTurn
    if ( _inTurnPolling ) {
        [_match saveCurrentTurnWithMatchData:newGameData completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error saving data: %@ - No need to report", error.localizedDescription);
            }
        }];
    }
    
    // Leaving Game Scene Invalidate all game timers
    [_turnTimer removeAllTimers];
}

-(void) endMatchwithData:(NSData*) newGameData andCompletionHandler:(void (^)(NSError*))completionHandler {
    
    GKTurnBasedParticipant *opponent = [self.match.participants objectAtIndex:0];
    GKTurnBasedParticipant *localPlayer = [self.match.participants objectAtIndex:1];
    if ([self.localPlayer.playerID isEqualToString:opponent.player.playerID]) {
        opponent = [self.match.participants objectAtIndex:1];
        localPlayer = [self.match.participants objectAtIndex:0];
    }
    
    [_match endMatchInTurnWithMatchData:newGameData completionHandler:completionHandler];
}

-(void) quitMatchwithData:(NSData*) newGameData andCompletionHandler:(void (^)(NSError*))completionHandler {
    
    GKTurnBasedParticipant *opponent = [self.match.participants objectAtIndex:0];
    GKTurnBasedParticipant *localPlayer = [self.match.participants objectAtIndex:1];
    if ([self.localPlayer.playerID isEqualToString:opponent.player.playerID]) {
        opponent = [self.match.participants objectAtIndex:1];
        localPlayer = [self.match.participants objectAtIndex:0];
    }
    
    if ( localPlayer == self.match.currentParticipant ) {
        // If it is your turn simply end the match.
        [self endMatchwithData:newGameData andCompletionHandler:completionHandler];
        
    } else {
        // Set self as current participant to avoid turn based error
        [_match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:completionHandler];
    }
}

-(void) removeMatchWithCompletionHandler:(void (^)(NSError*))completionHandler {
    // Remove match - error check
    [_match removeWithCompletionHandler:^(NSError *error) {
        if (!error)
        {
            // Player requested to remove match - invalidate/reset menu timer
            [self->_mainMenuTimer removeAllTimers];
            
            // Post Notification of Game Removal
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerGamesChanged object:nil];
        } else {
            completionHandler(error);
        }
    }];
}

#pragma mark GKInviteListener

// player:didAcceptInvite: gets called when another player accepts the invite from the local player
- (void)player:(GKPlayer *)player  didAcceptInvite:(GKInvite *)invite {
    NSLog(@"Invite Accepted?");
}

- (void)player:(GKPlayer *)player didRequestMatchWithRecipients:(NSArray<GKPlayer *> *)recipientPlayers {
    NSLog(@"Invite Accepted?");
}

#pragma mark GKLocalPlayerListener

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(nonnull GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    
    // Event handler for inviteScene match
    
    if ( _savedEntryHandler ) {
        [_view dismissViewControllerAnimated:NO completion:nil];
        
        // Clean hand-shake
        void (^tempHandler)(GKTurnBasedMatch*,NSError*) = _savedEntryHandler;
        _savedEntryHandler = nil;
        
        // Call handler
        tempHandler(match,nil);
        return;
    } else {
        
        if ( [_currentLeader isMemberOfClass:[GameScene class]] ) {
            // Relay to custom receivedTurnEventForMatch, do nothing.
            NSLog(@"In canned receivedTurnEventForMatch without _savedEntryHandler.");
            //[self player:player receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:nil];
        } else if ( [_currentLeader isMemberOfClass:[MainScene class]] ) {
            
            // Invalidate all previous polls
            [_mainMenuTimer removeAllTimers];
            
            //Some game event happened - reprint main scene buttons
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerGamesChanged object:nil];
        }
    }
}

// Called when match is selected from VC
// Should be called when it becomes localPlayer's turn - unreliable
- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive withCompletionHandler:(void (^)(NSError*))completionHandler {
    
    // Invalidate stale game timers and main menu timers
    [_turnTimer removeAllTimers];
    [_mainMenuTimer removeAllTimers];
    
    // Save current match and polling completionHandler
    _match = match;
    _pollerHandler = completionHandler;
    
    if ( _savedEntryHandler ) {
        [_view dismissViewControllerAnimated:NO completion:nil];
        _savedEntryHandler(match,nil);
        _savedEntryHandler = nil;
        completionHandler(nil);
        return;
    }
    
    // Set match status conservatively
    _inTurnPolling = NO;

    // Determine responce based on turn status
    NSDate* participantLastTurnDate = match.participants[0].lastTurnDate;
    NSString* currentParticipantPlayerID = match.currentParticipant.player.playerID;
    if ( match.status == GKTurnBasedMatchStatusEnded ) {
        NSLog(@"Ready to view ended match!");

        // Set-Up GameScene - No Poll
        [_gkDelegate turnHandler: match isMyTurn:NO withCompletionHandler:^(NSError * error) {
            if ( completionHandler )
                self->_pollerHandler(error);
        }];
        
    } else if (participantLastTurnDate == nil && currentParticipantPlayerID == [GKLocalPlayer localPlayer].playerID) {
        NSLog(@"Ready to start/continue match!");
        
        // Handel turn
        [_gkDelegate turnHandler: match isMyTurn:YES withCompletionHandler:^(NSError * error) {
            if ( self->_pollerHandler )
                self->_pollerHandler(error);
        }];
        
        //Start Polling for next move
        [self monitorInTurn];
    } else if (participantLastTurnDate == nil && currentParticipantPlayerID != [GKLocalPlayer localPlayer].playerID) {
        NSLog(@"Joined new match. Not my turn!");
        
        // Set-Up GameScene
        [_gkDelegate turnHandler: match isMyTurn:NO withCompletionHandler:^(NSError * error) {
            if ( self->_pollerHandler )
                self->_pollerHandler(error);
        }];
        
        //Start Polling for next move
        [self monitorOutOfTurn];
    } else if ( currentParticipantPlayerID == [GKLocalPlayer localPlayer].playerID ) {
        NSLog(@"Ready to start/continue match!");

        // Handel turn
        [_gkDelegate turnHandler: match isMyTurn:YES withCompletionHandler:^(NSError * error) {
            if ( self->_pollerHandler )
                self->_pollerHandler(error);
        }];
        
        //Start Polling for next move
        [self monitorInTurn];
    } else if ( currentParticipantPlayerID != [GKLocalPlayer localPlayer].playerID ) {
        NSLog(@"Existing Game. Their turn");
        
        // Set-Up GameScene
        [_gkDelegate turnHandler: match isMyTurn:NO withCompletionHandler:^(NSError * error) {
            if ( self->_pollerHandler )
                self->_pollerHandler(error);
        }];
        
        //Start Polling for next move
        [self monitorOutOfTurn];
    } else {
        completionHandler([[NSError alloc] initWithDomain:@"ReceivedTurnEventForMatch in confused state!" code:1 userInfo:nil]);
    }
}

// Poll match until it is our turn - to circumvent unreilable receivedTurnEventForMatch:
-(void) monitorOutOfTurn
{
    NSString *matchID = _match.matchID;
    
    // Invalidate all previous polls
    [_turnTimer removeAllTimers];
    
    // Set match status conservatively
    _inTurnPolling = NO;
    
    // Early exit if in wrong scene
    if ( ![_currentLeader isMemberOfClass:[GameScene class]] ) {
        return;
    }
    
    [GKTurnBasedMatch loadMatchWithID:matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
        if ( !error ) {
            GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
            GKTurnBasedParticipant *currentParticipant = match.currentParticipant;
            
            if ( !currentParticipant || [localPlayer.playerID isEqualToString:currentParticipant.player.playerID]) {
                 //we have become active or game is over. Call the event handler like it's supposed to be called
                 [self player:localPlayer receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:nil];
            } else {
                 NSLog(@"REPOLL! - Out of Turn");

                 //we are still waiting to become active. Check back soon
                 float dTime = poll_time;
                [self->_turnTimer addObject:[NSTimer scheduledTimerWithTimeInterval:dTime
                                                               target:self
                                                                      selector:@selector(monitorOutOfTurn)
                                                             userInfo:nil
                                                              repeats:NO]];
             }
        } else {
            // Call completion handler
            self->_pollerHandler(error);
        }
     }];
}

// Poll match until for inciting events - to circumvent unreilable receivedTurnEventForMatch:
-(void)monitorInTurn
{
    NSString *matchID = _match.matchID;
    
    // Set match status conservatively
    _inTurnPolling = YES;
    
    // Invalidate all previous polls
    [_turnTimer removeAllTimers];
    
    // Early exit if in wrong scene
    if ( ![_currentLeader isMemberOfClass:[GameScene class]] ) {
        return;
    }
    
    [GKTurnBasedMatch loadMatchWithID:matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
        if ( !error ) {
             GKTurnBasedParticipant *opponent = [match.participants objectAtIndex:0];
             GKTurnBasedParticipant *localPlayer = [match.participants objectAtIndex:1];
             GKTurnBasedParticipant *currentParticipant = match.currentParticipant;

             if ([self.localPlayer.playerID isEqualToString:opponent.player.playerID]) {
                 opponent = [self.match.participants objectAtIndex:1];
                 localPlayer = [self.match.participants objectAtIndex:0];
             }
            
             if ( opponent.matchOutcome == GKTurnBasedMatchOutcomeQuit ) {
                 
                 NSLog(@"Opponent quit - ending match!");
                 
                 //Other player quit - end game
                 [self->_gkDelegate endMatchOnQuit];
                 
                 //we have become active or game is over. Call the event handler like it's supposed to be called
                 [self player:nil receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:nil];
             } else if ( ![localPlayer.player.playerID isEqualToString:currentParticipant.player.playerID])
             {
                 
                 NSLog(@"No longer current player - reload!");
                 
                 //we have become active or game is over. Call the event handler like it's supposed to be called
                 [self player:nil receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:nil];
             } else {
                 NSLog(@"REPOLL! - In Turn");

                 //we are still waiting for something to change. Check back soon
                 float dTime = poll_time;
                 [self->_turnTimer addObject:[NSTimer scheduledTimerWithTimeInterval:dTime
                                                               target:self
                                                                      selector:@selector(monitorInTurn)
                                                             userInfo:nil
                                                              repeats:NO]];
             }
        } else {
            // Call completion handler
            self->_pollerHandler(error);
        }
     }];
}

// Poll - Post noticiation if match "last played" time has advanced
-(void)haveMatchesChangedSinceCallIn: (NSDate*) testDate count:(NSUInteger)count
{
    
    // Invalidate all previous polls
    [_mainMenuTimer removeAllTimers];

    // Early exit if in wrong scene
    if ( ![_currentLeader isMemberOfClass:[MainScene class]] ) {
        return;
    }
    
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray<GKTurnBasedMatch *>* matches, NSError* error) {
        
        int statusCount = 0;
        
         // Evaluate each match
         for ( GKTurnBasedMatch* match in matches ) {
             NSDate* latestMove = [GameKitHelper lastMoveInMatch:match];
             
             statusCount += match.status;
             
             if ( (latestMove && [latestMove timeIntervalSinceDate:testDate] > 0) || count != [matches count] ) {
                 //latestMove is later than testDate - post notification
                 [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerGamesChanged object:nil];
                 
                 NSLog(@"CHANGEFOUND!");

                 return;
             }
         }
        
        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
        [infoDict setObject:testDate forKey:@"date"];
        [infoDict setObject:[NSNumber numberWithUnsignedInteger:[matches count]] forKey:@"count"];
        [infoDict setObject:[NSNumber numberWithInteger:statusCount] forKey:@"status"];

        NSLog(@"REPOLL!");

        //we are still waiting for a change. Check back soon!
        float dTime = poll_time;
        [self->_mainMenuTimer addObject:[NSTimer scheduledTimerWithTimeInterval:dTime
                                          target:self
                                        selector:@selector(haveMatchesChangedSinceCallBack:)
                                        userInfo:infoDict
                                         repeats:NO]];
     }];
}

-(void)haveMatchesChangedSinceCallBack: (NSTimer*) timer
{

    NSDictionary* infoDict = (NSDictionary*)[timer userInfo];
    NSDate* testDate = (NSDate*)[infoDict objectForKey:@"date"];
    NSNumber* count = (NSNumber*)[infoDict objectForKey:@"count"];
    NSNumber* oldStatus = (NSNumber*)[infoDict objectForKey:@"status"];

    // Invalidate all previous polls
    [_mainMenuTimer removeAllTimers];
    
    // Early exit if in wrong scene
    if ( ![_currentLeader isMemberOfClass:[MainScene class]] ) {
        return;
    }
    
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray<GKTurnBasedMatch *>* matches, NSError* error) {
        
        int statusCount = 0;

         // Evaluate each match
         for ( GKTurnBasedMatch* match in matches ) {
             NSDate* latestMove = [GameKitHelper lastMoveInMatch:match];
             
             statusCount += match.status;

             if ( (latestMove && [latestMove timeIntervalSinceDate:testDate] > 0) ) {
                 //latestMove is later than testDate - post notification
                 [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerGamesChanged object:nil];
                 
                 NSLog(@"CHANGEFOUND!");
                 
                 return;
             }
         }
        
        if ( [oldStatus integerValue] != statusCount || [count unsignedIntegerValue] != [matches count]) {
            //status count or match count have changed
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerGamesChanged object:nil];
            
            NSLog(@"CHANGEFOUND!");
            
            return;
        }
        
        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
        [infoDict setObject:testDate forKey:@"date"];
        [infoDict setObject:[NSNumber numberWithUnsignedInteger:[matches count]] forKey:@"count"];
        [infoDict setObject:[NSNumber numberWithInteger:statusCount] forKey:@"status"];
         
        NSLog(@"REPOLL!");
         
        //we are still waiting for a change. Check back soon!
        float dTime = poll_time;
        [self->_mainMenuTimer addObject:[NSTimer scheduledTimerWithTimeInterval:dTime
                                          target:self
                                        selector:@selector(haveMatchesChangedSinceCallBack:)
                                        userInfo:infoDict
                                         repeats:NO]];
     }];
}

#pragma mark Helpers

+(NSDate *)lastMoveInMatch:(GKTurnBasedMatch*) match {
    GKTurnBasedParticipant *localParticipant, *otherParticipant;
    NSDate *lastMove;
    
    for (GKTurnBasedParticipant *participant in match.participants) {
        if (YES == [participant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            localParticipant = participant;
        } else {
            otherParticipant = participant;
        }
    }

    if (localParticipant == match.currentParticipant) {
        lastMove = otherParticipant.lastTurnDate;
    } else {
        lastMove = localParticipant.lastTurnDate;
    }
    
    return lastMove;
}

+(NSArray<GKTurnBasedMatch *>*)sortMatchArraybyDate:(NSArray<GKTurnBasedMatch *>*) matches {
    return [matches sortedArrayUsingComparator:^NSComparisonResult(GKTurnBasedMatch* match1,
                                                          GKTurnBasedMatch* match2) {
        
        NSDate *lm1 = [self lastMoveInMatch:match1];
        NSDate *lm2 = [self lastMoveInMatch:match2];
        if (lm1 != nil && lm2 != nil) {
            return -1*[lm1 compare:lm2];
        }
        
        return NSOrderedSame;
        
    }];
}

+(NSArray<GKPlayer *>*)sortPlayerArraybyName:(NSArray<GKPlayer *>*) players {
    return [players sortedArrayUsingComparator:^NSComparisonResult(GKPlayer* player1,
                                                                   GKPlayer* player2) {
        
        NSString* s1 = player1.alias;
        NSString* s2 = player2.alias;
        if (s1 != nil && s2 != nil) {
            return [s1 compare:s2];
        }
        
        return NSOrderedSame;
        
    }];
}

@end
