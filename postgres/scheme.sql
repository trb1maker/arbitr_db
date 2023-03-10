create table if not exists register_creditor (
	creditor_id   serial not null,
	register_date date not null,
	creditor      text not null,
	address       text,

	primary key (creditor_id)
);

create table if not exists register_debt (
	debt_id       serial  not null,
	turn_id       serial  not null check (turn_id >= 1 and turn_id <= 3),
	creditor_id   serial  not null,
	register_date date    not null,
	cause_date    date    not null,
	debt          decimal not null check (debt > 0),
	is_guaranteed bool    not null,
	is_forfeit    bool    not null,
	is_late       bool    not null,
	is_deleted    bool    not null,

	primary key (debt_id),
	foreign key (creditor_id) references register_creditor (creditor_id)
);

create table if not exists register_payment (
	payment_id    serial  not null,
	register_date date    not null,
	debt_id       serial  not null,
	payment       decimal not null check (payment > 0),

	primary key (payment_id),
	foreign key (debt_id) references register_debt (debt_id)
);

create table if not exists current_category (
	category_id serial not null,
	category    text   not null,

	primary key (category_id)
);

create table if not exists current_creditor (
	creditor_id   serial not null,
	register_date date   not null,
	creditor      text   not null,
	address       text,

	primary key (creditor_id)
);

create table if not exists current_debt (
	debt_id       serial  not null,
	turn_id       serial  not null check (turn_id >= 1 and turn_id <= 5),
	creditor_id   serial  not null,
	register_date date    not null,
	category_id   serial  not null,
	debt          decimal not null check (debt > 0),
	context       text    not null,
	is_deleted    bool    not null,

	primary key (debt_id),
	foreign key (creditor_id) references current_creditor (creditor_id)
);

create table if not exists current_payment (
	payment_id    serial  not null,
	register_date date    not null,
	debt_id       serial  not null,
	payment       decimal not null check (payment > 0),

	primary key (payment_id),
	foreign key (debt_id) references current_debt (debt_id)
);