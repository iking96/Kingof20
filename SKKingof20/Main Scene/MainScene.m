//
//  GameScene.m
//  SKKingof20
//
//  Created by Ishmael King on 1/15/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import "MainScene.h"
#import "CustomScrollView.h"
#import "CustomKTButton.h"
#import "GameKitHelper.h"
#import "PastGameButtons.h"
#import "NSDate+Helper.h"
#import "MultiplayerNetworking.h"
#import "GeneralPopover.h"

static const int PASTGAME_START_POSITION_Y = -675;
NSString* MOVABLE_NODE_NAME = @"moveableNode";
NSString* PAST_GAME_NODE_NAME = @"pastGameNode";
NSString*  AUTHENTICATING_IDENTIFIER_NODE  = @"authenticatingIdentifierNode";

NSString *const MainSceneWillMoveFromView = @"MainSceneWillMoveFromView";

@implementation MainScene {
    
    // Scrollview for menu
    CustomScrollView* _scrollview;
    
    // Past Game Button Segragated
    NSMutableArray* _activeGameButtons;
    NSMutableArray* _completedGameButtons;
    
    // Current view of Main Scene
    SKView* _view;
    
    // Popover Layer
    GeneralPopover* _errorPopover;
    
    // Weak lock
    bool _attemptingGameStart;
    
}

#pragma mark Init

- (void)sceneDidLoad {

}

- (void)didMoveToView:(SKView *)view {
    
    // Is scene trying to open gamescene
    _attemptingGameStart = NO;
    
    // Enable gesture recognition
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:swipeLeft];
    
    // Init past game lists
    _activeGameButtons = [[NSMutableArray alloc] init];
    _completedGameButtons = [[NSMutableArray alloc] init];

    // Create movable (central) node and Scrolling VC
    SKNode* moveableNode = [SKNode node];
    moveableNode.name = MOVABLE_NODE_NAME;
    CustomScrollView* new_view = [[CustomScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) scene:self moveableNode:moveableNode scrollDirection:vertical paging:NO];
    
    _scrollview = new_view;
    _view = view;
    
    // Set content size and add to current view
    new_view.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [view addSubview:new_view];
    
    // Create logo
    SKSpriteNode* menu_logo = [SKSpriteNode spriteNodeWithImageNamed:@"Menu_Logo.png"];
    menu_logo.position = CGPointMake(0, self.frame.size.height*.5-self.frame.size.height*.2);

    // Create New Game Button
    CustomKTButton* newGame_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"New_Game_Button.png" selected:@"New_Game_Button.png"];
    newGame_button.position = CGPointMake(0, self.frame.size.height*.5-self.frame.size.height*.2-325);
    [newGame_button setTouchUpInsideTarget:self action:@selector(newGame) object:nil];
    
    // Create Invite Button
    CustomKTButton* invite_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"Invite_Button.png" selected:@"Invite_Button.png"];
    invite_button.position = CGPointMake(-158, self.frame.size.height*.5-self.frame.size.height*.2-525);
    [invite_button setTouchUpInsideTarget:self action:@selector(invite) object:nil];
    
    // Create Rules Button
    CustomKTButton* rules_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"Rules_Button.png" selected:@"Rules_Button.png"];
    rules_button.position = CGPointMake(158, self.frame.size.height*.5-self.frame.size.height*.2-525);
    [rules_button setTouchUpInsideTarget:self action:@selector(rules) object:nil];
    
    // Create spinner
    SKSpriteNode* authenticating_indicator = [SKSpriteNode spriteNodeWithImageNamed:@"Main_Menu_Authenticating_Indication.png"];
    authenticating_indicator.position = CGPointMake(0, self.frame.size.height*.5-self.frame.size.height*.2+PASTGAME_START_POSITION_Y-20);
    [authenticating_indicator runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:2*M_PI duration:4]]];
    authenticating_indicator.name = AUTHENTICATING_IDENTIFIER_NODE;
    
    // Create spinner
    _errorPopover = [[GeneralPopover alloc] initWithSize:self.frame.size];
    _errorPopover.hidden = NO;
    _errorPopover.zPosition = 2;

    // Fill moveableNode
    [moveableNode addChild:menu_logo];
    [moveableNode addChild:newGame_button];
    [moveableNode addChild:invite_button];
    [moveableNode addChild:rules_button];
    [moveableNode addChild:authenticating_indicator];
    
    // Make moveable node visible - add popover layer
    [self addChild:moveableNode];
    [self addChild:_errorPopover];
    
    // Subscribe to notifications for when player is authenticated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readjustList)
                                                 name:LocalPlayerIsAuthenticated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readjustList)
                                                 name:LocalPlayerGamesChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handelError:)
                                                 name:LocalPlayerIsUnauthenticated
                                               object:nil];
    
    // If game center is enabled - proceed
    if ( [GameKitHelper sharedGameKitHelper].getEnableGameCenter ) {
        [self readjustList];
    } else if ( [GameKitHelper sharedGameKitHelper].lastError ) {
        [self handelError:[GameKitHelper sharedGameKitHelper].lastError];
    }
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer*) sender {
    
    CGPoint pointPastGameRef = [self convertPoint:[self convertPointFromView:[sender locationInView:_view]] toNode:[[self childNodeWithName:MOVABLE_NODE_NAME] childNodeWithName:PAST_GAME_NODE_NAME]];
    
    BOOL toDelete;
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight ) {
        toDelete = NO;
    } else {
        toDelete = YES;
    }
    
    for ( PastGameButtons* game_button in _activeGameButtons ) {
        if ( CGRectContainsPoint(game_button.frame, pointPastGameRef) ){
            [game_button handleSwipe:toDelete];
        }
    }

    for ( PastGameButtons* game_button in _completedGameButtons ) {
        if ( CGRectContainsPoint(game_button.frame, pointPastGameRef) ){
            [game_button handleSwipe:toDelete];
        }
    }
}

-(void) viewDidLoad {
    //[super viewDidLoad];
}

#pragma mark Adjustable new game list

-(void) readjustList {

    // Load local player matches
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray<GKTurnBasedMatch *>* matches, NSError* error) {
        
        // Sort by date
        matches = [GameKitHelper sortMatchArraybyDate:matches];
        
        // Empty previous buttons
        [self->_activeGameButtons removeAllObjects];
        [self->_completedGameButtons removeAllObjects];
        
        // Remove Error
        [self->_errorPopover removeError];
        
        // Remove spinner
        [[[self childNodeWithName:MOVABLE_NODE_NAME] childNodeWithName:AUTHENTICATING_IDENTIFIER_NODE] removeFromParent];
        
        // Remove previous buttons (if any)
        [[[self childNodeWithName:MOVABLE_NODE_NAME] childNodeWithName:PAST_GAME_NODE_NAME] removeFromParent];
        
        if (error == nil)
        {
            // Create Node to group buttons
            SKNode* pastGamesNode = [SKNode node];
            pastGamesNode.name = PAST_GAME_NODE_NAME;
            pastGamesNode.position = CGPointMake(0, self.frame.size.height*.5-self.frame.size.height*.2+PASTGAME_START_POSITION_Y);
            
            // Collect matches by catagory
            for ( GKTurnBasedMatch* match in matches ) {
                
                // Get opponent gamekit info
                GKTurnBasedParticipant *participant = [match.participants objectAtIndex:0];
                GKTurnBasedParticipant *opponent = [match.participants objectAtIndex:1];
                if ([[GKLocalPlayer localPlayer].playerID isEqualToString:opponent.player.playerID]) {
                    participant = [match.participants objectAtIndex:1];
                    opponent = [match.participants objectAtIndex:0];
                }
                
                // Date as string
                NSDate* lastPlayedDate;
                NSString* lastPlayedPropt;
                if ( (lastPlayedDate = [GameKitHelper lastMoveInMatch:match]) ) {
                    lastPlayedPropt = [NSDate stringForDisplayFromDate:[GameKitHelper lastMoveInMatch:match]];
                } else {
                    lastPlayedPropt = nil;
                }
                
                // Opponent Name as string
                NSString* opponentNamePropt;
                if ( opponent.status == GKTurnBasedParticipantStatusMatching  ) {
                    opponentNamePropt = @"Matching...";
                } else if ( opponent.status == GKTurnBasedParticipantStatusInvited  ) {
                    opponentNamePropt = @"Invited...";
                } else {
                    opponentNamePropt = (opponent.player.alias.length > 16) ? [NSString stringWithFormat:@"%@...", [opponent.player.alias substringToIndex:14]] : opponent.player.alias;
                    
//                    // Screenshot - DEBUG
//                    NSArray* name_array = [NSArray arrayWithObjects:@"Joyce",@"Mike",@"Tommy",@"Sarah",@"Conner", nil];
//                     opponentNamePropt = name_array.count == 0 ? nil : name_array[arc4random_uniform(name_array.count)];
//                     opponentNamePropt = (opponentNamePropt.length > 16) ? [opponentNamePropt substringToIndex:16] : opponentNamePropt;
                }
                
                // Active Game State as string
                NSString* activeGameStatePropt;
                NSString* currentParticipantPlayerID = match.currentParticipant.player.playerID;
                if ( !currentParticipantPlayerID ) {
                    
                    // Match ended
                    switch ( participant.matchOutcome ) {
                        case GKTurnBasedMatchOutcomeWon :
                            activeGameStatePropt = @"You Won";
                            break;
                            
                        case GKTurnBasedMatchOutcomeTied:
                            activeGameStatePropt = @"Your Tied";
                            break;
                            
                        case GKTurnBasedMatchOutcomeLost :
                            activeGameStatePropt = @"You Lost";
                            break;
                            
                        case GKTurnBasedMatchOutcomeQuit :
                            activeGameStatePropt = @"You Lost";
                            break;
                        default:
                            activeGameStatePropt = @"Not Considered";
                            break;
                    }
                    
                    if ( opponent.matchOutcome == GKTurnBasedMatchOutcomeQuit ) {
                        activeGameStatePropt = @"They Quit";
                    }
                    
                    if ( opponent.status == GKTurnBasedMatchStatusMatching ) {
                        activeGameStatePropt = @"Their Turn";
                    }
                } else if ( currentParticipantPlayerID == [GKLocalPlayer localPlayer].playerID ) {
                    activeGameStatePropt = @"Your Turn";
                } else {
                    activeGameStatePropt = @"Their Turn";
                }
                
                // Create New Button with offset
                PastGameButtons* new_game_button = [[PastGameButtons alloc] initWithImageNamedNormal:@"Past_Game_Button.png" selected:@"Past_Game_Button.png" disabled:nil labelLastPlayed:lastPlayedPropt opponentName:opponentNamePropt activeGameState:activeGameStatePropt match:match];
                [new_game_button setTouchUpInsideTarget:self action:@selector(continueGame:) object:nil];
                [new_game_button setQuitTarget:self action:@selector(quitGame:)];
                
                // Add button to list by type
                if ( match.status == GKTurnBasedMatchStatusEnded ) {
                    // Match ended
                    [self->_completedGameButtons addObject:new_game_button];
                } else {
                    [self->_activeGameButtons addObject:new_game_button];
                }
            }
            
            int off_set = 0;
            // Add active game buttons
            if ( [self->_activeGameButtons count] > 0 ) {
                SKSpriteNode* activeGameLabel = [SKSpriteNode spriteNodeWithImageNamed:@"Active_Games_Label.png"];
                activeGameLabel.position = CGPointMake(0, off_set + 20);
                
                SKSpriteNode* menu_divider = [SKSpriteNode spriteNodeWithImageNamed:@"Past_Game_Division.png"];
                menu_divider.position = CGPointMake(0, off_set);
                off_set = off_set - 125;
                
                [pastGamesNode addChild:menu_divider];
                [pastGamesNode addChild:activeGameLabel];

            }
            for ( PastGameButtons* new_game_button in self->_activeGameButtons ) {
                
                new_game_button.position = CGPointMake(0, off_set);
                [pastGamesNode addChild:new_game_button];
                new_game_button.zPosition = 1;
                
                off_set = off_set - 200;
            }
            // Add completed game buttons
            if ( [self->_completedGameButtons count] > 0 ) {
                
                // Correction for active games buffer
                if ( [self->_activeGameButtons count] > 0 ) {
                    off_set = off_set + 50;
                }
                
                SKSpriteNode* completedGameLabel = [SKSpriteNode spriteNodeWithImageNamed:@"Complete_Games_Label.png"];
                completedGameLabel.position = CGPointMake(0, off_set + 20);
                
                SKSpriteNode* menu_divider = [SKSpriteNode spriteNodeWithImageNamed:@"Past_Game_Division.png"];
                menu_divider.position = CGPointMake(0, off_set);
                off_set = off_set - 125;
                
                [pastGamesNode addChild:menu_divider];
                [pastGamesNode addChild:completedGameLabel];

            }
            for ( PastGameButtons* new_game_button in self->_completedGameButtons ) {
                
                new_game_button.position = CGPointMake(0, off_set);
                [pastGamesNode addChild:new_game_button];
                new_game_button.zPosition = 1;

                off_set = off_set - 200;
            }
            
            //Add new button set
            [[self childNodeWithName:MOVABLE_NODE_NAME] addChild:pastGamesNode];

            // Adjust scroll view
            self->_scrollview.contentSize = CGSizeMake(self.frame.size.width, -(-self.frame.size.height*.2+PASTGAME_START_POSITION_Y+off_set));
            
            [[GameKitHelper sharedGameKitHelper] setCurrentLeader:self];
            [[GameKitHelper sharedGameKitHelper] haveMatchesChangedSinceCallIn:[NSDate date] count: [matches count]];
        } else {
            // PRESENT ERROR SCREEN
            NSLog(@"Could not fetch online games because: %@", error);
            if ( error.code != 6 ) { // Dont show ever for not being logged in
                [self handelError:error];
            }
        }
    }];
    
}

#pragma mark Button Reactions

-(void) newGame {

    // Error if game center not enabled
    if ( ![[GameKitHelper sharedGameKitHelper] getEnableGameCenter] || ![GKLocalPlayer localPlayer].isAuthenticated ) {
        [self handelError:[NSError errorWithDomain:@"Not proprtly logged in!" code:-500 userInfo:nil]];
        return;
    }
    
    if ( !_attemptingGameStart ) {
        // Lock others out
        _attemptingGameStart = YES;
        
        // Present GameScene
        [_sceneOrganizer presentGameSceneWithCompletionHandler:^(NSError * error) {
            if ( !error ) {
                [self leavingGameScene];
            } else {
                // PRESENT ERROR SCREEN
                NSLog(@"Could not enter online game because: %@", error);
                [self handelError:error];
                
                // Allow re-try
                self->_attemptingGameStart = NO;
            }
        }];
    }
}

-(void) continueGame: (GKTurnBasedMatch*) match {
    
    // Error if game center not enabled
    if ( ![[GameKitHelper sharedGameKitHelper] getEnableGameCenter] || ![GKLocalPlayer localPlayer].isAuthenticated ) {
        [self handelError:[NSError errorWithDomain:@"Not proprtly logged in!" code:-500 userInfo:nil]];
        return;
    }
   
    if ( !_attemptingGameStart ) {
        
        // Lock others out
        _attemptingGameStart = YES;
        
        // Present Game Scene
        [_sceneOrganizer presentGameScenewithMatch:match andCompletionHandler:^(NSError * error) {
            if ( !error ) {
                [self leavingGameScene];
            } else {
                // PRESENT ERROR SCREEN
                NSLog(@"Could not enter online game because: %@", error);
                [self handelError:error];
                
                // Allow re-try
                self->_attemptingGameStart = NO;
            }
        }];
    }
    
}

-(void) quitGame: (GKTurnBasedMatch*) match {
    
    // Set match and create multinetworking helper
    GameKitHelper* gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper setMatch:match];
    MultiplayerNetworking* networkingEngine = [[MultiplayerNetworking alloc] init];
    
    // Give GameKitHelper MultiplayerNetworking reference
    [[GameKitHelper sharedGameKitHelper] setGkDelegate:networkingEngine];
    
    // Quit and delete match
    if ( match.status != GKTurnBasedMatchStatusEnded ) {
        // Match still active
        
        // Error if game center not enabled
        if ( ![[GameKitHelper sharedGameKitHelper] getEnableGameCenter]  || ![GKLocalPlayer localPlayer].isAuthenticated ) {
            [self handelError:[NSError errorWithDomain:@"Not proprtly logged in!" code:-500 userInfo:nil]];
            return;
        }
        
        [networkingEngine quitMatchWithCompletionHandler:^(NSError *error) {
            if ( !error ) {
                // Match should be quit and safe to remove
                [gameKitHelper removeMatchWithCompletionHandler:^(NSError * error) {
                    if ( error ) {
                        // PRESENT ERROR SCREEN
                        NSLog(@"Could not remove game because: %@", error);
                        [self handelError:error];
                    }
                }];
            } else {
                // PRESENT ERROR SCREEN
                NSLog(@"Could not quit game because: %@", error.localizedDescription);
                [self handelError:error];
            }
        }];
    } else {
        // Remove ended match
        [gameKitHelper removeMatchWithCompletionHandler:^(NSError * error) {
            if ( error ) {
                // PRESENT ERROR SCREEN
                NSLog(@"Could not remove game because: %@", error);
                [self handelError:error];
            }
        }];
    }
}

-(void) invite {
    NSLog(@"Invite Button Pressed.");
    
    // Error if game center not enabled
    if ( ![[GameKitHelper sharedGameKitHelper] getEnableGameCenter] || ![GKLocalPlayer localPlayer].isAuthenticated ) {
        [self handelError:[NSError errorWithDomain:@"Not proprtly logged in!" code:-500 userInfo:nil]];
        return;
    }
    
    [self leavingGameScene];
    
    // Present Rules
    [_sceneOrganizer presentInviteScene];
    
}

// Scene about to exit - post notification; used by invite scene
- (void)willMoveFromView:(SKView *)view {
    // Notify all watchers that game scene is leaving
    [[NSNotificationCenter defaultCenter] postNotificationName:MainSceneWillMoveFromView object:nil userInfo:nil];
}

-(void) rules {    
    [self leavingGameScene];
    
    // Present Rules
    [_sceneOrganizer presentRulesScene];
}

-(void) leavingGameScene {
    // Unsubscribe to notifications for when player is authenticated
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LocalPlayerIsAuthenticated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LocalPlayerGamesChanged
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LocalPlayerIsUnauthenticated
                                                  object:nil];
    
    // Remove scrollview
    [_scrollview removeFromSuperview];
}

-(void) handelError:(id)notification {
    
    NSError* errorNum;
    
    if ( [notification isKindOfClass:[NSNotification class]] ) {
        NSDictionary *userInfo = [notification userInfo];
        errorNum = userInfo[@"index"];
    } else if ( [notification isKindOfClass:[NSError class]] ) {
        errorNum = notification;
    } else {
        [[NSException exceptionWithName:@"unrecognized selector" reason:@"handelError accepts NSNotification or NSError" userInfo:nil] raise];
    }
    
    [_errorPopover showWithError:errorNum];
    
    // Empty previous buttons
    [_activeGameButtons removeAllObjects];
    [_completedGameButtons removeAllObjects];
    
    // Remove spinner
    [[[self childNodeWithName:MOVABLE_NODE_NAME] childNodeWithName:AUTHENTICATING_IDENTIFIER_NODE] removeFromParent];
    
}

@end
