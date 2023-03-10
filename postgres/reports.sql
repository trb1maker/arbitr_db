create view report_voices as
select
	creditor_id,
	creditor,
	address,
	total_debt,
	voices_min,
	round(voices_min / sum(voices_min) over(), 6) voices_min_perc,
	voices_max,
	round(voices_max / sum(voices_max) over(), 6) voices_max_perc
from (
	select
		creditor_id,
		sum(debt) total_debt
	from register_debt
	where not is_late and
	      not is_deleted
	group by creditor_id
) as a
left join (
	select
		creditor_id,
		sum(debt) voices_min
	from register_debt
	where not is_late and
	      not is_deleted and
	      not is_forfeit and
	      turn_id = 3
	group by creditor_id
) as b using (creditor_id)
left join (
	select
		creditor_id,
		sum(debt) voices_max
	from register_debt
	where not is_late and
	      not is_deleted and
	      not is_forfeit and
	      not is_guaranteed and
	      turn_id = 3
	group by creditor_id
) as c using (creditor_id)
join register_creditor using(creditor_id)
order by creditor_id;


create view report_register_creditor as
select
	turn_id,
	creditor,
	debt,
	debt_payment,
	debt - debt_payment debt_balance,
	forfeit,
	forfeit_payment,
	forfeit - forfeit_payment forfeit_balance
from (
	-- Суммирование требований по очередям и кредиторам
	select
		turn_id,
		creditor_id,
		sum(debt) debt,
		sum(debt_payment) debt_payment,
		sum(forfeit) forfeit,
		sum(forfeit_payment) forfeit_payment
	from (
		-- Выборка требований и их объединение с погашениями
		select
			turn_id,
			creditor_id,
			debt_id,
			case when not is_forfeit then debt else 0.0 end debt,
			case when not is_forfeit then payment else 0.0 end debt_payment,
			case when is_forfeit then debt else 0.0 end forfeit,
			case when is_forfeit then payment else 0.0 end forfeit_payment
		from register_debt
		left join (
			-- Учет погашения
			select
				debt_id,
				sum(payment) payment
			from register_payment
			group by debt_id
		) as a using(debt_id)
	) as a
	group by turn_id, creditor_id
) as a
join register_creditor using(creditor_id)
order by turn_id, creditor_id;


create view report_current_debt as
select
	current_debt.register_date,
	turn_id,
	creditor,
	category,
	debt,
	coalesce(payment, 0) payment,
	debt - coalesce(payment, 0) balance,
	context
from current_debt
left join (
	select
		debt_id,
		sum(payment) payment
	from current_payment
	group by debt_id
) as a using (debt_id)
join current_creditor using(creditor_id)
left join current_category using(category_id)
where not is_deleted
order by turn_id, register_date, creditor_id, category_id;


create view report_cost as
select
	turn_id,
	category,
	sum(debt) debt,
	sum(payment) payment,
	sum(balance) balance
from report_current_debt
where category notnull
group by turn_id, category
order by turn_id, category;