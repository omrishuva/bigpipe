select 
  probability,owner,customer_name,stage, sum(revenue) revenue
from 
(
  select 
    opportunity_id,
    case
    when probability = 100 then "1 Very High"
    when probability = 90 then "2 High"
    when probability in (60, 70,75) then "3 Medium"
    when probability = 50 then "4 Low"
    else "5 Very Low" end probability,
    owner,
    left(opportunity_name, (INSTR(opportunity_name, "-") -1) ) customer_name, 
  from sf_raw_data
  where closed = "0"
  group by 1,2,3,4
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
    select 
      opportunity_id, 
      edit_date,
      case
      when to_stage = "Needs Analysis" then "1 Early Stage"
      when to_stage = "Prospecting" then "1 Early Stage"
      when to_stage = "Qualification" then "1 Early Stage"
      when to_stage = "Perception Analysis" then "1 Early Stage"    
      when to_stage = "Id. Decision Makers" then "2 Mid Stage"
      when to_stage = "Value Proposition" then "2 Mid Stage"
      when to_stage = "Proposal/Quote" then "2 Mid Stage"
      when to_stage = "Proposal/Price Quote" then "2 Mid Stage"
      when to_stage = "Negotiation" then "3 Advanced Stage"
      when to_stage = "Negotiation/Review" then "3 Advanced Stage"
      else "" end stage,
      amount revenue
    from sf_raw_data
    where closed = "0"
    and to_stage !="Closed Won" and to_stage != "Closed Lost"
  ) rev
  on rev.edit_date = last_event.edit_date
) revenue
on probability.opportunity_id = revenue.opportunity_id
group by 1,2,3,4
order by 1 asc