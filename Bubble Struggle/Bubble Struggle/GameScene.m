//
//  GameScene.m
//  Bubble Struggle
//
//  Created by David Rynn on 7/6/15.
//  Copyright (c) 2015 David Rynn. All rights reserved.
//

#import "GameScene.h"
#import "BubbleNode.h"
#import "GroundNode.h"
#import "SideNode.h"
#import "CeilingNode.h"
#import "Utility.h"
#import "HudNode.h"
#import "THGameOverNode.h"
#import <AVFoundation/AVFoundation.h>


#define ARC4RANDOM_MAX      0x100000000
@interface GameScene ()
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic) NSTimeInterval timeSinceBubbleAdded;
@property (nonatomic) NSTimeInterval addBubbleTimeInterval;
@property (nonatomic) NSTimeInterval totalGameTime;
@property (nonatomic) SKAction *popSFX;
@property (nonatomic) SKAction *spawnSFX;
@property (nonatomic) AVAudioPlayer *backgroundMusic;
@property (nonatomic) AVAudioPlayer *gameOverMusic;
@property (nonatomic) BOOL addBubbleToggle;
@property (nonatomic) BOOL gameOver;
@property (nonatomic) BOOL restart;
@property (nonatomic) BOOL gameOverDisplayed;

@end


@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    self.lastUpdateTimeInterval = 0;
    self.timeSinceBubbleAdded = 0;
    self.addBubbleTimeInterval = 1.0;
    self.totalGameTime = 0;
    
    self.size = self.view.frame.size;
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, -0.1);
    
    //Setup Nodes
    CGPoint centerScreen = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bubble"];
//    background.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    background.position =centerScreen;

    [self addChild:background];
    
    GroundNode *ground = [GroundNode groundWithSize:CGSizeMake(self.frame.size.width, 54)];
    ground.zPosition = 2;
    [self addChild:ground];
    
    CeilingNode *ceiling = [CeilingNode ceilingWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    ceiling.zPosition =15;
    [self addChild:ceiling];
    
    
    
    SideNode *leftSide = [SideNode sideWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) leftSide:YES];
    NSLog(@"frame height: %f", self.frame.size.height);
    leftSide.zPosition = 15;
    [self addChild:leftSide];
    
    SideNode *rightSide = [SideNode sideWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) leftSide:NO];
    rightSide.zPosition = 14;
    [self addChild:rightSide];
    
    HudNode *hud = [HudNode hudAtPosition:CGPointMake(0, ground.size.height/2) inFrame:self.frame];
    hud.zPosition = 15;
    [self addChild:hud];


    
    [self soundSetup];
    [self.backgroundMusic play];

    
    
    //FOR POSSIBLE FUTURE LIGHT SOURCE
//    //Setup a LightNode
//    SKLightNode* light = [[SKLightNode alloc] init];
//    light.categoryBitMask = 1;
//    light.falloff = 1;
//    light.ambientColor = [UIColor whiteColor];
//    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.5];
//    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
//    [self addChild:light];
    
    
}

- (void)soundSetup {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"LateNightMix" withExtension:@"m4a"];
    
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    self.backgroundMusic.volume =0.4;
    [self.backgroundMusic prepareToPlay];

    self.popSFX = [SKAction playSoundFileNamed:@"bubbleSpawn3.caf" waitForCompletion:NO];
    

    self.spawnSFX = [SKAction playSoundFileNamed:@"bubbleSpawn3.caf" waitForCompletion:YES];
    
    NSURL *gameOverURL = [[NSBundle mainBundle] URLForResource:@"gameOver" withExtension:@"mp3"];
    
    self.gameOverMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:gameOverURL error:nil];
    self.gameOverMusic.volume= 0.3;
    self.gameOverMusic.numberOfLoops = 0;
    [self.gameOverMusic prepareToPlay];
    
}


- (void) addPoints:(NSInteger)points{
    if (!self.gameOverDisplayed){
        HudNode *hud = (HudNode*)[self childNodeWithName:@"HUD"];
        [hud addPoints:points];
    }
}


-(void) joinBodies: (SKPhysicsBody *) bodyA secondBody: (SKPhysicsBody *) bodyB jointPoint: (CGPoint) point {

    SKPhysicsJointFixed *joint = [SKPhysicsJointFixed jointWithBodyA:bodyA bodyB:bodyB anchor:point];
    [self.physicsWorld addJoint:joint];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touchedNode = [touches anyObject]; // Registers the touch
    CGPoint touchPoint = [touchedNode locationInNode:self]; // (x, y) of where the touch was
    SKNode *node = [self nodeAtPoint:touchPoint]; // Returns the node at touch

//    NSLog(@"X: %f",touchPoint.x);
//    NSLog(@"Y: %f",touchPoint.y);
    if ([node.name isEqualToString:@"bubbleNode"] && !self.gameOverDisplayed){
            // do something with that node
            [node removeFromParent];
        [self addPoints:100];
            NSLog(@"%@",node);
        
            NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
            SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
            explosion.position = touchPoint;
            [self addChild:explosion];
        [self runAction:self.popSFX];
            
            [explosion runAction:[SKAction waitForDuration:2.0] completion:^{
                    [explosion removeFromParent];
                
                }
             ];
    }
    
     else if ( self.restart ) {
        for (SKNode *node in [self children]) {
            [node removeFromParent];
        }
        
        GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
        [self.view presentScene:scene];
    }

}


-(void)update:(CFTimeInterval)currentTime {
    NSLog(@"time interval: %f", self.addBubbleTimeInterval);
   
    if (!self.gameOverDisplayed) {
        HudNode *hud = (HudNode *)[self childNodeWithName:@"HUD"];
        [hud addTimeInterval:self.totalGameTime];
    }

    
    if ( self.lastUpdateTimeInterval ) {
        self.timeSinceBubbleAdded += currentTime - self.lastUpdateTimeInterval;
        self.totalGameTime += currentTime - self.lastUpdateTimeInterval;
    }
    
    if ( self.timeSinceBubbleAdded > self.addBubbleTimeInterval && !self.gameOver ) {
        [self generateBubble];
        self.timeSinceBubbleAdded = 0;
    }
    
    self.lastUpdateTimeInterval = currentTime;
    
    if ( self.totalGameTime > 480 && self.addBubbleToggle) {
        // 480 / 60 = 8 minutes
        self.addBubbleToggle = NO;
        self.addBubbleTimeInterval *= .75;
    //    self.minSpeed = -160;
        
    } else if ( self.totalGameTime > 240 && self.totalGameTime <= 480 && !self.addBubbleToggle) {
        // 240 / 60 = 4 minutes
        self.addBubbleToggle = YES;
        self.addBubbleTimeInterval *= .75;
//        self.minSpeed = -150;
    } else if ( self.totalGameTime > 20 && self.totalGameTime <= 240 && self.addBubbleToggle) {
        // 120 / 60 = 2 minutes
        self.addBubbleToggle = NO;
        self.addBubbleTimeInterval *= .75;
//        self.minSpeed = -125;
    } else if ( self.totalGameTime > 10 && self.totalGameTime <= 20 && !self.addBubbleToggle) {
        self.addBubbleToggle =YES;
        self.addBubbleTimeInterval *= .75;
//        self.minSpeed = -100;
    }

    
  
}

- (void) performGameOver {
    THGameOverNode *gameOver = [THGameOverNode gameOverAtPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    [self addChild:gameOver];
    self.restart = YES;
    self.gameOver =YES;
    
    if (!self.gameOverDisplayed) {
        [self.gameOverMusic play];
    }
    
    self.gameOverDisplayed = YES;
    [gameOver performAnimation];
    
    [self.backgroundMusic stop];


}

- (void) didBeginContact:(SKPhysicsContact *)contact{
//    NSLog(@"Contact!!");
    SKPhysicsBody *firstBody, *secondBody;

    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }

    if (
        firstBody.categoryBitMask == CollisionCategoryBubbleTypeA &&
        ((secondBody.categoryBitMask == CollisionCategoryGround) ||
        (secondBody.categoryBitMask == CollisionCategoryBubbleTypeB )) )
    {
//        NSLog(@"Hit ground!");
        
        [self joinBodies:firstBody secondBody:secondBody jointPoint:contact.contactPoint];
        BubbleNode *bubble = (BubbleNode *) firstBody.node;
        bubble.physicsBody.categoryBitMask = CollisionCategoryBubbleTypeB;
        bubble.physicsBody.collisionBitMask = CollisionCategoryGround | CollisionCategoryBubbleTypeA | CollisionCategorySide | CollisionCategoryBubbleTypeB;
        bubble.physicsBody.contactTestBitMask = CollisionCategoryCeiling;

    }
    
        if (firstBody.categoryBitMask == CollisionCategoryBubbleTypeA &&
            secondBody.categoryBitMask == CollisionCategorySide){
//            NSLog(@"side hit");
        };
    
    if(firstBody.categoryBitMask == CollisionCategoryBubbleTypeB &&
       secondBody.categoryBitMask == CollisionCategoryCeiling){
        [self performGameOver];
        NSLog(@"GAME OVER!!!");
    }



}



-(void)generateBubble{
    
    
    
    BubbleNode *bubble = [[BubbleNode alloc] init];
//    float dy = [Utility randomIntegerBetweenAndIncluding:100 maximum:400];
  //  bubble.physicsBody.velocity = CGVectorMake(0, 1000);
    
    float y = self.frame.size.height + 2*bubble.size.height+100;
    float x = [Utility randomIntegerBetweenAndIncluding:bubble.size.width+20 maximum:self.frame.size.width-(2*bubble.size.width)];
    
   // bubble.position = CGPointMake(x,y);
    [self addChild:[bubble bubbleAtPosition:CGPointMake(x, y)]];
    
    
  //      [self runAction:self.spawnSFX];
    
    
    
    
    
    
//    BubbleNode *bubble = [[BubbleNode alloc]init];
//    //Generate bubble at a specificPosition
//    
//
//    [self addChild:[bubble bubbleAtPosition:CGPointMake([self generateRandomFloatBetween:320 and: self.size.width - 320], self.size.height + 10)]];


}


-(CGFloat)generateRandomFloatBetween:(NSInteger) firstNumber and:(NSInteger)secondNumber{
     return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (secondNumber - firstNumber) + firstNumber);
}

-(void)spawnBubbleWithInterval
{
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(generateBubble) onTarget:self], [SKAction waitForDuration:5.0]]]] withKey:@"generateBubble" ];

}
    
@end