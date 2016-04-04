//
// Created by Nima on 4/4/16.
//

#import "IMCategoryFetchOptions.h"


@implementation IMCategoryFetchOptions {

}
- (nonnull instancetype)initWithClassification:(IMImojiSessionCategoryClassification)classification {
    self = [super init];
    if (self) {
        self.classification = classification;
    }

    return self;
}

- (nonnull instancetype)initWithClassification:(IMImojiSessionCategoryClassification)classification
                        contextualSearchPhrase:(nullable NSString *)contextualSearchPhrase {
    self = [super init];
    if (self) {
        self.classification = classification;
        self.contextualSearchPhrase = contextualSearchPhrase;
    }

    return self;
}

- (nonnull instancetype)initWithClassification:(IMImojiSessionCategoryClassification)classification
                        contextualSearchPhrase:(nullable NSString *)contextualSearchPhrase
                        contextualSearchLocale:(nullable NSLocale *)contextualSearchLocale {
    self = [super init];
    if (self) {
        self.classification = classification;
        self.contextualSearchPhrase = contextualSearchPhrase;
        self.contextualSearchLocale = contextualSearchLocale;
    }

    return self;
}

+ (nonnull instancetype)optionsWithClassification:(IMImojiSessionCategoryClassification)classification {
    return [[self alloc] initWithClassification:classification];
}

+ (nonnull instancetype)optionsWithClassification:(IMImojiSessionCategoryClassification)classification
                           contextualSearchPhrase:(nullable NSString *)contextualSearchPhrase {
    return [[self alloc] initWithClassification:classification
                         contextualSearchPhrase:contextualSearchPhrase];
}

+ (nonnull instancetype)optionsWithClassification:(IMImojiSessionCategoryClassification)classification
                           contextualSearchPhrase:(nullable NSString *)contextualSearchPhrase
                           contextualSearchLocale:(nullable NSLocale *)contextualSearchLocale {
    return [[self alloc] initWithClassification:classification
                         contextualSearchPhrase:contextualSearchPhrase
                         contextualSearchLocale:contextualSearchLocale];

}

@end
