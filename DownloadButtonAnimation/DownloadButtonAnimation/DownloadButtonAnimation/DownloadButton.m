//
//  DownloadButton.m
//  DownloadButtonAnimation
//
//  Created by  孟丰 on 17/2/14.
//  Copyright © 2017年  孟丰. All rights reserved.
//

#import "DownloadButton.h"

@implementation DownloadButton{

    BOOL animating;
    CGRect originframe;
}

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpSomething];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setUpSomething];
    }
    return self;
}

- (instancetype)init {

    self = [super init];
    if (self) {
        [self setUpSomething];
    }
    return self;
}

//添加响应手势以及设置外观
-(void)setUpSomething{
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = self.frame.size.height/2;
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapGes];
}

//点击手势方法
- (void)tapped:(UITapGestureRecognizer *)tapped {
    
    //记录初始frame 由于后面会改变视图的 bounds，一开始先保存原始frame，以便后面计算时使用。”
    originframe = self.frame;
    
    //判断动画的执行状态 避免正在执行的动画再次触发。
    if (animating) {
        return;
    }
    
    for (CALayer *subLabyer in self.layer.sublayers) {
        [subLabyer removeFromSuperlayer];
    }
    
    self.backgroundColor = [UIColor colorWithRed:0.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    
    animating = YES;
    
    //绘制矩形的圆角! 如果你让想让一个正方形变成圆形，那么你所要做的就是把 cornerRadius 这个值变成边长的 1/2。
    //同理，如果是一个矩形，想让两头变为圆角，只需要把 cornerRadius 设置成矩形高的 1/2 即可”
    self.layer.cornerRadius = self.progressBarHeight/2;
    
    CABasicAnimation *radiusShrinkAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    radiusShrinkAnimation.duration = 0.2f;
    radiusShrinkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    radiusShrinkAnimation.fromValue = @(originframe.size.height/2);
    
    radiusShrinkAnimation.delegate = self;
    [self.layer addAnimation:radiusShrinkAnimation forKey:@"cornerRadiusShrinkAnim"];
    
    
}


- (void)animationDidStart:(CAAnimation *)animation {

    //圆角动画开始的同时，我们开始一个 bounds 的动画。让圆变化到一根长长的进度条。因为使用了弹性效果，而 CAAnimation 直到 iOS9 之后才引入了CASpringAnimation, 所以我们只能用 UIView 的 UIViewAnimationWithBlocks Category 来实现弹性动画了。

    
    //这里介绍两种方式区分不同的anim 1、对于加在一个全局变量上的anima，比如例子里的self.AnimateView ，这是一个全局变量，所以我们在这里可以通过[self.AnimateView.layer animationForKey:]根据动画不同的key来区分
    //2、然而对于一个非全局的变量，比如demo中的progressLayer，可以用KVO:[pathAnimation setValue:@"strokeEndAnimation" forKey:@"animationName"];注意这个animationName是我们自己设定的。
    
    if ([animation isEqual:[self.layer animationForKey:@"cornerRadiusShrinkAnim"]]) {
        
        //圆形变成进度条,然后调用进度条加载的动画[self progressBarAnimation]
        [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.bounds = CGRectMake(0, 0, _progressBarWidth, _progressBarHeight);
        } completion:^(BOOL finished) {
            [self.layer removeAllAnimations];
            [self progressBarAnimation];
        }];
        
    }else if ([animation isEqual:[self.layer animationForKey:@"cornerRadiusExpandAnim"]]){
        
        [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.bounds = CGRectMake(0, 0, originframe.size.width, originframe.size.height);
            self.backgroundColor = [UIColor colorWithRed:0.1803921568627451 green:0.8 blue:0.44313725490196076 alpha:1.0];
        } completion:^(BOOL finished) {
            [self.layer removeAllAnimations];
            [self checkAnimation];

            animating = NO;
        }];
        
    }

}


//“当进度条动画走完后，我们先让进度条做一个透明度到 0 的动画，之后立马同时开始一个 cornerRadius 动画和一个 bounds 动画，让进度条恢复到圆形状态。”
-(void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag{
    
    if ([[animation valueForKey:@"animationName"]isEqualToString:@"progressBarAnimation"]){
        
        [UIView animateWithDuration:0.3 animations:^{
            for (CALayer *subLayer in self.layer.sublayers) {
                subLayer.opacity = 0.0f;
            }
        } completion:^(BOOL finished) {
            if (finished) {
                for (CALayer *subLayer in self.layer.sublayers) {
                    [subLayer removeFromSuperlayer];
                }
                
                self.layer.cornerRadius = originframe.size.height/2;
                
                CABasicAnimation *radiusExpandAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                radiusExpandAnimation.duration = 0.2f;
                radiusExpandAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                radiusExpandAnimation.fromValue = @(_progressBarHeight/2);
                
                radiusExpandAnimation.delegate = self;
                [self.layer addAnimation:radiusExpandAnimation forKey:@"cornerRadiusExpandAnim"];
                
            }
        }];
        
    }
}


//加载进度的动画
-(void)progressBarAnimation{
    
    //这类进度的动画，都是用的 strokeEnd 属性。而 strokeEnd 不是 CALayer 的属性，而是其子类 CAShapeLayer 的一个特有的属性。所以我们必须创建一个 CAShapeLayer. 注意path是必须赋值的参数
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(_progressBarHeight/2, self.bounds.size.height/2)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width-_progressBarHeight/2, self.bounds.size.height/2)];
    
    progressLayer.path = path.CGPath;
    progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    progressLayer.lineWidth = _progressBarHeight-6;
    //“lineCap 指的是线段的线帽”
    //kCALineCapButt: 默认格式，不附加任何形状;
    //kCALineCapRound: 在线段头尾添加半径为线段 lineWidth 一半的半圆；
    //kCALineCapSquare: 在线段头尾添加半径为线段 lineWidth 一半的矩形
    progressLayer.lineCap = kCALineCapRound;
    //设置了kCALineCapRound 那么圆角弧度自动被设为 lineWidth/2 .所以要想进度条距离外围的间距相等，起始点的 x 坐标应该等于满足公式 x=lineWidth/2+space; ∵ lineWidth ＝ _progressBarHeight-space*2 ∴x = height/2.与 linewidth 是多少并没有关系
    [self.layer addSublayer:progressLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0f;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    pathAnimation.delegate = self;
    [pathAnimation setValue:@"progressBarAnimation" forKey:@"animationName"];
    [progressLayer addAnimation:pathAnimation forKey:nil];
    
}

-(void)checkAnimation{
    
    CAShapeLayer *checkLayer = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect rectInCircle = CGRectInset(self.bounds, self.bounds.size.width*(1-1/sqrt(2.0))/2, self.bounds.size.width*(1-1/sqrt(2.0))/2);
    [path moveToPoint:CGPointMake(rectInCircle.origin.x + rectInCircle.size.width/9, rectInCircle.origin.y + rectInCircle.size.height*2/3)];
    [path addLineToPoint:CGPointMake(rectInCircle.origin.x + rectInCircle.size.width/3,rectInCircle.origin.y + rectInCircle.size.height*9/10)];
    [path addLineToPoint:CGPointMake(rectInCircle.origin.x + rectInCircle.size.width*8/10, rectInCircle.origin.y + rectInCircle.size.height*2/10)];
    
    checkLayer.path = path.CGPath;
    checkLayer.fillColor = [UIColor clearColor].CGColor;
    checkLayer.strokeColor = [UIColor whiteColor].CGColor;
    checkLayer.lineWidth = 10.0;
    checkLayer.lineCap = kCALineCapRound;
    checkLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:checkLayer];
    
    
    CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    checkAnimation.duration = 0.3f;
    checkAnimation.fromValue = @(0.0f);
    checkAnimation.toValue = @(1.0f);
    checkAnimation.delegate = self;
    [checkAnimation setValue:@"checkAnimation" forKey:@"animationName"];
    [checkLayer addAnimation:checkAnimation forKey:nil];
    
}






@end
