//
//  ImojiSDK
//
//  Created by Nima Khoshini
//  Copyright (C) 2015 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "IMImojiObjectRenderingOptions.h"

@implementation IMImojiObjectRenderingOptions {

}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.renderSize = (IMImojiObjectRenderSize) [coder decodeIntForKey:@"renderSize"];
        self.targetSize = [coder decodeObjectForKey:@"targetSize"];
        self.aspectRatio = [coder decodeObjectForKey:@"aspectRatio"];
        self.borderStyle = (IMImojiObjectBorderStyle) [coder decodeIntForKey:@"borderStyle"];
        self.imageFormat = (IMImojiObjectImageFormat) [coder decodeIntForKey:@"imageFormat"];
        self.renderAnimatedIfSupported = [coder decodeBoolForKey:@"renderAnimatedIfSupported"];
        self.maximumFileSize = [coder decodeObjectForKey:@"maximumFileSize"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.renderSize forKey:@"renderSize"];
    [coder encodeObject:self.targetSize forKey:@"targetSize"];
    [coder encodeObject:self.aspectRatio forKey:@"aspectRatio"];
    [coder encodeInt:self.borderStyle forKey:@"borderStyle"];
    [coder encodeInt:self.imageFormat forKey:@"imageFormat"];
    [coder encodeBool:self.renderAnimatedIfSupported forKey:@"renderAnimatedIfSupported"];
    [coder encodeObject:self.maximumFileSize forKey:@"maximumFileSize"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.renderSize = IMImojiObjectRenderSizeThumbnail;
        self.borderStyle = IMImojiObjectBorderStyleSticker;
        self.imageFormat = IMImojiObjectImageFormatWebP;
        self.renderAnimatedIfSupported = NO;
    }

    return self;
}

- (instancetype)initWithRenderSize:(IMImojiObjectRenderSize)renderSize
                       borderStyle:(IMImojiObjectBorderStyle)borderStyle
                       imageFormat:(IMImojiObjectImageFormat)imageFormat {
    self = [super init];
    if (self) {
        self.renderSize = renderSize;
        self.borderStyle = borderStyle;
        self.imageFormat = imageFormat;
        self.renderAnimatedIfSupported = NO;
    }

    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToOptions:other];
}

- (BOOL)isEqualToOptions:(IMImojiObjectRenderingOptions *)options {
    if (self == options)
        return YES;
    if (options == nil)
        return NO;
    if (self.aspectRatio != options.aspectRatio && ![self.aspectRatio isEqualToValue:options.aspectRatio])
        return NO;
    if (self.renderSize != options.renderSize)
        return NO;
    if (self.targetSize != options.targetSize && ![self.targetSize isEqualToValue:options.targetSize])
        return NO;
    if (self.borderStyle != options.borderStyle)
        return NO;
    if (self.imageFormat != options.imageFormat)
        return NO;
    if (self.renderAnimatedIfSupported != options.renderAnimatedIfSupported)
        return NO;
    if (self.maximumFileSize != options.maximumFileSize)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.aspectRatio hash];
    hash = hash * 31u + (NSUInteger) self.renderSize;
    hash = hash * 31u + [self.targetSize hash];
    hash = hash * 31u + (NSUInteger) self.borderStyle;
    hash = hash * 31u + (NSUInteger) self.imageFormat;
    hash = hash * 31u + (NSUInteger) self.renderAnimatedIfSupported;
    hash = hash * 31u + [self.maximumFileSize hash];
    return hash;
}

- (id)copyWithZone:(NSZone *)zone {
    IMImojiObjectRenderingOptions *copy = [[IMImojiObjectRenderingOptions allocWithZone:zone] init];

    if (copy != nil) {
        copy.aspectRatio = self.aspectRatio;
        copy.renderSize = self.renderSize;
        copy.targetSize = self.targetSize;
        copy.borderStyle = self.borderStyle;
        copy.imageFormat = self.imageFormat;
        copy.renderAnimatedIfSupported = self.renderAnimatedIfSupported;
        copy.maximumFileSize = self.maximumFileSize;
    }

    return copy;
}

- (IMImojiObjectRenderingOptions *)toAnimatedRenderingOptions {
    IMImojiObjectRenderingOptions * animatedOptions = [self copy];
    animatedOptions.imageFormat = IMImojiObjectImageFormatAnimatedGif;
    animatedOptions.borderStyle = IMImojiObjectBorderStyleNone;

    return animatedOptions;
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize {
    return [[IMImojiObjectRenderingOptions alloc] initWithRenderSize:renderSize borderStyle:IMImojiObjectBorderStyleSticker imageFormat:IMImojiObjectImageFormatWebP];
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderStyle:(IMImojiObjectBorderStyle)borderStyle {
    return [[IMImojiObjectRenderingOptions alloc] initWithRenderSize:renderSize borderStyle:borderStyle imageFormat:IMImojiObjectImageFormatWebP];
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderStyle:(IMImojiObjectBorderStyle)borderStyle
                          imageFormat:(IMImojiObjectImageFormat)imageFormat {
    return [[IMImojiObjectRenderingOptions alloc] initWithRenderSize:renderSize borderStyle:borderStyle imageFormat:imageFormat];
}

+ (instancetype)optionsWithAnimationAndRenderSize:(IMImojiObjectRenderSize)renderSize {
    IMImojiObjectRenderingOptions* options = [[IMImojiObjectRenderingOptions alloc] initWithRenderSize:renderSize borderStyle:IMImojiObjectBorderStyleNone imageFormat:IMImojiObjectImageFormatAnimatedGif];
    options.renderAnimatedIfSupported = YES;
    return options;
}

@end
