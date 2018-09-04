//
//  CustomScrollView.m
//  SKKingof20
//
//  Created by Ishmael King on 1/16/18.
//  Copyright © 2018 Ishmael King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomScrollView.h"

@implementation CustomScrollView

#pragma mark View Initilization

- (void) viewDidLoad {
    is_inited = false;
}

-(id) initWithFrame:(CGRect)frame
            scene:(SKScene*) scene
     moveableNode:(SKNode*)moveableNode
    scrollDirection:(NSInteger) scrollDirection
             paging:(BOOL) shouldPage {
    
    self = [super init];
    
    // Init properties
    _currentScene = scene;
    _moveableNode = moveableNode;
    _scrollDirection = scrollDirection;
    
    // Init instance variables
    disabledTouches = false;
    is_inited = true;

    // Init UIView
    self.frame = frame;
    self.delegate = self;
    self.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.scrollEnabled = true;
    self.userInteractionEnabled = true;
    
    if (scrollDirection == horizontal) {
        CGAffineTransform flip = CGAffineTransformMakeScale(-1,-1);
        self.transform = flip;
    }
    
    self.pagingEnabled = shouldPage;
    
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    
    return self;
}

#pragma mark Touches

// Override of touchBegan
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        CGPoint location = [touch locationInNode:_currentScene];
        
        // Early exit if touch should be disabled
        if (disabledTouches) {
            return;
        }
        
        /// Call touches began in current scene
        [_currentScene touchesBegan:touches withEvent:event];
        
        /// Call touches began in all touched nodes in the current scene
        _nodesTouched = [_currentScene nodesAtPoint:location];
        for (SKNode* node in _nodesTouched) {
            [node touchesBegan:touches withEvent:event];
        }
    }
}

// Override of touchesMoved
-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        CGPoint location = [touch locationInNode:_currentScene];
        
        // Early exit if touch should be disabled
        if (disabledTouches) {
            return;
        }
        
        /// Call touches began in current scene
        [_currentScene touchesMoved:touches withEvent:event];
        
        /// Call touches began in all touched nodes in the current scene
        _nodesTouched = [_currentScene nodesAtPoint:location];
        for (SKNode* node in _nodesTouched) {
            [node touchesMoved:touches withEvent:event];
        }
    }
}

// Override of touchesEnded
-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        CGPoint location = [touch locationInNode:_currentScene];
        
        // Early exit if touch should be disabled
        if (disabledTouches) {
            return;
        }
        
        /// Call touches began in current scene
        [_currentScene touchesEnded:touches withEvent:event];
        
        /// Call touches began in all touched nodes in the current scene
        _nodesTouched = [_currentScene nodesAtPoint:location];
        for (SKNode* node in _nodesTouched) {
            [node touchesEnded:touches withEvent:event];
        }
    }
}

// Override of touchesCancelled
-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        CGPoint location = [touch locationInNode:_currentScene];
        
        // Early exit if touch should be disabled
        if (disabledTouches) {
            return;
        }
        
        /// Call touches began in current scene
        [_currentScene touchesCancelled:touches withEvent:event];
        
        /// Call touches began in all touched nodes in the current scene
        _nodesTouched = [_currentScene nodesAtPoint:location];
        for (SKNode* node in _nodesTouched) {
            [node touchesCancelled:touches withEvent:event];
        }
    }
}

#pragma mark Touch Controls

-(void) disable {
    self.userInteractionEnabled = false;
    disabledTouches = true;
}

-(void) enable {
    self.userInteractionEnabled = true;
    disabledTouches = false;
}

#pragma mark Delegates

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( _scrollDirection == horizontal ) {
        [_moveableNode setPosition:CGPointMake(self.contentOffset.x, _moveableNode.position.y)];
        //_moveableNode.position.x = self.contentOffset.x;
    } else {
        [_moveableNode setPosition:CGPointMake(_moveableNode.position.x, self.contentOffset.y)];
        //_moveableNode.position.y = self.contentOffset.y;
    }
}

@end
