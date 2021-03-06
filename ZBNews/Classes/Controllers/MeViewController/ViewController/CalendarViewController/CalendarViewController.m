//
//  CalendarViewController.m
//  ZBNews
//
//  Created by NQ UEC on 16/12/2.
//  Copyright © 2016年 Suzhibin. All rights reserved.
//

#import "CalendarViewController.h"
#import "FSCalendar.h"
#import "ZBKit.h"
#import "RACChannelModel.h"

#import "DetailViewController.h"
@interface CalendarViewController ()<UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance>{
    CGFloat height;
}
@property (weak , nonatomic) FSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (nonatomic, strong) NSMutableArray* dataArray;

@property (strong, nonatomic) NSMutableArray *datesWithEvent;
@end

@implementation CalendarViewController
- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.dataArray = [[NSMutableArray alloc] init];
    
    self.datesWithEvent=[[NSMutableArray array]init];
    
    height=390;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0,ZB_STATUS_HEIGHT+44, SCREEN_WIDTH, 300)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;//周一、一
   // calendar.scrollDirection = FSCalendarScrollDirectionVertical;//滚动方向
    [self.view addSubview:calendar];
    self.calendar = calendar;

    [_calendar selectDate:[NSDate date]];
    _calendar.scopeGesture.enabled = YES;
    
    [self.view addSubview:self.tableView];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyyMMdd";
  // NSLog(@"时间 ：%@",[self.dateFormatter stringFromDate:[NSDate date]]);
    NSString *TableName=[NSString stringWithFormat:@"%@%@",Scalendar,[self.dateFormatter stringFromDate:[NSDate date]]];
    SLog(@"表名：%@",TableName);
    NSArray *allData = [[ZBDataBaseManager sharedInstance]getAllDataWithTable:TableName];
    [allData enumerateObjectsUsingBlock:^(ZBDataBaseModel *dbModel, NSUInteger idx, BOOL * _Nonnull stop) {
        //   SLog(@"object:%@",dbModel.object);
        RACChannelModel *model=[[RACChannelModel alloc]initWithDict:dbModel.object];
        [self.dataArray addObject:model];
    }];

    [self.tableView reloadData];
    
 
}

#pragma mark - <FSCalendarDelegate>
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    SLog(@"should select date %@",[self.dateFormatter stringFromDate:date]);
    SLog(@"should  %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
    return YES;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    self.tableView.frame=CGRectMake(0, CGRectGetMaxY(_calendar.frame), self.view.frame.size.width, SCREEN_HEIGHT-CGRectGetMaxY(_calendar.frame));
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
   // NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    NSMutableArray *selectedDates = [NSMutableArray arrayWithCapacity:calendar.selectedDates.count];
    [calendar.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedDates addObject:[self.dateFormatter stringFromDate:obj]];
    }];
   // NSLog(@"selected dates is %@",selectedDates);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    [self.dataArray removeAllObjects];
    NSString *TableName=[NSString stringWithFormat:@"%@%@",Scalendar,[self.dateFormatter stringFromDate:date]];

    SLog(@"表名：%@",TableName);
    NSArray *allData = [[ZBDataBaseManager sharedInstance]getAllDataWithTable:TableName];
    [allData enumerateObjectsUsingBlock:^(ZBDataBaseModel *dbModel, NSUInteger idx, BOOL * _Nonnull stop) {
        //   SLog(@"object:%@",dbModel.object);
        RACChannelModel *model=[[RACChannelModel alloc]initWithDict:dbModel.object];
        [self.dataArray addObject:model];
    }];
    
    [self.tableView reloadData];
    
}
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    SLog(@"%s %@", __FUNCTION__, [self.dateFormatter stringFromDate:calendar.currentPage]);
}
#pragma mark - <FSCalendarDataSource>
/*
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    return 2;
}
 */
#pragma mark - <FSCalendarDelegateAppearance>

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorForDate:(NSDate *)date{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    if ([_datesWithEvent containsObject:dateString]) {
        return [UIColor blackColor];
    }
    return nil;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ChannelBranchCell=@"channelBranchCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ChannelBranchCell];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ChannelBranchCell];
    }
   RACChannelModel *model=self.dataArray[indexPath.row];
    NSString *hitsStr=[NSString stringWithFormat:@"%@次浏览",model.hits];
    cell.textLabel.text=model.title;
    cell.detailTextLabel.text=hitsStr;
    return cell;
}
#pragma mark - <UITableViewDelegate>
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *InfoLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, 30)];
    InfoLabel.textAlignment=NSTextAlignmentCenter;
    NSString *count=[NSString stringWithFormat:@"您今天阅读了%zd条新闻",[self.dataArray count]];
    NSString *lengthStr=[NSString stringWithFormat:@"%zd",[self.dataArray count]];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:count];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:20.0]
                          range:NSMakeRange(6, [lengthStr length])];
    [AttributedStr addAttribute:NSForegroundColorAttributeName
                          value:[UIColor redColor]
                          range:NSMakeRange(6, [lengthStr length])];
    InfoLabel.attributedText = AttributedStr;
    [view addSubview:InfoLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RACChannelModel *model=[self.dataArray objectAtIndex:indexPath.row];
    [self.baseVM pushModel:model controller:self completion:nil];
}
/**
 * 当用户手松开(停止拖拽),就会调用这个代理方法
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    int contentOffsety = scrollView.contentOffset.y;
    if (contentOffsety<30) {
        [self.calendar setScope:FSCalendarScopeMonth animated:YES];
    }else{
        [self.calendar setScope:FSCalendarScopeWeek animated:YES];
    }
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_calendar.frame), self.view.frame.size.width, SCREEN_HEIGHT-CGRectGetMaxY(_calendar.frame)) style:UITableViewStyleGrouped];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView=[UIView new];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
