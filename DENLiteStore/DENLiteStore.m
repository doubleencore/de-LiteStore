//
//  DELiteStore.m
//  DELiteStore
//
//  Created by Brad Dillon on 3/15/14.
//  Copyright (c) 2014 Double Encore. All rights reserved.
//

#import "DENLiteStore.h"

NSString *const DELiteStoreDidChangeNotification = @"DELiteStoreDidChangeNotification";

static dispatch_queue_t _classQueue = nil;
static NSMapTable *_liteStores = nil;

@interface DENLiteStore ()

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *storePath;
@property (nonatomic, strong, readonly) NSMutableDictionary *store;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@end


@implementation DENLiteStore

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _classQueue = dispatch_queue_create("com.doubleencore.litestore.class", NULL);
        _liteStores = [NSMapTable strongToWeakObjectsMapTable];
    });
}


+ (instancetype)storeWithName:(NSString *)name
{
    return [self storeWithName:name path:nil];
}


+ (instancetype)storeWithName:(NSString *)name path:(NSString *)path
{
    __block id store = nil;
    
    dispatch_sync(_classQueue, ^{
        store = [_liteStores objectForKey:name];
        
        if (!store) {
            store = [[self alloc] initWithName:name path:path];
            [_liteStores setObject:store forKey:name];
        }
    });
    
    return store;
}


- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name path:nil];
}


- (instancetype)initWithName:(NSString *)name path:(NSString *)path
{
    if (self = [super init]) {
        _name = name;
        
        if (path.length > 0) {
            _storePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.litestore", name]];
        }
        else {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            _storePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.litestore", name]];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_storePath]) {
            _store = [NSMutableDictionary dictionaryWithContentsOfFile:_storePath];
        }
        else {
            _store = [NSMutableDictionary new];
        }
        
        NSString *queueName = [NSString stringWithFormat:@"com.doubleencore.litestore.%@", name];
        _queue = dispatch_queue_create([queueName UTF8String], NULL);
    }
    
    return self;
}


- (NSDictionary *)dictionaryRepresentation
{
    __block NSDictionary *output = nil;
    dispatch_sync(_queue, ^{
        output = [_store copy];
    });
    
    return output;
}


- (BOOL)synchronize
{
    __block BOOL success;
    dispatch_sync(_queue, ^{
        success = [_store writeToFile:_storePath atomically:YES];
    });
    
    return success;
}


- (void)notify
{
    // NOTICE: Notification is posted on whichever thread the object is set from.
    NSNotification *n = [NSNotification notificationWithName:DELiteStoreDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}


- (id)objectForKey:(NSString *)key
{
    __block id object = nil;
    dispatch_sync(_queue, ^{
        object = _store[key];
    });
    
    return object;
}


- (void)setObject:(id)value forKey:(NSString *)key
{
    dispatch_sync(_queue, ^{
        _store[key] = value;
    });
    
    [self synchronize];
    [self notify];
}


- (void)removeObjectForKey:(NSString *)key
{
    dispatch_sync(_queue, ^{
        [_store removeObjectForKey:key];
    });
    
    [self synchronize];
    [self notify];
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
