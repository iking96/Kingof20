//
//  RulesScene.m
//  SKKingof20
//
//  Created by Ishmael King on 1/23/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RulesScene.h"
#import "CustomScrollView.h"
#import "CustomKTButton.h"

@implementation RulesScene {
    CustomScrollView* _scrollview;
}

- (void)didMoveToView:(SKView *)view {
    
    // Create movable (central) node and Scrolling VC
    SKNode* moveableNode = [SKNode node];
    CustomScrollView* new_view = [[CustomScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) scene:self moveableNode:moveableNode scrollDirection:horizontal paging:YES];
    
    _scrollview = new_view;
    
    // Set content size and add to current view
    new_view.contentSize = CGSizeMake(self.frame.size.width * 5, self.frame.size.height);
    new_view.contentOffset = CGPointMake(self.frame.size.width * 4, 0);
    [view addSubview:new_view];
    
    float arrow_offset = (-self.frame.size.height/2)+100;
    
    // Create Page 1
    SKSpriteNode* rules_one = [SKSpriteNode spriteNodeWithImageNamed:@"Rules_1.png"];
    rules_one.position = CGPointMake(-self.frame.size.width * 4, 0);
    SKSpriteNode* arrow_one = [SKSpriteNode spriteNodeWithImageNamed:@"Swipe_Arrow_Right.png"];
    arrow_one.position = CGPointMake(-self.frame.size.width * 4, arrow_offset);
    
    // Create Page 2
    SKSpriteNode* rules_two = [SKSpriteNode spriteNodeWithImageNamed:@"Rules_2.png"];
    rules_two.position = CGPointMake(-self.frame.size.width * 3, 0);
    SKSpriteNode* arrow_two = [SKSpriteNode spriteNodeWithImageNamed:@"Swipe_Arrow_Double.png"];
    arrow_two.position = CGPointMake(-self.frame.size.width * 3, arrow_offset);
    
    // Create Page 3
    SKSpriteNode* rules_three = [SKSpriteNode spriteNodeWithImageNamed:@"Rules_3.png"];
    rules_three.position = CGPointMake(-self.frame.size.width * 2, 0);
    SKSpriteNode* arrow_three = [SKSpriteNode spriteNodeWithImageNamed:@"Swipe_Arrow_Double.png"];
    arrow_three.position = CGPointMake(-self.frame.size.width * 2, arrow_offset);
    
    // Create Page 4
    SKSpriteNode* rules_four = [SKSpriteNode spriteNodeWithImageNamed:@"Rules_4.png"];
    rules_four.position = CGPointMake(-self.frame.size.width, 0);
    SKSpriteNode* arrow_four = [SKSpriteNode spriteNodeWithImageNamed:@"Swipe_Arrow_Double.png"];
    arrow_four.position = CGPointMake(-self.frame.size.width, arrow_offset);
    
    // Create Page 5
    SKSpriteNode* rules_five = [SKSpriteNode spriteNodeWithImageNamed:@"Rules_5.png"];
    rules_five.position = CGPointMake(0, 0);
    SKSpriteNode* arrow_five = [SKSpriteNode spriteNodeWithImageNamed:@"Swipe_Arrow_Left.png"];
    arrow_five.position = CGPointMake(0, arrow_offset);
    
    // Create Back Button
    CustomKTButton* back_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"Game_Scene_Back_Button.png" selected:@"Game_Scene_Back_Button.png"];
    back_button.position = CGPointMake((-self.frame.size.width)/2 + 100, (self.frame.size.height)/2 - 100);
    [back_button setTouchUpInsideTarget:self action:@selector(shouldBack) object:nil];
    
    // Create Back Button
    CustomKTButton* privacy_button = [[CustomKTButton alloc] initWithImageNamedNormal:@"Privacy_Policy_Button.png" selected:@"Privacy_Policy_Button.png"];
    privacy_button.position = CGPointMake(0, (self.frame.size.height)/2 - 100);
    [privacy_button setTouchUpInsideTarget:self action:@selector(presentPrivacy) object:nil];
    
    // Fill moveableNode
    [moveableNode addChild:rules_one];
    [moveableNode addChild:arrow_one];
    [moveableNode addChild:rules_two];
    [moveableNode addChild:arrow_two];
    [moveableNode addChild:rules_three];
    [moveableNode addChild:arrow_three];
    [moveableNode addChild:rules_four];
    [moveableNode addChild:arrow_four];
    [moveableNode addChild:rules_five];
    [moveableNode addChild:arrow_five];

    // Make moveable node visible
    [self addChild:moveableNode];
    [self addChild:back_button];
    [self addChild:privacy_button];

}

-(void)shouldBack{
    NSLog(@"Go back to main menu!");
    
    // Remove scrollview
    [_scrollview removeFromSuperview];
    
    // Present Rules
    [_sceneOrganizer presentMainScene];
}

-(void) presentPrivacy {
    NSLog(@"Show privacy policy!");
    
    // Go to URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://sites.google.com/a/kingof20.com/king-of-20/press-kit"] options:@{} completionHandler:nil];

}

@end
