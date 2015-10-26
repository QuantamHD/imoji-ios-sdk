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
- (instancetype)init {
    self = [super init];
    if (self) {
        self.renderSize = IMImojiObjectRenderSizeThumbnail;
        self.borderStyle = IMImojiObjectBorderStyleSticker;
        self.imageFormat = IMImojiObjectImageFormatWebP;
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
    if (self.maximumRenderSize != options.maximumRenderSize && ![self.maximumRenderSize isEqualToValue:options.maximumRenderSize])
        return NO;
    if (self.borderStyle != options.borderStyle)
        return NO;
    if (self.imageFormat != options.imageFormat)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.aspectRatio hash];
    hash = hash * 31u + (NSUInteger) self.renderSize;
    hash = hash * 31u + [self.targetSize hash];
    hash = hash * 31u + [self.maximumRenderSize hash];
    hash = hash * 31u + (NSUInteger) self.borderStyle;
    hash = hash * 31u + (NSUInteger) self.imageFormat;
    return hash;
}

- (id)copyWithZone:(NSZone *)zone {
    IMImojiObjectRenderingOptions *copy = [[IMImojiObjectRenderingOptions allocWithZone:zone] init];

    if (copy != nil) {
        copy.aspectRatio = self.aspectRatio;
        copy.renderSize = self.renderSize;
        copy.targetSize = self.targetSize;
        copy.maximumRenderSize = self.maximumRenderSize;
        copy.borderStyle = self.borderStyle;
        copy.imageFormat = self.imageFormat;
    }

    return copy;
}


+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize {
    return [[self alloc] initWithRenderSize:renderSize borderStyle:IMImojiObjectBorderStyleSticker imageFormat:IMImojiObjectImageFormatWebP];
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderStyle:(IMImojiObjectBorderStyle)borderStyle {
    return [[self alloc] initWithRenderSize:renderSize borderStyle:borderStyle imageFormat:IMImojiObjectImageFormatWebP];
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderStyle:(IMImojiObjectBorderStyle)borderStyle
                          imageFormat:(IMImojiObjectImageFormat)imageFormat {
    return [[self alloc] initWithRenderSize:renderSize borderStyle:borderStyle imageFormat:imageFormat];
}

@end
