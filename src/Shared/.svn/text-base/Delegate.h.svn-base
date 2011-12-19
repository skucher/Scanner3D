//
//  Delegate.h
//  Scanner
//
//  Created by אדמין on 1/20/72.
//  Copyright 5772 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**Represents delegate (function pointer)*/
@interface Delegate : NSObject {
    id callie;
    SEL selector;   
}
/**invoke method*/
-(void)run;
/**invoke method
 @param parameter - the parameter to invoke method with
 */
-(void)run:(id)parameter;

/**init delegate
 @param _caliie - the object to perform selector
 @param _selector - the selector to perform
 */
-(id)init:(id)_caliie:(SEL)_selector;

@end
