//
//  VSSlidingViewController.m
//  VictoryStep
//
//  Created by Steven on 5/15/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSSlidingViewController.h"
#import "VSSlidingAnimationController.h"
#import "VSSlidingInteractiveTransition.h"
#import "VSSlidingSegue.h"


@interface VSSlidingViewController ()
{
    UIPanGestureRecognizer* _panGesture;
    UITapGestureRecognizer* _resettingTapGesture;
}

@property (nonatomic, assign) VSSlidingViewControllerOperation currentOperation;
@property (nonatomic, strong) VSSlidingAnimationController* defaultAnimationController;
@property (nonatomic, strong) VSSlidingInteractiveTransition* defaultInteractiveTransition;
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> currentAnimationController;
@property (nonatomic, strong) id<UIViewControllerInteractiveTransitioning> currentInteractiveTransition;

@property (nonatomic, strong) UIView* gestureView;
@property (nonatomic, strong) NSMapTable* customAnchoredGestureViewMap;

@property (nonatomic, assign) CGFloat currentAnimationPercentage;
@property (nonatomic, assign) BOOL transitionWasCancelled;
@property (nonatomic, assign) BOOL transitionInProgress;
@property (nonatomic, assign) BOOL isAnimated;
@property (nonatomic, assign) BOOL isInteractive;

@property (nonatomic, copy) void (^animationCompletionHandler)();
@property (nonatomic, copy) void (^coordinatorAnimations)(id<UIViewControllerTransitionCoordinatorContext> context);
@property (nonatomic, copy) void (^coordinatorCompletion)(id<UIViewControllerTransitionCoordinatorContext> context);
@property (nonatomic, copy) void (^coordinatorInteractionEnded)(id<UIViewControllerTransitionCoordinatorContext> context);

- (CGRect) topViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position;
- (CGRect) underViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position;
- (void) moveTopViewToPosition: (VSSlidingViewControllerTopViewPosition)position
                      animated: (BOOL)animated
             completionHandler: (void(^)())completionHandler;
- (void) updateTopViewGestures;
@end

@implementation VSSlidingViewController

+ (instancetype) slidingViewControllerWithTopViewController: (UIViewController *)topViewController
{
    return [[VSSlidingViewController alloc] initWithTopViewController: topViewController];
}

- (void) setup
{
    self.fixedTopViewLengthIfAnchored = 0;
    self.fixedTopViewLengthIfCentered = 100;
    
    self.anchorPosition = VSSlidingViewControllerAnchorPositionLeft;
    
    self.currentTopViewPosition = VSSlidingViewControllerTopViewPositionCentered;
    
    self.transitionInProgress = NO;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self setup];
    }
    
    return self;
}

- (instancetype) initWithCoder: (NSCoder *)aDecoder
{
    if (self = [super initWithCoder: aDecoder])
    {
        [self setup];
    }
    
    return self;
}

- (instancetype) initWithTopViewController: (UIViewController *)topViewController
{
    if (self = [self initWithNibName: nil bundle: nil])
    {
        self.topViewController = topViewController;
    }
    
    return self;
}

#pragma mark - UIViewController

- (void) awakeFromNib
{
    if (self.topViewControllerStoryoardID)
        self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier: self.topViewControllerStoryoardID];
    
    if (self.underViewControllerStoryoardID)
        self.underViewController = [self.storyboard instantiateViewControllerWithIdentifier: self.underViewControllerStoryoardID];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (!self.topViewController)
    {
        [NSException raise: @"Missing topViewController" format: @"Set the topViewController before loading VSSlidingViewController"];
    }
    
    self.topViewController.view.frame = [self topViewCalculatedFrameForPosition: self.currentTopViewPosition];
    
    [self.view addSubview: self.topViewController.view];
}

- (void) viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.topViewController beginAppearanceTransition: YES animated: animated];
    [self.underViewController beginAppearanceTransition: YES animated: animated];
}

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    
    [self.topViewController endAppearanceTransition];
    [self.underViewController endAppearanceTransition];
}

- (void) viewWillDisappear: (BOOL)animated
{
    [super viewWillDisappear: animated];
    
    [self.topViewController beginAppearanceTransition: NO animated: animated];
    [self.underViewController beginAppearanceTransition: NO animated: animated];
}

- (void) viewDidDisappear: (BOOL)animated
{
    [super viewDidDisappear: animated];
    
    [self.topViewController endAppearanceTransition];
    [self.underViewController endAppearanceTransition];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.topViewController.view.frame = [self topViewCalculatedFrameForPosition: self.currentTopViewPosition];
    self.underViewController.view.frame = [self underViewCalculatedFrameForPosition: self.currentTopViewPosition];
    
    //TO-DO
    self.gestureView.frame = self.topViewController.view.frame;
}

- (BOOL) shouldAutorotate
{
    return _currentOperation == VSSlidingViewControllerOperationNone;
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (BOOL) shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

- (UIStoryboardSegue*) segueForUnwindingToViewController: (UIViewController *)toViewController
                                      fromViewController: (UIViewController *)fromViewController
                                              identifier:(NSString *)identifier
{
    if ([self.underViewController isMemberOfClass: [toViewController class]])
    {
        VSSlidingSegue* unwindSegue = [[VSSlidingSegue alloc] initWithIdentifier: identifier
                                                                          source: fromViewController
                                                                     destination: toViewController];
        [unwindSegue setValue: @YES forKey: @"isUnwinding"];
        
        return unwindSegue;
    }
    else
    {
        return [super segueForUnwindingToViewController: toViewController fromViewController: fromViewController identifier: identifier];
    }
}

- (UIViewController*) childViewControllerForStatusBarHidden
{
    UIViewController* vc;
    
    switch (self.currentTopViewPosition)
    {
        case VSSlidingViewControllerTopViewPositionCentered:
            vc = self.topViewController;
            break;
            
        default:
            vc = self.underViewController;
            break;
    }
    
    return vc;
}

- (UIViewController*) childViewControllerForStatusBarStyle
{
    UIViewController* vc;
    
    switch (self.currentTopViewPosition)
    {
        case VSSlidingViewControllerTopViewPositionCentered:
            vc = self.topViewController;
            break;
            
        default:
            vc = self.underViewController;
            break;
    }
    
    return vc;
}

- (id<UIViewControllerTransitionCoordinator>) transitionCoordinator
{
    return self;
}

#pragma mark - Properties

- (void) setTopViewController: (UIViewController *)topViewController
{
    [_topViewController.view removeFromSuperview];
    
    [_topViewController willMoveToParentViewController: nil];
    [_topViewController beginAppearanceTransition: NO animated: NO];
    [_topViewController removeFromParentViewController];
    [_topViewController endAppearanceTransition];
    
    _topViewController = topViewController;
    
    if (_topViewController)
    {
        [self addChildViewController: _topViewController];
        [_topViewController didMoveToParentViewController: self];
        
        if ([self isViewLoaded])
        {
            [_topViewController beginAppearanceTransition: YES animated: NO];
            [self.view addSubview: _topViewController.view];
            [_topViewController endAppearanceTransition];
        }
    }
}

- (void) setUnderViewController: (UIViewController *)underViewController
{
    [_underViewController.view removeFromSuperview];
    
    [_underViewController willMoveToParentViewController: nil];
    [_underViewController beginAppearanceTransition: NO animated: NO];
    [_underViewController removeFromParentViewController];
    [_underViewController endAppearanceTransition];
    
    _underViewController = underViewController;
    
    if (_underViewController)
    {
        [self addChildViewController: _topViewController];
        [_topViewController didMoveToParentViewController: self];
        
        //?? should do something if [self isViewLoaded]??
    }
}

- (void) setDefaultTransitionDuration: (NSTimeInterval)defaultTransitionDuration
{
    _defaultTransitionDuration = defaultTransitionDuration;
    
    self.defaultAnimationController.defaultTransitionDuration = _defaultTransitionDuration;
}

- (VSSlidingAnimationController*) defaultAnimationController
{
    if (!_defaultAnimationController)
    {
        _defaultAnimationController = [[VSSlidingAnimationController alloc] init];
    }
    
    return _defaultAnimationController;
}

- (VSSlidingInteractiveTransition*) defaultInteractiveTransition
{
    if (!_defaultInteractiveTransition)
    {
        _defaultInteractiveTransition = [[VSSlidingInteractiveTransition alloc] initWithSlidingViewController: self];
        _defaultInteractiveTransition.animatedController = self.defaultAnimationController;
    }
    
    return _defaultInteractiveTransition;
}

- (UIView*) gestureView
{
    if(!_gestureView)
    {
        _gestureView = [[UIView alloc] initWithFrame: CGRectZero];
    }
    
    return _gestureView;
}

- (NSMapTable*) customAnchoredGestureViewMap
{
    if (!_customAnchoredGestureViewMap)
    {
        _customAnchoredGestureViewMap = [NSMapTable mapTableWithKeyOptions: NSMapTableWeakMemory valueOptions: NSMapTableWeakMemory];
    }
    
    return _customAnchoredGestureViewMap;
}

- (UIPanGestureRecognizer*) panGesture
{
    if (!_panGesture)
    {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(detectPanGestureRecognizer:)];
    }
    
    return _panGesture;
}

- (UITapGestureRecognizer*) resettingTapGesture
{
    if (!_resettingTapGesture)
    {
        _resettingTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(resetTopViewWithTapGestureRecognizer:)];
    }
    
    return _resettingTapGesture;
}

#pragma mark - UIPanGestureRecognizer action
- (void) detectPanGestureRecognizer: (UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.view endEditing: YES];
        _isInteractive = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       //TO-DO: use default but not current??
                       [self.defaultInteractiveTransition updateTopViewHorizontalCenterWithRecognizer: recognizer];
                   });
    
    _isInteractive = NO;
}

#pragma mark - UITapGestureRecognizer action
- (void) resetTopViewWithTapGestureRecognizer: (UIPanGestureRecognizer*)recognizer
{
    [self resetTopViewAnimated: NO];
}

#pragma mark - protocol UIViewControllerContextTransitioning and UIViewControllerTransitionCoordinatorContext

- (UIView*) containerView
{
    return self.view;
}

- (BOOL) isAnimated
{
    return _isAnimated;
}

- (BOOL) isInteractive
{
    return _isInteractive;
}

- (BOOL) transitionWasCancelled
{
    return _transitionWasCancelled;
}

- (UIModalPresentationStyle) presentationStyle
{
    return UIModalPresentationCustom;
}

- (void) updateInteractiveTransition: (CGFloat)percentComplete
{
    self.currentAnimationPercentage = percentComplete;
}

- (void) finishInteractiveTransition
{
    _transitionWasCancelled = NO;
}

- (void) cancelInteractiveTransition
{
    _transitionWasCancelled = YES;
}

- (void) completeTransition: (BOOL)didComplete
{
    if (_currentOperation != VSSlidingViewControllerOperationNone)
    {
        switch (_currentOperation)
        {
            case VSSlidingViewControllerOperationAnchorToLeft:
                _currentTopViewPosition = _transitionWasCancelled ? VSSlidingViewControllerTopViewPositionCentered : VSSlidingViewControllerTopViewPositionAnchoredLeft;
                break;
                
            case VSSlidingViewControllerOperationAnchorToRight:
                _currentTopViewPosition = _transitionWasCancelled ? VSSlidingViewControllerTopViewPositionCentered : VSSlidingViewControllerTopViewPositionAnchoredRight;
                break;
                
            case VSSlidingViewControllerOperationResetFromLeft:
                _currentTopViewPosition = _transitionWasCancelled ? VSSlidingViewControllerTopViewPositionAnchoredLeft : VSSlidingViewControllerTopViewPositionCentered;
                break;
                
            case VSSlidingViewControllerOperationResetFromRight:
                _currentTopViewPosition = _transitionWasCancelled ? VSSlidingViewControllerTopViewPositionAnchoredRight : VSSlidingViewControllerTopViewPositionCentered;
                break;
                
            default:
                break;
        }
        
        if ([self.currentAnimationController respondsToSelector: @selector(animationEnded:)])
            [self.currentAnimationController animationEnded: didComplete];
        
        if (self.animationCompletionHandler)
        {
            self.animationCompletionHandler();
            
            self.animationCompletionHandler = nil;
        }
        
        [self updateTopViewGestures];
        
        [self endAppearanceTransitionForOperation: _currentOperation isCancelled: _transitionWasCancelled];
        
        _transitionWasCancelled = NO;
        _transitionInProgress = NO;
        _isInteractive = NO;
        self.coordinatorAnimations = nil;
        self.coordinatorCompletion = nil;
        self.coordinatorInteractionEnded = nil;
        self.currentAnimationPercentage = 0;
        self.currentOperation = VSSlidingViewControllerOperationNone;
        
        self.view.userInteractionEnabled = YES;
        
        [UIViewController attemptRotationToDeviceOrientation];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIViewController*) viewControllerForKey: (NSString *)key
{
    UIViewController* vc = nil;
    
    if ([key isEqualToString: kVSTransitionContextTopViewControllerKey])
        vc = self.topViewController;
    else if ([key isEqualToString: kVSTransitionContextUnderViewControllerKey])
        vc = self.underViewController;
    else if ([key isEqualToString: UITransitionContextFromViewControllerKey])
    {
        if (_currentOperation == VSSlidingViewControllerOperationAnchorToLeft ||
            _currentOperation == VSSlidingViewControllerOperationAnchorToRight)
        {
            vc = self.topViewController;
        }
        else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft ||
                 _currentOperation == VSSlidingViewControllerOperationResetFromRight)
        {
            vc = self.underViewController;
        }
    }
    else if ([key isEqualToString: UITransitionContextToViewControllerKey])
    {
        if (_currentOperation == VSSlidingViewControllerOperationAnchorToLeft ||
            _currentOperation == VSSlidingViewControllerOperationAnchorToRight)
        {
            vc = self.underViewController;
        }
        else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft ||
                 _currentOperation == VSSlidingViewControllerOperationResetFromRight)
        {
            vc = self.topViewController;
        }
    }
    
    return nil;
}

- (CGRect) initialFrameForViewController: (UIViewController *)vc
{
    CGRect frame = CGRectZero;
    
    if (_currentOperation == VSSlidingViewControllerOperationAnchorToLeft ||
        _currentOperation == VSSlidingViewControllerOperationAnchorToRight)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionCentered];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft];
        else if ([vc isEqual: self.underViewController])
            frame = [self underViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationResetFromRight)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
        else if ([vc isEqual: self.underViewController])
            frame = [self underViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
    }
    
    return frame;
}

- (CGRect) finalFrameForViewController: (UIViewController *)vc
{
    CGRect frame = CGRectZero;
    
    if (_currentOperation == VSSlidingViewControllerOperationAnchorToLeft)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft];
        else if ([vc isEqual: self.underViewController])
            frame = [self underViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationAnchorToRight)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
        else if ([vc isEqual: self.underViewController])
            frame = [self underViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft ||
             _currentOperation == VSSlidingViewControllerOperationResetFromRight)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionCentered];
    }
    
    return frame;
}

#pragma mark - protocol UIViewControllerTransitionCoordinatorContext

- (BOOL) initiallyInteractive
{
    return _isAnimated && _isInteractive;
}

- (BOOL) isCancelled
{
    return _transitionWasCancelled;
}

- (NSTimeInterval) transitionDuration
{
    return [self.currentAnimationController transitionDuration: self];
}

- (CGFloat) percentComplete
{
    return self.currentAnimationPercentage;
}

- (CGFloat) completionVelocity
{
    return 1.0;
}

- (UIViewAnimationCurve) completionCurve
{
    return UIViewAnimationCurveLinear;
}

#pragma mark - protocol UIViewControllerTransitionCoordinator

- (BOOL) animateAlongsideTransition: (void (^)(id<UIViewControllerTransitionCoordinatorContext>))animation
                         completion: (void (^)(id<UIViewControllerTransitionCoordinatorContext>))completion
{
    self.coordinatorAnimations = animation;
    self.coordinatorCompletion = completion;
    
    return YES;
}

- (BOOL) animateAlongsideTransitionInView: (UIView *)view
                                animation: (void (^)(id<UIViewControllerTransitionCoordinatorContext>))animation
                               completion: (void (^)(id<UIViewControllerTransitionCoordinatorContext>))completion
{
    self.coordinatorAnimations = animation;
    self.coordinatorCompletion = completion;
    
    return YES;
}

- (void) notifyWhenInteractionEndsUsingBlock: (void (^)(id<UIViewControllerTransitionCoordinatorContext>))handler
{
    self.coordinatorInteractionEnded = handler;
}

#pragma mark - Public

- (void) anchorTopViewToLeftAnimated: (BOOL)animated
{
    [self anchorTopViewToLeftAnimated: animated completionHandler: nil];
}

- (void) anchorTopViewToLeftAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler
{
    [self moveTopViewToPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft animated: animated completionHandler: completionHandler];
}

- (void) anchorTopViewToRightAnimated: (BOOL)animated
{
    [self anchorTopViewToRightAnimated: animated completionHandler: nil];
}

- (void) anchorTopViewToRightAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler
{
    [self moveTopViewToPosition: VSSlidingViewControllerTopViewPositionAnchoredRight animated: animated completionHandler: completionHandler];
}

- (void) resetTopViewAnimated: (BOOL)animated
{
    [self resetTopViewAnimated: animated completionHandler: nil];
}

- (void) resetTopViewAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler
{
    [self moveTopViewToPosition: VSSlidingViewControllerTopViewPositionCentered animated: animated completionHandler: completionHandler];
}

#pragma mark - Private

- (CGRect) frameFromDelegateForViewController: (UIViewController*)vc
                              topViewPosition: (VSSlidingViewControllerTopViewPosition)topViewPosition
{
    CGRect frame = CGRectInfinite;
    
    if ([(NSObject*)self.delegate respondsToSelector: @selector(slidingViewController:layoutControllerForTopViewPosition:)])
    {
        id<VSSlidingViewControllerLayout> layoutController = [self.delegate slidingViewController: self
                                                               layoutControllerForTopViewPosition: topViewPosition];
        
        if (layoutController)
        {
            frame = [layoutController slidingViewController: self
                                     frameForViewController: vc
                                            topViewPosition: topViewPosition];
        }
    }
    
    return frame;
}

- (CGRect) adjustForExtendedLayoutWithLayoutGuide: (CGRect)rect
{
    //TO-DO: Take care of edgesForExtendedLayout status, and recaculate with xxxLayoutGuide
    //TO-DO: Here only consider for AnchorLeft and AnchorRight, but not for AnchorTop and AnchorBottom
    
    CGRect frame = rect;
    
    if (!(self.edgesForExtendedLayout & UIRectEdgeTop))
    {
        CGFloat topLayoutGuideLength = [self.topLayoutGuide length];
        
        frame.origin.y += topLayoutGuideLength;
        frame.size.height -= topLayoutGuideLength;
    }
    
    if (!(self.edgesForExtendedLayout & UIRectEdgeBottom))
    {
        CGFloat bottomLayoutGuideLength = [self.bottomLayoutGuide length];
        
        frame.size.height -= bottomLayoutGuideLength;
    }
    
    return frame;
}

- (CGRect) defaultTopViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = self.view.bounds;
    
    frame = [self adjustForExtendedLayoutWithLayoutGuide: frame];
    
    switch (self.anchorPosition)
    {
        case VSSlidingViewControllerAnchorPositionLeft:
        case VSSlidingViewControllerAnchorPositionRight:
        {
            if (position == VSSlidingViewControllerTopViewPositionCentered)
                frame.size.width = self.fixedTopViewLengthIfCentered;
            else
                frame.size.width = self.fixedTopViewLengthIfAnchored;
            
            break;
        }
            
        default:
            break;
    }
    
    switch (position)
    {
        case VSSlidingViewControllerTopViewPositionCentered:
            if (self.anchorPosition == VSSlidingViewControllerAnchorPositionRight)
            {
                CGFloat remainWidth = self.view.bounds.size.width - self.fixedTopViewLengthIfCentered;
                
                if (remainWidth > 0)
                    frame.origin.x += remainWidth;
            }
            break;
            
        case VSSlidingViewControllerTopViewPositionAnchoredLeft:
            if (self.anchorPosition == VSSlidingViewControllerAnchorPositionLeft)
            {
                CGFloat hiddenWidth = frame.size.width - self.fixedTopViewLengthIfAnchored;
                
                if (hiddenWidth > 0)
                    frame.origin.x -= hiddenWidth;
            }
            break;
            
        case VSSlidingViewControllerTopViewPositionAnchoredRight:
            if (self.anchorPosition == VSSlidingViewControllerAnchorPositionRight)
            {
                CGFloat width = self.view.frame.size.width - self.fixedTopViewLengthIfAnchored;
                
                if (width > 0)
                    frame.origin.x += (width);
            }
            break;
            
        default:
            frame = CGRectZero;
            break;
    }
    
    return frame;
}

-(CGRect) defaultUnderViewCalculatedFrame
{
    CGRect frame = self.view.bounds;
    
    frame = [self adjustForExtendedLayoutWithLayoutGuide: frame];
    
    return frame;
}

- (CGRect) topViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = [self frameFromDelegateForViewController: self.topViewController topViewPosition: position];
    
    //Default layout
    if (CGRectIsInfinite(frame))
    {
        frame = [self defaultTopViewCalculatedFrameForPosition: position];
    }
    
    return frame;
}

- (CGRect) underViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = [self frameFromDelegateForViewController: self.underViewController
                                            topViewPosition: position];
    
    //Default layout
    if (CGRectIsInfinite(frame))
    {
        frame = [self defaultUnderViewCalculatedFrame];
    }
    
    return frame;
}

- (VSSlidingViewControllerOperation) operationFromPosition: (VSSlidingViewControllerTopViewPosition)fromPosition
                                                toPosition: (VSSlidingViewControllerTopViewPosition)toPosition
{
    VSSlidingViewControllerOperation operation;
    
    if (fromPosition == VSSlidingViewControllerTopViewPositionCentered && toPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft)
        operation = VSSlidingViewControllerOperationAnchorToLeft;
    else if (fromPosition == VSSlidingViewControllerTopViewPositionCentered && toPosition == VSSlidingViewControllerTopViewPositionAnchoredRight)
        operation = VSSlidingViewControllerOperationAnchorToRight;
    else if (fromPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft && toPosition == VSSlidingViewControllerTopViewPositionCentered)
        operation = VSSlidingViewControllerOperationResetFromLeft;
    else if (fromPosition == VSSlidingViewControllerTopViewPositionAnchoredRight && toPosition == VSSlidingViewControllerTopViewPositionCentered)
        operation = VSSlidingViewControllerOperationResetFromRight;
    else
        operation = VSSlidingViewControllerOperationNone;
    
    return operation;
}

- (BOOL) operationIsValid: (VSSlidingViewControllerOperation)operation
{
    return ((self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft
             && operation == VSSlidingViewControllerOperationResetFromLeft) ||
            (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredRight
             && operation == VSSlidingViewControllerOperationResetFromRight) ||
            (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionCentered
             && (operation == VSSlidingViewControllerOperationAnchorToLeft ||
                 operation == VSSlidingViewControllerOperationAnchorToRight)
             && self.underViewController));
}

- (void) beginAppearanceTransitionForOperation: (VSSlidingViewControllerOperation)operation
{
    if (operation == VSSlidingViewControllerOperationAnchorToLeft ||
        operation == VSSlidingViewControllerOperationAnchorToRight)
    {
        [_underViewController beginAppearanceTransition: YES animated: _isAnimated];
    }
    else if (operation == VSSlidingViewControllerOperationResetFromLeft ||
             operation == VSSlidingViewControllerOperationResetFromRight)
    {
        [_underViewController beginAppearanceTransition: NO animated: _isAnimated];
    }
}

- (void) endAppearanceTransitionForOperation: (VSSlidingViewControllerOperation)operation isCancelled: (BOOL)isCancelled
{
    if (isCancelled)
    {
        if (operation == VSSlidingViewControllerOperationAnchorToLeft ||
            operation == VSSlidingViewControllerOperationAnchorToRight)
        {
            [_underViewController beginAppearanceTransition: NO animated: _isAnimated];
        }
        else if (operation == VSSlidingViewControllerOperationResetFromLeft ||
                 operation == VSSlidingViewControllerOperationResetFromRight)
        {
            [_underViewController beginAppearanceTransition: YES animated: _isAnimated];
        }
    }
    
    [_underViewController endAppearanceTransition];
}

- (void) animateCurrentOperation
{
    self.view.userInteractionEnabled = NO;
    
    self.transitionInProgress = YES;
    
    self.currentAnimationController = nil;
    self.currentInteractiveTransition = nil;
    
    if ([(NSObject*)self.delegate respondsToSelector: @selector(slidingViewController:animationControllerForOperation:topViewController:)])
    {
        self.currentAnimationController = [self.delegate slidingViewController: self
                                               animationControllerForOperation: _currentOperation
                                                             topViewController: self.topViewController];
        
        if ([(NSObject*)self.delegate respondsToSelector: @selector(slidingViewController:interactionControllerForAnimationController:)])
        {
            self.currentInteractiveTransition = [self.delegate slidingViewController: self
                                         interactionControllerForAnimationController: self.currentAnimationController];
        }
    }
    
    //TO-DO: ???
    if (self.currentAnimationController && self.currentInteractiveTransition)
    {
        _isInteractive = YES;
    }
    
    if (!self.currentAnimationController)
        self.currentAnimationController = self.defaultAnimationController;
    
    if (!self.currentInteractiveTransition)
    {
        self.defaultInteractiveTransition.animatedController = self.currentAnimationController;
        
        self.currentInteractiveTransition = self.defaultInteractiveTransition;
    }
    
    [self beginAppearanceTransitionForOperation: _currentOperation];
    
    //TO-DO: ???
    [self.defaultAnimationController setValue: self.coordinatorAnimations forKey: @"coordinatorAnimations"];
    [self.defaultAnimationController setValue: self.coordinatorCompletion forKey: @"coordinatorCompletion"];
    [self.defaultInteractiveTransition setValue: self.coordinatorInteractionEnded forKey: @"coordinatorInteractionEnded"];
    
    if (_isInteractive)
        [self.currentInteractiveTransition startInteractiveTransition: self];
    else
        [self.currentAnimationController animateTransition: self];
}

- (void) animateOperation: (VSSlidingViewControllerOperation)operation
{
    if ([self operationIsValid: operation])
    {
        if (!self.transitionInProgress)
        {
            self.transitionInProgress = YES;
            
            self.currentOperation = operation;
            
            [self animateCurrentOperation];
        }
    }
    else
    {
        _isInteractive = NO;
    }
}

- (void) moveTopViewToPosition: (VSSlidingViewControllerTopViewPosition)position
                      animated: (BOOL)animated
             completionHandler: (void(^)())completionHandler
{
    self.isAnimated = animated;
    self.animationCompletionHandler = completionHandler;
    
    [self.view endEditing: YES];
    
    VSSlidingViewControllerOperation operation = [self operationFromPosition: self.currentTopViewPosition
                                                                  toPosition: position];
    [self animateOperation: operation];
}

- (void) updateTopViewGestures
{
    
}

@end


