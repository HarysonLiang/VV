//
//  Language.m
//  V&V
//
//  Created by Haryson Liang on 5/17/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "Language.h"

@implementation Language

//-------------------------------------------------------------------------------
static NSBundle *bundle = nil;
static int currentLanguage = LANGUAGE_AUTO;


+ (void)loadLanguage
{
    int langType = LANGUAGE_AUTO;
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    if (preferences != nil) {
        langType = [(NSNumber*)[preferences objectForKey:KEY_LANG] intValue];
    }
    if (langType == LANGUAGE_AUTO) {
        langType = [Language getDefaultLanguage];
    }
    [Language setLanguage:langType];
}


//-------------------------------------------------------------------------------
+ (void)setLanguage:(int)newLanguage {
	currentLanguage = newLanguage;

    NSString *path = NULL;
    NSString *languageText = LANGUAGE_EN_TEXT;
	switch (currentLanguage) {
		case LANGUAGE_EN:
			languageText = LANGUAGE_EN_TEXT;	
			break;
		case LANGUAGE_ZHCN:
			languageText = LANGUAGE_ZHCN_TEXT;	
			break;
		case LANGUAGE_ZHHK:
			languageText = LANGUAGE_ZHHK_TEXT;	
			break;
        case LANGUAGE_ZHTW:
            languageText = LANGUAGE_ZHTW_TEXT;
            break;
        case LANGUAGE_JA:
            languageText = LANGUAGE_JA_TEXT;
            break;
        case LANGUAGE_TH:
            languageText = LANGUAGE_TH_TEXT;
            break;
    }
	
	path = [[NSBundle mainBundle] pathForResource:languageText ofType:@"lproj" ];
	bundle = [NSBundle bundleWithPath:path];
}

//-------------------------------------------------------------------------------
+ (int)getCurrentLanguage {
    return currentLanguage;
}


//-------------------------------------------------------------------------------
+ (NSString *)getText:(NSString *)key{
	NSString *text;
	if (bundle == nil) { // Auto
		text = [[NSBundle mainBundle] localizedStringForKey:key value:@"getText bug" table:nil];
	} else {
		text = [bundle localizedStringForKey:key value:@"getText bug" table:nil];
	}

	if (text == nil) { // defaultText is nil or key not exist
		text = [NSString stringWithFormat:@"[%@]", key];
	}
	return text;
}


//-------------------------------------------------------------------------------
+ (int)getDefaultLanguage 
{
    // get the current language and country config
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString* languageCode = [languages objectAtIndex:0];
    //    NSString *currentLanguage = [languages objectAtIndex:0];
    //
    //    // get the current language code.(such as English is "en", Chinese is "zh" and so on)
    //    NSDictionary* temp = [NSLocale componentsFromLocaleIdentifier:currentLanguage];
    //    NSString * languageCode = [temp objectForKey:NSLocaleLanguageCode];
    
    int langType = LANGUAGE_EN;
    if ([languageCode hasPrefix:@"zh-Hans"])
    {
        langType = LANGUAGE_ZHCN;
    }
    else if ([languageCode hasPrefix:@"en"])
    {
        langType = LANGUAGE_EN;
    }
    else if ([languageCode hasPrefix:@"zh-Hant"])
    {
        if ([languageCode isEqualToString:@"zh-Hant-HK"] || [languageCode isEqualToString:@"zh-Hant-MO"]) {
            langType = LANGUAGE_ZHHK;
        } else {
            langType = LANGUAGE_ZHTW;
        }
    }
    else if ([languageCode hasPrefix:@"ja"])
    {
        langType = LANGUAGE_JA;
    }
    else if ([languageCode hasPrefix:@"th"])
    {
        langType = LANGUAGE_TH;
    }
    return langType;
}

+ (void)setLocalLanguage:(int)langType
{
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    if (preferences == nil) {
        return;
    }
    [preferences setObject:[[NSNumber alloc] initWithInt:langType] forKey:KEY_LANG];
    [preferences synchronize];
    
    [Language setLanguage:langType];
}
@end
