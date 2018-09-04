//
//  InviteScene.h
//  SKKingof20
//
//  Created by Ishmael King on 5/20/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef InviteScene_h
#define InviteScene_h

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "SceneOrganizerViewController.h"
#import "MainScene.h"

@interface InviteScene : SKScene <UITextFieldDelegate>

@property id <SceneOrganizerDelegate> sceneOrganizer;

@end

#endif /* InviteScene_h */
