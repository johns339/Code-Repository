/* Dashboard.sas

Directory:	C:\Users\[User redacted]\Desktop\SAS
Author:		[User redacted]
Purpose:	Data pull for a Dashboard

*/

%let date_range_m24 = "01jan2017"d;
%let date_range_m6 = "01jul2018"d;
%let date_range_m4 = "01sep2018"d;
%let date_range_m1 = "31dec2018"d;

*--------------------- Data for Dashboard ---------------------* 
| This program was made to pull monthly data for a dashboard.  |
|                                                              |
| 1. Subset Data                                               |
| 2. Create Tiles and Alerts                                   |
| 3. Export Tiles                                              |
| 4. Export Alerts                                             |
*--------------------------------------------------------------*;

/* 1. Subset Data */
proc sql;
	create table work.data_subset as
	select *,
			case
			when data_field = data
			then 1
			when data_field = data
			then -1
			else 0
			end as new_data_field,
			case
			when month(mmddyy) between 1 and 9
			then cats(year(mmddyy),'0',month(mmddyy))
			when month(mmddyy) between 10 and 12
			then cats(year(mmddyy),month(mmddyy))
			else ''
			end as year_month,
				intck("days", (&date_range_m24 - 1), &date_range_m1) as days_1
	from work.data
	where mmddyy between &date_range_m24 and &date_range_m1;
quit;

/* 2. Create Tiles and Alerts */
proc sql;
	create table work.data_point1 as
		select year_month,
				sum(data_field1) as sum_data_field1 format=comma12.
		from work.data_subset
		group by year_month;
quit;

proc sql;
	create table work.data_point2 as
		select year_month,
				sum(data_field1) / count(distinct(data_field2)) as avg_data_field2 format=dollar15.2
		from work.data_subset
		group by year_month;
quit;

proc sql;
	create table work.prep_data_point3 as
		select year_month,
				count(distinct(data_field21)) as cnt_dst_data_field21
		from work.data_subset
		where data_field4 = data
		group by year_month;
quit;

proc sql;
	create table work.data_point3 as
		select distinct t1.year_month,
				t2.data_field21 / count(distinct(t1.data_field2)) as avg_data_field3 format=percent12.2
		from work.data_subset t1 left join work.prep_data_point3 t2 on (t1.year_month = t2.year_month)
		group by t1.year_month;
quit;

proc sql;
	create table work.merge_data_points as
		select *
		from work.data_point1 t1 left join work.data_point2 t2 on (t1.year_month = t2.year_month)
								left join work.data_point3 t3 on (t1.dos_year_month = t3.dos_year_month);
quit;