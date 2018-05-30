//
//  ViewController.m
//  nodataShow
//
//  Created by apple on 2018/5/30.
//  Copyright © 2018年 anlong. All rights reserved.
//

#import "ViewController.h"
#import "ALExceptionView.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)NSMutableArray *datas;
@property(nonatomic, strong)UITableView *mainTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"无数据/无网络";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"有/无数据" style:(UIBarButtonItemStylePlain) target:self action:@selector(noDatas)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"无网络" style:(UIBarButtonItemStylePlain) target:self action:@selector(neterror)];
    
    
    [self.view addSubview:self.mainTableView];
    
}
-(void)noDatas{
    if (self.datas.count) [self.datas removeAllObjects];
    else [self.datas addObjectsFromArray:@[@"蛮族之王",@"诺克萨斯之手",@"德玛西亚皇子"]];
    [self.mainTableView reloadData];
}
-(void)neterror{
    [self.mainTableView al_networkError];
}
#pragma mark -- uitableview delegate --
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}
-(NSMutableArray *)datas{
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64)];
        _mainTableView.dataSource = self;
        _mainTableView.dataSource = self;
        ALExceptionView *exceptionView = [_mainTableView al_insertExceptionView];
        //自定义显示文字和图片（无需自定义 默认里设置即可）
        [exceptionView setExplain:@"nothing" forMode:ALExceptionViewModeNoData];
        [exceptionView setImage:[UIImage imageNamed:@"list_nodata"] forMode:ALExceptionViewModeNoData];
        exceptionView.update = ^{
            NSLog(@"点击处理");
        };
    }
    return _mainTableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
