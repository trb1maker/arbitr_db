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