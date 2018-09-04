//
//  CustomScrollView.h
//  SKKingof20
//
//  Created by Ishmael King on 1/16/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#ifndef CustomScrollView_h
#define CustomScrollView_h

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

// Scroll direction enum
typedef NS_ENUM(NSInteger, ScrollDirection) {
    vertical,
    horizontal
};

@interface CustomScrollView : UIScrollView <UIScrollViewDelegate> {
    
    // Instance Variables
    BOOL disabledTouches;
    BOOL is_inited;
}

// Properties

/// Current scene
@property SKScene* currentScene;

/// Moveable node
@property SKNode* moveableNode;

/// Scroll direction
@property ScrollDirection scrollDirection;

/// Touched nodes
@property NSArray<SKNode *> * nodesTouched;

/**
 * Convenience creation method.
 *
 * @param frame The size required for the ScrollView.
 * @param scene The scene over which the ScrollView is placed.
 * @param moveableNode The node the ScrollView will scroll.
 */
-(id) initWithFrame:(CGRect) frame scene:(SKScene*) scene moveableNode:(SKNode*)moveableNode scrollDirection:(NSInteger) scrollDirection paging:(BOOL) shouldPage;

/**
 * Disable user interaction.
 */
-(void) disable;

/**
 * Enable user interaction.
 */
-(void) enable;

@end

#endif /* CustomScrollView_h */
