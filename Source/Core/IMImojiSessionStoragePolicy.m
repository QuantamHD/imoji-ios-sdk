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

#import "IMImojiSessionStoragePolicy.h"

const NSUInteger IMImojiSessionStoragePolicyMemoryCacheSize = 0;
const NSUInteger IMImojiSessionStoragePolicyDiskCacheSize = 15 * 1024 * 1024;

@interface IMImojiSessionStoragePolicy ()
@end

@implementation IMImojiSessionStoragePolicy {

}

- (instancetype)initWithCachePath:(NSURL *)cachePath persistentPath:(NSURL *)persistentPath {
    self = [super init];
    if (self) {
        _cachePath = cachePath;
        _persistentPath = persistentPath;

        [self createDirectoriesIfNeeded];
    }

    return self;
}

- (void)createDirectoriesIfNeeded {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cachePath.path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath.path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:self.persistentPath.path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.persistentPath.path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }

}

- (nonnull NSURLSessionConfiguration *)generateURLSessionConfiguration {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 10;
    sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeDefault;
    sessionConfiguration.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:IMImojiSessionStoragePolicyMemoryCacheSize
                                                                  diskCapacity:IMImojiSessionStoragePolicyDiskCacheSize
                                                                      diskPath:self.cachePath.path];
    sessionConfiguration.HTTPShouldUsePipelining = YES;
    sessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;

    return sessionConfiguration;
}

+ (instancetype)storagePolicyWithCachePath:(nonnull NSURL *)cachePath persistentPath:(nonnull NSURL *)persistentPath {
    return [[IMImojiSessionStoragePolicy alloc] initWithCachePath:cachePath
                                                   persistentPath:persistentPath];
}

+ (instancetype)temporaryDiskStoragePolicy {
    return [[IMImojiSessionStoragePolicy alloc] initWithCachePath:[NSURL URLWithString:NSTemporaryDirectory()]
                                                   persistentPath:[NSURL URLWithString:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject]];
}

@end
