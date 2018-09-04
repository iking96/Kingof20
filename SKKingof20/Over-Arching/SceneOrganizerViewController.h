//
//  GameViewController.h
//  SKKingof20
//
//  Created by Ishmael King on 1/15/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "GameKitHelper.h"

@protocol SceneOrganizerDelegate
@required

// Present Various Scenes
-(void) presentMainScene;
-(void) presentRulesScene;
-(void) presentInviteScene;
-(void) presentGameScenewithMatch: (GKTurnBasedMatch*) match andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;
-(void) presentGameScenewithFriend: (GKPlayer*) playerID andCompletionHandler:(nonnull void (^)(NSError*))completionHandler;
-(void) presentGameScenefromInvitewithCompletionHandler:(nonnull void (^)(NSError*))completionHandler;
-(void) presentGameSceneWithCompletionHandler:(nonnull void (^)(NSError*))completionHandler;

@end

@interface SceneOrganizerViewController : UIViewController <SceneOrganizerDelegate>

@end
