//
//  ImojiSDKUI
//
//  Created by Alex Hoang
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

#import "IMMutableArtist.h"


@implementation IMMutableArtist {

}

- (instancetype)initWWithIdentifier:(NSString *)identifier
                               name:(NSString *)name
                            summary:(NSString *)summary
                       previewImoji:(IMImojiObject *)previewImoji {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _name = name;
        _summary = summary;
        _previewImoji = previewImoji;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _identifier = [coder decodeObjectForKey:@"identifier"];
        _name = [coder decodeObjectForKey:@"name"];
        _summary = [coder decodeObjectForKey:@"summary"];
        _previewImoji = [coder decodeObjectForKey:@"previewImoji"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_identifier forKey:@"identifier"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_summary forKey:@"summary"];
    [coder encodeObject:_previewImoji forKey:@"previewImoji"];
}

- (NSString *)identifier {
    return _identifier;
}

- (NSString *)name {
    return _name;
}

- (NSString *)summary {
    return _summary;
}

- (IMImojiObject *)previewImoji {
    return _previewImoji;
}

+ (instancetype)artistWithIdentifier:(NSString *)identifier
                                name:(NSString *)name
                             summary:(NSString *)summary
                        previewImoji:(IMImojiObject *)previewImoji {
    return [[IMMutableArtist alloc] initWWithIdentifier:identifier
                                                   name:name
                                                summary:summary
                                           previewImoji:previewImoji];
}

@end
