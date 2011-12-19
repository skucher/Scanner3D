//
//  Event.h
//  Scanner


#import <Foundation/Foundation.h>

/**Event representation*/
@interface Event : NSObject {
    NSMutableArray* methodArray;
}

/**invoke all methods that are sighned to event*/
- (void)invoke;
/**Sign method to event
 @param _caliie - the object to perform selector
 @param _selector - the selector to perform
 */
- (void)signMethod:(id)_caliie:(SEL)_selector;
/**clears all methods that sighned to the event*/
- (void)clear;
@end
