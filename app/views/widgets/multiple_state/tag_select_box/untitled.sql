select 
  probability, stage, sum(revenue) revenue
from 
(
  select 
    opportunity_id,
    case
    when probability in (90, 100) then "High"
    when probability in (50, 60, 70,75) then "Medium"
    else "low" end probability
  from sf_raw_data
  where closed = "0"
  group by 1,2 
) probability
join
(
  select 
    rev.opportunity_id opportunity_id,stage, revenue
  from 
  (
    select 
      opportunity_id,
      max(edit_date) edit_date
    from sf_raw_data
    where closed = "0"
    group by 1
  ) last_event
  join 
  (
    select opportunity_id, edit_date,
    case
    when to_stage = "Needs Analysis" then 
    when to_stage = "Prospecting" then
    when to_stage = "Qualification" then
    when to_stage = "Perception Analysis" then     
    when to_stage = "Id. Decision Makers" then 
    when to_stage = "Value Proposition" then
    when to_stage = "Proposal/Quote" then 
    when to_stage = "Proposal/Price Quote" then
    when to_stage = "Negotiation" then 
    when to_stage = "Negotiation/Review" then
    else "" end stage
    to_stage stage ,amount revenue
    from sf_raw_data
    where closed = "0"
    and stage !="Closed Won" and stage != "Closed Lost"
  ) rev
  on rev.edit_date = last_event.edit_date
) revenue
on probability.opportunity_id = revenue.opportunity_id
group by 1,2
order by 1 asc