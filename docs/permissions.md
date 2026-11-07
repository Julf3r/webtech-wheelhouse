# Wheelhouse — Authorization Matrix

Wheelhouse uses Pundit for role-based authorization.

## Roles

- **Owner:** Full administrative access.
- **Counter:** Manages customers, bikes and repair intake.
- **Mechanic:** Works only on assigned repairs.
- **Visitor:** Unauthenticated user.

Authorization is enforced server-side through Pundit policies.
Hiding buttons in views is not considered an authorization boundary.

## Permissions

| Resource / Action | Owner | Counter | Mechanic | Visitor |
|---|---|---|---|---|
| Services: index/show | Yes | Yes | Yes | Yes |
| Services: create/update/delete | Yes | No | No | No |
| Staff: index/show | Yes | Yes | Yes | No |
| Staff: create/update/delete | Yes | No | No | No |
| Customers: index/show | Yes | Yes | No | No |
| Customers: create/update | Yes | Yes | No | No |
| Customers: delete | Yes | No | No | No |
| Bikes: index/show | Yes | Yes | No | No |
| Bikes: create/update | Yes | Yes | No | No |
| Bikes: delete | Yes | No | No | No |
| Repairs: index | All | All | Assigned only | No |
| Repairs: show | All | All | Assigned only | No |
| Repairs: create | Yes | Yes | No | No |
| Repairs: update | All | Non-completed | Assigned, non-completed | No |
| Repairs: delete | Yes | No | No | No |
| Repair photo removal | Yes | Non-completed | No | No |

The `new` and `edit` actions follow their corresponding
`create` and `update` permissions.

## Repair Assignment

A mechanic may access a repair only when:

    repair.mechanic_id == Current.user.staff_id

Mechanics without an associated Staff record cannot access
any repair.

A completed repair is read-only for counter and mechanic users.

## Repair Attributes

Owners and counter users may submit the normal repair fields,
subject to their action-level permissions.

Mechanics may submit only:

- `status`
- `diagnosis`
- `intake_photos`

Mechanics cannot change:

- Bike assignment
- Mechanic assignment
- Quoted price
- Customer decision
- Received date
- Promised date
- Handed-back date
- Repair services and their prices

The controller uses `RepairPolicy#permitted_attributes`
to enforce these restrictions.

`received_by` is assigned server-side from `Current.user`.

## Record Visibility

All protected index actions use `policy_scope`.

The repair scope returns:

- All repairs for owners and counter users.
- Only assigned repairs for mechanics with a linked Staff record.
- No repairs for mechanics without a linked Staff record.

Other repair lists must use the same policy scope.

Scopes return ActiveRecord relations so filtering occurs
in SQL rather than filtering loaded records in Ruby.

## Unauthorized Requests

- Unauthenticated users are redirected to the login page
  when requesting protected resources.
- Authenticated users without permission receive HTTP 403.
- The 403 page is rendered using the application layout.
- Unauthorized requests must not modify database records.

## Public Resources

The service catalog (`index` and `show`) is public.

The existing public informational pages remain accessible
without authentication.

The existing API authentication and behavior are not changed
by the HTML authorization layer.

## Verification

Authorization is covered by:

- `test/policies/repair_policy_test.rb`
- `test/controllers/repairs_controller_test.rb`

The tests include unauthorized access, record visibility,
completed-repair restrictions and crafted parameters.
