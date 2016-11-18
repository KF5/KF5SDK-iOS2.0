//
//  KFDocObject.m
//  Pods
//
//  Created by admin on 15/12/14.
//
//

#import "KFDocItem.h"

#import "KFHelper.h"

@implementation KFDocItem

+ (instancetype)docItemForDict:(NSDictionary *)dict{
    KFDocItem *docItem = [[KFDocItem alloc]init];
    docItem.content = [dict kf5_stringForKeyPath:@"content"];
    docItem.Id = [dict kf5_numberForKeyPath:@"id"].integerValue;
    docItem.title = [dict kf5_stringForKeyPath:@"title"];
    return docItem;
}

+ (NSMutableArray<KFDocItem *> *)docItemsWithDictArray:(NSArray<NSDictionary *> *)dictArray{
    NSMutableArray *docItems = [NSMutableArray arrayWithCapacity:dictArray.count];
    for (NSDictionary *dict in dictArray) {
        KFDocItem *object = [KFDocItem docItemForDict:dict];
        [docItems addObject:object];
    }
    return docItems;
}

@end
