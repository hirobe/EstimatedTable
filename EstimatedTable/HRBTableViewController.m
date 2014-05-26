//
//  HRBViewController.m
//  EstimatedTable
//
//  Created by Hirobe Kazuya on 5/26/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import "HRBTableViewController.h"

@interface HRBTableViewController ()
@end

@implementation HRBTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.estimatedRowHeight = 44.0f;
    
}

- (void)reloadButtonTapped:(id)sender {
    [self reloadTable];
}

/*
 UITableViewにestimatedRowHeightを指定してreloadDataを呼ぶと、セルのスクロール位置がおかしな位置にジャンプしてしまいます。これを補正します。
 
 何をやっているか：
 reloadDataをすると、現在表示中のセルと、その1つ上のセルについてtableView:heightForRowAtIndexPath:が呼ばれ、それ以外のセルはestimatedRowHeightの高さが使われるようです（推測）。reloadData前に正確な高さを取得していたセルについてもリセットされてestimatedRowHeightを使うようになるため、reloadData前と後でセルのy座標が変化してしまいます。そこで、reloadDataの直前のセルのy座標に合わせてestimatedRowHeightの値を調整します。これにより表示中のセルのy座標は変化しないことになります。
 
 注意事項：
 - 調査時点のiOS(iOS7.1.1)の動作に強く依存しているので、iOSのバージョンがあがると正しく動作しなくなる可能性があります。
 - セクションヘッダとフッタは一応計算していますが、未検証です。ヘッダ、フッタを使う人はテストしてね。
 - estimatedRowHeightと似たメソッドであるtableView:estimatedHeightForRowAtIndexPath:には仕組み上非対応です。がんばればできる？
 */

// fix : UITableView using estimatedRowHeight jump the scroll position at reloadData.
-(void)reloadTable {
    // このメソッドは、UITableViewControllerに、高さの異なる複数のセルが表示されている前提です。
    // UITableViewでもたぶん動作します。
    
    if (!self.tableView.estimatedRowHeight ||
        ([[self.tableView indexPathsForVisibleRows] count] <=1))
    {
        [self.tableView reloadData];
        return;
    }
    
    // visibleRowsの1つ前のcellからheightForRowAtIndexPathが呼ばれるので、1つ前のindexPathを取得。
    NSIndexPath *path0 = [self.tableView indexPathsForVisibleRows][0];
    if (path0.section == 0 && path0.row == 0) {
        [self.tableView reloadData];
        return;
    }
    NSIndexPath *calculateStartPath = (path0.row ==0) ? [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:path0.section-1]-1 inSection:path0.section] : [NSIndexPath indexPathForRow:path0.row-1 inSection:path0.section];
    
    // estimateで数えられる(画面外上方向にある)セルの数を数える
    long cellCount = calculateStartPath.row;
    for (int section=0; section < calculateStartPath.section; section++) {
        cellCount += [self.tableView numberOfRowsInSection:section];
    }

    if (cellCount <= 0) { //estimateされるセルが無いなら位置調整不要。reloadして終了
        [self.tableView reloadData];
        return;
    }
    
    // セクションヘッダ、セクションフッダのサイズを計算。
    // estimatedSectionHeaderHeight,estimatedSectionFooterHeightは使われないっぽい
    CGFloat headerHeights = 0.0f;
    CGFloat footerHeights = 0.0f;
    for (int section=0;section <= calculateStartPath.section;section++) {
        headerHeights += [self.tableView.delegate tableView:self.tableView heightForHeaderInSection:section];
    }
    for (int section=0;section < calculateStartPath.section;section++) {
        footerHeights += [self.tableView.delegate tableView:self.tableView heightForFooterInSection:section];
    }

    // estimatedRowHeightを、現在のセルのy位置に合うように調整する
    CGRect rect = [self.tableView rectForRowAtIndexPath:calculateStartPath];
    self.tableView.estimatedRowHeight = (rect.origin.y - headerHeights - footerHeights - self.tableView.tableHeaderView.bounds.size.height ) / cellCount ;
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section*10+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // heightを計算
    CGFloat height = (indexPath.row % 4 * 30.0f) + 60.0f;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"section:%ld",(long)section];
}

- (IBAction)reloadTunedTapped:(id)sender {
    [self reloadTable];
}

- (IBAction)reloadDefaultTapped:(id)sender {
    [self.tableView reloadData];
}
@end
