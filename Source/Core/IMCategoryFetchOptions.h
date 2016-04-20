//
// Created by Nima on 4/4/16.
//

#import <Foundation/Foundation.h>
#import "IMImojiSession.h"


/**
*  @abstract Set of options for retrieving Categories within IMImojiSession
*/
@interface IMCategoryFetchOptions : NSObject

/**
 * @abstract classification Type of category classification to retrieve
 */
@property(nonatomic) IMImojiSessionCategoryClassification classification;

/**
 * @abstract When set, instructs the server to return categories relevant to the search phrase.
 */
@property(nonatomic, strong, nullable) NSString *contextualSearchPhrase;

/**
 * @abstract Used in conjunction with contextualSearchPhrase to identify the locale of the phrase.
 */
@property(nonatomic, strong, nullable) NSLocale *contextualSearchLocale;

/**
 * @abstract A bit-field of one or more IMImojiObjectLicenseStyle values to filter the categories on.
 */
@property(nonatomic, strong, nullable) NSNumber *licenseStyles;

+ (nonnull instancetype)optionsWithClassification:(IMImojiSessionCategoryClassification)classification;

+ (nonnull instancetype)optionsWithClassification:(IMImojiSessionCategoryClassification)classification
                           contextualSearchPhrase:(nullable NSString *)contextualSearchPhrase;

+ (nonnull instancetype)optionsWithClassification:(IMImojiSessionCategoryClassification)classification
                           contextualSearchPhrase:(nullable NSString *)contextualSearchPhrase
                           contextualSearchLocale:(nullable NSLocale *)contextualSearchLocale;


@end
