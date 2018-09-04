//
//  GeneralPopover.m
//  SKKingof20
//
//  Created by Ishmael King on 5/1/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneralPopover.h"

@implementation GeneralPopover {
    CGSize _size;
    
    SKSpriteNode* _movingNode;
    
    SKAction* _popoverDown;
    SKAction* _popoverUp;
    
    NSInteger _currError;
}

#pragma mark Init

-(id) initWithSize:(CGSize)size {
    self = [super init];
    
    _size = size;
    
    // Set textures
    _networkTexture = [SKTexture textureWithImageNamed:@"General_Warning_Network.png"];
    _loginTexture = [SKTexture textureWithImageNamed:@"General_Warning_Login.png"];
    _unknownTexture = [SKTexture textureWithImageNamed:@"General_Warning_Unknown.png"];
    _gameCenterTexture = [SKTexture textureWithImageNamed:@"General_Warning_Game_Center.png"];

    /**
     * BACKGROUND
     **/
    // Create Back Button
    _movingNode = [SKSpriteNode spriteNodeWithTexture:_networkTexture];
    _movingNode.position = CGPointMake( 0 , (size.height/2)+(_movingNode.size.height/2)+10); // Place popover just above scene
    
    // Creat popover actions
    _popoverDown = [SKAction sequence:@[
                                        //[SKAction moveToY:(size.height/2)+(_movingNode.size.height/2)+10 duration:.25 ],
                                        [SKAction moveToY:(size.height/2)-(_movingNode.size.height/2) duration:.25 ]
                                        ]];
    
    _popoverUp = [SKAction sequence:@[
                                      [SKAction moveToY:(size.height/2)+(_movingNode.size.height/2)+10 duration:.25 ]
                                      ]];
    
    [self addChild:_movingNode];
    
    return self;
}

#pragma -
#pragma mark Change Display

-(void) showWithError:(NSError*) error {
    
    switch ( error.code ) {
        case -1999 ... -1000: // All network error codes
            [_movingNode setTexture:_networkTexture];
            break;
            
        case 15: // The requested operation could not be completed because this application is not recognized by Game Center
        case 6: // The requested operation could not be completed because local player has not been authenticated
        case -500: // _enableGameCenter = No
            [_movingNode setTexture:_loginTexture];
            break;
            
        case 2: // Login Cancelled
            // Do nothing, but still cant play
            return;
            
        case -400: // Any Game Center function returns error
            [_movingNode setTexture:_gameCenterTexture];
            break;
            
        default:
            [_movingNode setTexture:_unknownTexture];
            break;
    }
    
    if ( _currError != error.code ) {
        [_movingNode runAction:_popoverUp];
    }
    
    // --DEBUG--
    SKLabelNode* error_label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    error_label.text = [@(error.code) stringValue];
    error_label.fontColor = [UIColor blueColor];
    //[_movingNode addChild:error_label];
    
    [_movingNode runAction:_popoverDown];
    _currError = error.code;
}

-(void) removeError {
    [_movingNode runAction:_popoverUp];
}

@end
