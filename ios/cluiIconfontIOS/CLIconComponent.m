//
//  CLIconComponent.m
//  BindingX
//
//  Created by ChesterLee on 2020/8/3.
//

#import "CLIconComponent.h"
#import "WeexSDK.h"
#import "CLIconFont.h"
#import <WeexPluginLoader/WeexPluginLoader.h>

@interface CLIconComponent ()

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, strong) UILabel *iconLab;

@property(nonatomic, strong) CLIconFont *iconFont;

@end

@implementation CLIconComponent

WX_PlUGIN_EXPORT_COMPONENT(cl-icon-ios, CLIconComponent)

WX_EXPORT_METHOD(@selector(setIcon:))
WX_EXPORT_METHOD(@selector(setIconSize:))
WX_EXPORT_METHOD(@selector(setIconColor:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        _content = @"";
        _color = @"#242424";
        _fontSize = [self font:38];
        
        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
        
        _angle = 0;
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _iconLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _iconLab.text = [self getFontText:_content];
    
    _iconLab.font =  [self.iconFont fontWithSize:_fontSize];
    _iconLab.textColor = [WXConvert UIColor:_color];
    _iconLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_iconLab];
    
    [self fireEvent:@"ready" params:nil];
}

- (NSString*)getFontText:(NSString*)text
{
    NSString *key = @"";
    NSArray *list = [text componentsSeparatedByString:@" "];
    if (list.count == 2) {
        key = [WXConvert NSString:list.firstObject];
        NSString *other = [WXConvert NSString:list.lastObject];
        if ([other hasSuffix:@"px"] || [other hasSuffix:@"dp"] || [other hasSuffix:@"sp"]) {
            _fontSize = [self font:[other integerValue]];
        } else if ([other hasSuffix:@"%"]) {
            _fontSize = [self font:38 * [other integerValue] * 1.0 / 100];
        } else if ([other isEqualToString:@"#"]) {
            _color = other;
        } else if ([other isEqualToString:@"spin"]) {
            [self startAnimation];
        }
    } else {
        key = text;
    }

    return key;
}

- (void)startAnimation
{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(_angle * (M_PI / 180.0f));
    
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        wself.view.transform = endAngle;
    } completion:^(BOOL finished) {
        wself.angle += 2;
        [wself startAnimation];
    }];
}

- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
}

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [self convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"eeui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"content"]) {
        _content = [WXConvert NSString:value];
        if ([_content hasPrefix:@"'"]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"'" withString:@""];
        }
        if ([_content hasPrefix:@"\""]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
        if (isUpdate) {
            [self setIcon:_content];
        }
    } else if ([key isEqualToString:@"text"]) {
        _content = [WXConvert NSString:value];
        if ([_content hasPrefix:@"'"]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"'" withString:@""];
        }
        if ([_content hasPrefix:@"\""]) {
            _content = [_content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
        if (isUpdate) {
            [self setIcon:_content];
        }
    } else if ([key isEqualToString:@"color"]) {
        _color = [WXConvert NSString:value];
        if (isUpdate) {
            _iconLab.textColor = [WXConvert UIColor:_color];
        }
    } else if ([key isEqualToString:@"fontSize"]) {
        _fontSize = [self font:[WXConvert NSInteger:value]];
        if (isUpdate) {
            _iconLab.font = [UIFont fontWithName:self.iconFont.fontFamily size: _fontSize];
        }
    } else if ([key isEqualToString:@"fontFamily"]) {
        if ([[WXConvert NSString:value] length] > 0) {
            self.iconFont.fontFamily = [WXConvert NSString:value];
        }
        
    } else if ([key isEqualToString:@"fontSrc"]) {
        NSString *src = [WXConvert NSString:value];
        if ([src hasPrefix:@"src"]) {
            src = [src stringByReplacingOccurrencesOfString:@"src" withString:@"bundlejs/eeui"];
        }
        self.iconFont.fontSrc = src;
    }
}

#pragma mark methods

- (CLIconFont *)iconFont {
    if (!_iconFont) {
        _iconFont = [[CLIconFont alloc] init];
    }
    return _iconFont;
}

- (void)setIcon:(id)value
{
    if (value) {
        _content = [WXConvert NSString:value];
        _iconLab.text = [self getFontText:_content];
    }
}

- (void)setIconSize:(id)value
{
    if (value) {
        _fontSize = [self font:[WXConvert NSInteger:value]];
        _iconLab.font = [UIFont fontWithName:self.iconFont.fontFamily size: _fontSize];
    }
}

- (void)setIconColor:(id)value
{
    if (value) {
        _color = [WXConvert NSString:value];
        _iconLab.textColor = [WXConvert UIColor:_color];
    }
}

//字符串中划线转驼峰写法
- (NSString *)convertToCamelCaseFromSnakeCase:(NSString *)key
{
    NSMutableString *str = [NSMutableString stringWithString:key];
    while ([str containsString:@"-"]) {
        NSRange range = [str rangeOfString:@"-"];
        if (range.location + 1 < [str length]) {
            char c = [str characterAtIndex:range.location+1];
            [str replaceCharactersInRange:NSMakeRange(range.location, range.length+1) withString:[[NSString stringWithFormat:@"%c",c] uppercaseString]];
        }
    }
    return str;
}
//字体尺寸转换
- (NSInteger)font:(NSInteger)font
{
    return [UIScreen mainScreen].bounds.size.width * 1.0f/750 * font;
}
@end
