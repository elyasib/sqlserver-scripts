set nocount on
set ansi_warnings off

declare 
@result nvarchar(100) = '',
@partial nvarchar(100),
@table nvarchar(20) = 'table_name',
@schema nvarchar(20) = 'schema',
@use_db nvarchar(20) = 'use your_database' --replace your_database with the name of your database
declare @tab_res table (result nvarchar(100))

exec sp_sqlexec @use_db

declare #fields cursor for 
	select 
	case when data_type='char' or data_type='varchar' 
	then cast(rtrim(column_name)  as varchar(25)) 
	else ('cast('+cast(rtrim(column_name)  as varchar(30))+' as varchar)') end columna
	from information_schema.columns
	where table_schema = @schema
	and table_name = @table
	order by ordinal_position
for read only

open #fields

insert into @tab_res values ('declare @z char(1)=char(0x00),@c char(1)='' '',@n char(4)=''null'',@a char(1)='''''''''),
('select ''insert into '+@schema+'.'+@table+' values(''')
fetch #fields into @partial
	set @result='+replace(isnull(@a+'+@partial+'+@a,@n),@z,@c)'
	insert into @tab_res values(cast(@result as varchar(100)))
while @@fetch_status = 0
begin
	fetch #fields into @partial
	set @result='+'',''+replace(isnull(@a+'+@partial+'+@a,@n),@z,@c)'
	if (@@fetch_status = 0)
	insert into @tab_res values(cast(@result as varchar(100)))
end

insert into @tab_res values('+'')'' from mazp.'+@table+' with(nolock)')
select * from @tab_res

close #fields
deallocate #fields

go
