//
//  DELiteStore.h
//  DELiteStore
//
//  Created by Brad Dillon on 3/15/14.
//  Copyright (c) 2014 Double Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTICE: Notification is posted on whichever thread the change occurs on.
extern NSString *const DELiteStoreDidChangeNotification;

@interface DENLiteStore : NSObject

+ (instancetype)storeWithName:(NSString *)name;
+ (instancetype)storeWithName:(NSString *)name path:(NSString *)path;

- (NSString *)name;

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
