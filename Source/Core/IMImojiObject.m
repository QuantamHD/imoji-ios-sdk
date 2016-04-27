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

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "IMImojiObject.h"

@implementation IMImojiObject {

}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToObject:other];
}

- (BOOL)isEqualToObject:(IMImojiObject *)object {
    if (self == object)
        return YES;
    if (object == nil)
        return NO;
    if (self.identifier != object.identifier && ![self.identifier isEqualToString:object.identifier])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.identifier=%@", self.identifier];
    [description appendString:@">"];
    return description;
}

- (nullable NSURL *)getUrlForRenderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions {
    if (renderingOptions.aspectRatio || renderingOptions.targetSize) {
        return [self generateImageUrlWithRenderingOptions:renderingOptions];
    }

    id url = self.urls[[IMImojiObjectRenderingOptions optionsWithRenderSize:renderingOptions.renderSize
                                                                borderStyle:renderingOptions.borderStyle
                                                                imageFormat:renderingOptions.imageFormat]];

    if (url && [url isKindOfClass:[NSURL class]]) {
        return url;
    }

    return nil;
}

- (CGSize)getImageDimensionsForRenderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions {
    id imageDimension = self.imageDimensions[[IMImojiObjectRenderingOptions optionsWithRenderSize:renderingOptions.renderSize
                                                                                      borderStyle:renderingOptions.borderStyle
                                                                                      imageFormat:renderingOptions.imageFormat]];

    if (imageDimension && [imageDimension isKindOfClass:[NSValue class]]) {
        return ((NSValue *) imageDimension).CGSizeValue;
    }

    return CGSizeZero;
}

- (NSUInteger)getFileSizeForRenderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions {
    id fileSize = self.fileSizes[[IMImojiObjectRenderingOptions optionsWithRenderSize:renderingOptions.renderSize
                                                                          borderStyle:renderingOptions.borderStyle
                                                                          imageFormat:renderingOptions.imageFormat]];

    if (fileSize && [fileSize isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *) fileSize).unsignedIntegerValue;
    }

    return 0;
}

- (nullable IMImojiObjectRenderingOptions *)supportedAnimatedRenderingOptionFromOption:(nonnull IMImojiObjectRenderingOptions *)renderingOptions {
    if (!self.supportsAnimation) {
        return nil;
    }

    // if the requested rendering options are for WebP, try to load an animated webp image, otherwise fallback to gif
    IMImojiObjectRenderingOptions *animatedRenderingOptions = [renderingOptions toAnimatedRenderingOptions];
    if (renderingOptions.imageFormat == IMImojiObjectImageFormatWebP) {
        animatedRenderingOptions.imageFormat = IMImojiObjectImageFormatAnimatedWebp;

        if ([self getUrlForRenderingOptions:animatedRenderingOptions]) {
            return animatedRenderingOptions;
        }

        animatedRenderingOptions.imageFormat = IMImojiObjectImageFormatAnimatedGif;
    }

    if ([self getUrlForRenderingOptions:animatedRenderingOptions]) {
        return animatedRenderingOptions;
    }

    return nil;
}

- (nonnull NSURL *)generateImageUrlWithRenderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions {
    NSMutableString *urlString = [NSMutableString string];
    [urlString appendFormat:@"https://render.imoji.io/%@/%@/", [self.identifier substringToIndex:3], self.identifier];
    if (renderingOptions.renderAnimatedIfSupported && self.supportsAnimation) {
        [urlString appendString:@"animated-"];
    } else if (renderingOptions.borderStyle == IMImojiObjectBorderStyleNone) {
        [urlString appendString:@"unbordered-"];
    } else {
        [urlString appendString:@"bordered-"];
    }

    if (renderingOptions.targetSize) {
        CGSize size = [renderingOptions.targetSize CGSizeValue];
        CGFloat maxSize = MAX(size.width, size.height);
        [urlString appendFormat:@"%@", @(maxSize)];
    } else {
        switch (renderingOptions.renderSize) {
            case IMImojiObjectRenderSizeThumbnail:
                [urlString appendString:@"150"];
                break;
            case IMImojiObjectRenderSizeFullResolution:
                [urlString appendString:@"1200"];
                break;
            case IMImojiObjectRenderSize320:
                [urlString appendString:@"320"];
                break;
            case IMImojiObjectRenderSize512:
                [urlString appendString:@"512"];
                break;
        }
    }

    if (renderingOptions.aspectRatio) {
        CGSize aspectRatio = [renderingOptions.aspectRatio CGSizeValue];
        [urlString appendFormat:@"-%@x%@", @(aspectRatio.width), @(aspectRatio.height)];
    }

    switch (renderingOptions.imageFormat) {
        case IMImojiObjectImageFormatPNG:
            [urlString appendString:@".png"];
            break;
        case IMImojiObjectImageFormatAnimatedGif:
            [urlString appendString:@".gif"];
            break;

        case IMImojiObjectImageFormatWebP:
        case IMImojiObjectImageFormatAnimatedWebp:
            [urlString appendString:@".webp"];
            break;
    }

    return [NSURL URLWithString:urlString];
}

@end
