create table if not exists correspondent (
	correspondent_id text    not null,
	correspondent    text    not null,
	is_person        bool    not null default false,
	status           text    not null,
	status_code      integer,
	start_date       date    not null,
	end_date         date,
	okved            text    not null,
	region           text    not null,

	primary key (correspondent_id)
);


update correspondent
set correspondent_id = md5(correspondent_id),
	correspondent = md5(correspondent);


create table if not exists bank_operation (
	date             date    not null,
	correspondent_id text    not null,
	debet            decimal not null,
	credit           decimal not null,
	context          text
);

update bank_operation
set correspondent_id = md5(correspondent_id);


alter table bank_operation add foreign key (correspondent_id) references correspondent (correspondent_id);


create table if not exists book_buy (
	code              text    not null,
	doc_id            text    not null,
	doc_date          date    not null,
	registration_date date,
	correspondent_id  text    not null,
	cost_with_tax     decimal not null,
	tax               decimal not null
);

update book_buy
set correspondent_id = md5(correspondent_id);

alter table book_buy add foreign key (correspondent_id) references correspondent (correspondent_id);


create table if not exists book_sell (
	code              text    not null,
	doc_id            text    not null,
	doc_date          date    not null,
	correspondent_id  text    not null,
	cost_with_tax     decimal not null,
	tax               decimal not null,
	tax_value         decimal not null
);

update book_sell
set correspondent_id = md5(correspondent_id);

alter table book_sell add foreign key (correspondent_id) references correspondent (correspondent_id);


create view analytics as
select
	correspondent_id,
	is_person,
	status,
	status_code,
	date_trunc('month', age(date('2018-06-08'), start_date)) start_before_bancrupt,
	date_trunc('month', age(end_date, start_date)) live_month,
	okved,
	region,
	outcome,
	cost_outcome,
	income,
	cost_income
from (
	select
		correspondent_id,
		debet outcome,
		coalesce(cost_outcome, 0.0) cost_outcome,
		credit income,
		coalesce(cost_income, 0.0) cost_income
	from (
		select
			correspondent_id,
			sum(debet) debet,
			sum(credit) credit
		from bank_operation
		group by correspondent_id
	) as a
	left join (
		select
			correspondent_id,
			sum(cost_with_tax) cost_outcome
		from book_buy
		where doc_id not like 'А%'
		group by correspondent_id
	) as b using(correspondent_id)
	left join (
		select
			correspondent_id,
			sum(cost_with_tax) cost_income
		from book_sell
		where doc_id not like 'А%'
		group by correspondent_id
	) as c using(correspondent_id)
) as a
left join correspondent using(correspondent_id)
order by start_before_bancrupt;