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

- (UIViewController*) intendedViewControllerForPosition: (VSSlidingViewControllerTopViewPosition)position;
- (void) connectSubViews;
- (CGRect) topViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position;
- (CGRect) leftSlideViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position;
- (CGRect) rightSlideViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position;
- (void) moveTopViewToPosition: (VSSlidingViewControllerTopViewPosition)position
                      animated: (BOOL)animated
             completionHandler: (void(^)())completionHandler;
- (void) updateTopViewGestures;
@end

@implementation VSSlidingViewController

+ (instancetype) slidingViewController
{
    return [[VSSlidingViewController alloc] init];
}

- (void) setup
{
    self.fixedLeftSlideViewLengthIfAnchored = 100;
    self.fixedLeftSlideViewLengthIfCentered = 0;
    self.fixedRightSlideViewLengthIfAnchored = 100;
    self.fixedRightSlideViewLengthIfCentered = 0;
    
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

- (instancetype) init
{
    if (self = [super init])
    {
        [self setup];
    }
    
    return self;
}

#pragma mark - UIViewController

- (void) awakeFromNib
{
    if (self.topViewControllerStoryoardID)
        self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier: self.topViewControllerStoryoardID];
    
    if (self.leftSlideViewControllerStoryoardID)
        self.leftSlideViewController = [self.storyboard instantiateViewControllerWithIdentifier: self.leftSlideViewControllerStoryoardID];
    
    if (self.rightSlideViewController)
        self.rightSlideViewController = [self.storyboard instantiateViewControllerWithIdentifier: self.rightSlideViewControllerStoryoardID];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self connectSubViews];
}

- (void) viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.topViewController beginAppearanceTransition: YES animated: animated];
    
    if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft)
        [self.rightSlideViewController beginAppearanceTransition: YES animated: animated];
    else if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredRight)
        [self.leftSlideViewController beginAppearanceTransition: YES animated: animated];
}

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    
    [self.topViewController endAppearanceTransition];
    
    if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft)
        [self.rightSlideViewController endAppearanceTransition];
    else if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredRight)
        [self.leftSlideViewController endAppearanceTransition];
}

- (void) viewWillDisappear: (BOOL)animated
{
    [super viewWillDisappear: animated];
    
    [self.topViewController beginAppearanceTransition: NO animated: animated];
    
    if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft)
        [self.rightSlideViewController beginAppearanceTransition: NO animated: animated];
    else if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredRight)
        [self.leftSlideViewController beginAppearanceTransition: NO animated: animated];
}

- (void) viewDidDisappear: (BOOL)animated
{
    [super viewDidDisappear: animated];
    
    [self.topViewController endAppearanceTransition];
    
    if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft)
        [self.rightSlideViewController endAppearanceTransition];
    else if (self.currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredRight)
        [self.leftSlideViewController endAppearanceTransition];
}

- (void) viewDidLayoutSubviews
{
    if (self.currentOperation == VSSlidingViewControllerOperationNone)
    {
        //TO-DO: ??
        //[super viewDidLayoutSubviews];
        
        self.topViewController.view.frame = [self topViewCalculatedFrameForPosition: self.currentTopViewPosition];
        self.leftSlideViewController.view.frame = [self leftSlideViewCalculatedFrameForPosition: self.currentTopViewPosition];
        self.rightSlideViewController.view.frame = [self rightSlideViewCalculatedFrameForPosition: self.currentTopViewPosition];
        
        //TO-DO
        self.gestureView.frame = self.topViewController.view.frame;
    }
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
    if ([self.leftSlideViewController isMemberOfClass: [toViewController class]] ||
        [self.rightSlideViewController isMemberOfClass: [toViewController class]])
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
    return [self intendedViewControllerForPosition: self.currentTopViewPosition];
}

- (UIViewController*) childViewControllerForStatusBarStyle
{
    return [self intendedViewControllerForPosition: self.currentTopViewPosition];
}

- (id<UIViewControllerTransitionCoordinator>) transitionCoordinator
{
    return self;
}

#pragma mark - Properties

- (void) setTopViewController: (UIViewController *)topViewController
{
    if (_topViewController != topViewController)
    {
        //TO-DO: ?? Could a view be added two or more super view? If could, what would happen for this involve?
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
            
            [self connectSubViews];
        }
    }
}

- (void) setLeftSlideViewController: (UIViewController *)slideViewController
{
    [_leftSlideViewController.view removeFromSuperview];
    
    [_leftSlideViewController willMoveToParentViewController: nil];
    [_leftSlideViewController beginAppearanceTransition: NO animated: NO];
    [_leftSlideViewController removeFromParentViewController];
    [_leftSlideViewController endAppearanceTransition];
    
    _leftSlideViewController = slideViewController;
    
    if (_leftSlideViewController)
    {
        [self addChildViewController: _leftSlideViewController];
        [_leftSlideViewController didMoveToParentViewController: self];
        
        //?? should do something if [self isViewLoaded]??
    }
}

- (void) setRightSlideViewController: (UIViewController *)slideViewController
{
    [_rightSlideViewController.view removeFromSuperview];
    
    [_rightSlideViewController willMoveToParentViewController: nil];
    [_rightSlideViewController beginAppearanceTransition: NO animated: NO];
    [_rightSlideViewController removeFromParentViewController];
    [_rightSlideViewController endAppearanceTransition];
    
    _rightSlideViewController = slideViewController;
    
    if (_rightSlideViewController)
    {
        [self addChildViewController: _rightSlideViewController];
        [_rightSlideViewController didMoveToParentViewController: self];
        
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
    else if ([key isEqualToString: kVSTransitionContextLeftSlideViewControllerKey])
        vc = self.leftSlideViewController;
    else if ([key isEqualToString: kVSTransitionContextLeftSlideViewControllerKey])
        vc = self.rightSlideViewController;
    else if ([key isEqualToString: UITransitionContextFromViewControllerKey])
    {
        if (_currentOperation == VSSlidingViewControllerOperationAnchorToLeft ||
            _currentOperation == VSSlidingViewControllerOperationAnchorToRight)
        {
            vc = self.topViewController;
        }
        else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft)
        {
            vc = self.rightSlideViewController;
        }
        else if (_currentOperation == VSSlidingViewControllerOperationResetFromRight)
        {
            vc = self.leftSlideViewController;
        }
    }
    else if ([key isEqualToString: UITransitionContextToViewControllerKey])
    {
        if (_currentOperation == VSSlidingViewControllerOperationAnchorToLeft)
        {
            vc = self.rightSlideViewController;
        }
        else if (_currentOperation == VSSlidingViewControllerOperationAnchorToRight)
        {
            vc = self.leftSlideViewController;
        }
        else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft ||
                 _currentOperation == VSSlidingViewControllerOperationResetFromRight)
        {
            vc = self.topViewController;
        }
    }
    
    return vc;
}

- (CGRect) initialFrameForViewController: (UIViewController *)vc
{
    CGRect frame = CGRectZero;
    
    
    if (_currentOperation == VSSlidingViewControllerOperationAnchorToLeft ||
        _currentOperation == VSSlidingViewControllerOperationAnchorToRight)
    {
        //TO-DO: how about the slidingView?
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionCentered];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft];
        else if ([vc isEqual: self.rightSlideViewController])
            frame = [self rightSlideViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationResetFromRight)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
        else if ([vc isEqual: self.leftSlideViewController])
            frame = [self leftSlideViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
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
        else if ([vc isEqual: self.rightSlideViewController])
            frame = [self rightSlideViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredLeft];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationAnchorToRight)
    {
        if ([vc isEqual: self.topViewController])
            frame = [self topViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
        else if ([vc isEqual: self.leftSlideViewController])
            frame = [self leftSlideViewCalculatedFrameForPosition: VSSlidingViewControllerTopViewPositionAnchoredRight];
    }
    else if (_currentOperation == VSSlidingViewControllerOperationResetFromLeft ||
             _currentOperation == VSSlidingViewControllerOperationResetFromRight)
    {
        //TO-DO: how about the slidingView?
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

- (UIViewController*) intendedViewControllerForPosition: (VSSlidingViewControllerTopViewPosition)position
{
    UIViewController* vc;
    
    switch (self.currentTopViewPosition)
    {
        case VSSlidingViewControllerTopViewPositionCentered:
            vc = self.topViewController;
            break;
            
        case VSSlidingViewControllerTopViewPositionAnchoredLeft:
            vc = self.rightSlideViewController;
            break;
            
        case VSSlidingViewControllerTopViewPositionAnchoredRight:
            vc = self.leftSlideViewController;
            break;
            
        default:
            vc = nil;
            break;
    }
    
    return vc;
}

- (void) connectSubViews
{
    //TO-DO:
    //1. remove previous view firstly
    //2. make sure all required view be prepared
    //3. how about changing slide VC
    
    if (self.isViewLoaded)
    {
        self.topViewController.view.frame = [self topViewCalculatedFrameForPosition: self.currentTopViewPosition];
        
        [_topViewController beginAppearanceTransition: YES animated: NO];
        [self.view addSubview: self.topViewController.view];
        [_topViewController endAppearanceTransition];
        
        [self moveTopViewToPosition: self.currentTopViewPosition animated: NO completionHandler: nil];
    }
}

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

//TO-DO:
- (CGRect) defaultTopViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = self.view.bounds;
    
    frame = [self adjustForExtendedLayoutWithLayoutGuide: frame];
    
    switch (position)
    {
        case VSSlidingViewControllerTopViewPositionCentered:
            frame.origin.x += self.fixedLeftSlideViewLengthIfCentered;
            break;
            
        case VSSlidingViewControllerTopViewPositionAnchoredLeft:
            frame.origin.x -= self.fixedRightSlideViewLengthIfAnchored;
            break;
            
        case VSSlidingViewControllerTopViewPositionAnchoredRight:
            frame.origin.x += self.fixedLeftSlideViewLengthIfAnchored;
            break;
            
        default:
            frame = CGRectZero;
            break;
    }
    
    return frame;
}

-(CGRect) defaultLeftSlideViewCalculatedFrame: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = self.view.bounds;
    
    frame = [self adjustForExtendedLayoutWithLayoutGuide: frame];
    
    if (position != VSSlidingViewControllerTopViewPositionAnchoredRight)
    {
        frame.origin.x -= (self.fixedLeftSlideViewLengthIfAnchored - self.fixedLeftSlideViewLengthIfCentered);
    }
    
    frame.size.width = self.fixedLeftSlideViewLengthIfAnchored;
    
    return frame;
}

-(CGRect) defaultRightSlideViewCalculatedFrame: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = self.view.bounds;
    
    frame = [self adjustForExtendedLayoutWithLayoutGuide: frame];
    
    if (position == VSSlidingViewControllerTopViewPositionAnchoredLeft)
    {
        frame.origin.x += (frame.size.width - self.fixedRightSlideViewLengthIfAnchored);
    }
    else
    {
        frame.origin.x += (frame.size.width - self.fixedRightSlideViewLengthIfCentered);
    }
    
    frame.size.width = self.fixedRightSlideViewLengthIfAnchored;
    
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

- (CGRect) leftSlideViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = [self frameFromDelegateForViewController: self.leftSlideViewController
                                            topViewPosition: position];
    
    //Default layout
    if (CGRectIsInfinite(frame))
    {
        frame = [self defaultLeftSlideViewCalculatedFrame: position];
    }
    
    return frame;
}

- (CGRect) rightSlideViewCalculatedFrameForPosition: (VSSlidingViewControllerTopViewPosition)position
{
    CGRect frame = [self frameFromDelegateForViewController: self.rightSlideViewController
                                            topViewPosition: position];
    
    //Default layout
    if (CGRectIsInfinite(frame))
    {
        frame = [self defaultRightSlideViewCalculatedFrame: position];
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
             && ((operation == VSSlidingViewControllerOperationAnchorToLeft && self.rightSlideViewController) ||
                 (operation == VSSlidingViewControllerOperationAnchorToRight && self.leftSlideViewController))));
}

- (void) beginAppearanceTransitionForOperation: (VSSlidingViewControllerOperation)operation
{
    if (operation == VSSlidingViewControllerOperationAnchorToLeft)
    {
        [self.rightSlideViewController beginAppearanceTransition: YES animated: _isAnimated];
    }
    else if(operation == VSSlidingViewControllerOperationAnchorToRight)
    {
        [self.leftSlideViewController beginAppearanceTransition: YES animated: _isAnimated];
    }
    else if (operation == VSSlidingViewControllerOperationResetFromLeft)
    {
        [self.rightSlideViewController beginAppearanceTransition: NO animated: _isAnimated];
    }
    else if (operation == VSSlidingViewControllerOperationResetFromRight)
    {
        [self.leftSlideViewController beginAppearanceTransition: NO animated: _isAnimated];
    }
}

- (void) endAppearanceTransitionForOperation: (VSSlidingViewControllerOperation)operation isCancelled: (BOOL)isCancelled
{
    if (operation == VSSlidingViewControllerOperationAnchorToLeft)
    {
        if (isCancelled)
            [self.rightSlideViewController beginAppearanceTransition: NO animated: _isAnimated];
        
        [self.rightSlideViewController endAppearanceTransition];
    }
    else if(operation == VSSlidingViewControllerOperationAnchorToRight)
    {
        if (isCancelled)
            [self.leftSlideViewController beginAppearanceTransition: NO animated: _isAnimated];
        
        [self.leftSlideViewController endAppearanceTransition];
    }
    else if (operation == VSSlidingViewControllerOperationResetFromLeft)
    {
        if (isCancelled)
            [self.rightSlideViewController beginAppearanceTransition: YES animated: _isAnimated];
        
        [self.rightSlideViewController endAppearanceTransition];
    }
    else if (operation == VSSlidingViewControllerOperationResetFromRight)
    {
        if (isCancelled)
            [self.leftSlideViewController beginAppearanceTransition: NO animated: _isAnimated];
        
        [self.leftSlideViewController endAppearanceTransition];
    }
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
    BOOL isTopViewAnchored = (_currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredLeft ||
                              _currentTopViewPosition == VSSlidingViewControllerTopViewPositionAnchoredRight);
    UIView* topView = self.topViewController.view;
    
    if (isTopViewAnchored)
    {
        if (_topViewAnchoredGestureMask & VSSlidingViewControllerAnchoredGestureDisabled)
        {
            topView.userInteractionEnabled = NO;
        }
        else
        {
            self.gestureView.frame = topView.frame;
            
            if ((_topViewAnchoredGestureMask & VSSlidingViewControllerAnchoredGesturePanning) &&
                ([self.customAnchoredGestureViewMap objectForKey: self.panGesture]))
            {
                //TO-DO: ??
                [self.customAnchoredGestureViewMap setObject: self.panGesture.view forKey: self.panGesture];
                [self.panGesture.view removeGestureRecognizer: self.panGesture];
                
                [self.gestureView addGestureRecognizer: self.panGesture];
            }
            
            if ((_topViewAnchoredGestureMask & VSSlidingViewControllerAnchoredGestureTapping) &&
                ([self.customAnchoredGestureViewMap objectForKey: self.resettingTapGesture]))
            {
                [self.gestureView addGestureRecognizer: self.resettingTapGesture];
            }
            
            if (_topViewAnchoredGestureMask & VSSlidingViewControllerAnchoredGestureCustom)
            {
                for (UIGestureRecognizer* customGesture in self.customAnchoredGestureArray)
                {
                    if ([self.customAnchoredGestureViewMap objectForKey: customGesture])
                    {
                        [self.customAnchoredGestureViewMap setObject: customGesture.view forKey: customGesture];
                        [customGesture.view removeGestureRecognizer: customGesture];
                        
                        [self.gestureView addGestureRecognizer: customGesture];
                    }
                }
            }
            
            if (_topViewAnchoredGestureMask != VSSlidingViewControllerAnchoredGestureNone)
            {
                if (!self.gestureView.superview)
                    [self.view insertSubview: self.gestureView aboveSubview: topView];
            }
        }
    }
    else
    {
        topView.userInteractionEnabled = YES;
        
        [self.gestureView removeFromSuperview];
        
        for (UIGestureRecognizer* customGesture in  self.customAnchoredGestureArray)
        {
            UIView* originView = [self.customAnchoredGestureViewMap objectForKey: customGesture];
            
            if (originView && [originView isDescendantOfView: topView])
            {
                [originView addGestureRecognizer: customGesture];
            }
        }
        
        UIView* originPanView = [self.customAnchoredGestureViewMap objectForKey: self.panGesture];
        if (originPanView && [originPanView isDescendantOfView: topView])
        {
            [originPanView addGestureRecognizer: self.panGesture];
        }
        
        [self.customAnchoredGestureViewMap removeAllObjects];
    }
}

@end


