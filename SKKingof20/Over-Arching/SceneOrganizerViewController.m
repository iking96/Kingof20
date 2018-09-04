//
//  GameViewController.m
//  SKKingof20
//
//  Created by Ishmael King on 1/15/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import "SceneOrganizerViewController.h"
#import "MainScene.h"
#import "RulesScene.h"
#import "GameScene.h"
#import "InviteScene.h"
#import "MultiplayerNetworking.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@implementation SceneOrganizerViewController {
    GameScene * _sceneNode;
}

#pragma mark Init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self presentMainScene];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark Scene Presentation

-(void) presentMainScene {
    // Load 'MainScene.sks' as a GKScene. This provides gameplay related content
    GKScene *scene;
    if ( IDIOM == IPAD) {
        scene = [GKScene sceneWithFileNamed:@"MainScene-ipad"];
    } else {
        scene = [GKScene sceneWithFileNamed:@"MainScene-iphone"];
    }
    
    // Get the SKScene from the loaded GKScene
    MainScene *sceneNode = (MainScene *)scene.rootNode;
    sceneNode.sceneOrganizer = self;
    
    // Set polling leader
    [[GameKitHelper sharedGameKitHelper] setCurrentLeader:sceneNode];
    
    // Set the scale mode to scale to fit the window
    sceneNode.scaleMode = SKSceneScaleModeAspectFill;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    SKTransition *reveal = [SKTransition moveInWithDirection:SKTransitionDirectionLeft duration:0.5];
    [skView presentScene:sceneNode transition:reveal];
    
    // --DEBUG--
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
}

-(void) presentRulesScene {
    // Load 'RulesScene.sks' as a GKScene. This provides gameplay related content
    GKScene *scene;
    if ( IDIOM == IPAD) {
        scene = [GKScene sceneWithFileNamed:@"RulesScene-ipad"];
    } else {
        scene = [GKScene sceneWithFileNamed:@"RulesScene-iphone"];
    }
    
    // Get the SKScene from the loaded GKScene
    RulesScene *sceneNode = (RulesScene *)scene.rootNode;
    sceneNode.sceneOrganizer = self;

    // Set the scale mode to scale to fit the window
    sceneNode.scaleMode = SKSceneScaleModeAspectFill;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    // Present the scene
    SKTransition *reveal = [SKTransition moveInWithDirection:SKTransitionDirectionRight duration:0.5];
    [skView presentScene:sceneNode transition:reveal];
    
    // --DEBUG--
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
}

-(void) presentInviteScene {
    // Load 'InviteScene.sks' as a GKScene. This provides gameplay related content
    GKScene *scene;
    if ( IDIOM == IPAD) {
        scene = [GKScene sceneWithFileNamed:@"InviteScene-ipad"];
    } else {
        scene = [GKScene sceneWithFileNamed:@"InviteScene-iphone"];
    }
    
    // Get the SKScene from the loaded GKScene
    InviteScene *sceneNode = (InviteScene *)scene.rootNode;
    sceneNode.sceneOrganizer = self;
    
    // Set the scale mode to scale to fit the window
    sceneNode.scaleMode = SKSceneScaleModeAspectFill;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    // Present the scene
    SKTransition *reveal = [SKTransition moveInWithDirection:SKTransitionDirectionRight duration:0.5];
    [skView presentScene:sceneNode transition:reveal];
    
    // --DEBUG--
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
}

-(void) presentGameScenewithMatch: (GKTurnBasedMatch*) match andCompletionHandler:(void (^)(NSError*))completionHandler {
    if ([[GameKitHelper sharedGameKitHelper] getEnableGameCenter]) {
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        GKScene *scene;
        if ( IDIOM == IPAD) {
            scene = [GKScene sceneWithFileNamed:@"GameScene-ipad"];
        } else {
            scene = [GKScene sceneWithFileNamed:@"GameScene-iphone"];
        }
        
        // Get the SKScene from the loaded GKScene
        _sceneNode = (GameScene *)scene.rootNode;
        _sceneNode.sceneOrganizer = self;
        
        // Connect Networking Class
        _sceneNode.networkingEngine = [[MultiplayerNetworking alloc] init];
        _sceneNode.networkingEngine.delegate = _sceneNode;
        
        // Give GameKitHelper MultiplayerNetworking reference
        [[GameKitHelper sharedGameKitHelper] setGkDelegate:_sceneNode.networkingEngine];
        [[GameKitHelper sharedGameKitHelper] setCurrentLeader:_sceneNode];
        
        // Update GameScene and present on completion
        [[GameKitHelper sharedGameKitHelper] player:[GKLocalPlayer localPlayer] receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:^(NSError * error) {
            
            // Present gameScene or respond to error
            if ( !error ) {
                [self onlineGameEnteredwithMatch:(GKTurnBasedMatch*)match];
                completionHandler(nil);
            } else {
                // Don't return completiton handler - take action; return to main scene
                [self presentMainScene];
                NSLog(@"Scene Organizer had to handel Game Scene error");
            }
            
        }];
        
    } else {
        // User was never authenticated
        completionHandler([[GameKitHelper sharedGameKitHelper] lastError]);
    }
}

-(void) presentGameScenewithFriend: (GKPlayer*) playerID andCompletionHandler:(void (^)(NSError*))completionHandler {
    if ([[GameKitHelper sharedGameKitHelper] getEnableGameCenter]) {
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        GKScene *scene;
        if ( IDIOM == IPAD) {
            scene = [GKScene sceneWithFileNamed:@"GameScene-ipad"];
        } else {
            scene = [GKScene sceneWithFileNamed:@"GameScene-iphone"];
        }
        
        // Get the SKScene from the loaded GKScene
        _sceneNode = (GameScene *)scene.rootNode;
        _sceneNode.sceneOrganizer = self;
        
        // Connect Networking Class
        _sceneNode.networkingEngine = [[MultiplayerNetworking alloc] init];
        _sceneNode.networkingEngine.delegate = _sceneNode;
        
        // Give GameKitHelper MultiplayerNetworking reference
        [[GameKitHelper sharedGameKitHelper] setGkDelegate:_sceneNode.networkingEngine];
        //[[GameKitHelper sharedGameKitHelper] setCurrentLeader:_sceneNode];
        
        // Send invite to friend - return match
        [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 specificOpponent:playerID  useVC: NO gameKitHelperDelegate:_sceneNode.networkingEngine withCompletionHandler:^(GKTurnBasedMatch * match, NSError * error) {
            
            if ( match ) {
                
                // Start polling for game scene
                [[GameKitHelper sharedGameKitHelper] setCurrentLeader:self->_sceneNode];
                
                // Update GameScene and present on completion
                [[GameKitHelper sharedGameKitHelper] player:[GKLocalPlayer localPlayer] receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:^(NSError * error) {
                    
                    // Present gameScene and return error
                    if ( !error ) {
                        [self onlineGameEnteredwithMatch:(GKTurnBasedMatch*)match];
                        completionHandler(nil);
                    } else {
                        // Don't return completiton handler - take action; return to main scene
                        [self presentMainScene];
                        NSLog(@"Scene Organizer had to handel Game Scene error");
                    }
                    
                }];
                
            } else {
                completionHandler(error);
            }
            
        }];
        
    } else {
        
        // User was never authenticated
        completionHandler([[GameKitHelper sharedGameKitHelper] lastError]);
        
    }
}

-(void) presentGameScenefromInvitewithCompletionHandler:(void (^)(NSError*))completionHandler {
    if ([[GameKitHelper sharedGameKitHelper] getEnableGameCenter]) {
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        GKScene *scene;
        if ( IDIOM == IPAD) {
            scene = [GKScene sceneWithFileNamed:@"GameScene-ipad"];
        } else {
            scene = [GKScene sceneWithFileNamed:@"GameScene-iphone"];
        }
        
        // Get the SKScene from the loaded GKScene
        _sceneNode = (GameScene *)scene.rootNode;
        _sceneNode.sceneOrganizer = self;
        
        // Connect Networking Class
        _sceneNode.networkingEngine = [[MultiplayerNetworking alloc] init];
        _sceneNode.networkingEngine.delegate = _sceneNode;
        
        // Give GameKitHelper MultiplayerNetworking reference
        [[GameKitHelper sharedGameKitHelper] setGkDelegate:_sceneNode.networkingEngine];
        //[[GameKitHelper sharedGameKitHelper] setCurrentLeader:_sceneNode];
        
        // Send invite to friend - return match
        [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 specificOpponent:nil useVC: YES gameKitHelperDelegate:_sceneNode.networkingEngine withCompletionHandler:^(GKTurnBasedMatch * match, NSError * error) {
            
            if ( match ) {
                
                // Start polling for game scene
                [[GameKitHelper sharedGameKitHelper] setCurrentLeader:self->_sceneNode];
                
                // Update GameScene and present on completion
                [[GameKitHelper sharedGameKitHelper] player:[GKLocalPlayer localPlayer] receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:^(NSError * error) {
                    
                    // Present gameScene and return error
                    if ( !error ) {
                        [self onlineGameEnteredwithMatch:(GKTurnBasedMatch*)match];
                        completionHandler(nil);
                    } else {
                        // Don't return completiton handler - take action; return to main scene
                        [self presentMainScene];
                        NSLog(@"Scene Organizer had to handel Game Scene error");
                    }
                    
                }];
                
            } else {
                completionHandler(error);
            }
            
        }];
        
    } else {
        
        // User was never authenticated
        completionHandler([[GameKitHelper sharedGameKitHelper] lastError]);
        
    }
}

-(void) presentGameSceneWithCompletionHandler:(void (^)(NSError*))completionHandler {
    if ([[GameKitHelper sharedGameKitHelper] getEnableGameCenter]) {
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        GKScene *scene;
        if ( IDIOM == IPAD) {
            scene = [GKScene sceneWithFileNamed:@"GameScene-ipad"];
        } else {
            scene = [GKScene sceneWithFileNamed:@"GameScene-iphone"];
        }
    
        // Get the SKScene from the loaded GKScene
        _sceneNode = (GameScene *)scene.rootNode;
        _sceneNode.sceneOrganizer = self;
        
        // Connect Networking Class
        _sceneNode.networkingEngine = [[MultiplayerNetworking alloc] init];
        _sceneNode.networkingEngine.delegate = _sceneNode;
        
        // Give GameKitHelper MultiplayerNetworking reference
        [[GameKitHelper sharedGameKitHelper] setGkDelegate:_sceneNode.networkingEngine];
        //[[GameKitHelper sharedGameKitHelper] setCurrentLeader:self->_sceneNode];

        // Find 2 player match to join/create
        [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 specificOpponent:nil useVC: NO gameKitHelperDelegate:_sceneNode.networkingEngine withCompletionHandler:^(GKTurnBasedMatch * match, NSError * error) {
            
            if ( match ) {
                
                // Start polling for game scene
                [[GameKitHelper sharedGameKitHelper] setCurrentLeader:self->_sceneNode];
                
                // Update GameScene and present on completion
                [[GameKitHelper sharedGameKitHelper] player:[GKLocalPlayer localPlayer] receivedTurnEventForMatch:match didBecomeActive:false withCompletionHandler:^(NSError * error) {
                    
                    // Present gameScene and return error
                    if ( !error ) {
                        [self onlineGameEnteredwithMatch:(GKTurnBasedMatch*)match];
                        completionHandler(nil);
                    } else {
                        // Don't return completiton handler - take action; return to main scene
                        [self presentMainScene];
                        NSLog(@"Scene Organizer had to handel Game Scene error");
                    }

                }];
                
            } else {
                completionHandler(error);
            }

        }];
        
    } else {
        
        // User was never authenticated
        completionHandler([[GameKitHelper sharedGameKitHelper] lastError]);
        
    }
}

-(void) onlineGameEnteredwithMatch:(GKTurnBasedMatch*)match {

    // Set the scale mode to scale to fit the window
    _sceneNode.scaleMode = SKSceneScaleModeAspectFill;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    SKTransition *reveal = [SKTransition crossFadeWithDuration:0.5];
    reveal.pausesIncomingScene = false;
    
    //SKTransition *reveal = [SKTransition moveInWithDirection:SKTransitionDirectionRight duration:0.5];
    [skView presentScene:_sceneNode transition:reveal];
    
    // --DEBUG--
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Forget Node pointer -- now presented as scene
    _sceneNode = nil;
    
}

@end
