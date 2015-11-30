//
//  RNQuiltView.m
//  RNQuiltView
//
//  Created by linyize on 26.11.15.
//  Copyright (c) 2015 mmslate. All rights reserved.
//

#import "RNQuiltView.h"

#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"
#import "UIView+React.h"
#import "JSONDataSource.h"
#import "RNCellView.h"
#import "RFQuiltLayout.h"
#import "RNCellModel.h"

#define HIDDENFLAG 4

@interface RNQuiltView()<UICollectionViewDataSource, UICollectionViewDelegate, RFQuiltLayoutDelegate>
{
    id<RNQuiltViewDatasource> datasource;
}
@property (strong, nonatomic) NSMutableArray *selectedIndexes;
@property (strong, nonatomic) UICollectionView *collectionView;

// 组件的像素信息
@property (nonatomic, strong) RNCellModel *cellInfo;

@end

@implementation RNQuiltView
{
    RCTEventDispatcher *_eventDispatcher;
    NSMutableArray *_cells;

}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
    RCTAssertParam(eventDispatcher);
    
    if ((self = [super initWithFrame:CGRectZero])) {
        _eventDispatcher = eventDispatcher;
        _cellHeight = 44;
        _cells = [NSMutableArray array];
        _autoFocus = YES;
        
        
        [self getScreenState:self.bounds.size];
    }
    return self;
}


// 获得所有section的数据
- (void)setSections:(NSArray *)sections
{
    _sections = [NSMutableArray arrayWithCapacity:[sections count]];
    
    for (NSDictionary *section in sections){
        NSMutableDictionary *sectionData = [NSMutableDictionary dictionaryWithDictionary:section];
        
        
        NSMutableArray *allItems = [NSMutableArray array];
        if (self.additionalItems){
            [allItems addObjectsFromArray:self.additionalItems];
        }
        [allItems addObjectsFromArray:sectionData[@"items"]];
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:[allItems count]];
        

        for (NSDictionary *item in allItems){
            NSMutableDictionary *itemData = [NSMutableDictionary dictionaryWithDictionary:item];
            
     
            [items addObject:itemData];
        }
 
        
        sectionData[@"items"] = items;
        [_sections addObject:sectionData];
    }
    [self.collectionView reloadData];
}


- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    if ([subview isKindOfClass:[RNCellView class]]){
        
        RNCellView *cellView = (RNCellView *)subview;
        cellView.collectionView = self.collectionView;
        
        while (cellView.section >= [_cells count]){
            [_cells addObject:[NSMutableArray array]];
        }
        [_cells[cellView.section] addObject:subview];
        
        if (cellView.section == [_sections count]-1 && cellView.row == [_sections[cellView.section][@"count"] integerValue]-1){
            [self.collectionView reloadData];
        }
    }
    
    // TODO: 通过组件名 判断组件类型
//    else if ([subview isKindOfClass:[RNTableFooterView class]]){
//        RNTableFooterView *footerView = (RNTableFooterView *)subview;
//        footerView.tableView = self.tableView;
//    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_collectionView setFrame:self.bounds];
    
    // 如果外部设置了值就不在自动计算
    if (!(self.pixelHeight || self.pixelWidth)) {
        [self getScreenState:self.bounds.size];
    }
    
}


#pragma mark - lazy load

-(UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        RFQuiltLayout *layout = [RFQuiltLayout new];
        layout.direction = UICollectionViewScrollDirectionVertical;
        layout.delegate = self;
        // item像素
        layout.blockPixels = CGSizeMake(self.cellInfo.pixelWidth, self.cellInfo.pixelHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        // 注册重用
        [_collectionView registerClass:[RNQuiltViewCell class] forCellWithReuseIdentifier:@"quiltCell"];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (RNCellModel *)cellInfo
{
    if(_cellInfo == nil)
    {
        _cellInfo = [RNCellModel new];
    }
    return _cellInfo;
}


-(void)setPixelWidth:(CGFloat)pixelWidth
{
    _pixelWidth = pixelWidth;
    
    RFQuiltLayout *layout = (RFQuiltLayout *)self.collectionView.collectionViewLayout;
    layout.blockPixels = CGSizeMake(pixelWidth, layout.blockPixels.height);
}

-(void)setPixelHeight:(CGFloat)pixelHeight
{
    pixelHeight = pixelHeight;
    
    RFQuiltLayout *layout = (RFQuiltLayout *)self.collectionView.collectionViewLayout;
    layout.blockPixels = CGSizeMake(layout.blockPixels.width, pixelHeight);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return [_sections[section][@"items"] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 当前jsx传输过来的view
    RNCellView *cellView = _cells[indexPath.section][indexPath.row];
    RNQuiltViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"quiltCell" forIndexPath:indexPath];
    
    cell.cellView = cellView;
    
    cell.backgroundColor = [self colorForNumber:@(indexPath.item)];

    return cell;
}

#pragma mark - RFQuiltLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath // defaults to 1x1
{
    NSDictionary *item = [self dataForRow:indexPath.item section:indexPath.section];
    return CGSizeMake([[item objectForKey:@"widthRatio"] floatValue], [[item objectForKey:@"heightRatio"] floatValue]);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetsForItemAtIndexPath:(NSIndexPath *)indexPath // defaults to uiedgeinsetszero
{
    // 默认有边距, 这里设置的数值,会在cell 的frame 中减掉
    return UIEdgeInsetsMake(10, 4, 0, 4);
}

/* 判断当前屏幕状态,并设定单元cell */
- (void)getScreenState:(CGSize)size
{
    switch ((int)size.width) {
        case 1366:
            [self.cellInfo updateCellWithTag:ScreenSize_1366];
            break;
        case 981:
            [self.cellInfo updateCellWithTag:ScreenSize_981];
            break;
        case 768:
            [self.cellInfo updateCellWithTag:ScreenSize_768];
            break;
        case 694:
            [self.cellInfo updateCellWithTag:ScreenSize_694];
            break;
        case 678:
            [self.cellInfo updateCellWithTag:ScreenSize_678];
            break;
        case 639:
            [self.cellInfo updateCellWithTag:ScreenSize_639];
            break;
        case 507:
            [self.cellInfo updateCellWithTag:ScreenSize_507];
            break;
        case 438:
            [self.cellInfo updateCellWithTag:ScreenSize_438];
            break;
        case 375:
            [self.cellInfo updateCellWithTag:ScreenSize_375];
            break;
        case 320:
            [self.cellInfo updateCellWithTag:ScreenSize_320];
            break;
        default:    // 默认pro 竖屏 1024宽
            [self.cellInfo updateCellWithTag:ScreenSize_1024];
            break;
    }
    
    
    // 修改布局属性
    RFQuiltLayout* layout = (RFQuiltLayout *)self.collectionView.collectionViewLayout;
    
    layout.blockPixels = CGSizeMake(self.cellInfo.pixelWidth, self.cellInfo.pixelHeight);
}

#pragma mark - Private APIs

/* 随机颜色 */
- (UIColor*)colorForNumber:(NSNumber*)num
{
    return [UIColor colorWithHue:((19 * num.intValue) % 255)/255.f saturation:1.f brightness:1.f alpha:1.f];
}

- (NSDictionary *)dataForRow:(NSInteger)row section:(NSInteger)section
{
    return (NSDictionary *)_sections[section][@"items"][row];
}

- (BOOL)hasCustomCells:(NSInteger)section
{
    return [[_sections[section] valueForKey:@"customCells"] boolValue];
}


RCT_NOT_IMPLEMENTED(-initWithFrame:(CGRect)frame)
RCT_NOT_IMPLEMENTED(-initWithCoder:(NSCoder *)aDecoder)


@end
