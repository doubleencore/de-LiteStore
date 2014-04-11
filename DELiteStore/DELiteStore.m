//
//  DELiteStore.m
//  DELiteStore
//
//  Created by Brad Dillon on 3/15/14.
//  Copyright (c) 2014 Double Encore. All rights reserved.
//

#import "DELiteStore.h"

NSString *const DELiteStoreDidChangeNotification = @"DELiteStoreDidChangeNotification";

static dispatch_queue_t _queue = nil;

@interface DELiteStore ()

@property (nonatomic, strong, readonly) NSString *storePath;
@property (nonatomic, strong, readonly) NSMutableDictionary *store;

@end


@implementation DELiteStore

+ (instancetype)storeWithName:(NSString *)name
{
    return [[self alloc] initWithName:name];
}


- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _storePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_storePath]) {
            _store = [NSMutableDictionary dictionaryWithContentsOfFile:_storePath];
        }
        else {
            _store = [NSMutableDictionary new];
        }
    }
    
    return self;
}


- (NSDictionary *)dictionaryRepresentation
{
    return [_store copy];
}


- (BOOL)synchronize
{
    if (!_queue) {
        _queue = dispatch_queue_create("com.doubleencore.litestore", NULL);
    }

    __block BOOL success;
    dispatch_sync(_queue, ^{
        success = [_store writeToFile:_storePath atomically:YES];
    });
    
    return success;
}


- (id)objectForKey:(NSString *)key
{
    return _store[key];
}


- (void)setObject:(id)value forKey:(NSString *)key
{
    _store[key] = value;
    
    [self synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DELiteStoreDidChangeNotification object:self];
}


- (void)removeObjectForKey:(NSString *)key
{
    _store[key] = nil;
    
    [self synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DELiteStoreDidChangeNotification object:self];
}


- (NSString *)stringForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    else if ([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }
    
    return nil;
}


- (NSArray *)arrayForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSArray class]]) {
        return object;
    }
    
    return nil;
}


- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        return object;
    }
    
    return nil;
}


- (NSData *)dataForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSData class]]) {
        return object;
    }
    
    return nil;
}


- (NSArray *)stringArrayForKey:(NSString *)key
{
    NSArray *array = [self arrayForKey:key];
    
    if (!array) {
        return nil;
    }
    
    for (id object in array) {
        if (![object isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    
    return array;
}


- (NSInteger)integerForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object respondsToSelector:@selector(integerValue)]) {
        return [object integerValue];
    }
    
    return 0;
}


- (float)floatForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object respondsToSelector:@selector(floatValue)]) {
        return [object floatValue];
    }
    
    return 0;
}


- (double)doubleForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object respondsToSelector:@selector(doubleValue)]) {
        return [object doubleValue];
    }
    
    return 0;
}


- (BOOL)boolForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object respondsToSelector:@selector(boolValue)]) {
        return [object boolValue];
    }
    
    return NO;
}


- (NSURL *)URLForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSURL class]]) {
        return object;
    }
    else if ([object isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:object];
    }
    else if ([object isKindOfClass:[NSData class]]) {
        id unarchived = [NSKeyedUnarchiver unarchiveObjectWithData:object];
        if ([unarchived isKindOfClass:[NSURL class]]) {
            return unarchived;
        }
    }
    
    return nil;
}


- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}


- (void)setFloat:(float)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}


- (void)setDouble:(double)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}


- (void)setBool:(BOOL)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}


- (void)setURL:(NSURL *)url forKey:(NSString *)key
{
    [self setObject:[url absoluteString] forKey:key];
}



@end
