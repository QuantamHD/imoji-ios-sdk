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

#import "IMMutableImojiObject.h"

@interface IMMutableImojiObject ()
@end

@implementation IMMutableImojiObject {

}
- (instancetype)initWWithIdentifier:(nonnull NSString *)identifier
                               tags:(nonnull NSArray *)tags
                               urls:(nonnull NSDictionary *)urls
                    imageDimensions:(nonnull NSDictionary *)imageDimensions
                          fileSizes:(nonnull NSDictionary *)fileSizes {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _urls = urls;
        _fileSizes = fileSizes;
        _imageDimensions = imageDimensions;
        _tags = tags;
        _supportsAnimation = urls && [urls[[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail
                                                                                    borderStyle:IMImojiObjectBorderStyleNone
                                                                                    imageFormat:IMImojiObjectImageFormatAnimatedGif]] isKindOfClass:[NSURL class]];
    }

    return self;
}

- (NSString *)identifier {
    return _identifier;
}

- (NSArray *)tags {
    return _tags;
}

- (NSDictionary *)urls {
    return _urls;
}

- (NSDictionary *)fileSizes {
    return _fileSizes;
}

- (NSDictionary *)imageDimensions {
    return _imageDimensions;
}

- (BOOL)supportsAnimation {
    return _supportsAnimation;
}

+ (nonnull instancetype)imojiWithIdentifier:(nonnull NSString *)identifier
                                       tags:(nonnull NSArray *)tags
                                       urls:(nonnull NSDictionary *)urls {
    return [[IMMutableImojiObject alloc] initWWithIdentifier:identifier
                                                        tags:tags
                                                        urls:urls
                                             imageDimensions:@{}
                                                   fileSizes:@{}];
}

+ (nonnull instancetype)imojiWithIdentifier:(nonnull NSString *)identifier
                                       tags:(nonnull NSArray *)tags
                                       urls:(nonnull NSDictionary *)urls
                            imageDimensions:(nonnull NSDictionary *)imageDimensions
                                  fileSizes:(nonnull NSDictionary *)fileSizes {
    return [[IMMutableImojiObject alloc] initWWithIdentifier:identifier
                                                        tags:tags
                                                        urls:urls
                                             imageDimensions:imageDimensions
                                                   fileSizes:fileSizes];
}

@end
