//
//  VSPercentDrivenInteractiveTransition.m
//  VictoryStep
//
//  Created by Steven on 5/16/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSPercentDrivenInteractiveTransition.h"


@interface VSPercentDrivenInteractiveTransition ()

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) id<UIViewControllerContextTransitioning> transitionContext;


- (void) removeAnimationsRecursively: (CALayer*)layer;

@end

@implementation VSPercentDrivenInteractiveTransition

- (void) startInteractiveTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    self.isActive = YES;
    self.transitionContext = transitionContext;
    
    [self removeAnimationsRecursively: [transitionContext containerView].layer];
    
    [self.animatedController animateTransition: transitionContext];
    
    [self updateInteractiveTransition: 0];
}

- (void) updateInteractiveTransition: (CGFloat)percentComplete
{
    if (self.isActive)
    {
        [self.transitionContext updateInteractiveTransition: percentComplete];
        
        _percentComplete = (percentComplete > 1.0) ? 1.0 : (percentComplete < 0.0 ? 0.0 : percentComplete);
        
        CALayer* layer = [self.transitionContext containerView].layer;
        layer.speed = 0.0;
        layer.timeOffset = [self.animatedController transitionDuration: self.transitionContext] * _percentComplete;
    }
}

- (void) cancelInteractiveTransition
{
    if (self.isActive)
    {
        [self.transitionContext cancelInteractiveTransition];
        
        CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(reversePausedAnimation:)];
        [displayLink addToRunLoop: [NSRunLoop mainRunLoop] forMode: NSDefaultRunLoopMode];
    }
}

- (void) finishInteractiveTransition
{
    if (self.isActive)
    {
        self.isActive = NO;
        
        [self.transitionContext finishInteractiveTransition];
        
        CALayer* layer = [self.transitionContext containerView].layer;
        
        //?? Call order?
        CFTimeInterval pausedTime = layer.timeOffset;
        
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        
        layer.beginTime = [layer convertTime: CACurrentMediaTime() fromLayer: nil] - pausedTime;
    }
}

#pragma mark - CADisplayLink action

- (void) reversePausedAnimation: (CADisplayLink*)displayLink
{
    _percentComplete = displayLink.duration / [self.animatedController transitionDuration: self.transitionContext];
    
    if (_percentComplete <= 0.0)
    {
        _percentComplete = 0.0;
        
        [displayLink invalidate];
    }
    
    [self updateInteractiveTransition: _percentComplete];
    
    if (_percentComplete == 0.0)
    {
        self.isActive = NO;
        
        CALayer* layer = [self.transitionContext containerView].layer;
        [layer removeAllAnimations];
        layer.speed = 1.0;
    }
}

#pragma mark - Private

- (void) removeAnimationsRecursively: (CALayer *)layer
{
    if ([layer.sublayers count] > 0)
    {
        for (CALayer* subLayer in layer.sublayers)
        {
            [subLayer removeAllAnimations];
            
            [self removeAnimationsRecursively: subLayer];
        }
    }
}

@end



