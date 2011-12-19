//
//  Messager.h
//  Scanner


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface Messager : NSObject
{
    UILabel* _logMesageLabel;
}

- (id)initWith:(UILabel*)logMesageLabel;

-(void)showMessage:(NSString *)theMessage 
  withFadeDuration:(float)fadeDuration 
  withShowDuration:(float)showDuration;

@end
