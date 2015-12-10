// AnimatedGIFImageSerialization.m
//
// Copyright (c) 2014 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AnimatedGIFImageSerialization.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

NSString *const AnimatedGIFImageErrorDomain = @"com.compuserve.gif.image.error";

__attribute__((overloadable)) UIImage *UIImageWithAnimatedGIFData(NSData *data) {
    return UIImageWithAnimatedGIFData(data, [[UIScreen mainScreen] scale], 0.0f, nil);
}

__attribute__((overloadable)) UIImage *UIImageWithAnimatedGIFData(NSData *data, CGFloat scale, NSTimeInterval duration, NSError *__autoreleasing *error) {
    if (!data) {
        return nil;
    }

    NSMutableDictionary *mutableOptions = [NSMutableDictionary dictionary];
    mutableOptions[(NSString *) kCGImageSourceShouldCache] = @(YES);
    mutableOptions[(NSString *) kCGImageSourceTypeIdentifierHint] = (NSString *) kUTTypeGIF;

    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, (__bridge CFDictionaryRef) mutableOptions);

    size_t numberOfFrames = CGImageSourceGetCount(imageSource);
    NSMutableArray *mutableImages = [NSMutableArray arrayWithCapacity:numberOfFrames];

    NSTimeInterval calculatedDuration = 0.0f;
    for (size_t idx = 0; idx < numberOfFrames; idx++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, idx, (__bridge CFDictionaryRef) mutableOptions);

        NSDictionary *properties = (__bridge_transfer NSDictionary *) CGImageSourceCopyPropertiesAtIndex(imageSource, idx, NULL);
        NSDictionary *gifDictionary = properties[(__bridge NSString *) kCGImagePropertyGIFDictionary];
        NSNumber *delay = gifDictionary[(__bridge NSString *) kCGImagePropertyGIFUnclampedDelayTime];

        if (!delay || [delay doubleValue] == 0) {
            delay = gifDictionary[(__bridge NSString *) kCGImagePropertyGIFDelayTime];
        }

        calculatedDuration += [delay doubleValue];

        [mutableImages addObject:[UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp]];

        CGImageRelease(imageRef);
    }

    CFRelease(imageSource);

    if (numberOfFrames == 1) {
        return [mutableImages firstObject];
    } else {
        return [UIImage animatedImageWithImages:mutableImages duration:(duration <= 0.0f ? calculatedDuration : duration)];
    }
}

__attribute__((overloadable)) NSData *UIImageAnimatedGIFRepresentation(UIImage *image) {
    return UIImageAnimatedGIFRepresentation(image, 0.0f, 0, nil);
}

__attribute__((overloadable)) NSData *UIImageAnimatedGIFRepresentation(UIImage *image, NSTimeInterval duration, NSUInteger loopCount, NSError *__autoreleasing *error) {
    if (!image.images) {
        return nil;
    }

    size_t frameCount = image.images.count;
    NSTimeInterval frameDuration = (duration <= 0.0 ? image.duration / frameCount : duration / frameCount);
    NSDictionary *frameProperties = @{
            (__bridge NSString *) kCGImagePropertyGIFDictionary : @{
                    (__bridge NSString *) kCGImagePropertyGIFDelayTime : @(frameDuration)
            }
    };

    NSMutableData *mutableData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) mutableData, kUTTypeGIF, frameCount, NULL);

    NSDictionary *imageProperties = @{(__bridge NSString *) kCGImagePropertyGIFDictionary : @{
            (__bridge NSString *) kCGImagePropertyGIFLoopCount : @(loopCount)
    }
    };
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef) imageProperties);

    for (size_t idx = 0; idx < image.images.count; idx++) {
        CGImageDestinationAddImage(destination, [image.images[idx] CGImage], (__bridge CFDictionaryRef) frameProperties);
    }

    BOOL success = CGImageDestinationFinalize(destination);
    CFRelease(destination);

    if (!success) {
        *error = [[NSError alloc] initWithDomain:AnimatedGIFImageErrorDomain
                                            code:-1
                                        userInfo:@{
                                                NSLocalizedDescriptionKey : NSLocalizedString(@"Could not finalize image destination", nil)
                                        }];

        return nil;
    }

    return [NSData dataWithData:mutableData];
}
