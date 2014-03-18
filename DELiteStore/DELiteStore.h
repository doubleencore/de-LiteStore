//
//  DELiteStore.h
//  DELiteStore
//
//  Created by Brad Dillon on 3/15/14.
//  Copyright (c) 2014 Double Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const DELiteStoreDidChangeNotification;

@interface DELiteStore : NSObject

+ (instancetype)storeWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (NSArray *)stringArrayForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSURL *)URLForKey:(NSString *)key;

- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)setURL:(NSURL *)url forKey:(NSString *)key;

- (NSDictionary *)dictionaryRepresentation;

- (BOOL)synchronize;

@end
