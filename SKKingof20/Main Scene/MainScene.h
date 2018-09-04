//
//  MainScene.h
//  SKKingof20
//
//  Created by Ishmael King on 1/15/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import <GameKit/GameKit.h>
#import "SceneOrganizerViewController.h"

extern NSString *const MainSceneWillMoveFromView;

@interface MainScene : SKScene

@property id <SceneOrganizerDelegate> sceneOrganizer;

@end
