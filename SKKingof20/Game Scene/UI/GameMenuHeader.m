//
//  GameMenuHeader.m
//  SKKingof20
//
//  Created by Ishmael King on 3/15/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameMenuHeader.h"

@interface GameMenuHeader()

/// Displayed participant/opponant score
@property SKLabelNode* participantScore;
@property SKLabelNode* opponentScore;
@property SKLabelNode* participantText;
@property SKLabelNode* opponentText;

/// Player Turn Indicator
@property SKSpriteNode* marker;
@end

@implementation GameMenuHeader {
    SKAction* _markerFirstUpdate;
    SKAction* _markerSecondUpdate;
    
    SKAction* _fullAlpha;
    SKAction* _halfAlpha;
}

-(id) initWithSize:(CGSize)size {
    self = [super init];
    
    _marker = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(size.width/2, 50)];
    _marker.position = CGPointMake(-size.width/4, 90);
    _marker.anchorPoint = CGPointMake(0, .5);
    
    // Creat Marker actions
    _markerFirstUpdate = [SKAction moveToX:-size.width/2 duration:.25];
    _markerSecondUpdate = [SKAction moveToX:0 duration:.25];

    // Creat Text actions
    _markerFirstUpdate = [SKAction moveToX:-size.width/2 duration:.25];
    _markerSecondUpdate = [SKAction moveToX:0 duration:.25];
    
    _fullAlpha = [SKAction fadeAlphaTo:1 duration:.25];
    _halfAlpha = [SKAction fadeAlphaTo:.5 duration:.25];
    
    // Create Participant Text
    _participantScore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [_participantScore setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_participantScore setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeRight];
    _participantScore.position = CGPointMake( -25, 0);
    _participantScore.fontSize = 75;
    _participantScore.text = @"0";
    
    _participantText = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [_participantText setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_participantText setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeRight];
    _participantText.position = CGPointMake( -25, -50);
    _participantText.fontSize = 35;
    _participantText.text = @"0";
    
    // Create Opponent Text
    _opponentScore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [_opponentScore setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_opponentScore setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    _opponentScore.position = CGPointMake(25, 0);
    _opponentScore.fontSize = 75;
    _opponentScore.text = @"0";
    
    _opponentText = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    [_opponentText setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_opponentText setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    _opponentText.position = CGPointMake(25, -50);
    _opponentText.fontSize = 35;
    _opponentText.text = @"0";
    
    [self addChild:_marker];
    [self addChild:_participantScore];
    [self addChild:_opponentScore];
    [self addChild:_participantText];
    [self addChild:_opponentText];
    
    return self;
}

-(void) updatePlayerNames:(NSString*)firstName and:(NSString*)secondName {
    
    _participantText.text = firstName;
    _opponentText.text = secondName;

}

-(void) updateFirstPlayerScore: (NSInteger) score {
    _participantScore.text = [@(score) stringValue];
}

-(void) updateSecondPlayerScore: (NSInteger) score {
    _opponentScore.text = [@(score) stringValue];
}

#pragma mark Animations

-(void) animateTurn:(BOOL)myTurn {
    // Run animations based on current Turn
    if ( myTurn ) {
        [_marker runAction:_markerFirstUpdate];
        [_participantScore runAction:_fullAlpha];
        [_participantText runAction:_fullAlpha];
        [_opponentScore runAction:_halfAlpha];
        [_opponentText runAction:_halfAlpha];
    } else {
        [_marker runAction:_markerSecondUpdate];
        [_participantScore runAction:_halfAlpha];
        [_participantText runAction:_halfAlpha];
        [_opponentScore runAction:_fullAlpha];
        [_opponentText runAction:_fullAlpha];
    }
}

@end
