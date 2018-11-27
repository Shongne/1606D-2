//
//  pictureViewController.m
//  1606D项目
//
//  Created by shy 佳佳 on 2018/9/28.
//  Copyright © 2018 zhangjiliang. All rights reserved.
//

#import "pictureViewController.h"
#import "VideoTableViewCell.h"
#import "PictureModel.h"
#import "pictureXQViewController.h"
@interface pictureViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableview;
@property(nonatomic,strong) NSMutableArray *datasource;
@end

@implementation pictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数据源
    self.datasource=[NSMutableArray new];
    
    [self.view addSubview:self.tableview];
    
    //加载数据
    [self loaddata];
    //添加刷新方法
    [self addfooterrefresh];
    [self addheaderrefresh];
}

-(void)loaddata{
    //显示加载栏
    [SVProgressHUD showWithStatus:@"加载中..."];
    //创建网络请求
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //设置默认请求类型（NSData）
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //数据请求
    [manager GET:PICTURE_PATH parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //解析数据
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:responseObject options:1 error:nil];
        
        for (NSDictionary *dicc in arr) {
            //封装model,建立数据模型
            PictureModel *model=[[PictureModel alloc]init];
            [model setValuesForKeysWithDictionary:dicc];
            [self.datasource addObject:model];
        }
        
        [self.tableview reloadData];
        //取消刷新控件
        [self.tableview.mj_header endRefreshing];
        [self.tableview.mj_footer endRefreshing];
        //去掉加载栏
        [SVProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //提示用户
        //取消刷新控件
        [self.tableview.mj_header endRefreshing];
        [self.tableview.mj_footer endRefreshing];
        //去掉加载栏
        [SVProgressHUD dismiss];
    }];
    
}
#pragma mark - 添加头部刷新
-(void)addheaderrefresh{
    MJRefreshGifHeader *header=[MJRefreshGifHeader headerWithRefreshingBlock:^{
        //刷新的回调
        //重置页数
        // self.page=1;
        //清空数据源
        [self.datasource removeAllObjects];
        //重新发送网络请求
        // [self setmyurl];
        [self loaddata];
    }];
    NSArray * imageArr = @[[UIImage imageNamed:@"common_loading_anne_0"],[UIImage imageNamed:@"common_loading_anne_1"]];
    //添加正在刷新中的状态
    [header setImages:imageArr forState:MJRefreshStateRefreshing];
    //闲置状态
    [header setImages:@[[UIImage imageNamed:@"common_loading_anne_0"]] forState:MJRefreshStateIdle];
    //文字
    [header setTitle:@"马上完成..." forState:MJRefreshStateRefreshing];
    self.tableview.mj_header=header;
    
}

#pragma mark - 上拉加载
-(void)addfooterrefresh{
    MJRefreshAutoGifFooter *footer=[MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
        //页面增加
        // self.page++;
        //重新请求数据
        //[self setmyurl];
        [self loaddata];
    }];
    NSArray * imageArr = @[[UIImage imageNamed:@"common_loading_anne_0"],[UIImage imageNamed:@"common_loading_anne_1"]];
    [footer setImages:imageArr forState:MJRefreshStateRefreshing];
    self.tableview.mj_footer=footer;
}



#pragma mark--表格
-(UITableView *)tableview {
    
    if(!_tableview) {
        
        _tableview = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        
        _tableview.delegate =self;
        
        _tableview.dataSource =self;
        
         [_tableview registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
    
    return _tableview;
    
}
#pragma mark--数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (self.datasource.count>0) {
        PictureModel *model=_datasource[indexPath.row];
        
        [cell.coverImgV sd_setImageWithURL:[NSURL URLWithString:model.clientcover1]];
        cell.titleLabel.text = model.setname;
        cell.lengthLabel.text = [NSString stringWithFormat:@" %@图",model.imgsum];
        cell.replyCountLabel.text =[NSString stringWithFormat:@"%@评论",model.replynum];
    }
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //跳转详情
    pictureXQViewController *detail=[[pictureXQViewController alloc] init];
    //传值 block
    
    PictureModel *model=self.datasource[indexPath.row];
    detail.model=model;
    
    //隐藏标签栏控制器
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
    
}
@end
