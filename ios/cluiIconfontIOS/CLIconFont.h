//
//  CLIconFont.h
//  BindingX
//
//  Created by ChesterLee on 2020/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLIconFont : NSObject

- (UIFont *)fontWithSize: (CGFloat)size;

@property(nonatomic, strong) NSString *fontSrc;

@property(nonatomic, strong) NSString *fontFamily;

@end

NS_ASSUME_NONNULL_END
