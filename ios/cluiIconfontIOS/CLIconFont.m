//
//  CLIconFont.m
//  BindingX
//
//  Created by ChesterLee on 2020/8/3.
//

#import "CLIconFont.h"
#import <CoreText/CoreText.h>

@implementation CLIconFont

- (void)registerFontWithURL:(NSURL *)url {
    if (!url) {
        return;
    }
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Font file doesn't exist");
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
    CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(newFont, nil);
    CGFontRelease(newFont);
}

- (UIFont *)fontWithSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:self.fontFamily size:size];
    if (font == nil) {
        NSString *src = [self.fontSrc stringByReplacingOccurrencesOfString:@"local://" withString:@"bundlejs"];
        src = [src stringByReplacingOccurrencesOfString:@".ttf" withString:@""];
        NSURL *fontFileUrl = [[NSBundle mainBundle] URLForResource:src withExtension:@"ttf"];

        [self registerFontWithURL:fontFileUrl];
        font = [UIFont fontWithName:self.fontFamily size:size];
    }
    return font;
}

- (NSString *)fontSrc {
    if (!_fontSrc) {
        _fontSrc = @"local:///eeui/font/iconfont.ttf";
    }
    return _fontSrc;
}

@end
