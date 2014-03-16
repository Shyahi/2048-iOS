//
//  Constants.h
//
//

#import <Foundation/Foundation.h>

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

extern int ddLogLevel;

@interface Constants : NSObject
@end
