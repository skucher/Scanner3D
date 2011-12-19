//
//  Messager.m
//  Scanner

#import "Messager.h"


@implementation Messager


#pragma Mark
#pragma Mark - Message Methods

- (id)initWith:(UILabel*)logMesageLabel
{
    self = [super init];
    if (self) 
    {
        _logMesageLabel = logMesageLabel;
        
    }
    return self; 
}

-(void)showMessage:(NSString *)theMessage 
  withFadeDuration:(float)fadeDuration 
  withShowDuration:(float)showDuration
{
    _logMesageLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    _logMesageLabel.layer.borderWidth = 2.0;
    _logMesageLabel.layer.cornerRadius = 4.0;
    _logMesageLabel.clipsToBounds = YES;
    
    _logMesageLabel.text = theMessage;
    _logMesageLabel.alpha = 0.0;
    _logMesageLabel.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:fadeDuration];
    _logMesageLabel.alpha = 1.0;
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:fadeDuration + showDuration target:self selector:@selector(hideMessageOnTimeout) userInfo:nil repeats:NO];
}

-(void)hideMessage:(float)fadeDuration
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:fadeDuration];
    [UIView  setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(messageFadedOut:finished:context:)];
    _logMesageLabel.alpha = 0.0;
    [UIView commitAnimations];    
}

-(void)messageFadedOut:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    _logMesageLabel.hidden = YES;
}

-(void)hideMessageOnTimeout
{
    [self hideMessage:2.0];
}

@end
