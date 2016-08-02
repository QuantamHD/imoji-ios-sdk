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
                          fileSizes:(nonnull NSDictionary *)fileSizes
                       licenseStyle:(IMImojiObjectLicenseStyle)licenseStyle {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _urls = urls;
        _fileSizes = fileSizes;
        _imageDimensions = imageDimensions;
        _tags = tags;
        _licenseStyle = licenseStyle;
        _supportsAnimation = urls && [urls[[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail
                                                                                    borderStyle:IMImojiObjectBorderStyleNone
                                                                                    imageFormat:IMImojiObjectImageFormatAnimatedGif]] isKindOfClass:[NSURL class]];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _identifier = [coder decodeObjectForKey:@"identifier"];
        _tags = [coder decodeObjectForKey:@"tags"];
        _urls = [coder decodeObjectForKey:@"urls"];
        _fileSizes = [coder decodeObjectForKey:@"fileSizes"];
        _imageDimensions = [coder decodeObjectForKey:@"imageDimensions"];
        _supportsAnimation = [coder decodeBoolForKey:@"supportsAnimation"];
        _licenseStyle = (IMImojiObjectLicenseStyle) [coder decodeIntForKey:@"licenseStyle"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_identifier forKey:@"identifier"];
    [coder encodeObject:_tags forKey:@"tags"];
    [coder encodeObject:_urls forKey:@"urls"];
    [coder encodeObject:_fileSizes forKey:@"fileSizes"];
    [coder encodeObject:_imageDimensions forKey:@"imageDimensions"];
    [coder encodeBool:_supportsAnimation forKey:@"supportsAnimation"];
    [coder encodeInt:_licenseStyle forKey:@"licenseStyle"];
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

- (IMImojiObjectLicenseStyle)licenseStyle {
    return _licenseStyle;
}

+ (nonnull instancetype)imojiWithIdentifier:(nonnull NSString *)identifier
                                       tags:(nonnull NSArray *)tags
                                       urls:(nonnull NSDictionary *)urls {
    return [[IMMutableImojiObject alloc] initWWithIdentifier:identifier
                                                        tags:tags
                                                        urls:urls
                                             imageDimensions:@{}
                                                   fileSizes:@{}
                                                licenseStyle:IMImojiObjectLicenseStyleNonCommercial];
}

+ (nonnull instancetype)imojiWithIdentifier:(nonnull NSString *)identifier
                                       tags:(nonnull NSArray *)tags
                                       urls:(nonnull NSDictionary *)urls
                            imageDimensions:(nonnull NSDictionary *)imageDimensions
                                  fileSizes:(nonnull NSDictionary *)fileSizes
                               licenseStyle:(IMImojiObjectLicenseStyle)licenseStyle {
    return [[IMMutableImojiObject alloc] initWWithIdentifier:identifier
                                                        tags:tags
                                                        urls:urls
                                             imageDimensions:imageDimensions
                                                   fileSizes:fileSizes
                                                licenseStyle:licenseStyle];
}

@end
