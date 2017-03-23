//
//  Language.h
//  V&V
//
//  Created by Haryson Liang on 5/17/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LANGUAGE_AUTO				0
#define LANGUAGE_ZHCN				1
#define LANGUAGE_ZHHK				2
#define LANGUAGE_EN					3
#define LANGUAGE_ZHTW               4
#define LANGUAGE_JA                 5
#define LANGUAGE_TH                 6


#define LANGUAGE_ZHCN_TEXT			@"zh-Hans"
#define LANGUAGE_ZHHK_TEXT			@"zh-Hant"
#define LANGUAGE_EN_TEXT			@"en"
#define LANGUAGE_ZHTW_TEXT          @"zh-Hant-TW"
#define LANGUAGE_JA_TEXT            @"ja"
#define LANGUAGE_TH_TEXT            @"th"

#define KEY_LANG                    @"key_lang"


//-------------------------------------------------------------------------------
@interface Language : NSObject {
}

//-------------------------------------------------------------------------------
+ (void)loadLanguage;
+ (void)setLanguage:(int)languageType;
+ (int)getCurrentLanguage;
+ (NSString*)getText:(NSString *)key;
+ (int)getDefaultLanguage;
+ (void)setLocalLanguage:(int)langType;


@end
