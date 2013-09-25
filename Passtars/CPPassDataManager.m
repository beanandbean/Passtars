//
//  CPPassDataManager.m
//  Passtars
//
//  Created by wangyw on 6/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassDataManager.h"

#import "CPHelperMacros.h"
#import "CPPasstarsConfig.h"

#import "CPMemo.h"
#import "CPPassword.h"

//#define AUTO_ADD_NEW_MEMOS

static NSString *const PASSWORD_CACHE_NAME = @"PasswordCache";

@interface CPPassDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPPassDataManager

static CPPassDataManager *defaultManager = nil;

+ (CPPassDataManager *)defaultManager {
    if (!defaultManager) {
        defaultManager = [[CPPassDataManager alloc] init];
        
#ifdef AUTO_ADD_NEW_MEMOS
        for (NSUInteger index = 0; index < MAX_PASSWORD_COUNT; index++) {
            [defaultManager newMemoText:@"Hello" inIndex:index];
        }
#endif
        
    }
    return defaultManager;
}

- (NSFetchedResultsController *)passwordsController {
    if (!_passwordsController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Password" inManagedObjectContext:self.managedObjectContext];
        request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES], nil];
        _passwordsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:PASSWORD_CACHE_NAME];
        [_passwordsController performFetch:nil];
        
        if (!_passwordsController.fetchedObjects.count) {
            for (NSUInteger index = 0; index < MAX_PASSWORD_COUNT; index++) {
                CPPassword *password = [NSEntityDescription insertNewObjectForEntityForName:@"Password" inManagedObjectContext:self.managedObjectContext];
                password.index = [NSNumber numberWithUnsignedInteger:index];
                /* debug code, remove later */
                password.isUsed = [NSNumber numberWithBool:index % 2 ? YES : NO];
                password.text = @"";
                password.colorIndex = [NSNumber numberWithInt:index];
                password.icon = CSTR_TO_OBJC(PASSWORD_ICON_NAMES[index]);
            }
            [_passwordsController performFetch:nil];
        }
    }
    return _passwordsController;
}

- (void)setPasswordText:(NSString *)text atIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert1(password, @"No password corresponding to password index %d!", (int)index);
    
    if ([text isEqualToString:@""]) {
        if (password.isUsed.boolValue) {
            [self toggleRemoveStateOfPasswordAtIndex:password.index.integerValue];
        }
    } else {
        if (!password.isUsed.boolValue) {
            for (CPMemo *memo in password.memos) {
                [self.managedObjectContext deleteObject:memo];
            }
            [password removeMemos:password.memos];
        }
        password.text = text;
        password.isUsed = [NSNumber numberWithBool:YES];
    }
    
    [self saveContext];
}

- (CPMemo *)newMemoText:(NSString *)text inIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert1(password, @"No password corresponding to password index %d!", (int)index);
    
    CPMemo *memo = [NSEntityDescription insertNewObjectForEntityForName:@"Memo" inManagedObjectContext:self.managedObjectContext];
    memo.text = text;
    memo.password = password;
    [password addMemosObject:memo];
    
    [self saveContext];
    return memo;
}

- (void)removeMemo:(CPMemo *)memo {
    [memo.password removeMemosObject:memo];
    [self.managedObjectContext deleteObject:memo];
    [self saveContext];
}

- (BOOL)canToggleRemoveStateOfPasswordAtIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert1(password, @"No password corresponding to password index %d!", (int)index);
    
    return ![password.text isEqualToString:@""];
}

- (void)toggleRemoveStateOfPasswordAtIndex:(NSUInteger)index {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index];
    NSAssert1(password, @"No password corresponding to password index %d!", (int)index);
    
    if (![password.text isEqualToString:@""]) {
        password.isUsed = [NSNumber numberWithBool:!password.isUsed.boolValue];
        [self saveContext];
    }
}

- (void)exchangePasswordBetweenIndex1:(NSUInteger)index1 andIndex2:(NSUInteger)index2 {
    CPPassword *password = [self.passwordsController.fetchedObjects objectAtIndex:index1];
    password.index = [NSNumber numberWithUnsignedInteger:index2];
    password = [self.passwordsController.fetchedObjects objectAtIndex:index2];
    password.index = [NSNumber numberWithUnsignedInteger:index1];
    [self saveContext];
}

- (NSArray *)memosContainText:(NSString *)text {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Memo" inManagedObjectContext:self.managedObjectContext]];
    
    if (text && ![text isEqualToString:@""]) {
        request.predicate = [NSPredicate predicateWithFormat:@"password.isUsed = YES && text contains %@", text];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"password.isUsed = YES", text];
    }
    request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"text" ascending:YES], nil];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             TODO: MAY ABORT! Handle the error appropriately when saving context.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Passtars" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Passtars.sqlite"];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            /*
             TODO: MAY ABORT! Handle the error appropriately when initializing persistent store coordinator.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

@end
