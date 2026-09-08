# Decisions

## Decision 1

**Question:**  
Can a bike have more than one current owner?

**Assumption:**  
No. Each bike has one current owner, represented by a single `customer_id` in `bikes`.

**What would change if the answer were different?**  
If ownership history had to be preserved, a separate ownership table would be needed to record each owner and the period during which they owned the bike.


## Decision 2

**Question:**  
Can a repair be assigned to more than one mechanic?

**Assumption:**  
No. Each repair has at most one mechanic assigned to it at a time.

**What would change if the answer were different?**  
If several mechanics could work on the same repair, a join table between `repairs` and `staff` would be required instead of storing a single `mechanic_id` in `repairs`.


## Decision 3

**Question:**  
Should a rejected repair estimate be represented as a separate repair status?

**Assumption:**  
No. The customer's decision is stored separately, and a rejected repair moves to `ready_for_pickup`.

**What would change if the answer were different?**  
If rejection were modeled as its own repair status, the repair lifecycle would need an additional `rejected` state and the allowed transitions would have to be updated.