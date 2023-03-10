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