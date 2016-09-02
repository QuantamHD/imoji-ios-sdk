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

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _identifier = [coder decodeObjectForKey:@"identifier"];
        _tags = [coder decodeObjectForKey:@"tags"];
        _urls = [coder decodeObjectForKey:@"urls"];
        _imageDimensions = [coder decodeObjectForKey:@"imageDimensions"];
        _fileSizes = [coder decodeObjectForKey:@"fileSizes"];
        _supportsAnimation = [coder decodeBoolForKey:@"supportsAnimation"];
        self.licenseStyle = (IMImojiObjectLicenseStyle) [coder decodeIntegerForKey:@"licenseStyle"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:@"identifier"];
    [coder encodeObject:self.tags forKey:@"tags"];
    [coder encodeObject:self.urls forKey:@"urls"];
    [coder encodeObject:self.imageDimensions forKey:@"imageDimensions"];
    [coder encodeObject:self.fileSizes forKey:@"fileSizes"];
    [coder encodeBool:self.supportsAnimation forKey:@"supportsAnimation"];
    [coder encodeInteger:self.licenseStyle forKey:@"licenseStyle"];
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

    BOOL findFallback = YES;
    IMImojiObjectRenderSize imageSize = renderingOptions.renderSize;
    while (findFallback) {
        IMImojiObjectRenderingOptions *options = [IMImojiObjectRenderingOptions optionsWithRenderSize:imageSize
                                                                                          borderStyle:renderingOptions.borderStyle
                                                                                          imageFormat:renderingOptions.imageFormat];
        id url = self.urls[options];

        if (renderingOptions.maximumFileSize) {
            NSNumber *size = self.fileSizes[options];
            
            // avoid the URL if the file size is larger than requested
            if ([size isKindOfClass:[NSNumber class]] &&
                    size.longLongValue > renderingOptions.maximumFileSize.longLongValue) {
                url = nil;
            }
        }

        if (url && [url isKindOfClass:[NSURL class]]) {
            return url;
        }

        // fallback to PNG format, the contents are the same when returned to the caller
        if (renderingOptions.imageFormat == IMImojiObjectImageFormatWebP) {
            url = self.urls[[IMImojiObjectRenderingOptions optionsWithRenderSize:imageSize
                                                                     borderStyle:renderingOptions.borderStyle
                                                                     imageFormat:IMImojiObjectImageFormatPNG]];
        }

        if (url && [url isKindOfClass:[NSURL class]]) {
            return url;
        }

        // fallback to a smaller size if we can't find the requested one
        switch (imageSize) {
            case IMImojiObjectRenderSizeThumbnail:
                findFallback = NO;
                break;

            case IMImojiObjectRenderSizeFullResolution:
                imageSize = IMImojiObjectRenderSize512;
                break;

            case IMImojiObjectRenderSize320:
                imageSize = IMImojiObjectRenderSizeThumbnail;
                break;

            case IMImojiObjectRenderSize512:
                imageSize = IMImojiObjectRenderSize320;
                break;
        }
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
