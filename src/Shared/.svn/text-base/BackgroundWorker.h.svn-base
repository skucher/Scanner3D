//
//  BackgroundWorker.h
//  Scanner


#import <Foundation/Foundation.h>

@class Event;

/**Class that represents backgroud worker thread
 */

@interface BackgroundWorker : NSObject {
    NSThread* backgroundWorker;
}
/**Here we sign the excecution methods that will run in different thread
 one after another
 @see Event*/
@property (nonatomic,readonly,retain) Event *onDoWork;
/**Here we sign the methods that will run after excecution on main thread
one after another
  @see Event*/
@property (nonatomic,readonly,retain) Event *onRunWorkerCompleted;
/**The method that will run before excecution on main thread
  @see Event*/
@property (nonatomic,readonly,retain) Event *onBeforeWork;
/**start running in new thread*/
- (bool)runWorkerAsync;
/**reset event methods*/
- (void)reset;
/**cancel thread run*/
- (void)cancelRunWorkerAsync;
/**is background worker finished*/
- (bool)isFinished;
@end
