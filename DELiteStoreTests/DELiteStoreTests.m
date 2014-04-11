//
//  DELiteStoreTests.m
//  DELiteStoreTests
//
//  Created by Brad Dillon on 3/17/14.
//  Copyright (c) 2014 Double Encore. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DELiteStore.h"

@interface DELiteStoreTests : XCTestCase

@property (nonatomic, strong) DELiteStore *store;
@property (nonatomic) BOOL receivedNotification;

@end

@implementation DELiteStoreTests

- (void)setUp
{
    [super setUp];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    for (NSString *filename in contents) {
        if ([filename rangeOfString:@"litestore"].location != NSNotFound) {
            [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:filename] error:nil];
        }
    }
    
    NSInteger i = arc4random();
    self.store = [DELiteStore storeWithName:[NSString stringWithFormat:@"store-%d", i]];
}


- (void)tearDown
{
    [super tearDown];
    
}


- (void)testInitialize
{
    XCTAssertNotNil(self.store, @"Initialization shouldn't really ever fail");
}


- (void)testInitializeMultipleStores
{
    DELiteStore *store2 = [DELiteStore storeWithName:@"store2"];

    XCTAssertNotEqualObjects(self.store, store2, @"Two stores with different names should never be the same");
}


- (void)testInitializeIdenticalStores
{
    NSString *name = [self.store name];
    DELiteStore *secondStore = [DELiteStore storeWithName:name];
    
    XCTAssertEqual(self.store, secondStore, @"Two stores with the same name should be the same object");
}


- (void)testSetObject
{
    NSString *object = @"Hello World";
    NSString *key = @"test";
    
    XCTAssertNil([self.store objectForKey:key], @"The store shouldn't contain an object for this key yet. This is likely an error in the test environment");
    
    [self.store setObject:object forKey:key];
    
    XCTAssertEqualObjects([self.store objectForKey:key], object, @"The store should now contain '%@'", object);
}


- (void)testRemoveObject
{
    NSString *object = @"Hello World";
    NSString *key = @"test";
    
    [self.store setObject:object forKey:key];
    
    XCTAssertEqualObjects([self.store objectForKey:key], object, @"The store should now contain '%@'", object);
    
    [self.store removeObjectForKey:key];
    
    XCTAssertNil([self.store objectForKey:key], @"The store should no longer contain '%@'", object);
}


- (void)testFileIntegrity
{
    NSDictionary *dict = @{ @"foo" : @"bar", @"hello" : @"world", @"number" : @1 };
    
    for (NSString *key in dict) {
        [self.store setObject:dict[key] forKey:key];
    }
    
    NSString *name = [self.store name];
    NSString *fileName = [name stringByAppendingPathExtension:@"litestore"];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
    NSDictionary *testDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    BOOL equal = [dict isEqualToDictionary:testDict];
    XCTAssertTrue(equal, @"The file on disk should be equal to the model dictionary");
}


- (void)testSetObjectWithMultipleStores
{
    DELiteStore *store2 = [DELiteStore storeWithName:@"store2"];
    NSString *object = @"Hello World";
    NSString *key = @"test";
    
    [self.store setObject:object forKey:key];
    
    XCTAssertEqualObjects([self.store objectForKey:key], object, @"The store should now contain '%@'", object);
    XCTAssertNil([store2 objectForKey:key], @"The second store should not contain anything");
}


#pragma mark - Type Tests


- (void)testStringForKey
{
    [self.store setObject:@"String" forKey:@"Foo"];
    
    XCTAssertEqualObjects([self.store stringForKey:@"Foo"], @"String", @"stringForKey should return an equal string");
}


- (void)testInvalidStringForKey
{
    [self.store setObject:@[@NO] forKey:@"Foo"];
    
    XCTAssertNil([self.store stringForKey:@"Foo"], @"stringForKey should return nil of the requested object is not a string or does not respond to -stringValue.");
}


- (void)testArrayForKey
{
    NSArray *array = @[@1, @YES, @"Foo"];
    NSString *key = @"array";
    
    [self.store setObject:array forKey:key];
    
    XCTAssertEqualObjects([self.store arrayForKey:key], array, @"arrayForKey should return an equal array");
}


- (void)testInvalidArrayForKey
{
    [self.store setObject:@"Bar" forKey:@"Foo"];
    
    XCTAssertNil([self.store arrayForKey:@"Foo"], @"arrayForKey should return nil if the requested object is not an array");
}


- (void)testDictionaryForKey
{
    NSDictionary *dict = @{ @"foo" : @"bar", @"hello" : @"world", @"number" : @1 };
    
    [self.store setObject:dict forKey:@"dict"];
    
    BOOL equal = [dict isEqualToDictionary:[self.store dictionaryForKey:@"dict"]];
    XCTAssertTrue(equal, @"dictionaryForKey should return an equal dictionary");
}


- (void)testInvalidDictionaryForKey
{
    [self.store setObject:@NO forKey:@"dict"];
    
    XCTAssertNil([self.store dictionaryForKey:@"dict"], @"dictionaryForKey should return nil if the requested object is not a dictionary");
}


- (void)testDataForKey
{
    
}


- (void)testInvalidDataForKey
{
    
}


- (void)testStringArrayForKey
{
    
}


- (void)testInvalidStringArrayForKey
{
    
}


- (void)testIntegerForKey
{
    
}


- (void)testInvalidIntegerForKey
{
    
}


- (void)testFloatForKey
{
    
}


- (void)testInvalidFloatForKey
{
    
}


- (void)testDoubleForKey
{
    
}


- (void)testInvalidDoubleForKey
{
    
}


- (void)testBoolForKey
{
    
}


- (void)testInvalidBoolForKey
{
    
}


- (void)testURLForKey
{
    
}


- (void)testInvalidURLForKey
{
    
}


- (void)testDictionaryRepresentation
{
    
}


#pragma mark - Dependency Tests


- (void)testNotification
{
    DELiteStore *storeToListenTo = [DELiteStore storeWithName:@"Listen"];
    DELiteStore *storeToIgnore = [DELiteStore storeWithName:@"Ignore"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:DELiteStoreDidChangeNotification object:storeToListenTo];
    
    [storeToIgnore setObject:@"Oops" forKey:@"Wrong"];
    [storeToListenTo setObject:@"Hello World!" forKey:@"Right"];
    
    XCTAssert(self.receivedNotification, @"");
}


- (void)notificationReceived:(NSNotification *)notification
{
    DELiteStore *store = notification.object;
    
    NSString *wrongString = [store stringForKey:@"Wrong"];
    NSString *rightString = [store stringForKey:@"Right"];
    
    self.receivedNotification = (!wrongString && rightString);
}

@end
