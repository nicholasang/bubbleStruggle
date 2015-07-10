//
//  BubbleNode.m
//  Bubble Struggle
//
//  Created by David Rynn on 7/6/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "BubbleNode.h"


#define ARC4RANDOM_MAX 0x100000000

@implementation BubbleNode

-(SKSpriteNode *)bubbleAtPosition:(CGPoint)position{
    
    SKSpriteNode *bubble = [SKSpriteNode spriteNodeWithImageNamed:@"bubble_sml_1"];
    bubble.position = position;
    bubble.name = @"bubbleNode";

    //Physics
    
    bubble.physicsBody.affectedByGravity = NO;
    

    [self randomBubbleFloat:bubble];
    
    //Bubble Random Size
    [self randomBubbleSize:bubble];
    
    //Bubble rotations
    [self randomBubbleRotation:bubble];
    [self randomBubbleScaling:bubble];
    
    
    return bubble;
}

-(void)randomBubbleFloat:(SKSpriteNode *)bubble{
    
    //Floating Action
    SKAction *moveDown = [SKAction moveToY:40 duration:[self generateRandomFloatBetween:5 and:18]];
    
    
    CGVector right = CGVectorMake([self generateRandomFloatBetween:10 and:15], 0);
    CGVector left = CGVectorMake( - [self generateRandomFloatBetween:10 and:15], 0);
    
    SKAction *moveToRight = [SKAction moveBy: right duration:1.5];
    SKAction *moveToLeft =  [SKAction moveBy:left duration:1.5];
    SKAction *repeatLeftRight = [SKAction repeatActionForever:[SKAction sequence:@[moveToRight,moveToLeft]]];
    
    [bubble runAction:moveDown];
    [bubble runAction: repeatLeftRight];

}


-(void)randomBubbleSize:(SKSpriteNode *)bubble{
    float number = [self generateRandomFloatBetween:0.8 and: 1.1];
    SKAction *scale = [SKAction scaleXBy:number y:number duration:0];
    [bubble runAction:scale];
}

-(void)randomBubbleRotation:(SKSpriteNode *)bubble{
    SKAction *rotation = [SKAction rotateByAngle: M_PI/16.0 duration:1.7];
    SKAction *reverseRotation = [SKAction rotateByAngle: - M_PI/16.0 duration:1.7];
    SKAction *repeatBubbleRotation = [SKAction repeatActionForever:[SKAction sequence:@[rotation,reverseRotation]]];
    [bubble runAction: repeatBubbleRotation];
}

-(void)randomBubbleScaling:(SKSpriteNode *)bubble{
    SKAction *scaleBubbleUp = [SKAction scaleXBy:1.05 y:1.05 duration:1.4];
    SKAction *scaleBubbleDown = [SKAction scaleXBy: 0.9524 y: 0.9524 duration:1.4];
    SKAction *repeatBubbleScaling = [SKAction repeatActionForever:[SKAction sequence:@[scaleBubbleUp,scaleBubbleDown]]];
    [bubble runAction:repeatBubbleScaling];
}


-(float)generateRandomFloatBetween:(float) firstNumber and:(float)secondNumber{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (secondNumber - firstNumber) + firstNumber);

}

@end