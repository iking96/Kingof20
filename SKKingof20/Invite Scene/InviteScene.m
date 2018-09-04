//
//  InviteScene.m
//  SKKingof20
//
//  Created by Ishmael King on 5/20/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InviteScene.h"
#import "CustomScrollView.h"
#import "CustomKTButton.h"

NSString* MOVABLE_NODE_NAME_INVITE = @"moveableNode";
static const int TOP_CENTER_NODE_RESTING_INVITE = 400;
static const int  TEXTFEILD_WIDTH = 225;
static const int  TEXTFEILD_HIGHT = 60;
static const int  NAMESPACE_HIGHT = 147;

@implementation InviteScene {
    // Scrollview for menu
    CustomScrollView* _scrollview;
    
    // Current view of Main Scene
    SKView* _view;
    
    // Text field for username search - spinning indicator
    UITextField* _textfield;
    SKSpriteNode* _authenticating_indicator;
    SKSpriteNode* _confirmation;
    SKLabelNode* _playerLabel;

    // Past Game Button Segragated
    NSMutableArray<CustomKTButton*>* _recentButtons;
    NSMutableArray<GKPlayer*>* _recentArray;
    
    // Other buttons
    CustomKTButton* _back_button;
    CustomKTButton* _nf_button;
    
    // Player choosen to play with
    GKPlayer* _player;
}

#pragma mark Node Initilization

- (void)didMoveToView:(SKView *)view {
    
    // Init
    _recentButtons = [[NSMutableArray alloc] init];
    _recentArray = [[NSMutableArray alloc] init];
    
    // Create movable (central) node and Scrolling VC
    SKNode* moveableNode = [SKNode node];
    moveableNode.name = MOVABLE_NODE_NAME_INVITE;
    CustomScrollView* new_view = [[CustomScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) scene:self moveableNode:moveableNode scrollDirection:vertical paging:NO];
    [self addChild:moveableNode];

    _scrollview = new_view;
    _view = view;
    
    // Set content size and add to current view
    new_view.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [view addSubview:new_view];
    
    // Get size of scene
    CGSize _size = self.frame.size;
    
    /**
     * TOP OVERLAY
     **/
    
    // Create top overlay
    SKSpriteNode* topLayover = [SKSpriteNode spriteNodeWithImageNamed:@"Game_Scene_Top_Overlay.png"];
    [topLayover setZPosition:1];
    topLayover.anchorPoint = CGPointMake(.5, 0);
    
    // Create text field
    //_textfield = [[UITextField alloc] initWithFrame:CGRectMake( (view.frame.size.width/2) - (TEXTFEILD_WIDTH/2) , -(TEXTFEILD_HIGHT/2) + 65 , TEXTFEILD_WIDTH, TEXTFEILD_HIGHT)];
    CGPoint viewAdjustedHight = [self convertPointToView:CGPointMake(0, ((TOP_CENTER_NODE_RESTING_INVITE+(_size.height)/2)/2)+5)];
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake( (view.frame.size.width/2) - (TEXTFEILD_WIDTH/2) , viewAdjustedHight.y-(TEXTFEILD_HIGHT/2) , TEXTFEILD_WIDTH, TEXTFEILD_HIGHT)];
    //_textfield.center = self.view.center;
    _textfield.borderStyle = UITextBorderStyleRoundedRect;
    _textfield.textColor = [UIColor blackColor];
    _textfield.font = [UIFont systemFontOfSize:17.0];
    _textfield.placeholder = @"Search...";
    _textfield.backgroundColor = [UIColor whiteColor];
    _textfield.autocorrectionType = UITextAutocorrectionTypeYes;
    _textfield.keyboardType = UIKeyboardTypeDefault;
    _textfield.keyboardAppearance = UIKeyboardAppearanceDefault;
    _textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textfield.delegate = self;
    _textfield.hidden = YES;
    // Add a "textFieldDidChange" notification method to the text field control.
    [_textfield addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [_view addSubview:_textfield];
    
    // Create Back Button
    _back_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Back_Button.png" selected:@"Game_Scene_Back_Button.png"];
    _back_button.position = CGPointMake( (-_size.width)/2 + 50, ((TOP_CENTER_NODE_RESTING_INVITE+(_size.height)/2)/2)-TOP_CENTER_NODE_RESTING_INVITE+5);
    [_back_button setTouchUpInsideTarget:self action:@selector(shouldBack) object:nil];
    [_back_button setZPosition:1];
    
    // Create New Friend Button
    _nf_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"Invite_Scene_Plus_Button.png" selected:@"Invite_Scene_Plus_Button.png"];
    _nf_button.position = CGPointMake( (_size.width)/2 - 50, ((TOP_CENTER_NODE_RESTING_INVITE+(_size.height)/2)/2)-TOP_CENTER_NODE_RESTING_INVITE+5);
    [_nf_button setTouchUpInsideTarget:self action:@selector(presentTBViewController) object:nil];
    [_nf_button setZPosition:1];
    
    SKNode* topCenterNode = [SKNode node]; //Top-Center Node
    topCenterNode.position = CGPointMake(0, TOP_CENTER_NODE_RESTING_INVITE);
    [topCenterNode addChild:topLayover];
    [topCenterNode addChild:_back_button];
    [topCenterNode addChild:_nf_button];

    /**
     * BODY
     **/
    
    // Create spinner
    _authenticating_indicator = [SKSpriteNode spriteNodeWithImageNamed:@"Main_Menu_Authenticating_Indication.png"];
    _authenticating_indicator.position = CGPointMake(0, TOP_CENTER_NODE_RESTING_INVITE-75);
    [_authenticating_indicator runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:2*M_PI duration:4]]];
    
    // Create confirmation and buttons
    _confirmation = [SKSpriteNode spriteNodeWithImageNamed:@"Invite_Scene_Confirmation.png"];
    CustomKTButton* play_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"InviteScene_Confirmation_Play.png" selected:@"InviteScene_Confirmation_Play.png"];
    _confirmation.hidden = YES;
    play_button.position = CGPointMake( 150, -250);
    [play_button setTouchUpInsideTarget:self action:@selector(handleConfirmation) object:nil];
    CustomKTButton* cancel_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"InviteScene_Confirmation_Cancel.png" selected:@"InviteScene_Confirmation_Cancel.png"];
    cancel_button.position = CGPointMake( -150, -250);
    [cancel_button setTouchUpInsideTarget:self action:@selector(handleCancel) object:nil];
    _playerLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    [_playerLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_playerLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    _playerLabel.position = CGPointMake( 0, 0);
    _playerLabel.fontColor = [UIColor blackColor];
    _playerLabel.fontSize = 75;
    _playerLabel.text = @"TEMP";
    
    // Form confirmation
    [_confirmation addChild:play_button];
    [_confirmation addChild:cancel_button];
    [_confirmation addChild:_playerLabel];
    
    [self addChild:topCenterNode];
    [self addChild:_authenticating_indicator];
    [self addChild:_confirmation];
    
    // Subscribe to notifications for when game scene leaves
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentTextBox)
                                                 name:MainSceneWillMoveFromView
                                               object:nil];
    
    // Find/Display Recents
    [[GKLocalPlayer localPlayer] loadRecentPlayersWithCompletionHandler:^(NSArray<GKPlayer *> * _Nullable recentPlayers, NSError * _Nullable error) {
        if ( !error ) {
            
            // Remove spinner
            [self->_authenticating_indicator removeFromParent];
            
            // If no friends display special message
            
            // Save each friend
            [self->_recentArray removeAllObjects];
            for ( GKPlayer* player in recentPlayers ) {
                [self->_recentArray addObject:player];
            }
            
            [self readjustList];
            
        } else {
            // No real handle - go back to game scene
            NSLog(@"Could not display recents: %@", error);
            [self shouldBack];
        }
    }];
}

// Simply make text feild visible
-(void) presentTextBox {
    _textfield.hidden = NO;
}

#pragma mark Node Player Selection

-(void) startGameWithPlayer:(GKPlayer*) player {
    
    // Set player
    _player = player;

    // Make confirmation popup visible
    _confirmation.hidden = NO;
    _playerLabel.text = (player.alias.length > 12) ? [NSString stringWithFormat:@"%@...", [player.alias substringToIndex:10]] : player.alias;
    [self shouldDisableAllButtons:YES];

}

-(void) handleConfirmation {
    NSLog(@"%@", _player);
    
    [self shouldDisableAllButtons:NO];
    
    // Present GameScene
    [_sceneOrganizer presentGameScenewithFriend:_player andCompletionHandler:^(NSError * error) {
        if ( !error ) {
            [self leavingInviteScene];
        } else {
            // Was an error - check if it is 
            // Leave to main scene
            NSLog(@"Could not enter invitee game because: %@", error);
            [self leavingInviteScene];
            [self->_sceneOrganizer presentMainScene];
        }
    }];
}

-(void) handleCancel {
    
    // Hide confirmation popup
    _confirmation.hidden = YES;
    
    [self shouldDisableAllButtons:NO];
}

-(void) presentTBViewController {
    
    [self shouldDisableAllButtons:YES];

    // Present GameScene
    [_sceneOrganizer presentGameScenefromInvitewithCompletionHandler:^(NSError * error) {
        if ( !error ) {
            [self leavingInviteScene];
        } else {
            // Leave to main scene turnBasedMatchmakerViewControllerWasCancelled
            if ( ![error.domain isEqualToString:@"turnBasedMatchmakerViewControllerWasCancelled"] ) {
                NSLog(@"Could not enter invitee game because: %@", error);
                [self leavingInviteScene];
                [self->_sceneOrganizer presentMainScene];
            }
        }
        [self shouldDisableAllButtons:NO];
    }];
}

-(void) readjustList {
    
    // Remove old buttons (if any)
//    for ( CustomKTButton* old_button in _recentButtons ) {
//        [old_button removeFromParent];
//    }
    
    // Remove old buttons (if any) and labels
    [[self childNodeWithName:MOVABLE_NODE_NAME_INVITE] removeAllChildren];
    
    // Display each friend - if visible in search
    int off_set = TOP_CENTER_NODE_RESTING_INVITE + 2; // Adjust for top_layover shadow
    
    _recentArray = [[GameKitHelper sortPlayerArraybyName:_recentArray] mutableCopy];
    
    for ( GKPlayer* player in _recentArray ) {
        
        if ( [_textfield.text isEqual:@""] || [[player.alias lowercaseString] containsString:[_textfield.text lowercaseString]] ) {
            // Create Friend Button
            CustomKTButton* friend_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"Invite_Scene_NameSpace.png" selected:@"Invite_Scene_NameSpace.png"];
            friend_button.position = CGPointMake(0, off_set - (NAMESPACE_HIGHT/2));
            friend_button.title.text = (player.alias.length > 16) ? [NSString stringWithFormat:@"%@...", [player.alias substringToIndex:12]] : player.alias;
            
            // Screenshot - DEBUG
//            NSArray* name_array = [NSArray arrayWithObjects:@"Joyce",@"Mike",@"Tommy",@"Sarah",@"Conner",@"Sammy",@"Ryan",@"Freddy",@"Rex", nil];
//            NSString* temp_string = name_array.count == 0 ? nil : name_array[arc4random_uniform(name_array.count)];
//            temp_string = (temp_string.length > 16) ? [temp_string substringToIndex:16] : temp_string;
//            friend_button.title.text = temp_string;
            
            friend_button.title.fontColor = [UIColor blackColor];
            friend_button.title.fontSize = 55;
            [friend_button setTouchUpInsideTarget:self action:@selector(startGameWithPlayer:) object:player];

            // Add button to scene
            [[self childNodeWithName:MOVABLE_NODE_NAME_INVITE] addChild:friend_button];

            // Adjust for next button
            off_set = off_set - NAMESPACE_HIGHT;
            
            // Add button to recents
            [_recentButtons addObject:friend_button];
        }
    }
    
    SKSpriteNode* inviteMessage = [SKSpriteNode spriteNodeWithImageNamed:@"InviteScene_Message.png"];
    inviteMessage.position = CGPointMake(0, off_set - (NAMESPACE_HIGHT/2));
    
    // Adjust for next button
    off_set = off_set - NAMESPACE_HIGHT;
    
    // Add button to scene
    [[self childNodeWithName:MOVABLE_NODE_NAME_INVITE] addChild:inviteMessage];
    
    // Adjust content size
    _scrollview.contentSize = CGSizeMake(self.frame.size.width, (self.frame.size.height/2) - off_set + NAMESPACE_HIGHT);
}

#pragma mark Node Textbox

// Text feild being editted
-(void)textFieldDidChange:(UITextField *)textField {
    //NSLog(@"Text: %@", textField.text);
    [self readjustList]; // Re-draw menu
}

// Return Key Pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:NO]; // Close keyboard

//    // Find player based on search
//    if ( ![textField.text  isEqual: @""] ) {
//        [GKPlayer loadPlayersForIdentifiers:@[textField.text] withCompletionHandler:^(NSArray *players, NSError *error) {
//            if (error != nil)
//            {
//                // PRESENT ERROR SCREEN
//                NSLog(@"Could not load players: %@", error);
//            }
//            if (players != nil)
//            {
//                // Process the array of GKPlayer objects.
//                NSLog(@"Players: %@", players);
//            }
//        }];
//    }
    
    return YES;
}

#pragma mark Node Buttons

-(void) leavingInviteScene {
    // Unsubscribe to notifications for when game scene leaves
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MainSceneWillMoveFromView
                                                  object:nil];
    
    // Remove scrollview
    [_scrollview removeFromSuperview];
    [_textfield removeFromSuperview];
}

-(void) shouldDisableAllButtons:(bool) disable {
    
    // Enable/Disable buttons (if any)
    for ( CustomKTButton* button in _recentButtons ) {
        button.isEnabled = !disable;
    }
    
    _back_button.isEnabled = !disable;
    _nf_button.isEnabled = !disable;

}
-(void)shouldBack{
    NSLog(@"Go back to main menu!");
    
    // Cleanup
    [self leavingInviteScene];
    
    // Present Rules
    [_sceneOrganizer presentMainScene];
}

@end
